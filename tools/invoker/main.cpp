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
#include <QtCore/QPointer>
#include <QtCore/qjsondocument.h>
#include <QtCore/qjsonobject.h>
#include <QtCore/QDataStream>

#include <QtNetwork/QLocalSocket>

#include <QtCore/QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    QString mainQml("");
    QString appId("");

    QStringList allArgs = QCoreApplication::arguments();
    for (int i = 0; i < allArgs.size(); i++) {
        const QString arg = allArgs.at(i);
        if (arg.startsWith('{')) {
            QJsonObject obj = QJsonDocument::fromJson(arg.toUtf8()).object();
            if (obj.contains("main"))
                mainQml = obj.value("main").toString();
            if (obj.contains("appId")) {
                appId = obj.value("appId").toString();
            }
        }
        if (arg == "--main" && (i + 1 < allArgs.size())) {
            mainQml = allArgs.at(i + 1);
            ++i;
            continue;
        }
    }

    QPointer <QLocalSocket> socket = new QLocalSocket();

    socket->connectToServer("EosBooster");
    if (!socket->waitForConnected()) {
        qWarning() << socket->error();
    }

    if(socket && socket->isOpen()) {
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out << QString("launch:%1:%2").arg(appId).arg(mainQml);
        out.device()->seek(0);
        socket->write(block);
        socket->flush();
    }

    app.exit();

    return 0;
}
