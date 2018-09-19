/* @@@LICENSE
*
* Copyright (c) 2018 LG Electronics, Inc.
*
* Confidential computer software. Valid license from HP required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

#include <QDebug>
#include "tabletitem.h"

TabletItem::TabletItem(QQuickItem* parent) : QQuickItem(parent)
{
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

void TabletItem::setValues(QTabletEvent *event)
{
    m_id = event->uniqueId();
    m_pos = event->pos();
    m_z = event->z();
    m_xTilt = event->xTilt();
    m_yTilt = event->yTilt();
    m_pressure = event->pressure();

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
