// Copyright (c) 2014-2022 LG Electronics, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#include <QGuiApplication>
#include <QQuickView>

#include <QtCore/QPointer>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QDateTime>

#include <QtGui/QGuiApplication>

#include "ipcclient.h"
#include "apploader.h"
#include "applifecyclemanager.h"

#ifdef QMLJSDEBUGGER
#include <QtQml/qqmldebug.h>
#endif

#include <QDebug>

#ifdef USE_PMLOGLIB
#include <PmLogLib.h>
#endif

#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <QSocketNotifier>

namespace {

QByteArray g_log_ctx_name ("eos");
QtMessageHandler g_default_handler = NULL;
qint64 g_startup_time = 0;

#ifdef USE_PMLOGLIB
static void pmlogMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    static PmLogContext ctx;
    static bool contextCreated = false;
    if (!contextCreated) {
        PmLogGetContext(g_log_ctx_name.constData(), &ctx);
        contextCreated = true;
    }
    const char *function  = context.function;
    /* Keep a reference for converted msg, otherwise it will be freed immediately. */
    QByteArray utf8 = msg.toUtf8();
    char* userMessage  = utf8.data();
    switch (type) {
        case QtDebugMsg:
            PmLogDebug(ctx, "%s: %s", function, userMessage);
            break;
        case QtInfoMsg:
            PmLogWarning(ctx, "QINFO", 0, "%s: %s", function, userMessage);
            break;
        case QtWarningMsg:
            PmLogWarning(ctx, "QWARNING", 0, "%s: %s", function, userMessage);
            break;
        case QtCriticalMsg:
            PmLogError(ctx, "QCRITICAL", 0, "%s: %s", function, userMessage);
            break;
        case QtFatalMsg:
            PmLogCritical(ctx, "QFATAL", 0, "%s: %s", function, userMessage);
            break;
    }
}
#endif

void benchmark_message_handler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if (!g_default_handler)
        return;

    g_default_handler(type,
                    context,
                    QString("[%2] %1")
                    .arg(msg)
                    .arg((QDateTime::currentMSecsSinceEpoch() - g_startup_time * 1000)));
}

// Calling Qt functions from signal handlers is a no no as per
// http://qt-project.org/doc/qt-5/unix-signals.html
static int sigtermFd[2];
static void signal_handler(int signum, siginfo_t *info, void *ptr)
{
    Q_UNUSED(signum);
    Q_UNUSED(info);
    Q_UNUSED(ptr);

    // Just write something so that the socket notifier
    // gets triggered
    int8_t a = 1;
    ::write(sigtermFd[0], &a, sizeof(a));
}

} // namespace

