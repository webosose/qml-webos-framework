// Copyright (c) 2019-2020 LG Electronics, Inc.
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

#include <QDebug>
#include "tabletitem.h"

TabletItem::TabletItem(QQuickItem* parent) : QQuickItem(parent)
{
    setAcceptedMouseButtons(Qt::LeftButton|Qt::RightButton);
}

TabletItem::~TabletItem()
{
}

bool TabletItem::event(QEvent *event)
{
    switch (event->type()) {
    case QEvent::TabletMove:
        setValues(static_cast<QTabletEvent *>(event));
        emit moved();
        return true;

    case QEvent::TabletPress:
        setValues(static_cast<QTabletEvent *>(event));
        emit pressed();
        return true;

    case QEvent::TabletRelease:
        setValues(static_cast<QTabletEvent *>(event));
        emit released();
        return true;
    }
    return QQuickItem::event(event);
}

void TabletItem::touchEvent(QTouchEvent *event)
{
    setTouchValues(static_cast<QTouchEvent *>(event));
    emit touchUpdated();
}

void TabletItem::setTouchValues(QTouchEvent *event)
{
    QList<QTouchEvent::TouchPoint> touchPoints = event->touchPoints();
    if (touchPoints.isEmpty())
        return;

    m_xTouch = touchPoints[0].screenPos().x();
    m_yTouch = touchPoints[0].screenPos().y();
    switch (event->type()) {
    case QEvent::TouchBegin:
        m_eventType = "TouchBegin";
        break;
    case QEvent::TouchUpdate:
        m_eventType = "TouchUpdate";
        break;
    case QEvent::TouchEnd:
        m_eventType = "TouchEnd";
        break;
    }
}

void TabletItem::setValues(QTabletEvent *event)
{
    m_id = event->uniqueId();
    m_pos = event->pos();
    m_z = event->z();
    m_xTilt = event->xTilt();
    m_yTilt = event->yTilt();
    m_pressure = event->pressure();
    m_uniqueId = event->uniqueId();

    switch (event->device()) {
    case QTabletEvent::NoDevice:
        m_device = "NoDevice";
        break;
    case QTabletEvent::Puck:
        m_device = "Puck";
        break;
    case QTabletEvent::Stylus:
        m_device = "Stylus";
        break;
    case QTabletEvent::Airbrush:
        m_device = "Airbrush";
        break;
    case QTabletEvent::FourDMouse:
        m_device = "FourDMouse";
        break;
    case QTabletEvent::XFreeEraser:
        m_device = "XFreeEraser";
        break;
    case QTabletEvent::RotationStylus:
        m_device = "RotationStylus";
        break;
    default:
        m_device = "Unknown";
    }

    switch (event->pointerType()) {
    case QTabletEvent::Pen:
        m_type = "Pen";
        break;
    case QTabletEvent::Cursor:
        m_type = "Cursor";
        break;
    case QTabletEvent::Eraser:
        m_type = "Eraser";
        break;
    case QTabletEvent::UnknownPointer:
    default:
        m_type = "Unknown";
        break;
    }
}
