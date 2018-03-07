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

#include <QtCore/QDateTime>
#include <QtNetwork/QLocalSocket>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QDataStream>

#include "../common/ipccommon.h"
#include "ipcserver.h"

IpcServer::IpcServer (QObject *parent) :
    QObject (parent)
{
    QLocalServer::removeServer(QStringLiteral("EosBooster"));
    m_server.listen(QStringLiteral("EosBooster"));
    connect(&m_server, &QLocalServer::newConnection, this, &IpcServer::setupConnection);
}

IpcServer::~IpcServer()
{
    qDeleteAll(m_runningSockets.values());
    m_server.close();
}

bool IpcServer::isListening() const
{
    return m_server.isListening();
}

int IpcServer::connectedRunnersCount() const
{
    return m_runnerClients.count();
}

void IpcServer::setupConnection()
{
    while (m_server.hasPendingConnections()) {
        QLocalSocket *socket = m_server.nextPendingConnection();
        QObject::connect(socket, &QLocalSocket::readyRead, this , &IpcServer::readSocket);
        QObject::connect(socket, &QLocalSocket::disconnected, this, &IpcServer::onDisconnected);
    }
}

void IpcServer::onDisconnected()
{
    QLocalSocket *socket = qobject_cast<QLocalSocket*>(sender());
    Q_ASSERT (socket);
    if (m_runnerClients.removeOne(socket)) {
        // TODO: measure rate of failures like this and go to an error state
        qWarning("A runner was dropped from the pool");
        emit connectedRunnersCountChanged(m_runnerClients.count());
    }
    for (auto it = m_runningSockets.begin(); it != m_runningSockets.end(); ++it) {
        if (it.value() == socket) {
            m_runningSockets.erase(it);
            break;
        }
    }
    socket->deleteLater();
}

void IpcServer::readSocket()
{
    QLocalSocket *socket = qobject_cast<QLocalSocket*>(sender());
    Q_ASSERT (socket);

    QByteArray raw_json;
    {
        QByteArray block = socket->readAll();
        QDataStream in (&block, QIODevice::ReadOnly);

        if (in.atEnd()) {
            qWarning("Nothing read from socket. Disconnecting client.");
            socket->disconnectFromServer();
            return;
        }
        in >> raw_json;
    }
    const QJsonDocument &json = QJsonDocument::fromBinaryData(raw_json);
    qDebug() << "received message:" << json.toJson(QJsonDocument::Compact);
    const QJsonObject &message = json.object();
    if (message.isEmpty()) {
        qWarning("Cannot parse message. Disconnecting client.");
        socket->disconnectFromServer();
        return;
    }

    int header = message.value(QStringLiteral("header")).toInt(-1);
    switch (header) {
    case REGISTER_REQUEST: {
        qint64 processId = static_cast<qint64>(message.value(QStringLiteral("pid")).toDouble());
        if (processId == 0) {
            qWarning("Cannot read PID from socket. Disconnecting client.");
            socket->disconnectFromServer();
            return;
        }
        m_runnerClients.append(socket);
        socket->setProperty("pid", processId);
        emit runnerRegistered(processId);
        emit connectedRunnersCountChanged(m_runnerClients.count());

        if (!m_deferredMessages.isEmpty()) {
            auto message = m_deferredMessages.takeFirst();
            launch(message->appId, message->mainQml, message->params, message->callback);
        }
      } break;
    case LAUNCH_REPLY: {
        const qint64 processId = socket->property("pid").value<qint64>();
        const QString appId = socket->property("appId").toString();
        Callback callback = m_launchCallbacks.take(processId);

        int errorCode = message.value(QStringLiteral("errorCode")).toInt(0);
        if (errorCode != 0) {
            const QString &errorText = message.value(QStringLiteral("errorText")).toString();
            qWarning("QML application launch failed: %s", qPrintable(errorText));
            if (callback)
                callback(0);
            return;
        }

        m_runningApps.insert(appId, processId);
        m_runningProcesses.insert(processId, appId);

        emit runnerLaunched(processId, appId);
        if (callback)
            callback(processId);
      } break;
    case RELAUNCH_REPLY: {
        const qint64 processId = socket->property("pid").value<qint64>();
        Callback callback = m_launchCallbacks.take(processId);

        int errorCode = message.value(QStringLiteral("errorCode")).toInt(0);
        if (errorCode != 0) {
            const QString &errorText = message.value(QStringLiteral("errorText")).toString();
            qWarning("QML application relaunch failed: %s", qPrintable(errorText));
            if (callback)
                callback(0);
            return;
        }

        if (callback)
            callback(processId);
      } break;
    default:
        break;
    }
}

bool IpcServer::relaunch(const QString &appId, const QJsonDocument &params, const Callback &callback)
{
    QPointer<QLocalSocket> socket = m_runningSockets.value(appId);

    if(socket && socket->isOpen()) {
        const qint64 processId = socket->property("pid").value<qint64>();
        Q_ASSERT (processId);

        qDebug("Got relaunch msg, appId: %s", qPrintable(appId));
        QByteArray block;
        QDataStream out {&block, QIODevice::WriteOnly};

        QJsonObject message;
        message.insert(QStringLiteral("header"), RELAUNCH_REQUEST);
        message.insert(QStringLiteral("params"), params.object());
        message.insert(QStringLiteral("callTime"), QDateTime::currentMSecsSinceEpoch());
        out << QJsonDocument(message).toBinaryData();

        socket->write(block);
        socket->flush();

        m_launchCallbacks[processId] = callback;
        return true;
    }

    return false;
}

void IpcServer::launch(const QString &appId, const QString &mainQml, const QJsonDocument &params, const Callback &callback)
{
    while (!m_runnerClients.isEmpty()) {
        // socket instance will be deleted on disconnect
        QLocalSocket *socket = m_runnerClients.takeFirst();
        emit connectedRunnersCountChanged(m_runnerClients.count());
        if (socket && socket->isOpen()) {
            m_runningSockets.insert(appId, socket);
            const qint64 processId = socket->property("pid").value<qint64>();
            socket->setProperty("appId", appId);
            Q_ASSERT (processId);
            qDebug("Launching using runner from the pool. appId: %s main: %s",
                   qPrintable(appId), qPrintable(mainQml));
            QByteArray block;
            QDataStream out {&block, QIODevice::WriteOnly};

            QJsonObject message;
            message.insert(QStringLiteral("header"), LAUNCH_REQUEST);
            message.insert(QStringLiteral("appId"), appId);
            message.insert(QStringLiteral("mainQml"), mainQml);
            message.insert(QStringLiteral("params"), params.object());
            message.insert(QStringLiteral("callTime"), QDateTime::currentMSecsSinceEpoch());
            out << QJsonDocument(message).toBinaryData();

            socket->write(block);
            socket->flush();

            m_launchCallbacks[processId] = callback;
            return;
        }
    }

    qWarning("ran out of qml-runners! Deferring %s %s", qPrintable(appId), qPrintable(mainQml));
    m_deferredMessages << QSharedPointer<Message>(new Message {appId, mainQml, params, callback});
    emit connectedRunnersCountChanged(m_runnerClients.count());
    return;
}
