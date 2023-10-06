// Copyright (c) 2015-2023 LG Electronics, Inc.
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

#include "eossurfacegroupclient.h"

EosSurfaceGroupClient::EosSurfaceGroupClient(QObject *parent)
    : QObject (parent)
    , m_webOSWindow (0)
    , m_SurfaceGroup (0)
    , m_attached(false)
{

}

EosSurfaceGroupClient::~EosSurfaceGroupClient()
{
    if (m_SurfaceGroup) {
        delete m_SurfaceGroup;
        m_SurfaceGroup = 0;
    }
}

void EosSurfaceGroupClient::classBegin()
{

}

void EosSurfaceGroupClient::componentComplete()
{
    if (!m_webOSWindow) {
        qCritical("Need valid value for \"webOSWindow\" ");
        return;
    }

    if (m_groupName.isEmpty()) {
        qCritical("Need valid value for \"groupName\" ");
        return;
    }

    handleWindowVisibility();
}

void EosSurfaceGroupClient::handleWindowVisibility()
{
    if (!m_webOSWindow) {
        return;
    }

    if (m_webOSWindow->isVisible()) {
        // attach surface
        WebOSSurfaceGroupCompositor* compositor = WebOSPlatform::instance()->surfaceGroupCompositor();
        if (compositor) {
            if (!m_groupName.isEmpty()) {
                m_SurfaceGroup = compositor->getGroup(m_groupName);
                if (m_SurfaceGroup && !m_attached) {
                    if (m_layerName.isEmpty()) {
                        m_SurfaceGroup->attachAnonymousSurface(m_webOSWindow);
                    } else {
                        m_SurfaceGroup->attachSurface(m_webOSWindow, m_layerName);
                    }
                    m_attached = true;
                }
            }
        }
    } else {
        // detach surface
        if (m_attached) {
            m_SurfaceGroup->detachSurface(m_webOSWindow);
            m_attached = false;
        }
    }
}

void EosSurfaceGroupClient::setGroupName(const QString& groupName)
{
    if (m_groupName.isEmpty() && !groupName.isEmpty()) {
        m_groupName = groupName;
    }
}

void EosSurfaceGroupClient::setWebOSWindow(WebOSQuickWindow* webOSWindow)
{
    if (!m_webOSWindow && webOSWindow) {
        m_webOSWindow = webOSWindow;
        QObject::connect(m_webOSWindow, SIGNAL(visibleChanged(bool)),
                         this, SLOT(handleWindowVisibility()));
    }
}

void EosSurfaceGroupClient::setLayerName(const QString& layerName)
{
    if (m_layerName.isEmpty() && !layerName.isEmpty()) {
        m_layerName = layerName;
    }
}

void EosSurfaceGroupClient::focusOwner()
{
    if (m_SurfaceGroup) {
        m_SurfaceGroup->focusOwner();
    }
}

void EosSurfaceGroupClient::focusLayer()
{
    if (m_SurfaceGroup) {
        if (!m_layerName.isEmpty()) {
            m_SurfaceGroup->focusLayer(m_layerName);
        }
    }
}
