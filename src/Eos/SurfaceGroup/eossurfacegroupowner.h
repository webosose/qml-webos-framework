// Copyright (c) 2015-2018 LG Electronics, Inc.
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

#ifndef EOS_SURFACE_GROUP_OWNER_H
#define EOS_SURFACE_GROUP_OWNER_H

#include <QObject>
#include <QQmlParserStatus>
#include <QQmlListProperty>

#include <webosplatform.h>
#include <webosshell.h>
#include <webosshellsurface.h>
#include <webossurfacegroup.h>
#include <webossurfacegroupcompositor.h>

#include <webosquickwindow.h>

#include "eossurfacegrouplayer.h"

class EosSurfaceGroupOwner : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString groupName READ groupName WRITE setGroupName)
    Q_PROPERTY(WebOSQuickWindow* webOSWindow READ webOSWindow WRITE setWebOSWindow)
    Q_PROPERTY(bool allowAnonymous READ allowAnonymous WRITE setAllowAnonymous)
    Q_PROPERTY(QQmlListProperty<EosSurfaceGroupLayer> layers READ layers)

    Q_INTERFACES(QQmlParserStatus)

public:
    EosSurfaceGroupOwner(QObject *parent = 0);
    ~EosSurfaceGroupOwner();

    virtual void classBegin();
    virtual void componentComplete();

    QString groupName() { return m_groupName; }
    void setGroupName(const QString& groupName);

    WebOSQuickWindow* webOSWindow() { return m_webOSWindow; }
    void setWebOSWindow(WebOSQuickWindow* webOSWindow);

    bool allowAnonymous() { return m_allowAnonymous; }
    void setAllowAnonymous(bool allowAnonymousValue);

    QQmlListProperty<EosSurfaceGroupLayer> layers();

    Q_INVOKABLE void focusOwner();
    Q_INVOKABLE void focusLayer(EosSurfaceGroupLayer* layer);

protected slots:
    void handleWindowVisibility();

protected:
    QString m_groupName;
    WebOSQuickWindow *m_webOSWindow;
    bool m_allowAnonymous;
    QList<EosSurfaceGroupLayer *> m_layers;

    WebOSSurfaceGroup* m_SurfaceGroup;
};

#endif // EOS_SURFACE_GROUP_OWNER_H
