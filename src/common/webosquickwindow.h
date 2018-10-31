// Copyright (c) 2014-2020 LG Electronics, Inc.
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

#ifndef WEBOSQUICKWINDOW_H
#define WEBOSQUICKWINDOW_H

#include <QtQml/QQmlPropertyMap>
#include <QtQuick/QQuickWindow>
#include <QQmlParserStatus>
#ifndef NO_WEBOS_PLATFORM
#include <webosshellsurface.h>
#endif

#define WP_TITLE QStringLiteral("title")
#define WP_SUBTITLE QStringLiteral("subtitle")
#define WP_WINDOWTYPE QStringLiteral("_WEBOS_WINDOW_TYPE")
#define WP_APPID QStringLiteral("appId")
#define WP_DISPLAYAFFINITY QStringLiteral("displayAffinity")

#include "eosregion.h"

class WebOSQuickEvent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool accepted READ accepted WRITE setAccepted)

public:
    WebOSQuickEvent(QEvent *event) : m_event (event) {}

    bool accepted() { return m_event->isAccepted(); }
    void setAccepted(bool accepted) { m_event->setAccepted(accepted); }

private:
    QEvent *m_event;
};

class WebOSQuickWindow : public QQuickWindow, public QQmlParserStatus
{
    Q_OBJECT
    Q_FLAGS(LocationHints)
    Q_FLAGS(KeyMasks)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString subtitle READ subtitle WRITE setSubtitle NOTIFY subtitleChanged)
    Q_PROPERTY(QString windowType READ windowType WRITE setWindowType NOTIFY windowTypeChanged)
    Q_PROPERTY(QPoint mousePosition READ mousePosition NOTIFY mousePositionChanged)
    Q_PROPERTY(QString appId READ appId WRITE setAppId NOTIFY appIdChanged) // TODO: read-only
    Q_PROPERTY(int displayAffinity READ displayAffinity WRITE setDisplayAffinity NOTIFY displayAffinityChanged)
    Q_PROPERTY(bool keepAlive READ keepAlive WRITE setKeepAlive NOTIFY keepAliveChanged)
    Q_PROPERTY(WebOSQuickWindow::LocationHints locationHint READ locationHint WRITE setLocationHint NOTIFY locationHintChanged)
    Q_PROPERTY(Qt::WindowState windowState READ windowState WRITE setInternalWindowState NOTIFY windowStateChanged)
    Q_PROPERTY(QObject* windowProperties READ windowProperties CONSTANT)

    Q_PROPERTY(EosRegion* inputRegion READ inputRegion WRITE setInputRegion)
    Q_PROPERTY(WebOSQuickWindow::KeyMasks keyMask READ keyMask WRITE setKeyMask)
    Q_PROPERTY(bool cursorVisible READ cursorVisible NOTIFY cursorVisibleChanged)
    Q_PROPERTY(QString addon READ addon WRITE setAddon NOTIFY addonChanged)
    Q_INTERFACES(QQmlParserStatus)

