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

#include <limits.h>

#include "eossurfacegrouplayer.h"

EosSurfaceGroupLayer::EosSurfaceGroupLayer(QObject *parent)
    : QObject(parent)
    , m_z(INT_MIN)
    , m_SurfaceGroupLayer(0)
    , m_isSurfaceAttached(false)
{

}

EosSurfaceGroupLayer::~EosSurfaceGroupLayer()
{
    if (m_SurfaceGroupLayer) {
        delete m_SurfaceGroupLayer;
        m_SurfaceGroupLayer = 0;
    }
}

void EosSurfaceGroupLayer::classBegin()
{

}

void EosSurfaceGroupLayer::componentComplete()
{
    if (m_layerName.isEmpty()) {
        qCritical("Need valid value for \"layerName\" ");
        return;
    }

    if (m_z == INT_MIN) {
        qCritical("Need valid value for \"z\" ");
        return;
    }
}

int EosSurfaceGroupLayer::z()
{
    if (m_SurfaceGroupLayer) {
        m_z = m_SurfaceGroupLayer->z();
    }
    return m_z;
}

QString EosSurfaceGroupLayer::layerName()
{
    if (m_SurfaceGroupLayer) {
        m_layerName = m_SurfaceGroupLayer->name();
    }
    return m_layerName;
}

void EosSurfaceGroupLayer::setZ(int valueZ)
{
    if (m_z != valueZ) {
        m_z = valueZ;
        if (m_SurfaceGroupLayer) {
            m_SurfaceGroupLayer->setZ(m_z);
        }
    }
}

void EosSurfaceGroupLayer::setLayerName(QString layerName)
{
    if (m_layerName.isEmpty() && !layerName.isEmpty()) {
        m_layerName = layerName;
    }
}

bool EosSurfaceGroupLayer::createWebOSSurfaceGroupLayer(WebOSSurfaceGroup *pSurfaceGroup)
{
    bool retValue = false;

    if (m_SurfaceGroupLayer) {
        return retValue;
    }

    if (pSurfaceGroup) {
        m_SurfaceGroupLayer = pSurfaceGroup->createNamedLayer(m_layerName, m_z);
         if (m_SurfaceGroupLayer) {
             QObject::connect(m_SurfaceGroupLayer, SIGNAL(surfaceAttached()), this, SLOT(onSurfaceAttached()));
             QObject::connect(m_SurfaceGroupLayer, SIGNAL(surfaceDetached()), this, SLOT(onSurfaceDetached()));
         }
        retValue = true;
    }

    return retValue;
}

void EosSurfaceGroupLayer::onSurfaceAttached()
{
    m_isSurfaceAttached = true;
    emit isSurfaceAttachedChanged();
}

void EosSurfaceGroupLayer::onSurfaceDetached()
{
    m_isSurfaceAttached = false;
    emit isSurfaceAttachedChanged();
}
