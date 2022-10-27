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


#include <QDebug>
#include <QJsonObject>

#include "applifecyclemanager.h"

const QLatin1String AppLifeCycleManager::serviceName = QLatin1String("com.webos.applicationManager");
const QLatin1String AppLifeCycleManager::defaultInterfaceMethodName = QLatin1String("registerApp");

AppLifeCycleManager::AppLifeCycleManager(const QString appId, const QString method, const QString params)
    : m_bus(NULL)
    , m_appLifeCycleManager(NULL)
{
    init(appId, method, params);
}

AppLifeCycleManager::~AppLifeCycleManager()
{
    if (m_appLifeCycleManager) {
        if (m_appLifeCycleManager->isSubscribed()) {
            disconnect(m_appLifeCycleManager, SIGNAL(messageReceived(QString&, QString&, QString&)),
                       this, SLOT(handleAppLifeCycle(QString&, QString&, QString&)));
            m_appLifeCycleManager->cancel();
        }

        delete m_appLifeCycleManager;
        m_appLifeCycleManager = NULL;
    }

    if (m_bus) {
        disconnect(m_bus, SIGNAL(messageReceived(QString&, QString&, QString&)),
                   this, SLOT(handleServerStatus(QString&, QString&, QString&)));
        m_bus->cancel();

        delete m_bus;
        m_bus = NULL;
    }
}

void AppLifeCycleManager::init(const QString appId, const QString method, const QString params)
{
    Q_ASSERT(appId.size());
    Q_ASSERT(method.size());
    Q_ASSERT(params.size());

    m_bus = new LunaServiceWrapper(serviceName + ".serverstatus",   // contextId
                                   appId,                           // appId
                                   "com.webos.service.bus",         // serviceId
                                   "signal/registerServerStatus",   // method
                                   serviceName);                    // param
    Q_ASSERT(m_bus);

    m_appLifeCycleManager = new LunaServiceWrapper(serviceName,     // contextId
                                                   appId,           // appId
                                                   serviceName,     // serviceId
                                                   method,          // method
                                                   params);         // param
    Q_ASSERT(m_appLifeCycleManager);

    connect(m_bus, SIGNAL(messageReceived(QString&, QString&, QString&)),
            this, SLOT(handleServerStatus(QString&, QString&, QString&)));
    m_bus->regist();
    m_bus->attachLoop();
    m_bus->subscribe();
    m_appLifeCycleManager->regist();
    m_appLifeCycleManager->attachLoop();
}

void AppLifeCycleManager::handleServerStatus(QString &contextId, QString &data, QString &method)
{
    Q_ASSERT(m_appLifeCycleManager);
    Q_UNUSED(contextId);
    Q_UNUSED(method);

    QJsonObject response = QJsonDocument::fromJson(data.toUtf8()).object();
    bool connected = response.value("connected").toBool();

    qDebug() << "registerServerStatus() response: " << response;
    if (connected) {
        if (!m_appLifeCycleManager->isSubscribed()) {
            connect(m_appLifeCycleManager, SIGNAL(messageReceived(QString&, QString&, QString&)),
                    this, SLOT(handleAppLifeCycle(QString&, QString&, QString&)));
            m_appLifeCycleManager->subscribe();
        }
    }
    else if (m_appLifeCycleManager->isSubscribed()) {
        disconnect(m_appLifeCycleManager, SIGNAL(messageReceived(QString&, QString&, QString&)),
                   this, SLOT(handleAppLifeCycle(QString&, QString&, QString&)));
        m_appLifeCycleManager->cancel();
    }
}

void AppLifeCycleManager::handleAppLifeCycle(QString &contextId, QString &data, QString &method)
{
    Q_UNUSED(contextId);

    QJsonObject response = QJsonDocument::fromJson(data.toUtf8()).object();
    const char* keyName = (method == defaultInterfaceMethodName) ? "message" : "event";
    QString message = response.value(keyName).toString();

    qDebug() << "handleAppLifeCycle()" << message << "event response: " << response;
    if (message == "relaunch") {
        const QJsonObject &parameters = response.value(QStringLiteral("parameters")).toObject();
        emit relaunchRequest(QJsonDocument(parameters));
    }
    else if (message == "close") {
        const QJsonObject &reason = response.value(QStringLiteral("reason")).toObject();
        emit closeRequest(QJsonDocument(reason));
    }
}
