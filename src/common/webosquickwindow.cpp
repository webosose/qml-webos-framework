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

#include "webosquickwindow.h"

#include <QGuiApplication>
#include <QDebug>

#ifndef NO_WEBOS_PLATFORM
#include <webosplatform.h>
#include <webosinputmanager.h>
#include <webosshell.h>
#include <webosshellsurface.h>
#endif

WebOSQuickWindow::WebOSQuickWindow(QWindow *parent)
    : QQuickWindow (parent)
    , m_windowProperties (this)
    , m_pendingLocationHint (LocationHintUndefined)
    , m_pendingWindowState (Qt::WindowNoState)
    , m_inputRegion(0)
    , m_keyMask(WebOSQuickWindow::KeyMaskDefault)
    , m_cursorVisible(false)
    , m_keepAlive(false)
{
    // "Force" create the platform window as without it the property settings
    // will fail even when tied to the visibility of the window
    installEventFilter(this);
    setFlags(flags() | Qt::FramelessWindowHint);

#ifndef NO_WINDOW_TRANSPARENCY
    // Set support for transparent windows
    QSurfaceFormat surfaceFormat = QWindow::format();
    surfaceFormat.setAlphaBufferSize(8);
    setFormat(surfaceFormat);
#endif

    QObject::connect(&m_windowProperties, &QQmlPropertyMap::valueChanged,
                     this, &WebOSQuickWindow::updateWindowProperties);
    create();
    QObject::connect(this, &WebOSQuickWindow::visibleChanged,
                     this, &WebOSQuickWindow::updatePendingWindowProperties);

    const QString &id = QCoreApplication::applicationName();
    m_windowProperties.insert(WP_APPID, id);
    setWindowProperty(WP_APPID, id);

#ifndef NO_WEBOS_PLATFORM
    WebOSInputManager *im = WebOSPlatform::instance()->inputManager();
    if (im) {
        setCursorVisible(im->getCursorVisible());
        QObject::connect(im, SIGNAL(cursorVisibleChanged(bool)), this, SLOT(setCursorVisible(bool)));
    }
    else qWarning() << "Fail to get inputManager instance";
#endif
}

WebOSQuickWindow::~WebOSQuickWindow()
{
}

void WebOSQuickWindow::classBegin()
{
}

void WebOSQuickWindow::componentComplete()
{
    if (m_keyMask != WebOSQuickWindow::KeyMaskDefault) {
        setKeyMask(m_keyMask);
    }

    if (m_inputRegion) {
        setInputRegion(m_inputRegion);
    }
}

void WebOSQuickWindow::setTitle(const QString& title)
{
    if (title != m_windowProperties.value(WP_TITLE)) {
        m_windowProperties.insert(WP_TITLE, QVariant(title));
        setWindowProperty(WP_TITLE, title);
        emit titleChanged();
    }
}

void WebOSQuickWindow::setSubtitle(const QString& subtitle)
{
    if (subtitle != m_windowProperties.value(WP_SUBTITLE)) {
        m_windowProperties.insert(WP_SUBTITLE, QVariant(subtitle));
        setWindowProperty(WP_SUBTITLE, subtitle);
        emit subtitleChanged();
    }
}

void WebOSQuickWindow::setWindowType(const QString& type)
{
    if (type != m_windowProperties.value(WP_WINDOWTYPE)) {
        m_windowProperties.insert(WP_WINDOWTYPE, QVariant(type));
        setWindowProperty(WP_WINDOWTYPE, type);
        emit windowTypeChanged();
    }
}

void WebOSQuickWindow::setAppId(const QString& id)
{
    qWarning("Deprecated: the property Window.appId will become read-only. "
             "Use QGuiApplication.applicationName instead.");

    if (id != m_windowProperties.value(WP_APPID)) {
        m_windowProperties.insert(WP_APPID, QVariant(id));
        setWindowProperty(WP_APPID, id);
        emit appIdChanged();
    }
}

void WebOSQuickWindow::setDisplayAffinity(int affinity)
{
    if (affinity != m_windowProperties.value(WP_DISPLAYAFFINITY)) {
        m_windowProperties.insert(WP_DISPLAYAFFINITY, QVariant(affinity));
        setWindowProperty(WP_DISPLAYAFFINITY, QString("%1").arg(affinity));
        emit displayAffinityChanged();
    }
}

void WebOSQuickWindow::setKeepAlive(bool keepAlive)
{
    if (m_keepAlive != keepAlive) {
        m_keepAlive = keepAlive;
        emit keepAliveChanged();
    }
}

void WebOSQuickWindow::updateWindowProperties(const QString &key, const QVariant &value)
{
    setWindowProperty(key, value.toString());
}

void WebOSQuickWindow::setInternalWindowState(Qt::WindowState state)
{
    // Call setWindowState even though the state is not changed.
    // This is just to handle WindowNoState.
    setWindowState(state);
    if (state != windowState()) {
#ifndef NO_WEBOS_PLATFORM
        WebOSShellSurface *ss = shellSurface();
        if (ss && isVisible()) {
            ss->setState(state);
        } else {
            m_pendingWindowState = state;
        }
#endif
        emit windowStateChanged();
    }
}

