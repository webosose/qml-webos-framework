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

#include <QtCore/QDateTime>
#include <QtNetwork/QLocalSocket>
#include <QtCore/QCoreApplication>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QDataStream>

#include "ipcclient.h"

IpcClient::IpcClient(QObject * parent) :
    QObject (parent)
{
    m_socket = new QLocalSocket(this);

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    QObject::connect(m_socket.data(), &QLocalSocket::errorOccurred,
                     this, &IpcClient::onSocketError);
#else
    void (QLocalSocket:: *error) (QLocalSocket::LocalSocketError) = &QLocalSocket::error;
    QObject::connect(m_socket.data(), error, this, &IpcClient::onSocketError);
#endif

    QObject::connect(m_socket.data(), &QLocalSocket::readyRead,
                     this, &IpcClient::onSocketReadyRead);

    QObject::connect(m_socket.data(), &QLocalSocket::disconnected,
                     m_socket.data(), &QLocalSocket::deleteLater);
}

IpcClient::~IpcClient()
{
    if (m_socket && m_socket->isOpen())
        m_socket->close();
}

void IpcClient::send(const QJsonDocument &json)
{
    if (m_socket && m_socket->isOpen()) {
        QByteArray data;
        QDataStream in (&data, QIODevice::WriteOnly);
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        // QTBUG-81239
        in << json.toJson(QJsonDocument::Compact);
#else
        in << json.toBinaryData();
#endif
        in.device()->seek(0);
        m_socket->write(data);
        m_socket->flush();
    }
}

bool IpcClient::connectToServer()
{
   m_socket->connectToServer("EosBooster");
   if (false == m_socket->waitForConnected(20000)) {
       qWarning() << m_socket->error();
       return false;
   }

   QJsonObject register_msg;
   register_msg.insert(QStringLiteral("header"), REGISTER_REQUEST);
   register_msg.insert(QStringLiteral("pid"), QCoreApplication::applicationPid());
   send(QJsonDocument(register_msg));

   return true;
}

void IpcClient::onSocketReadyRead()
{
    QByteArray raw_json;
    {
        QByteArray block = m_socket->readAll();
        QDataStream in (&block, QIODevice::ReadOnly);

        if (in.atEnd()) {
            qWarning("Nothing read from socket. ignoring.");
            return;
        }
        in >> raw_json;
    }
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    const QJsonDocument &json = QJsonDocument::fromJson(raw_json);
#else
    const QJsonDocument &json = QJsonDocument::fromBinaryData(raw_json);
#endif
    qDebug() << "received message:" << json.toJson(QJsonDocument::Compact);
    const QJsonObject &message = json.object();
    if (message.isEmpty()) {
        qWarning("Cannot parse message. Quitting.");
        QCoreApplication::exit(-1);
        return;
    }

    int header = message.value(QStringLiteral("header")).toInt(-1);
    switch (header) {
    case LAUNCH_REQUEST: {
        const QString &appId = message.value(QStringLiteral("appId")).toString();
        const QString &mainQml = message.value(QStringLiteral("mainQml")).toString();
        const QJsonObject &params = message.value(QStringLiteral("params")).toObject();
        //qint64 callTime = static_cast<qint64>(message.value(QStringLiteral("callTime")).toDouble());
        emit launchRequest(appId, mainQml, QJsonDocument(params));
      } break;
    case RELAUNCH_REQUEST: {
        const QJsonObject &params = message.value(QStringLiteral("params")).toObject();
        //qint64 callTime = static_cast<qint64>(message.value(QStringLiteral("callTime")).toDouble());
        emit relaunchRequest(QJsonDocument(params));
      } break;
    default:
        qWarning("Unsupported header %d. Quitting.", header);
        QCoreApplication::exit(-1);
    }
}

void IpcClient::onSocketError(QLocalSocket::LocalSocketError error)
{
    qWarning("IPC ConnectionError %d, quitting.", error);
    QCoreApplication::exit(-1);
}
