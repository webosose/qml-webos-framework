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

#include <QtTest>
#include <QtCore/QString>
#include <QtCore/QPair>

#include "../../../tools/runner/ipcclient.h"
#include "../../../tools/booster/ipcserver.h"

class BoosterIpcTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void sendingMessageToPoolOfClients();
    void sendingMessagesWithEmptyPool();
    void connectingWithoutRunningServer();
    void noClients();
};

void BoosterIpcTest::sendingMessageToPoolOfClients()
{
    QScopedPointer<IpcServer> server (new IpcServer());
    QVERIFY (server->isListening());

    QScopedPointer<IpcClient> client (new IpcClient());

    bool runner_connected = false;
    QObject::connect(server.data(), &IpcServer::runnerRegistered, [&runner_connected]() {
        runner_connected = true;
    });

    QPair<QString, QString> received_message;
    QObject::connect(client.data(), &IpcClient::launchRequest,
                     [&received_message](const QString &first, const QString &second) {
        received_message.first = first;
        received_message.second = second;
    });

    QVERIFY (client->connectToServer());
    QTRY_VERIFY (runner_connected);

    server->launch("app.id", "main.qml", QJsonDocument::fromJson("{}"), nullptr);
    QTRY_VERIFY (received_message.first == "app.id" && received_message.second == "main.qml");
}

void BoosterIpcTest::sendingMessagesWithEmptyPool()
{
    QScopedPointer<IpcServer> server (new IpcServer());
    QVERIFY (server->isListening());

    // sending message before client is connected
    server->launch("app.id", "main.qml", QJsonDocument::fromJson("{}"), nullptr);

    QScopedPointer<IpcClient> client (new IpcClient());

    bool runner_connected = false;
    QObject::connect(server.data(), &IpcServer::runnerRegistered, [&runner_connected]() {
        runner_connected = true;
    });

    QPair<QString, QString> received_message;
    QObject::connect(client.data(), &IpcClient::launchRequest,
                     [&](const QString &first, const QString &second) {
        received_message.first = first;
        received_message.second = second;
    });

    QVERIFY (client->connectToServer());
    QTRY_VERIFY (runner_connected);
    QTRY_VERIFY (received_message.first == "app.id" && received_message.second == "main.qml");
}

void BoosterIpcTest::connectingWithoutRunningServer()
{
    QScopedPointer<IpcClient> client (new IpcClient());
    QVERIFY (false == client->connectToServer());
}

void BoosterIpcTest::noClients()
{
    QScopedPointer<IpcServer> server (new IpcServer());
    QVERIFY (server->isListening());

    // sending message with no clients connected
    server->launch("app.id", "main.qml", QJsonDocument::fromJson("{}"), nullptr);

    bool runner_connected = false;
    QObject::connect(server.data(), &IpcServer::runnerRegistered, [&runner_connected]() {
        runner_connected = true;
    });
    QEXPECT_FAIL ("", "This is expected failure:", Continue);
    QTRY_VERIFY_WITH_TIMEOUT (runner_connected, 1000);
}

QTEST_MAIN (BoosterIpcTest)

#include "tst_ipctest.moc"
