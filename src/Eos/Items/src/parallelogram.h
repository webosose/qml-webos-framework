// Copyright (c) 2014-2018 LG Electronics, Inc.
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

#ifndef PARALLELOGRAM_H
#define PARALLELOGRAM_H

#include "samplergeometry.h"
namespace SamplerGeometry {

class Parallelogram : public Item
{
    Q_OBJECT
    Q_PROPERTY(qreal angle READ angle WRITE setAngle NOTIFY angleChanged)
    Q_PROPERTY(qreal offset READ offset NOTIFY offsetChanged)
public:
    Parallelogram(QQuickItem *parent = 0);
    ~Parallelogram();
    qreal angle() const { return m_angle; }
    qreal offset() const { return m_offset; }
    Q_INVOKABLE qreal offsetAt(qreal y) const;
    void setAngle(qreal angle);
    bool contains(const QPointF & point) const Q_DECL_OVERRIDE;

protected:
    SolidMaterial* createSolidMaterial() Q_DECL_OVERRIDE;
    SampledMaterial* createSampledMaterial() Q_DECL_OVERRIDE;

    void updateSolidMaterial(GeometryNode* node) Q_DECL_OVERRIDE;
    void updateSampledMaterial(GeometryNode* node) Q_DECL_OVERRIDE;

    QSGGeometry* generateBodyGeometry(QSGGeometry* old) Q_DECL_OVERRIDE;
    QSGGeometry* generateFringeGeometry(QSGGeometry* old) Q_DECL_OVERRIDE;

public slots:
    void updateOffset();

signals:
    void angleChanged(qreal a);
    void offsetChanged(qreal o);

private:
    qreal m_angle;
    qreal m_offset;
};

}

#endif /* PARALLELOGRAM_H */
