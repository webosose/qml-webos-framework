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

#ifndef TABLETITEM_H
#define TABLETITEM_H

#include <QQuickItem>
#include <QEvent>

class TabletItem : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(int id READ id)
    Q_PROPERTY(QPointF pos READ pos)
    Q_PROPERTY(int z READ z)
    Q_PROPERTY(int xTilt READ xTilt)
    Q_PROPERTY(int yTilt READ yTilt)
    Q_PROPERTY(qreal pressure READ pressure)
    Q_PROPERTY(QString type READ type)
    Q_PROPERTY(QString device READ device)
    Q_PROPERTY(qint64 uniqueId READ uniqueId)
    Q_PROPERTY(int xTouch READ xTouch)
    Q_PROPERTY(int yTouch READ yTouch)
    Q_PROPERTY(QString eventType READ eventType)

public:
    TabletItem(QQuickItem* parent = nullptr);
    virtual ~TabletItem();

    bool event(QEvent *event);

    int id() { return m_id; };
    QPointF pos() { return m_pos; };
    int z() { return m_z; };
    int xTilt() { return m_xTilt; };
    int yTilt() { return m_yTilt; };
    qreal pressure() { return m_pressure; };
    QString type() { return m_type; };
    QString device() { return m_device; };
    qint64 uniqueId() { return m_uniqueId; };
    int xTouch() { return m_xTouch; }
    int yTouch() { return m_yTouch; }
    QString eventType() const { return m_eventType; }

    void touchEvent(QTouchEvent *event) override;

signals:
    void moved();
    void pressed();
    void released();
    void touchUpdated();

private:
    void setValues(QTabletEvent *event);
    void setTouchValues(QTouchEvent *event);

    int m_id = 0;
    QString m_type;
    QString m_device;
    QPointF m_pos;
    int m_z = 0;
    int m_xTilt = 0;
    int m_yTilt = 0;
    qreal m_pressure = 0;
    qint64 m_uniqueId = 0;
    int m_xTouch = 0;
    int m_yTouch = 0;
    QString m_eventType;
};

#endif // TABLETITEM_H
