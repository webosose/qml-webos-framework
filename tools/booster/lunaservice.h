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

#ifndef LUNASERVICE_H
#define LUNASERVICE_H

#include "abstractlunaservice.h"

#include <QJsonDocument>
#include "ipcserver.h"
#include "launchmanager.h"

/*
 * As this service class derived from AbstractLunaService and call
 * AbstractLunaService::registerService in it's constructor, it will
 * introspect metatype information and automatically call LS2 API.
 *
 * Signal "processFinished" will be registered as luna signal.
 * Protected slots "launch", "close" will be registered as luna private method.
 */

class LunaService : public AbstractLunaService
{
    Q_OBJECT

public:
    explicit LunaService(IpcServer *server, LaunchManager *launchManager, QObject *parent = 0);
    void update(bool firstResponce = false);

signals:
    //luna-send -i palm://com.palm.bus/signal/addmatch '{"category":"/booster","method":"processFinished"}'
    void processFinished(const QJsonDocument &params);

protected slots:
    //luna-send -n 1 luna://com.webos.booster/launch '{"main":"/path/main.qml","appId":"com.test"}'
    void launch(const LunaServiceMessage &msg);

    //luna-send -n 1 luna://com.webos.booster/close '{"appId":"com.test"}'
    void close(const LunaServiceMessage &msg);

    //luna-send -n 1 luna://com.webos.booster/running '{}'
    void running(const LunaServiceMessage &msg);

private:
    QJsonObject getRunningList();

private:
    QPointer<IpcServer> m_ipcServer;
    QPointer<LaunchManager> m_launchManager;
};

#endif // LUNASERVICE_H
