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

#ifndef IPCSERVER_H
#define IPCSERVER_H

#include <functional>

#include <QtCore/QJsonDocument>
#include <QtCore/QPointer>
#include <QtNetwork/QLocalServer>

class QLocalSocket;

class IpcServer : public QObject
{
    Q_OBJECT

public:
    typedef std::function<void(qint64 pid)> Callback;

    IpcServer(QObject * parent = 0);
    virtual ~IpcServer();
    bool isListening() const;
    int connectedRunnersCount() const;
    const QMap<QString, qint64> & runningApps() const { return m_runningApps;}

signals:
    void connectedRunnersCountChanged(int);
    void runnerRegistered(qint64 processId);
    void runnerLaunched(qint64 processId, const QString& appId);

public slots:
    void launch(const QString &appId, const QString &mainQml, const QJsonDocument &params, const Callback &callback);
    bool relaunch(const QString &appId, const QJsonDocument &params, const Callback &callback);
    void removeProcess(qint64 processId) {
        const QString &appId = m_runningProcesses.take(processId);
        // we may already started new process for this appId
        if (m_runningApps.value(appId) == processId)
            m_runningApps.remove(appId);
    }

private slots:
    void setupConnection();
    void readSocket();
    void onDisconnected();

private:
    struct Message { QString appId; QString mainQml; QJsonDocument params; Callback callback; };

    QLocalServer m_server;
    QList <QPointer<QLocalSocket> > m_runnerClients;
    QList<QSharedPointer<Message>> m_deferredMessages;
    QMap<QString, QPointer<QLocalSocket>> m_runningSockets;
    QMap<QString, qint64> m_runningApps;
    QMap<qint64, QString> m_runningProcesses;
    QMap<qint64, Callback> m_launchCallbacks;
};

#endif // IPCSERVER_H
