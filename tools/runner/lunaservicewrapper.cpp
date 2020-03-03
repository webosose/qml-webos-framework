/* @@@LICENSE
 *
 *      Copyright (c) 2017-2020 LG Electronics, Inc.
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

#include "lunaservicewrapper.h"
#include <QDebug>
#include <QGuiApplication>
#include <glib.h>

//WARN This code is from luna-surfacemanager repository (http://wall.lge.com:8110/138487).
//     lunaHandle and mainLoop are defined as global variables shared between
//     inherited instances for LunaServiceWrapper. They are alive during whole
//     running time of qml-runner. According to its functional requirement,
//     we don't consider to manage their variables. If you wanna consider
//     dynamic lifecycle of the instances, please think about how to manager them.
const QString ls2ServiceNameDeprecated = QString("com.webos.app.qmlrunner-%1").arg(QCoreApplication::applicationPid());
LSHandle* lunaHandle = NULL;
GMainLoop* mainLoop = NULL;

static bool staticCallbackFunc(LSHandle* handle, LSMessage* message, void* ctxt)
{
    Q_ASSERT(handle);
    Q_ASSERT(message);
    Q_ASSERT(ctxt);

    QString strPayload;
    const char *payload = NULL;

    payload = LSMessageGetPayload(message);
    if (payload != NULL)
        strPayload = payload;

    ((LunaServiceWrapper *)ctxt)->callbackFunc(strPayload);
    return true;
}

LunaServiceWrapper::LunaServiceWrapper(const QString contextId, const QString appId,
                                       const QString serviceId, const QString method,
                                       const QString param)
  : m_token(LSMESSAGE_TOKEN_INVALID)
  , m_contextId(contextId)
  , m_appId(appId)
  , m_serviceId(serviceId)
  , m_method(method)
  , m_param(param)
  , m_isSubscribed(false)
{
}

LunaServiceWrapper::~LunaServiceWrapper()
{
    LSError lsError;
    LSErrorInit(&lsError);
    if (lunaHandle)
        LSUnregister(lunaHandle, &lsError);
    lunaHandle = NULL;

    if (mainLoop)
        g_main_loop_unref(mainLoop);
    mainLoop = NULL;
}

void LunaServiceWrapper::regist()
{
    if (NULL != lunaHandle)
        return;

    //NOTE qml-runner's LunaService gets allowedName as "com.webos.app.qmlrunner-{pid}"
    //     described at /usr/share/ls2/{prv,pub}/com.webos.app.qml.json files.
    //     I follows naming rule and refer to below wiki page:
    //     - https://wiki.lgsvl.com/pages/viewpage.action?pageId=106594749
    LSError lsError;
    LSErrorInit(&lsError);

    QString ls2ServiceName(ls2ServiceNameDeprecated);
    QString ls2Name = QString::fromLatin1(qgetenv("LS2_NAME"));
    if (!ls2Name.isEmpty())
        ls2ServiceName = ls2Name;

    qInfo() << "LS2_NAME:" << ls2ServiceName << ", ls2ServiceName:" << ls2ServiceName;
    if (!LSRegister(ls2ServiceName.toLatin1(), &lunaHandle, &lsError))
        qWarning() << "LSRegister error:" << lsError.error_code << lsError.message;
}

void LunaServiceWrapper::attachLoop()
{
    if (NULL != mainLoop)
        return;

    LSError lsError;
    LSErrorInit(&lsError);
    mainLoop = g_main_loop_new(NULL, FALSE);
    if (!LSGmainAttach(lunaHandle, mainLoop, &lsError))
        qWarning() << "GMainAttach error:" << lsError.error_code << lsError.message;
}

void LunaServiceWrapper::subscribe()
{
    QString param = "{";
    if (m_param != "")
        param += "\"serviceName\":\"" + m_param + "\",";
    param += "\"subscribe\":true}";

    LSError lsError;
    LSErrorInit(&lsError);
    if (LSCallFromApplication(lunaHandle,
                              ("luna://" + m_serviceId + "/" + m_method).toLatin1(),
                              param.toLatin1(),
                              m_appId.toLatin1(),
                              (LSFilterFunc) staticCallbackFunc,
                              this,
                              &m_token,
                              &lsError)) {
        m_isSubscribed = true;
    } else {
        qWarning() << "Failed to LSCallFromApplication:"
                   << lsError.error_code << lsError.message;
    }
}

void LunaServiceWrapper::cancel()
{
    LSError lsError;
    LSErrorInit(&lsError);
    LSCallCancel(lunaHandle, m_token, &lsError);
    m_isSubscribed = false;
    m_token = LSMESSAGE_TOKEN_INVALID;
}

void LunaServiceWrapper::callbackFunc(QString message)
{
    qDebug() << "LunaServiceWrapper::callBackFunc" << m_contextId << ","
                                                   << message << ","
                                                   << m_method;
    emit messageReceived(m_contextId, message, m_method);
}
