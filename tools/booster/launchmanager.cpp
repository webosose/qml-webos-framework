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

#include "launchmanager.h"

#include <QtCore/QDateTime>
#include <QtCore/QProcess>
#include <QtCore/QTimerEvent>
#include <QtNetwork/QLocalSocket>

namespace {
const int CLOSE_TIMEOUT = qgetenv("WEBOS_BOOSTER_KILL_TIMEOUT").isEmpty() ?
            1000 : qgetenv("WEBOS_BOOSTER_KILL_TIMEOUT").toInt();
}

LaunchManager::LaunchManager(int maxPrestarted, int delay, QString command, QObject *parent) :
    QObject (parent),
    m_maxPreCachedRunners (maxPrestarted),
    m_launchDelay (delay),
    m_launchRunnerCommand (command),
    m_launchTimerId (-1),
    m_closeTimerId (-1)
{
}

void LaunchManager::onConnectedRunnersCountChanged(int number)
{
    /* Number of connected runners defines the pool. If it's less than
     * m_maxPreCachedRunners we need to start more runners
     */
    int pending = m_maxPreCachedRunners - (m_startingUp.count() + number);
    if (m_launchTimerId != -1) {
        killTimer(m_launchTimerId);
        m_launchTimerId = -1;
    }
    if (pending > 0) {
        qDebug("Runner pool is missing %d instances. Pre-starting new instance in %d ms.",
               pending, m_launchDelay);
        m_launchTimerId = startTimer(m_launchDelay);
    }
}

void LaunchManager::onRunnerReady(qint64 processId)
{
    m_startingUp.remove(processId);
}

bool LaunchManager::terminate(qint64 processId)
{
    if (m_closing.contains(processId)) {
        qWarning("Asked to terminate process %lld that is already closing. Ignoring.", processId);
        return false;
    }

    QProcess *process = m_running.value(processId);
    if (!process)
        return false;

    m_closing.insert(processId);
    qint64 timestamp = QDateTime::currentMSecsSinceEpoch();
    process->setProperty("timestamp", QVariant::fromValue<qint64>(timestamp));
    if (m_closeTimerId == -1)
        m_closeTimerId = startTimer(CLOSE_TIMEOUT);

    process->terminate();
    return true;
}


void LaunchManager::timerEvent(QTimerEvent *e)
{
    if (e->timerId() == m_closeTimerId) {
        killTimer(m_closeTimerId);
        m_closeTimerId = -1;
        closeTimeoutHandler();
        return;
    }

    if (e->timerId() == m_launchTimerId) {
        killTimer(m_launchTimerId);
        m_launchTimerId = -1;
        launchRunner();
        return;
    }

    qWarning("Ignoring unexpected timer event.");
}

void LaunchManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    QProcess *process = qobject_cast<QProcess *>(sender());
    Q_ASSERT (process);
    qint64 processId = process->pid();
    if (0 == processId)
        processId = process->property("pid").value<qint64>();
    Q_ASSERT (processId);

    if (m_startingUp.remove(processId)) {

        int delay = 5000;

        // TODO: check surface-manager / wayland server, and in case it's not running wait for it.
        qWarning("Runner process %lld has quit without connecting to the pool. "
                 "Retrying in %d ms.", processId, delay);

        if (m_launchTimerId != -1) {
            killTimer(m_launchTimerId);
            m_launchTimerId = -1;
        }
        m_launchTimerId = startTimer(delay);
    }

    emit processFinished(processId, exitCode, exitStatus);
    process->deleteLater();
}

void LaunchManager::onProcessError(QProcess::ProcessError error)
{
    Q_UNUSED (error)

    QProcess *process = qobject_cast<QProcess *>(sender());
    Q_ASSERT (process);

    if (process->property("killed").toBool()) {
        // killed process reported by QProcess as crashed..
        qDebug("Process %lld killed.", process->pid());
    } else {
        qCritical("QProcess emitted error for \"%s\": %s",
                  qPrintable(process->program()), qPrintable(process->errorString()));
    }

    process->deleteLater();
}

void LaunchManager::onProcessDestroyed(QObject *object)
{
    qint64 processId = object->property("pid").value<qint64>();
    Q_ASSERT (processId);
    m_startingUp.remove(processId);
    m_running.remove(processId);
    m_closing.remove(processId);
}

void LaunchManager::launchRunner()
{
    QProcess *process = new QProcess();
    QObject::connect(process, &QProcess::destroyed, this, &LaunchManager::onProcessDestroyed);

    void (QProcess:: *finished) (int, QProcess::ExitStatus) = &QProcess::finished;
    QObject::connect(process, finished, this, &LaunchManager::onProcessFinished);
    void (QProcess:: *error) (QProcess::ProcessError) = &QProcess::error;
    QObject::connect(process, error, this, &LaunchManager::onProcessError);

    process->start(m_launchRunnerCommand);

    qDebug("Starting \"%s\" %s",
           qPrintable(process->program()),
           qPrintable(process->arguments().join(" ")));

    Q_ASSERT (process->pid());
    process->setProperty("pid", process->pid());
    m_startingUp.insert(process->pid());
    m_running.insert(process->pid(), process);
}

void LaunchManager::closeTimeoutHandler()
{
    int timeTillNextKill = 0;
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    foreach (const qint64 pid, m_closing) {
        QProcess *process = m_running.value(pid);
        const qint64 timestamp = process->property("timestamp").value<qint64>();
        const int wait = (timestamp + CLOSE_TIMEOUT) - now;
        if (wait > 0) {
            timeTillNextKill = timeTillNextKill ? qMin(wait, timeTillNextKill) : wait;
        } else {
            qWarning("Process %lld close operation is timed-out, killing.", pid);
            m_closing.remove(pid);
            process->setProperty("killed", true);
            process->kill();
        }
    }

    if (timeTillNextKill) {
        m_closeTimerId = startTimer(timeTillNextKill);
    }
}
