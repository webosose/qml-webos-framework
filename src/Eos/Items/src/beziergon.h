// Copyright (c) 2014-2021 LG Electronics, Inc.
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

#ifndef BEZIERGON_H
#define BEZIERGON_H

#include <QtGlobal>
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QOpenGLShaderProgram>
#endif
#include "samplergeometry.h"

namespace SamplerGeometry {

struct BeziergonState {
    QPointF m_topLeft, m_topRight, m_bottomLeft, m_bottomRight;
    QPointF m_controlTopLeft, m_controlTopRight, m_controlBottomLeft, m_controlBottomRight;
    QPointF m_controlLeftTop, m_controlLeftBottom, m_controlRightTop, m_controlRightBottom;
};

class Beziergon : public Item
{
    Q_OBJECT

public:

    Q_PROPERTY(QPoint resolution READ resolution WRITE setResolution NOTIFY resolutionChanged)

    Q_PROPERTY(QPointF topLeft READ topLeft WRITE setTopLeft NOTIFY topLeftChanged)
    Q_PROPERTY(QPointF topRight READ topRight WRITE setTopRight NOTIFY topRightChanged)
    Q_PROPERTY(QPointF bottomLeft READ bottomLeft WRITE setBottomLeft NOTIFY bottomLeftChanged)
    Q_PROPERTY(QPointF bottomRight READ bottomRight WRITE setBottomRight NOTIFY bottomRightChanged)

    Q_PROPERTY(QPointF controlTopLeft READ controlTopLeft WRITE setControlTopLeft NOTIFY controlTopLeftChanged)
    Q_PROPERTY(QPointF controlTopRight READ controlTopRight WRITE setControlTopRight NOTIFY controlTopRightChanged)

    Q_PROPERTY(QPointF controlBottomLeft READ controlBottomLeft WRITE setControlBottomLeft NOTIFY controlBottomLeftChanged)
    Q_PROPERTY(QPointF controlBottomRight READ controlBottomRight WRITE setControlBottomRight NOTIFY controlBottomRightChanged)

    Q_PROPERTY(QPointF controlRightTop READ controlRightTop WRITE setControlRightTop NOTIFY controlRightTopChanged)
    Q_PROPERTY(QPointF controlRightBottom READ controlRightBottom WRITE setControlRightBottom NOTIFY controlRightBottomChanged)

    Q_PROPERTY(QPointF controlLeftTop READ controlLeftTop WRITE setControlLeftTop NOTIFY controlLeftTopChanged)
    Q_PROPERTY(QPointF controlLeftBottom READ controlLeftBottom WRITE setControlLeftBottom NOTIFY controlLeftBottomChanged)

    Beziergon(QQuickItem *parent = 0);
    ~Beziergon();

    QPoint resolution() const { return m_resolution; }

    QPointF topLeft() const { return m_topLeft; }
    QPointF topRight() const { return m_topRight; }
    QPointF bottomLeft() const { return m_bottomLeft; }
    QPointF bottomRight() const { return m_bottomRight; }

    QPointF controlTopLeft() const { return m_controlTopLeft; }
    QPointF controlTopRight() const { return m_controlTopRight; }
    QPointF controlBottomLeft() const { return m_controlBottomLeft; }
    QPointF controlBottomRight() const { return m_controlBottomRight; }

    QPointF controlLeftTop() const { return m_controlLeftTop; }
    QPointF controlLeftBottom() const { return m_controlLeftBottom; }
    QPointF controlRightTop() const { return m_controlRightTop; }
    QPointF controlRightBottom() const { return m_controlRightBottom; }

    void setResolution(const QPoint& tess);

    void setTopLeft(const QPointF& p);
    void setTopRight(const QPointF& p);
    void setBottomLeft(const QPointF& p);
    void setBottomRight(const QPointF& p);

    void setControlTopLeft(const QPointF& p);
    void setControlTopRight(const QPointF& p);
    void setControlBottomLeft(const QPointF& p);
    void setControlBottomRight(const QPointF&p);

    void setControlLeftTop(const QPointF& p);
    void setControlLeftBottom(const QPointF& p);
    void setControlRightTop(const QPointF& p);
    void setControlRightBottom(const QPointF& p);

protected:
    SolidMaterial* createSolidMaterial() Q_DECL_OVERRIDE;
    SampledMaterial* createSampledMaterial() Q_DECL_OVERRIDE;
    void updateSolidMaterial(GeometryNode* node) Q_DECL_OVERRIDE;
    void updateSampledMaterial(GeometryNode* node) Q_DECL_OVERRIDE;
    void updateBeziergonState(BeziergonState* state);

    QSGGeometry* generateBodyGeometry(QSGGeometry* old) Q_DECL_OVERRIDE;
    QSGGeometry* generateFringeGeometry(QSGGeometry* old) Q_DECL_OVERRIDE;
public slots:
    void calculateTopLeft();
    void calculateTopRight();
    void calculateBottomLeft();
    void calculateBottomRight();

    void calculateControlTopLeft();
    void calculateControlTopRight();
    void calculateControlBottomLeft();
    void calculateControlBottomRight();

    void calculateControlRightTop();
    void calculateControlRightBottom();
    void calculateControlLeftTop();
    void calculateControlLeftBottom();

signals:
    void resolutionChanged(QPoint tess);

    void topLeftChanged(QPointF p);
    void topRightChanged(QPointF p);
    void bottomLeftChanged(QPointF p);
    void bottomRightChanged(QPointF p);

    void controlTopLeftChanged(QPointF p);
    void controlTopRightChanged(QPointF p);
    void controlBottomLeftChanged(QPointF p);
    void controlBottomRightChanged(QPointF p);

    void controlLeftTopChanged(QPointF p);
    void controlLeftBottomChanged(QPointF p);
    void controlRightTopChanged(QPointF p);
    void controlRightBottomChanged(QPointF p);

private:
    QPoint m_resolution;

    QPointF m_topLeft, m_topRight, m_bottomLeft, m_bottomRight;
    QPointF m_controlTopLeft, m_controlTopRight, m_controlBottomLeft, m_controlBottomRight;
    QPointF m_controlLeftTop, m_controlLeftBottom, m_controlRightTop, m_controlRightBottom;
};

class BeziergonShaderAspect {
public:
    void updateState(QOpenGLShaderProgram* program, BeziergonState *state);
    void initialize(QOpenGLShaderProgram* program);

private:
    int id_topLeft, id_topRight, id_bottomLeft, id_bottomRight;
    int id_controlTopLeft, id_controlTopRight, id_controlBottomLeft, id_controlBottomRight;
    int id_controlLeftTop, id_controlLeftBottom, id_controlRightTop, id_controlRightBottom;
};


class SolidBeziergonShader
    : public SolidShader
    , public BeziergonShaderAspect
{
    friend class SolidBeziergonMaterial;
    public:
    SolidBeziergonShader();
    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial);
    void initialize() Q_DECL_OVERRIDE;

private:
    static QSGMaterialType type;
};

class SampledBeziergonShader
    : public SampledShader
    , public BeziergonShaderAspect
{
    friend class SampledBeziergonMaterial;
public:
    SampledBeziergonShader();

    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;

    void initialize() Q_DECL_OVERRIDE;
private:
    static QSGMaterialType type;
};

class SimpleSampledBeziergonShader
    : public SimpleSampledShader
    , public BeziergonShaderAspect
{
    friend class SimpleSampledBeziergonMaterial;
public:
    SimpleSampledBeziergonShader();

    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;

    void initialize() Q_DECL_OVERRIDE;
private:
    static QSGMaterialType type;
};

} // namespace
#endif
