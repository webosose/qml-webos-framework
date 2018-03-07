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

#ifndef EOS_REGION_RECT_H
#define EOS_REGION_RECT_H

#include <QDebug>
#include <QObject>
#include <QQmlParserStatus>

#include <QRect>

class EosRect : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(int x READ x WRITE setX)
    Q_PROPERTY(int y READ y WRITE setY)
    Q_PROPERTY(int width READ width WRITE setWidth)
    Q_PROPERTY(int height READ height WRITE setHeight)
    Q_INTERFACES(QQmlParserStatus)

public:
    EosRect(QObject *parent = 0);
    ~EosRect();

    virtual void classBegin();
    virtual void componentComplete();

    int x() { return m_Rect.x(); }
    void setX(int valueX) { m_Rect.setX(valueX); }

    int y() { return m_Rect.y(); }
    void setY(int valueY) { m_Rect.setY(valueY); }

    int width() { return m_Rect.width(); }
    void setWidth(int valueWidth) { m_Rect.setWidth(valueWidth); }

    int height() { return m_Rect.height(); }
    void setHeight(int valueHeight) { m_Rect.setHeight(valueHeight); }

    QRect rect();

protected:
    QRect m_Rect;
};

#endif // EOS_REGION_RECT_H
