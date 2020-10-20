// Copyright (c) 2019-2021 LG Electronics, Inc.
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

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    switch (event->deviceType()) {
    case QInputDevice::DeviceType::Mouse:
        m_device = "Mouse";
        break;
    case QInputDevice::DeviceType::TouchScreen:
        m_device = "TouchScreen";
        break;
    case QInputDevice::DeviceType::TouchPad:
        m_device = "TouchPad";
        break;
    case QInputDevice::DeviceType::Puck:
        m_device = "Puck";
        break;
    case QInputDevice::DeviceType::Stylus:
        m_device = "Stylus";
        break;
    case QInputDevice::DeviceType::Airbrush:
        m_device = "Airbrush";
        break;
    case QInputDevice::DeviceType::Keyboard:
        m_device = "Keyboard";
        break;
    case QInputDevice::DeviceType::Unknown:
        [[fallthrough]];
#else
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
#endif
    default:
        m_device = "Unknown";
        break;
    }

    switch (event->pointerType()) {
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    case QPointingDevice::PointerType::Pen:
        m_type = "Pen";
        break;
    case QPointingDevice::PointerType::Cursor:
        m_type = "Cursor";
        break;
    case QPointingDevice::PointerType::Eraser:
        m_type = "Eraser";
        break;
    case QPointingDevice::PointerType::Unknown:
        [[fallthrough]];
#else
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
#endif
    default:
        m_type = "Unknown";
        break;
    }
}
