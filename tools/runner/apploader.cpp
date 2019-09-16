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

#include <QtQml/qqmlcomponent.h>
#include <QtQml/qqmlcontext.h>

#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>

#include <QtCore/QCoreApplication>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonValue>
#include "apploader.h"
#include <QDebug>

#if defined(SMACK_ENABLED)
#include <QCryptographicHash>
#include <unistd.h>
#include <fcntl.h>
#endif

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

void AppLoader::setLaunchParams(const QVariant &params)
{
    if (m_window && !m_window->handle()) {
        qWarning("Window is invalid, setLaunchParams failed");
        return;
    }

    QJsonValue paramsJson = QJsonValue::fromVariant(params);
    if (!paramsJson.isNull() && !paramsJson.isUndefined()) {
        QJsonDocument doc(paramsJson.toObject());
        if (!doc.isNull() && !doc.isEmpty())
            m_window->setProperty("launchParams", doc.toJson(QJsonDocument::Compact));
    }
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

    setLaunchParams(params);

    // NOTE
    // Logically, the compositor determines client's wl_webos_shell@state, and the client follows it.
    // But what the client calls QWindow::showFullScreen() is out of the compositor's logic.
    // We should use QWindow::show() instead of QWindow::showFullScreen(), but there are some problem.
    // 1. qml-runner doesn't react a 'background' (including 'keepAlive')  application required to call QWindow::hide().
    // 2. qml-runner doesn't support 'relaunch' lifecycle.
    //    - If CARD TYPE WINDOW goes to background,
    //      client's window state goes to 'Minimized' state without a 'surfaceUnmapped' event.
    //    - In this situation, if the client goes to 'relaunch',
    //      the client only calling QWindow::show() never lead to a 'surfaceMapped' event.
    //    - In conclusion,
    //      client's window should call QWindow::hide() at the 'background', and
    //      client's window should call QWindow::show() at the 'relaunch'.
    // Because of this problem, we are going to keep using QWindow::showFullScreen() at here.
    m_window->showFullScreen();
}

#if defined(SMACK_ENABLED)
std::string GetSmackLabelFromAppId(const std::string& appId, const std::string& prefix) {
  const int MAX_SMACK_LABEL_LENGTH = 255;
  const int MAX_APP_ID_LENGTH = 128;
  std::string label, smack_label;
  bool filtered = false;

  auto filter_appId = [=, &filtered] {
    std::string input(appId);
    input.erase(std::remove_if(input.begin(), input.end(),
                               [](const char& c) {
                                 switch (c) {
                                   case '\\':
                                   case '/':
                                   case '"':
                                   case '\'':
                                     return true;
                                   default:
                                     return false;
                                 }
                               }),
                input.end());

    if (input.size() < appId.size())
      filtered = true;

    return input;
  };

  auto sha256 = [](const std::string& input) {
    // Create a cryptographic hash object for SHA-256
    QCryptographicHash hash(QCryptographicHash::Sha256);
    hash.addData(input.c_str());
    QByteArray hashedData = hash.result();
    QString hashedString = QString(hashedData.toHex());
    return hashedString.toStdString();
  };

  label = prefix + filter_appId();
  // 255 is the max length of smack label
  if (label.length() <= MAX_SMACK_LABEL_LENGTH && !filtered) {
    smack_label = label;
  } else {
    smack_label = (label.length() > MAX_APP_ID_LENGTH) ? std::string(label, 0, MAX_APP_ID_LENGTH) : label;
    smack_label += sha256(appId);
  }

  return smack_label;
}

int AppLoader::setProcessSmackLabel(const std::string& appId) {
    int fd, err = 0;
    const std::string SMACK_APP_PREFIX = "webOS::App::";
    std::string smack_label = GetSmackLabelFromAppId(appId, SMACK_APP_PREFIX);
    if (-1 == (fd = open("/proc/self/attr/current", O_WRONLY))) {
        qWarning("SMACK is not enabled");
        return -errno;
    }

    if (-1 == write(fd, smack_label.c_str(), smack_label.length())) {
        qFatal("Can not set SMACK label %s", smack_label.c_str());
        err = -errno;
    } else {
        qInfo("Set SMACK label %s", smack_label.c_str());
    }

    close(fd);

    return err;
}
#endif

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
#if defined(SMACK_ENABLED)
    setProcessSmackLabel(appId.toStdString());
#endif
    if (!m_component)
        return false;

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
        setLaunchParams(params);
    } else {
        QQuickItem *contentItem = qobject_cast<QQuickItem *>(m_topLevelComponent.data());
        if (contentItem) {
            QQuickView* qxView = new QQuickView(&m_engine, NULL);
            m_window.clear();
            m_window = qxView;
            qxView->setResizeMode(QQuickView::SizeRootObjectToView);
            qxView->setContent(mainQml, m_component.data(), contentItem);
        }
        setLaunchParams(params);
        m_window->show();
    }

    QObject::connect(m_window.data(), &QQuickWindow::frameSwapped, [this]() {
        qDebug("QQuickWindow::frameSwapped");
        QObject::disconnect(m_window.data(), &QQuickWindow::frameSwapped, nullptr, nullptr);
    });
    qDebug("created QQuickWindow");

    return true;
}
