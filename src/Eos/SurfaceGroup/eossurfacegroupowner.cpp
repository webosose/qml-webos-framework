// Copyright (c) 2015-2021 LG Electronics, Inc.
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

#include "eossurfacegroupowner.h"

EosSurfaceGroupOwner::EosSurfaceGroupOwner(QObject *parent)
    : QObject (parent)
    , m_webOSWindow (0)
    , m_SurfaceGroup (0)
    , m_allowAnonymous(false)
{

}

EosSurfaceGroupOwner::~EosSurfaceGroupOwner()
{
    if (m_SurfaceGroup) {
        delete m_SurfaceGroup;
        m_SurfaceGroup = 0;
    }
}

void EosSurfaceGroupOwner::classBegin()
{

}

void EosSurfaceGroupOwner::componentComplete()
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

void EosSurfaceGroupOwner::handleWindowVisibility()
{
    if (m_SurfaceGroup) {
        return;
    }

    if (m_webOSWindow && m_webOSWindow->isVisible()) {
        WebOSSurfaceGroupCompositor* compositor = WebOSPlatform::instance()->surfaceGroupCompositor();
        if (compositor) {
            if (!m_groupName.isEmpty()) {
                m_SurfaceGroup = compositor->createGroup(m_webOSWindow, m_groupName);
                if (m_SurfaceGroup) {
                    if (m_allowAnonymous) {
                        m_SurfaceGroup->setAllowAnonymousLayers(m_allowAnonymous);
                    }

                    for (int i = 0; i < m_layers.size(); ++i) {
                        EosSurfaceGroupLayer *pSurfaceGroupLayer = m_layers.at(i);
                        if (pSurfaceGroupLayer) {
                            pSurfaceGroupLayer->createWebOSSurfaceGroupLayer(m_SurfaceGroup);
                        }
                    }
                }
            }
        }
    }
}

void EosSurfaceGroupOwner::setGroupName(const QString& groupName)
{
    if (m_groupName.isEmpty() && !groupName.isEmpty()) {
        m_groupName = groupName;
    }
}

void EosSurfaceGroupOwner::setWebOSWindow(WebOSQuickWindow* webOSWindow)
{
    if (!m_webOSWindow && webOSWindow) {
        m_webOSWindow = webOSWindow;
        QObject::connect(m_webOSWindow, SIGNAL(visibleChanged(bool)),
                         this, SLOT(handleWindowVisibility()));
    }
}

void EosSurfaceGroupOwner::setAllowAnonymous(bool allowAnonymousValue)
{
    if (m_allowAnonymous != allowAnonymousValue) {
        m_allowAnonymous = allowAnonymousValue;
    }
}

QQmlListProperty<EosSurfaceGroupLayer> EosSurfaceGroupOwner::layers()
{
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    return QQmlListProperty<EosSurfaceGroupLayer>(this, &m_layers);
#else
    return QQmlListProperty<EosSurfaceGroupLayer>(this, m_layers);
#endif
}

void EosSurfaceGroupOwner::focusLayer(EosSurfaceGroupLayer* layer)
{
    if (m_SurfaceGroup) {
        if (layer && !layer->layerName().isEmpty()) {
            m_SurfaceGroup->focusLayer(layer->layerName());
        }
    }
}

void EosSurfaceGroupOwner::focusOwner()
{
    if (m_SurfaceGroup) {
        m_SurfaceGroup->focusOwner();
    }
}
