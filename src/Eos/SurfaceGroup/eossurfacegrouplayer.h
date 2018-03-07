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

#ifndef EOS_SURFACE_GROUP_LAYER_H
#define EOS_SURFACE_GROUP_LAYER_H

#include <QDebug>
#include <QObject>
#include <QQmlParserStatus>

#include <webossurfacegrouplayer.h>
#include <webossurfacegroup.h>

class EosSurfaceGroupLayer : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(int z READ z WRITE setZ)
    Q_PROPERTY(QString layerName READ layerName WRITE setLayerName)
    Q_PROPERTY(bool isSurfaceAttached READ isSurfaceAttached NOTIFY isSurfaceAttachedChanged)
    Q_INTERFACES(QQmlParserStatus)

public:
    EosSurfaceGroupLayer(QObject *parent = 0);
    ~EosSurfaceGroupLayer();

    virtual void classBegin();
    virtual void componentComplete();

    int z();
    void setZ(int valueZ);

    QString layerName();
    void setLayerName(QString layerName);

    bool isSurfaceAttached() { return m_isSurfaceAttached; }

    bool createWebOSSurfaceGroupLayer(WebOSSurfaceGroup *pSurfaceGroup);

    WebOSSurfaceGroupLayer* getSurfaceGroupLayer() { return m_SurfaceGroupLayer; }

signals:
    void isSurfaceAttachedChanged();

protected slots:
    void onSurfaceAttached();
    void onSurfaceDetached();

protected:
    int m_z;
    QString m_layerName;
    bool m_isSurfaceAttached;

    WebOSSurfaceGroupLayer *m_SurfaceGroupLayer;
};

#endif // EOS_SURFACE_GROUP_LAYER_H
