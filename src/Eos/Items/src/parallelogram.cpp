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

#include "parallelogram.h"

#include <QtQuick/qsgnode.h>
#include <QDebug>
#include <math.h>

namespace SamplerGeometry {

Parallelogram::Parallelogram(QQuickItem *parent)
    : Item(parent)
    , m_angle(10)
{
    connect(this, &QQuickItem::widthChanged, this, &Parallelogram::markDirtyGeometry);
    connect(this, &QQuickItem::heightChanged, this, &Parallelogram::updateOffset);

    m_offset = tan(m_angle * M_PI / 180) * height();
}

Parallelogram::~Parallelogram() {
}

void Parallelogram::updateOffset() {
    m_offset = tan(m_angle * M_PI / 180) * height();
    m_geometryDirty = true;
    emit offsetChanged(m_offset);
}

qreal Parallelogram::offsetAt(qreal y) const {
    if (qFuzzyCompare(height(), 0.0f))
        return 0.0f;
    return m_offset - (m_offset / height()) * y;
}

bool Parallelogram::contains(const QPointF & point) const {
    if(point.y() < 0 || point.y() > height()) {
        return false;
    }
    float offsetAtY = offsetAt(point.y());
    if(point.x() < offsetAtY || point.x() > (width()-m_offset) + offsetAtY)
        return false;
    return true;
}

SolidMaterial* Parallelogram::createSolidMaterial() {
    return new SolidMaterial();
}

SampledMaterial* Parallelogram::createSampledMaterial() {
    if(m_dest.contains(QRectF(0,0,width(), height())) || m_clampToEdge) {
        return new SimpleSampledMaterial();
    } else {
        return new SampledMaterial();
    }
}

QSGGeometry* Parallelogram::generateBodyGeometry(QSGGeometry* old) {
    QSGGeometry* geometry = old;
    int xVertices = 2;
    int yVertices = 2;
    int vertexCount = xVertices * yVertices;
    int numTriangles = 2;
    int indexCount = numTriangles * 3;

    if(!geometry) {
        geometry = new QSGGeometry(meshAttributes(), vertexCount, indexCount);
        geometry->setDrawingMode(GL_TRIANGLES);
    } else {
        geometry->allocate(vertexCount, indexCount);
    }

    Vertex* vertex = (Vertex*) geometry->vertexData();
    int vindex = 0;

    float a = m_angle * float(M_PI) / 180.0f;
    float xOff = cos(a) * 1.0f;
    float yOff = sin(a) * 1.0f;
    float yOff2 = 0.49f;

    // disable the fringe when we are not blending (ugly transparent pixels otherwise)
    if(!antialiasing()) {
        xOff = yOff = yOff2 = 0.0;
    }

    //second row: top, inner AA border
    vertex[vindex++].set(0       + m_offset + xOff, 0.0f + yOff, 1.0f); // x-X-------x-x
    vertex[vindex++].set(width()            - xOff, 0.0f + yOff, 1.0f); // x-x-------X-x
    //third row: bottom, inner AA border
    vertex[vindex++].set(0                  + xOff, height() - yOff, 1.0f); // x-X-------x-x
    vertex[vindex++].set(width() - m_offset - xOff, height() - yOff, 1.0f); // x-x-------X-x
    Q_ASSERT(vindex == vertexCount);

    int iindex = 0;
    quint16* index = geometry->indexDataAsUShort();
    index[iindex++] = 0;
    index[iindex++] = 1;
    index[iindex++] = 2;
    index[iindex++] = 1;
    index[iindex++] = 3;
    index[iindex++] = 2;

    Q_ASSERT(iindex == indexCount);
    return geometry;
}

QSGGeometry* Parallelogram::generateFringeGeometry(QSGGeometry* old) {
    QSGGeometry* geometry = old;

    int xVertices = 4;
    int yVertices = 4;
    int vertexCount = xVertices * yVertices;
    int numTriangles = (xVertices - 1) * (yVertices - 1) * 2 - 2;
    int indexCount = numTriangles * 3;

    if(!geometry) {
        geometry = new QSGGeometry(meshAttributes(), vertexCount, indexCount);
        geometry->setDrawingMode(GL_TRIANGLES);
    } else {
        geometry->allocate(vertexCount, indexCount);
    }

    Vertex* vertex = (Vertex*) geometry->vertexData();
    int vindex = 0;

    float a = m_angle * float(M_PI) / 180.0f;
    float xOff = cos(a) * 1.0f;
    float yOff = sin(a) * 1.0f;
    float yOff2 = 0.49f;

    //first row: top, outer AA border
    vertex[vindex++].set(0       + m_offset - xOff, 0.0f - yOff2, 0.0f); // X-x-------x-x
    vertex[vindex++].set(0       + m_offset + xOff, 0.0f - yOff2, 0.0f); // x-X-------x-x
    vertex[vindex++].set(width()            - xOff, 0.0f - yOff2, 0.0f); // x-x-------X-x
    vertex[vindex++].set(width()            + xOff, 0.0f - yOff2, 0.0f); // x-x-------x-X
    //second row: top, inner AA border
    vertex[vindex++].set(0       + m_offset - xOff, 0.0f + yOff, 0.0f); // X-x-------x-x
    vertex[vindex++].set(0       + m_offset + xOff, 0.0f + yOff, 1.0f); // x-X-------x-x
    vertex[vindex++].set(width()            - xOff, 0.0f + yOff, 1.0f); // x-x-------X-x
    vertex[vindex++].set(width()            + xOff, 0.0f + yOff, 0.0f); // x-x-------x-X
    //third row: bottom, inner AA border
    vertex[vindex++].set(0                  - xOff, height() - yOff, 0.0f); // X-x-------x-x
    vertex[vindex++].set(0                  + xOff, height() - yOff, 1.0f); // x-X-------x-x
    vertex[vindex++].set(width() - m_offset - xOff, height() - yOff, 1.0f); // x-x-------X-x
    vertex[vindex++].set(width() - m_offset + xOff, height() - yOff, 0.0f); // x-x-------x-X
    //fourth row: bottom, outer AA border
    vertex[vindex++].set(0                  - xOff, height() + yOff2, 0.0f); // X-x-------x-x
    vertex[vindex++].set(0                  + xOff, height() + yOff2, 0.0f); // x-X-------x-x
    vertex[vindex++].set(width() - m_offset - xOff, height() + yOff2, 0.0f); // x-x-------X-x
    vertex[vindex++].set(width() - m_offset + xOff, height() + yOff2, 0.0f); // x-x-------x-X
    Q_ASSERT(vindex == vertexCount);

    int iindex = 0;
    quint16* index = geometry->indexDataAsUShort();
    for(int y=0; y < yVertices-1; y++) {
        for(int x=0; x < xVertices-1; x++) {
            if(x == 1 && y == 1) continue; // skip middle square
            index[iindex++] = y * xVertices + x;
            index[iindex++] = y * xVertices + (x+1);
            index[iindex++] = (y+1) * xVertices + x;
            index[iindex++] = (y+1) * xVertices + x;
            index[iindex++] = (y+1)* xVertices + (x+1);
            index[iindex++] = y * xVertices + (x+1);
        }
    }

    Q_ASSERT(iindex == indexCount);
    return geometry;
}

void Parallelogram::updateSampledMaterial(GeometryNode* node) {
    Item::updateSampledMaterial(node);
}

void Parallelogram::updateSolidMaterial(GeometryNode* node) {
    Item::updateSolidMaterial(node);
}

void Parallelogram::setAngle(qreal angle) {
    if (qFuzzyCompare(m_angle, angle))
        return;
    m_angle = angle;
    m_geometryDirty = true;
    emit angleChanged(m_angle);
    updateOffset();
    update();
}

} // namespace
