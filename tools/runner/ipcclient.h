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

#ifndef IPCCLIENT_H
#define IPCCLIENT_H

#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtNetwork/QLocalSocket>

#include "../common/ipccommon.h"

class QLocalSocket;
class QJsonDocument;

class IpcClient : public QObject
{
    Q_OBJECT

public:
    IpcClient(QObject * parent = 0);
    virtual ~IpcClient();

    void send(const QJsonDocument &json);

signals:
    void launchRequest(const QString &, const QString &, const QJsonDocument &);
    void relaunchRequest(const QJsonDocument &);

public slots:
    bool connectToServer();

private slots:
    void onSocketReadyRead();
    void onSocketError(QLocalSocket::LocalSocketError socketError);

private:
    QPointer <QLocalSocket> m_socket;
};

#endif // IPCCLIENT_H
