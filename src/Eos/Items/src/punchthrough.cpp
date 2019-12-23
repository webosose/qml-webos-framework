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

#include "punchthrough.h"

#include <QtQuick/QSGSimpleRectNode>
#include <QGuiApplication>
#include <QScreen>

static QHash<void *, QRectF> punchThroughRects;
static bool (*setWindowPunchThroughRectFunc)(QScreen *, const QHash<void*, QRectF> &);

PunchThrough::PunchThrough(QQuickItem *parent):
    QQuickItem(parent),
    m_nativeInterface(QGuiApplication::platformNativeInterface()),
    m_x(0),
    m_y(0),
    m_width(0),
    m_height(0)
{
    setFlags(ItemHasContents);

    connect(static_cast<QQuickItem *>(this), SIGNAL(xChanged()), this, SLOT(setXValue()));
    connect(static_cast<QQuickItem *>(this), SIGNAL(yChanged()), this, SLOT(setYValue()));
    connect(static_cast<QQuickItem *>(this), SIGNAL(widthChanged()), this, SLOT(setWidthValue()));
    connect(static_cast<QQuickItem *>(this), SIGNAL(heightChanged()), this, SLOT(setHeightValue()));

    setWindowPunchThroughRectFunc = (bool (*)(QScreen*, const QHash<void*, QRectF> &)) m_nativeInterface->nativeResourceForScreen("setWindowPunchThroughRectFunc", QGuiApplication::primaryScreen());
}

PunchThrough::~PunchThrough() {
    punchThroughRects.remove(this);
    setWindowPunchThroughRect();
}

QSGNode *PunchThrough::updatePaintNode(QSGNode *node, UpdatePaintNodeData *)
{
    QSGSimpleRectNode *rectNode = static_cast<QSGSimpleRectNode *>(node);

    if (rectNode) {
        rectNode->setRect(boundingRect());
    } else {
        rectNode = new QSGSimpleRectNode(boundingRect(), Qt::transparent);
        rectNode->material()->setFlag(QSGMaterial::Blending, false);
    }

    if (punchThroughRects[this].isNull()) {
        QRectF rect(m_x, m_y, m_width,  m_height);
        punchThroughRects[this] = rect;

        setWindowPunchThroughRect();

    }

    return rectNode;
}

void PunchThrough::setRegion(const QRectF& region)
{
    int changed = false;

    if (!qFuzzyCompare(region.x(), x())) {
        setX(region.x());
        changed = true;
    }

    if (!qFuzzyCompare(region.y(), y())) {
        setY(region.y());
        changed = true;
    }

    if (!qFuzzyCompare(region.width(), width())) {
        setWidth(region.width());
        changed = true;
    }

    if (!qFuzzyCompare(region.height(), height())) {
        setHeight(region.height());
        changed = true;
    }

    if(changed) {
        QRectF changedRegion(m_x, m_y, m_width,  m_height);
        punchThroughRects[this] = changedRegion;
        qWarning() << "punchThrough ( " << this << ") is changed as " << changedRegion;
        setWindowPunchThroughRect();
    }
}

void PunchThrough::setXValue()
{
   m_x = x();
   qDebug() << "x (" << this << "): " << m_x;
}

void PunchThrough::setYValue()
{
    m_y = y();
    qDebug() << "y (" << this << "): " << m_y;
}

void PunchThrough::setWidthValue()
{
    m_width = width();
    qDebug() << "width (" << this << "): " << m_width;
}

void PunchThrough::setHeightValue()
{
    m_height = height();
    qDebug() << "height (" << this << "): " << m_height;
}

void PunchThrough::setWindowPunchThroughRect()
{
    if (setWindowPunchThroughRectFunc) {
        qWarning() << "punchThroughRects: " << punchThroughRects;
        setWindowPunchThroughRectFunc(QGuiApplication::primaryScreen(), punchThroughRects);
    } else {
        qWarning() << "setWindowPunchThroughRectFunc is not defined";
    }
}
