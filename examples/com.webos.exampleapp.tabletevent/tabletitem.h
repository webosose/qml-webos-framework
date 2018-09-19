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

signals:
    void moved();
    void pressed();
    void released();

private:
    void setValues(QTabletEvent *event);

    int m_id;
    QString m_type;
    QString m_device;
    QPointF m_pos;
    int m_z;
    int m_xTilt;
    int m_yTilt;
    qreal m_pressure;
};

#endif // TABLETITEM_H
