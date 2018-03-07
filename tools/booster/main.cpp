// Copyright (c) 2014-2018 LG Electronics, Inc.
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

#include <QtCore/QCoreApplication>
#include <QtCore/QCommandLineParser>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonDocument>
#include <QtCore/QLockFile>

#include "lunaservice.h"
#include "launchmanager.h"
#include "ipcserver.h"
#include "logger.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("qml booster daemon");
    parser.addHelpOption();

    QCommandLineOption maxCachedOption(QStringList() << "m" << "max-cached",
                "Max pre-started runners",
                "maxCached", "2");
    parser.addOption(maxCachedOption);

    QCommandLineOption runnerCommandOption(QStringList() << "c" <<
                "runner-command", "Command to run pre-started applicaion instance.",
                "runnerCommand", "qml-runner --interactive");
    parser.addOption(runnerCommandOption);

    parser.process(app);

    int maxCached = parser.value(maxCachedOption).toInt();
    QString runnerCommand = parser.value(runnerCommandOption);

    // If started as a service, use platform's logging facility.
    if (qgetenv("UPSTART_JOB").isEmpty() == false)
        initLogger();

    QLockFile l ("/run/boosterd.pid");
    if (!l.tryLock()) {
        qCritical("Another instance of %s is already running.", argv[0]);
        return -1;
    }

    LaunchManager lm {maxCached, 1000, runnerCommand};

    IpcServer server;

    LunaService ls {&server, &lm};

    QObject::connect(&server, &IpcServer::connectedRunnersCountChanged,
                     &lm, &LaunchManager::onConnectedRunnersCountChanged);

    QObject::connect(&server, &IpcServer::runnerRegistered,
                     &lm, &LaunchManager::onRunnerReady);

    QObject::connect(&lm, &LaunchManager::processFinished,
                     [&ls, &server](qint64 pid, int code, QProcess::ExitStatus status) {
        QJsonObject data;
        data.insert("pid", pid);
        data.insert("exitCode", code);
        data.insert("exitStatus", QString(status == QProcess::CrashExit ? "crash" : "normal"));
        server.removeProcess(pid);
        emit ls.processFinished(QJsonDocument(data));
        ls.update();
    });

    QObject::connect(&server, &IpcServer::runnerLaunched,
                     [](qint64 processId, const QString& appId) {
        // TODO: emit LS2 notification
        qDebug() << "# runnerLaunched"
                 << "pid:" << processId
                 << "app:" << appId;
    });

    qDebug("Initializing Runner pool.");
    lm.onConnectedRunnersCountChanged(server.connectedRunnersCount());

    return app.exec();
}
