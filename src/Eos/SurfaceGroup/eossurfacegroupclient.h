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

#ifndef EOS_SURFACE_GROUP_CLIENT_H
#define EOS_SURFACE_GROUP_CLIENT_H

#include <QObject>
#include <QQmlParserStatus>

#include <webosplatform.h>
#include <webosshell.h>
#include <webosshellsurface.h>
#include <webossurfacegroup.h>
#include <webossurfacegroupcompositor.h>

#include <webosquickwindow.h>

class EosSurfaceGroupClient : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString groupName READ groupName WRITE setGroupName)
    Q_PROPERTY(WebOSQuickWindow* webOSWindow READ webOSWindow WRITE setWebOSWindow)
    Q_PROPERTY(QString layerName READ layerName WRITE setLayerName)

    Q_INTERFACES(QQmlParserStatus)

public:
    EosSurfaceGroupClient(QObject *parent = 0);
    ~EosSurfaceGroupClient();

    virtual void classBegin();
    virtual void componentComplete();

    QString groupName() { return m_groupName; }
    void setGroupName(const QString& groupName);

    WebOSQuickWindow* webOSWindow() { return m_webOSWindow; }
    void setWebOSWindow(WebOSQuickWindow* webOSWindow);

    QString layerName() { return m_layerName; }
    void setLayerName(const QString& layerName);

    Q_INVOKABLE void focusOwner();
    Q_INVOKABLE void focusLayer();

protected slots:
    void handleWindowVisibility();

protected:
    QString m_groupName;
    WebOSQuickWindow *m_webOSWindow;
    QString m_layerName;

    WebOSSurfaceGroup* m_SurfaceGroup;
};

#endif // EOS_SURFACE_GROUP_CLIENT_H