int main(int argc, char *argv[])
{
#ifdef QMLJSDEBUGGER
    QQmlDebuggingEnabler enabler;
#endif
    qputenv("QV4_NO_SSA", "1");

    if (qEnvironmentVariableIsEmpty("WEBOS_WINDOW_BASE_GEOMETRY")) {
        // Set "1920x1080" by default
        qputenv("WEBOS_WINDOW_BASE_GEOMETRY", QByteArray("1920x1080"));
        qDebug("Set default WEBOS_WINDOW_BASE_GEOMETRY as '1920x1080'");
    }
    if (qEnvironmentVariableIsEmpty("WEBOS_DEVICE_PIXEL_RATIO")) {
        // Set "auto" by default
        qputenv("WEBOS_DEVICE_PIXEL_RATIO", QByteArray("auto"));
        qDebug("Set default WEBOS_DEVICE_PIXEL_RATIO as 'auto'");
    }

    QGuiApplication app(argc, argv);
    QString mainQml("");
    QString appId("");
    QString methodName("");
    QVariant params;

    bool interactive = false;

    QStringList allArgs = QCoreApplication::arguments();
    for (int i = 0; i < allArgs.size(); i++) {
        const QString arg = allArgs.at(i);
        if (arg.startsWith(QChar('{'))) {
            QJsonObject obj = QJsonDocument::fromJson(arg.toUtf8()).object();
            if (obj.contains("main"))
                mainQml = obj.value("main").toString();
            if (obj.contains("appId")) {
                appId = obj.value("appId").toString();
                g_log_ctx_name = appId.toUtf8();
            }
            if (obj.contains("params")) {
                params = obj.value("params").toVariant();
            }
            if (obj.contains("interfaceMethod")) {
                methodName = obj.value("interfaceMethod").toString();
            }
        }
        if (arg == "--main" && (i + 1 < allArgs.size())) {
            mainQml = allArgs.at(i + 1);
            ++i;
            continue;
        }
        if (arg == "--startup" && (i + 1 < allArgs.size())) {
            g_startup_time = allArgs.at(i + 1).toLongLong();
            ++i;
            continue;
        }
        if (arg == "--interactive") {
            interactive = true;
        }
    }

    if (params.type() != QVariant::Map) {
        params = QVariantMap();
    }

    if (g_startup_time != 0) {
        g_default_handler = qInstallMessageHandler(benchmark_message_handler);
    } else {
#ifdef USE_PMLOGLIB
    qInstallMessageHandler(pmlogMessageHandler);
#endif
    }

    if (methodName.isEmpty()) {
        // Refer to http://collab.lge.com/main/display/TVSWPF/Native+app+life+cycle+interface.
        // SAM doesn't send the "interfaceMethod" key if an application is running under
        // nativeLifeCycleInterfaceVersion=1. So, here is to set default lifecycle interface (registerNativeApp).
        // As you know, SAM provides registerApp as nativeLifeCycleInterfaceVersion=2.
        methodName = AppLifeCycleManager::defaultInterfaceMethodName;
    }

    qDebug("instantiated QGuiApplication, methodName = %s", methodName.toUtf8().data());

    AppLoader loader;
    qDebug("instantiated QQmlEngine and AppLoader");

    QPointer<IpcClient> client;
    AppLifeCycleManager* appLifeCycleManager = NULL;

    if (!interactive) {
        appLifeCycleManager = new AppLifeCycleManager(appId, methodName, "");
        Q_ASSERT(appLifeCycleManager);

        // relaunching case
        QObject::connect(appLifeCycleManager, &AppLifeCycleManager::relaunchRequest,
                         [&loader, client] (const QJsonDocument &params) {
            if (loader.ready()) {
                loader.reloadApplication(params.toVariant());
            } else {
                qWarning() << "loader isn't ready to reload";
                QCoreApplication::exit(-1);
            }
        });

        // close case
        QObject::connect(appLifeCycleManager, &AppLifeCycleManager::closeRequest,
                         [&loader, client] (const QJsonDocument &params) {
            Q_UNUSED(params);

            if (loader.ready()) {
                loader.terminate();
            } else {
                qWarning() << "loader isn't ready to close";
                QCoreApplication::exit(-1);
            }
        });

        if (!loader.loadApplication(appId, mainQml, params)) {
            return -1;
        }
    } else {
        client = new IpcClient();
        if (!client)
            return -1;
        QObject::connect(client.data(), &IpcClient::launchRequest,
                         [&loader, client] (const QString &appId,
                                            const QString &mainQml,
                                            const QJsonDocument &params) {
            QJsonObject reply;
            reply.insert(QStringLiteral("header"), LAUNCH_REPLY);
            if (loader.loadApplication(appId, mainQml, params.toVariant())) {
                reply.insert(QStringLiteral("returnValue"), true);
            } else {
                reply.insert(QStringLiteral("returnValue"), false);
                reply.insert(QStringLiteral("errorCode"), -1);
                reply.insert(QStringLiteral("errorText"),
                             QStringLiteral("Failed to load qml file %1").arg(mainQml));
                QCoreApplication::exit(-1);
            }
            client->send(QJsonDocument(reply));
        });

        QObject::connect(client.data(), &IpcClient::relaunchRequest,
                         [&loader, client] (const QJsonDocument &params) {
            QJsonObject reply;
            reply.insert(QStringLiteral("header"), RELAUNCH_REPLY);
            if (loader.ready()) {
                loader.reloadApplication(params.toVariant());
                reply.insert(QStringLiteral("returnValue"), true);
            } else {
                reply.insert(QStringLiteral("returnValue"), false);
                reply.insert(QStringLiteral("errorCode"), -1);
                reply.insert(QStringLiteral("errorText"),
                             QStringLiteral("Failed to reload qml app: Component is not loaded,"));
                QCoreApplication::exit(-1);
            }
            client->send(QJsonDocument(reply));
        });

        if (!client->connectToServer()) {
            return -1;
        }
    }

    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigtermFd)) {
        qFatal("Couldn't create SIGTERM socketpair");
    }

    static QSocketNotifier sigTermNotifier(sigtermFd[1], QSocketNotifier::Read);
    // Not connected directly to QCoreApplication::quit slot as otherwise no
    // possibility to log the cases when SIGTERM/SIGINT caused the process
    // exit
    QObject::connect(&sigTermNotifier, &QSocketNotifier::activated,
                     &loader, &AppLoader::terminate);

    struct sigaction action;
    memset(&action, 0, sizeof(struct sigaction));
    action.sa_sigaction = signal_handler;
    action.sa_flags = SA_SIGINFO;
    if(sigaction(SIGTERM, &action, NULL) == -1)
        qWarning() << "sigaction error with SIGTERM";

    if(sigaction(SIGINT, &action, NULL) == -1)
        qWarning() << "sigaction error with SIGINT";

    int ret = app.exec();

    if (!client.isNull())
        delete client.data();
    if (appLifeCycleManager) {
        delete appLifeCycleManager;
        appLifeCycleManager = NULL;
    }

    qDebug("pid '%lld' return from exec with '%d'", QCoreApplication::applicationPid(), ret);
    return ret;
}
