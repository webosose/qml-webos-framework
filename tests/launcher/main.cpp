// Copyright (c) 2014-2021 LG Electronics, Inc.
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
#include <QtCore/QProcess>
#include <QtCore/QDateTime>
#include <QtCore/QMap>
#include <QtCore/QPair>

QStringList validateEnvironment(const QStringList &environment)
{
    QMap<QString, QString> envmap;
    foreach (const QString &env, environment) {
        int i = env.indexOf(QChar('='));
        if (i == -1) {
            qWarning("Invalid environment variable: %s", env.toUtf8().data());
            continue;
        }
        envmap[env.left(i)] = env.mid(i + 1);
    }

    typedef QPair<QString, QString> Pair;
    foreach (auto pair, QList<Pair>() << Pair("XDG_RUNTIME_LOCATION", "/var/run/xdg")
                                      << Pair("XDG_RUNTIME_DIR", "/var/run/xdg")
                                      << Pair("QT_QPA_PLATFORM", "wayland-egl")) {
        if (!envmap.contains(pair.first)) {
            qWarning("Environment variable '%s' is missing, set to '%s'",
                     pair.first.toUtf8().data(), pair.second.toUtf8().data());
            envmap[pair.first] = pair.second;
        }
    }

    QStringList res;
    for (auto i = envmap.constBegin(); i != envmap.end(); ++i)
        res << (i.key() + "=" + i.value());
    return res;
}


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    if (argc < 2) {
        qWarning("Missing input QML filename argument.");
        return -1;
    }

    QProcess *runner = new QProcess(&a);
    runner->setEnvironment(validateEnvironment(QProcess::systemEnvironment()));
    runner->setProcessChannelMode(QProcess::ForwardedChannels);

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    QObject::connect(runner, &QProcess::finished, &a, &QCoreApplication::quit);
    QObject::connect(runner, &QProcess::errorOccurred, &a, &QCoreApplication::quit);
#else
    void (QProcess:: *finished) (int, QProcess::ExitStatus) = &QProcess::finished;
    void (QProcess:: * error) (QProcess::ProcessError) = &QProcess::error;

    QObject::connect(runner, finished, &a, &QCoreApplication::quit);
    QObject::connect(runner, error, &a, &QCoreApplication::quit);
#endif

    QStringList arglist;
    //AppId and main qml can be passed in a json object.
    // {\"appId\":\"com.webos.app.quicksettings\",\"main\":\"file:///usr/palm/applications/com.webos.app.quicksettings/main.qml\"}
    if(QString(argv[1]).startsWith(QChar('{'))) {
       arglist << argv[1];
    }
    else {
        arglist << "--main" << argv[1];
    }
    arglist << "--startup" << QString::number(QDateTime::currentMSecsSinceEpoch());
    runner->start("qml-runner", arglist);

    return a.exec();
}
