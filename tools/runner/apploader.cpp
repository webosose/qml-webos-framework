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

#include <QtQml/qqmlcomponent.h>
#include <QtQml/qqmlcontext.h>

#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>

#include <QtCore/QCoreApplication>

#include "apploader.h"

#include <QDebug>

AppLoader::AppLoader (QObject * parent)
    : QObject (parent),
      m_component (new QQmlComponent(&m_engine, nullptr))
{
    QObject::connect(&m_engine, &QQmlEngine::quit,
                     QCoreApplication::instance(), &QCoreApplication::quit);
}

AppLoader::~AppLoader()
{
    // Root QQmlComponent must be deleted before QQmlEngine.
    delete m_component.data();
    //m_window should be deleted in case new QQuickView was created
    if (!m_window.isNull())
        delete m_window.data();
}

bool AppLoader::ready() const
{
    return m_component->status() == QQmlComponent::Ready;
}


void AppLoader::terminate()
{
    qDebug("Exiting pid '%lld'", QCoreApplication::applicationPid());
    QCoreApplication::quit();
}

void AppLoader::reloadApplication(const QVariant &params)
{
    // NOTE: input parameters could be used in deep linking case, according to DRD-5061 description:
    // "In addition we should allow Booster to pass additional parameters to support deep linking of
    // apps (e.g. EPG integration)"

    if (m_window && !m_window->handle()) {
        qWarning() << "Got relaunch on closing";
        return;
    }

    m_engine.rootContext()->setContextProperty("params", params);
    m_window->showFullScreen();
}

bool AppLoader::loadApplication(const QString &appId, const QString &mainQml, const QVariant &params)
{
    qDebug() << "Entered" << Q_FUNC_INFO;

    if (m_window && !m_window->handle()) {
        qWarning() << "Got launch on closing";
        return false;
    }

    m_engine.rootContext()->setContextProperty("params", params);

    // APP_ID envvar is used in multiple places, e.g WebOSQuickWindow and Service plugins.
    if (!appId.isEmpty()) {
        QCoreApplication::setApplicationName(appId);
        // TODO: deprecate APP_ID in favor of QCoreApplication::applicationName
        qputenv("APP_ID", appId.toUtf8());
    }

    m_component->loadUrl(mainQml);
    if ( !m_component->isReady() ) {
        qWarning("%s", qPrintable(m_component->errorString()));
        return false;
    }

    m_topLevelComponent = m_component->create();
    if (m_topLevelComponent.isNull() && m_component->isError()) {
        qWarning("%s", qPrintable(m_component->errorString()));
        return false;
    }

    qDebug("created QQmlComponent");
    m_window = qobject_cast<QQuickWindow *>(m_topLevelComponent.data());
    if (!m_window.isNull()) {
        m_engine.setIncubationController(m_window->incubationController());
    } else {
        QQuickItem *contentItem = qobject_cast<QQuickItem *>(m_topLevelComponent.data());
        if (contentItem) {
            QQuickView* qxView = new QQuickView(&m_engine, NULL);
            m_window.clear();
            m_window = qxView;
            qxView->setResizeMode(QQuickView::SizeRootObjectToView);
            qxView->setContent(mainQml, m_component.data(), contentItem);
        }
        m_window->show();
    }

    QObject::connect(m_window.data(), &QQuickWindow::frameSwapped, [this]() {
        qDebug("QQuickWindow::frameSwapped");
        QObject::disconnect(m_window.data(), &QQuickWindow::frameSwapped, nullptr, nullptr);
    });
    qDebug("created QQuickWindow");

    return true;
}
