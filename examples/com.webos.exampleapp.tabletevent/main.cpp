/* @@@LICENSE
*
* Copyright (c) 2018 LG Electronics, Inc.
*
* Confidential computer software. Valid license from HP required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

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