bool WebOSQuickWindow::eventFilter(QObject *obj, QEvent *event)
{
    Q_UNUSED(obj);
    if (event->type() == QEvent::WindowStateChange) {
        emit windowStateChanged();
    } else if (event->type() == QEvent::Close) {
        if (!keepAlive()) {
            qDebug() << "Close event received, Window will be closed";
            WebOSQuickEvent quickevent(event);
            emit windowCloseRequested(&quickevent);
        } else {
            qDebug() << "Close event received, Window will be hidden since the client is a keepAlive application";
            this->hide();
            return true;
        }
    } else if (event->type() == QEvent::Expose) {
        setInputRegion(m_inputRegion);
    }
    return false;
}

WebOSShellSurface* WebOSQuickWindow::shellSurface()
{
    return WebOSPlatform::instance()->shell()->shellSurfaceFor(this);
}

void WebOSQuickWindow::setWindowProperty(const QString& key, const QString& value)
{
#ifndef NO_WEBOS_PLATFORM
    WebOSShellSurface *ss = shellSurface();
    if (ss && isVisible()) {
        ss->setProperty(key, value);
    } else {
        qDebug() << "Window not ready, setting as pending property" << key << value;
        m_pendingProperties[key] = value;
    }
#else
    Q_UNUSED(key);
    Q_UNUSED(value);
#endif
}

WebOSQuickWindow::LocationHints WebOSQuickWindow::locationHint()
{
#ifndef NO_WEBOS_PLATFORM
    WebOSShellSurface *ss = shellSurface();
    if (ss)
        return (WebOSQuickWindow::LocationHints)((int)ss->locationHint());
    return (WebOSQuickWindow::LocationHints) WebOSQuickWindow::LocationHintCenter;
#else
    return WebOSQuickWindow::LocationHintCenter;
#endif
}

void WebOSQuickWindow::setLocationHint(WebOSQuickWindow::LocationHints hint)
{
#ifndef NO_WEBOS_PLATFORM
    WebOSShellSurface *ss = shellSurface();
    if (ss && isVisible()) {
        ss->setLocationHint((WebOSShellSurface::LocationHints)(int)hint);
    } else {
        qDebug() << "Window not ready, deferring hint" << hint;
        m_pendingLocationHint = hint;
    }
#else
    Q_UNUSED(hint);
#endif
}

void WebOSQuickWindow::updatePendingWindowProperties()
{
#ifndef NO_WEBOS_PLATFORM
    if (isVisible()) {
        WebOSShellSurface *ss = shellSurface();
        if (ss) {
            QObject::connect(ss, &WebOSShellSurface::stateAboutToChange,
                    this, &WebOSQuickWindow::stateAboutToChange);
            QObject::connect(ss, &WebOSShellSurface::locationHintChanged,
                    this, &WebOSQuickWindow::locationHintChanged);

            ss->setState(m_pendingWindowState);

            // Make sure that the location hint get also propagated
            if (m_pendingLocationHint > 0) {
                ss->setLocationHint((WebOSShellSurface::LocationHints)(int)m_pendingLocationHint);
            }

            // Make sure that the input region get also propagated
            if (m_inputRegion) {
                setInputRegion(m_inputRegion);
            }

            // Make sure that the key mask get also propagated
            if (m_keyMask != WebOSQuickWindow::KeyMaskDefault) {
                setKeyMask(m_keyMask);
            }
        }

        if (m_pendingProperties.size() > 0) {
            qDebug() << "Updating pending properties";
            QMapIterator<QString, QString> i(m_pendingProperties);
            while (i.hasNext()) {
                i.next();
                setWindowProperty(i.key(), i.value());
            }
        }
    }
#endif

}

void WebOSQuickWindow::setInputRegion(EosRegion* pRegion)
{
    if (pRegion) {
        m_inputRegion = pRegion;
#ifndef NO_WEBOS_PLATFORM
        WebOSShellSurface *ss = shellSurface();
        if (ss) {
            ss->setInputRegion(m_inputRegion->region());
        }
#endif
    }
}

void WebOSQuickWindow::setKeyMask(const WebOSQuickWindow::KeyMasks& keyMask)
{
    m_keyMask = keyMask;
#ifndef NO_WEBOS_PLATFORM
    WebOSShellSurface *ss = shellSurface();
    if (ss) {
        ss->setKeyMask((WebOSShellSurface::KeyMasks)(int)m_keyMask);
    }
#endif
}

void WebOSQuickWindow::setCursorVisible(const bool cursorVisible)
{
    m_cursorVisible = cursorVisible;
    emit cursorVisibleChanged();
}

void WebOSQuickWindow::mouseMoveEvent(QMouseEvent *ev)
{
    if (m_mousePosition != ev->pos()) {
        m_mousePosition = ev->pos();
        emit mousePositionChanged(m_mousePosition);
    }
    QQuickWindow::mouseMoveEvent(ev);
}

QPoint WebOSQuickWindow::mousePosition() const
{
    return m_mousePosition;
}
