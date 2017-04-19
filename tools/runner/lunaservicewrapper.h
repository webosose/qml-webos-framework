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

#ifndef LUNASERVICEWRAPPER_H
#define LUNASERVICEWRAPPER_H

#include <QObject>
#include <luna-service2/lunaservice.h>

class LunaServiceWrapper : public QObject
{
    Q_OBJECT

public:
    LunaServiceWrapper(const QString contextId, const QString appId, const QString serviceId,const QString method, const QString param);
    ~LunaServiceWrapper();

    void regist();
    void attachLoop();
    void subscribe();
    void cancel();
    void callbackFunc(QString message);
    bool isSubscribed() { return m_isSubscribed; }

private:
    LSMessageToken m_token;

    QString m_contextId;
    QString m_appId;
    QString m_serviceId;
    QString m_method;
    QString m_param;

    bool m_isSubscribed;

signals:
    void messageReceived(QString &type, QString &data, QString &method);

};
#endif // LUNASERVICEWRAPPER_H
