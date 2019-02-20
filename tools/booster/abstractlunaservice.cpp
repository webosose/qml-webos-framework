// Copyright (c) 2014-2019 LG Electronics, Inc.
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

#include "abstractlunaservice.h"

#include <QtCore/QMetaMethod>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QVector>

#include <glib.h>
#include <luna-service2/lunaservice.h>

namespace {

bool ls_callback(LSHandle *sh, LSMessage *msg, void *category_context)
{
    Q_UNUSED (sh)

    const char *method_name = LSMessageGetMethod(msg);

    QObject *obj = static_cast<QObject*>(category_context);
    Q_ASSERT (obj);

    LunaServiceMessage message (msg);
    bool res = QMetaObject::invokeMethod(obj, method_name, Qt::AutoConnection,
                                         Q_ARG(LunaServiceMessage, message));
    if (!res) {
        QJsonObject reply;
        reply.insert(QStringLiteral("returnValue"), false);
        reply.insert(QStringLiteral("errorCode"), -1);
        reply.insert(QStringLiteral("errorText"), QStringLiteral("Failed to invoke %1::%2")
                     .arg(obj->metaObject()->className()).arg(method_name));
        LSMessageRespond(msg, QJsonDocument(reply).toJson().data(), nullptr);
    }

    return res;
}

struct MetaHelper
{
    MetaHelper(const QMetaObject* metaObject);
    ~MetaHelper();

    QVector<LSSignal> signalsArray;
    QVector<LSMethod> methodsArray;
    QList<QMetaMethod> signalsToForward;
};

MetaHelper::MetaHelper(const QMetaObject* metaObject)
{
    for (int i = metaObject->methodOffset(); i < metaObject->methodCount(); ++i) {
        const QMetaMethod &m = metaObject->method(i);

        if (m.methodType() == QMetaMethod::Signal) {
            signalsArray << LSSignal {qstrdup(m.name()), (LSSignalFlags)0};
            signalsToForward << m;

        } else if (m.methodType() == QMetaMethod::Slot) {
            switch (m.access()) {
            case QMetaMethod::Protected:
            case QMetaMethod::Public:
                methodsArray << LSMethod {qstrdup(m.name()), &ls_callback, (LSMethodFlags)0};
                break;
            default:
                // skipping private slots
                break;
            }
        } else {
            // skipping normal methods and constructors
        }
    }

    signalsArray << LSSignal {nullptr, (LSSignalFlags)0 };
    methodsArray << LSMethod {nullptr, nullptr, (LSMethodFlags)0};
}

MetaHelper::~MetaHelper()
{
    foreach (auto item, signalsArray) delete[] item.name;
    foreach (auto item, methodsArray) delete[] item.name;
}

} // namespace

LunaServiceMessage::Data::Data(LSMessage *m) :
    msg (m)
{
    LSMessageRef(msg);
}

LunaServiceMessage::Data::~Data()
{
    LSMessageUnref(msg);
}

LunaServiceMessage::LunaServiceMessage(LSMessage *message) :
    d (new Data(message))
{
}

QJsonDocument LunaServiceMessage::payload() const
{
    return QJsonDocument::fromJson(LSMessageGetPayload(d->msg));
}

void LunaServiceMessage::respond(const QJsonDocument &reply) const
{
    LSMessageRespond(d->msg, reply.toJson().data(), nullptr);
}

void AbstractLunaService::subscribeAdd(const LunaServiceMessage & lsmsg, const char *key)
{
    Q_ASSERT (m_sh);

    LSMessage * msg = const_cast<LSMessage *>(lsmsg.getMsg());
    LSSubscriptionAdd(m_sh, key, msg, nullptr);
}

void AbstractLunaService::subscribesReply(const QJsonDocument &data, const char *key)
{
    Q_ASSERT (m_sh);

    LSSubscriptionReply(m_sh, key, data.toJson().data(), nullptr);
}

AbstractLunaService::AbstractLunaService(QObject *parent) :
    QObject (parent),
    m_sh (nullptr)
{
}

AbstractLunaService::~AbstractLunaService()
{
    Q_ASSERT (m_sh);

    LSError err;
    LSErrorInit(&err);

    bool res = LSUnregister(m_sh, &err);
    Q_ASSERT_X (res, "LSUnregister", err.message);
}

bool AbstractLunaService::registerService(const char *serviceName,
                                          const char *methodsCategory,
                                          const char *signalsCategory)
{
    m_serviceName = serviceName;
    m_signalsCategory = signalsCategory;

    LSError err;
    LSErrorInit(&err);

    if (!LSRegister(m_serviceName.toLatin1().constData(), &m_sh, &err)) {
        qFatal("Failed to register Luna Service: '%s'. Reason: %s",
               qPrintable(m_serviceName),
               err.message);
    }

    MetaHelper meta {metaObject()};

    if (!LSRegisterCategory(m_sh, methodsCategory,
                                        meta.methodsArray.data(),
                                        nullptr,
                                        nullptr,
                                        &err)) {
        qFatal("Failed to register Luna Service Category '%s'. Reason '%s'",
               methodsCategory,
               err.message);
    }
    if (!LSCategorySetData(m_sh, methodsCategory, this, &err) ) {
        qFatal("Failed to set user data for the category '%s'. Reason '%s'",
               methodsCategory,
               err.message);
    }

    if (!LSRegisterCategory(m_sh, m_signalsCategory.toLatin1().constData(),
                             nullptr,
                             meta.signalsArray.data(),
                             nullptr,
                             &err)) {
        qFatal("LSRegisterCategory", err.message);
    }

    if (!LSGmainContextAttach(m_sh, g_main_context_default(), &err)) {
        qFatal("Failed to attach Luna Service to event loop. Reason: %s", err.message);
    }

    foreach (const QMetaMethod &m, meta.signalsToForward) {
        // Cannot use SIGNAL macro here, prefixing "2" manually. See qobjectdefs.h
        const QByteArray signal =  "2" + m.methodSignature();
        bool res = QObject::connect(this, signal, this, SLOT(onSignalEmitted(QJsonDocument)));
        Q_ASSERT (res); // if failed, there will be a warning message from "connect" call.
    }

    return true;
}

void AbstractLunaService::onSignalEmitted(const QJsonDocument &params)
{
    Q_ASSERT (m_sh);

    LSError err;
    LSErrorInit(&err);

    const QObject *obj = sender();
    const QMetaMethod &method = obj->metaObject()->method(senderSignalIndex());
    QStringList path = QStringList() << m_serviceName;
    const QString category = m_signalsCategory.section('/', 1);
    if (!category.isEmpty())
        path << category;
    path << method.name();
    const QByteArray uri = "palm://" + path.join('/').toLatin1();

    bool res = LSSignalSend(m_sh, uri.constData(), params.toJson().data(), &err);
    Q_ASSERT_X (res, "LSSignalSend", err.message);
}
