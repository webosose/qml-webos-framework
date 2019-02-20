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

#ifndef ABSTRACTLUNASERVICE_H
#define ABSTRACTLUNASERVICE_H

#include <QObject>
#include <QSharedData>

struct LSHandle;
struct LSMessage;

/*
 * TODO: Refactor code that is common with qml-webos-bridge plugin into a library.
 */

class LunaServiceMessage
{
    struct Data : public QSharedData
    {
        Data(LSMessage *msg);
        ~Data();
        Data(const Data &) = delete;
        Data & operator=(const Data &) = delete;
        LSMessage *msg;
    };

public:
    LunaServiceMessage(LSMessage *);

    QJsonDocument payload() const;
    void respond(const QJsonDocument &data) const;

    const LSMessage * getMsg() const { return d->msg;}

private:
    QExplicitlySharedDataPointer<Data> d;
};

class AbstractLunaService : public QObject
{
    Q_OBJECT

public:
    explicit AbstractLunaService(QObject *parent = 0);
    ~AbstractLunaService();

    void subscribeAdd(const LunaServiceMessage &lsmsg, const char *key);
    void subscribesReply(const QJsonDocument &data, const char *key);

protected:
    bool registerService(const char *serviceName,
                         const char *methodsCategory,
                         const char *signalsCategory);

private slots:
    // This is not registered on LS2
    void onSignalEmitted(const QJsonDocument &params);

protected:
    LSHandle *m_sh;

private:

    QString m_serviceName;
    QString m_signalsCategory;
};

#endif // ABSTRACTLUNASERVICE_H
