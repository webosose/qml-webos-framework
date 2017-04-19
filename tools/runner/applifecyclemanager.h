/* @@@LICENSE
 *
 *      Copyright (c) 2017 LG Electronics, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * LICENSE@@@ */

#ifndef APPLIFECYCLEMANAGER_H
#define APPLIFECYCLEMANAGER_H

#include <QJsonDocument>
#include <QString>
#include "lunaservicewrapper.h"

QT_BEGIN_NAMESPACE
class AppLifeCycleManager : public QObject
{
    Q_OBJECT

public:
    static const QLatin1String serviceName;
    static const QLatin1String defaultInterfaceMethodName;

public:
    AppLifeCycleManager(const QString appId, const QString method, const QString params);
    ~AppLifeCycleManager();

signals:
    void relaunchRequest(const QJsonDocument &);

private slots:
    void handleServerStatus(QString &contextId, QString &data, QString &method);
    void handleAppLifeCycle(QString &contextId, QString &data, QString &method);

private:
    void init(const QString appId, const QString method, const QString params);

    LunaServiceWrapper *m_bus;
    LunaServiceWrapper *m_appLifeCycleManager;
};

QT_END_NAMESPACE

#endif // APPLIFECYCLEMANAGER_H
