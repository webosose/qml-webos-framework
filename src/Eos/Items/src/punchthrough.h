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

#ifndef PUNCHTHROUGH_H
#define PUNCHTHROUGH_H

#include <QtQuick/QQuickItem>
#include <qpa/qplatformnativeinterface.h>

class PunchThrough : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(PunchThrough)

public:
    PunchThrough(QQuickItem *parent = 0);
    ~PunchThrough();

    //Q_PROPERTY(QRect region READ region)
    Q_INVOKABLE void setRegion(const QRectF& region);

    QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *);
    void setWindowPunchThroughRect();

public slots:
    void setXValue();
    void setYValue();
    void setWidthValue();
    void setHeightValue();

private:
    QPlatformNativeInterface *m_nativeInterface;
    qreal m_x;
    qreal m_y;
    qreal m_width;
    qreal m_height;
    QRectF m_region;
};

#endif // PUNCHTHROUGH_H
