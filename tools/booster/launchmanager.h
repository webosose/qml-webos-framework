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

#ifndef LAUNCHMANAGER_H
#define LAUNCHMANAGER_H

#include <QtCore/QObject>
#include <QtCore/QProcess>
#include <QtCore/QMap>
#include <QtCore/QSet>
#include <QtCore/QTimer>

class QTimerEvent;

class LaunchManager : public QObject
{
    Q_OBJECT

public:
    LaunchManager(int maxPrestarted, int delay, QString command, QObject *parent = nullptr);

signals:
    void processStarted(qint64 processId);
    void processFinished(qint64 processId, int exitCode, QProcess::ExitStatus exitStatus);

public slots:
    void onConnectedRunnersCountChanged(int number);
    void onRunnerReady(qint64 processId);
    bool terminate(qint64 processId);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessError(QProcess::ProcessError error);
    void onProcessDestroyed(QObject *object);

private:
    void launchRunner();
    void closeTimeoutHandler();

protected:
    void timerEvent(QTimerEvent *e);

private:
    int m_maxPreCachedRunners;
    int m_launchDelay;
    QString m_launchRunnerCommand;
    int m_launchTimerId;
    int m_closeTimerId;
    QSet<qint64> m_startingUp;
    QSet<qint64> m_closing;
    QMap<qint64, QProcess *> m_running;
};

#endif // LAUNCHMANAGER_H
