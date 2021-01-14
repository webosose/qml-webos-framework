// Copyright (c) 2014-2021 LG Electronics, Inc.
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

#ifndef APPLOADER_H
#define APPLOADER_H

#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtQml/QQmlEngine>

#include "webosquickwindow.h"

class QLocalSocket;

class AppLoader : public QObject
{
    Q_OBJECT

public:
    AppLoader(QObject * parent = 0);
    virtual ~AppLoader();
    bool ready() const;

public slots:
    bool loadApplication(const QString &appId, const QString &mainQml, const QVariant &params);
    void reloadApplication(const QVariant &params);
    void terminate();

private:
    void setLaunchParams(const QVariant &params);

    QQmlEngine m_engine;
    QPointer<QQmlComponent> m_component;
    QPointer<QQuickWindow> m_window;
    QPointer<QObject> m_topLevelComponent;
};

#endif // APPLOADER_H