public:

    enum LocationHint {
        LocationHintUndefined = 0,
        LocationHintNorth     = 1,
        LocationHintWest      = 2,
        LocationHintSouth     = 4,
        LocationHintEast      = 8,
        LocationHintCenter    = 16
    };
    Q_DECLARE_FLAGS(LocationHints, LocationHint)

    enum KeyMask {
        KeyMaskHome                 = 1,
        KeyMaskBack                 = 1 << 1,
        KeyMaskExit                 = 1 << 2,
        KeyMaskLeft                 = 1 << 3,
        KeyMaskRight                = 1 << 4,
        KeyMaskUp                   = 1 << 5,
        KeyMaskDown                 = 1 << 6,
        KeyMaskOk                   = 1 << 7,
        KeyMaskNumeric              = 1 << 8,
        KeyMaskRemoteColorRed       = 1 << 9,
        KeyMaskRemoteColorGreen     = 1 << 10,
        KeyMaskRemoteColorYellow    = 1 << 11,
        KeyMaskRemoteColorBlue      = 1 << 12,
        KeyMaskRemoteProgrammeGroup = 1 << 13,
        KeyMaskRemotePlaybackGroup  = 1 << 14,
        KeyMaskRemoteTeletextGroup  = 1 << 15,
        KeyMaskLocalLeft            = 1 << 16,
        KeyMaskLocalRight           = 1 << 17,
        KeyMaskLocalUp              = 1 << 18,
        KeyMaskLocalDown            = 1 << 19,
        KeyMaskLocalOk              = 1 << 20,
        KeyMaskRemoteMagnifierGroup = 1 << 21,
        KeyMaskMinimalPlaybackGroup = 1 << 22,
        KeyMaskGuide                = 1 << 23,
        KeyMaskTeletextActiveGroup  = 1 << 24,
        KeyMaskData                 = 1 << 25,
        KeyMaskInfo                 = 1 << 26,
        KeyMaskDefault = 0xFFFFFFF8
    };
    Q_DECLARE_FLAGS(KeyMasks, KeyMask)

    enum AddonStatus {
        AddonStatusNull,
        AddonStatusLoaded,
        AddonStatusDenied,
        AddonStatusError,
    };
    Q_ENUM(AddonStatus)

    WebOSQuickWindow(QWindow *parent = 0);
    ~WebOSQuickWindow();

    virtual void classBegin();
    virtual void componentComplete();

    QString title() { return m_windowProperties.value(WP_TITLE).toString(); }
    void setTitle(const QString& title);

    QString subtitle() { return m_windowProperties.value(WP_SUBTITLE).toString(); }
    void setSubtitle(const QString& subtitle);

    QString windowType() { return m_windowProperties.value(WP_WINDOWTYPE).toString(); }
    void setWindowType(const QString& type);

    QString appId() { return m_windowProperties.value(WP_APPID).toString(); }
    void setAppId(const QString& id);

    int displayAffinity() { return m_windowProperties.value(WP_DISPLAYAFFINITY).toInt(); }
    void setDisplayAffinity(int affinity);

    bool keepAlive() { return m_keepAlive; }
    void setKeepAlive(bool keepAlive);

    LocationHints locationHint();
    void setLocationHint(LocationHints hint);

    EosRegion* inputRegion() { return m_inputRegion; }
    void setInputRegion(EosRegion* pRegion);
    KeyMasks keyMask() { return m_keyMask; }
    void setKeyMask(const KeyMasks& keyMask);

    bool cursorVisible() { return m_cursorVisible; }

    QObject *windowProperties() { return &m_windowProperties; }

    /*!
     * The parent class function is not virtual and we need to signal the
     * qml code when it changes
     */
    void setInternalWindowState(Qt::WindowState state);

    QString addon();
    void setAddon(const QString& path);

    Q_INVOKABLE void resetAddon();

public slots:
    void setCursorVisible(const bool cursorVisible);
    QPoint mousePosition() const;

Q_SIGNALS:
    void titleChanged();
    void subtitleChanged();
    void windowTypeChanged();
    void appIdChanged();
    void displayAffinityChanged();
    void keepAliveChanged();
    void locationHintChanged();
    void windowStateChanged();
    void mousePositionChanged(const QPoint &mousePosition);
    void windowCloseRequested(WebOSQuickEvent *event);

    void stateAboutToChange(Qt::WindowState state);

    void cursorVisibleChanged();
    void addonChanged();
    void addonStatusChanged(AddonStatus status);

protected:
    bool eventFilter(QObject *obj, QEvent *event);
    void mouseMoveEvent(QMouseEvent *ev);
    bool event(QEvent *ev);
    bool translateTabletToMouse(QTabletEvent* event, QQuickItem* item);

private:
    QQmlPropertyMap m_windowProperties;

    /*! The properties cannot be set prior the platform window being set visible */
    QMap<QString, QString> m_pendingProperties;
    LocationHints m_pendingLocationHint;
    Qt::WindowState m_pendingWindowState;
    QString m_pendingAddon;

    EosRegion* m_inputRegion;
    KeyMasks m_keyMask;
    bool m_cursorVisible;

#ifndef NO_WEBOS_PLATFORM
    WebOSShellSurface* shellSurface();
#endif

    void setWindowProperty(const QString& key, const QString& value);
    QPoint m_mousePosition;

    bool m_keepAlive;
    bool handleTabletEvent(QQuickItem* item, QTabletEvent* event);

private slots:
    void updatePendingWindowProperties();
    void updateWindowProperties(const QString &key, const QVariant &value);
    void onAddonStatusChanged(WebOSShellSurface::AddonStatus status);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(WebOSQuickWindow::LocationHints)
Q_DECLARE_OPERATORS_FOR_FLAGS(WebOSQuickWindow::KeyMasks)

#endif
