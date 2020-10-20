// Copyright (c) 2018-2020 LG Electronics, Inc.
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

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "tabletitem.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //register custom qml component
    qmlRegisterType<TabletItem>("TabletItem", 1, 0, "TabletItem");

    QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    QQmlApplicationEngine engine;
    engine.load(url);

    return app.exec();
}
