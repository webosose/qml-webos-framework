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

#include "beziergon.h"

#include <QtQuick/qsgnode.h>
#include <QQuickWindow>
#include "material.h"

namespace SamplerGeometry {
//

QSGMaterialType SolidBeziergonShader::type;
QSGMaterialType SampledBeziergonShader::type;
QSGMaterialType SimpleSampledBeziergonShader::type;

class SolidBeziergonMaterial
    : public BeziergonState
    , public SolidMaterial
{
public:
    virtual QSGMaterialType *type() const override {
        return &SolidBeziergonShader::type;
    };
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override
#else
    virtual QSGMaterialShader *createShader() const override
#endif
    {
        return new SolidBeziergonShader();
    };
};

class SampledBeziergonMaterial
    : public BeziergonState
    , public SampledMaterial
{
public:
    virtual QSGMaterialType *type() const override {
    return &SampledBeziergonShader::type;
    };
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override
#else
    virtual QSGMaterialShader *createShader() const override
#endif
    {
        return new SampledBeziergonShader();
    };
};

class SimpleSampledBeziergonMaterial
    : public BeziergonState
    , public SimpleSampledMaterial
{
public:
    virtual QSGMaterialType *type() const override {
    return &SimpleSampledBeziergonShader::type;
    };
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override
#else
    virtual QSGMaterialShader *createShader() const override
#endif
    {
        return new SimpleSampledBeziergonShader();
    };
};

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
void BeziergonShaderAspect::updateState(UniformWriter &uniformWriter, BeziergonState *state) {
    uniformWriter.write(state->m_topLeft);
    uniformWriter.write(state->m_topRight);
    uniformWriter.write(state->m_bottomLeft);
    uniformWriter.write(state->m_bottomRight);
    uniformWriter.write(state->m_controlTopLeft);
    uniformWriter.write(state->m_controlTopRight);
    uniformWriter.write(state->m_controlBottomLeft);
    uniformWriter.write(state->m_controlBottomRight);
    uniformWriter.write(state->m_controlLeftTop);
    uniformWriter.write(state->m_controlLeftBottom);
    uniformWriter.write(state->m_controlRightTop);
    uniformWriter.write(state->m_controlRightBottom);
}

SolidBeziergonShader::SolidBeziergonShader() {
    setShaderFileName(VertexStage, QStringLiteral(":bezier.vert"));
    // fragment shader from parent constructor
}

void SolidBeziergonShader::updateUniformBlock(UniformWriter &uniformWriter) {
    SolidShader::updateUniformBlock(uniformWriter);
    BeziergonShaderAspect::updateState(uniformWriter, static_cast<SolidBeziergonMaterial*>(uniformWriter.newMaterial));
}

SampledBeziergonShader::SampledBeziergonShader() {
    setShaderFileName(VertexStage, QStringLiteral(":bezier.vert"));
    // fragment shader from parent constructor
}

void SampledBeziergonShader::updateUniformBlock(UniformWriter &uniformWriter) {
    SampledShader::updateUniformBlock(uniformWriter);
    BeziergonShaderAspect::updateState(uniformWriter, static_cast<SampledBeziergonMaterial*>(uniformWriter.newMaterial));
}
#else
void BeziergonShaderAspect::updateState(QOpenGLShaderProgram* program, BeziergonState *state) {
    program->setUniformValue(id_topLeft, state->m_topLeft);
    program->setUniformValue(id_topRight, state->m_topRight);
    program->setUniformValue(id_bottomLeft, state->m_bottomLeft);
    program->setUniformValue(id_bottomRight, state->m_bottomRight);
    program->setUniformValue(id_controlTopLeft, state->m_controlTopLeft);
    program->setUniformValue(id_controlTopRight, state->m_controlTopRight);
    program->setUniformValue(id_controlBottomLeft, state->m_controlBottomLeft);
    program->setUniformValue(id_controlBottomRight, state->m_controlBottomRight);
    program->setUniformValue(id_controlLeftTop, state->m_controlLeftTop);
    program->setUniformValue(id_controlLeftBottom, state->m_controlLeftBottom);
    program->setUniformValue(id_controlRightTop, state->m_controlRightTop);
    program->setUniformValue(id_controlRightBottom, state->m_controlRightBottom);
}

void BeziergonShaderAspect::initialize(QOpenGLShaderProgram* program) {
    id_topLeft = program->uniformLocation("topLeft");
    id_topRight = program->uniformLocation("topRight");
    id_bottomLeft = program->uniformLocation("bottomLeft");
    id_bottomRight = program->uniformLocation("bottomRight");
    id_controlTopLeft = program->uniformLocation("controlTopLeft");
    id_controlTopRight = program->uniformLocation("controlTopRight");
    id_controlBottomLeft = program->uniformLocation("controlBottomLeft");
    id_controlBottomRight = program->uniformLocation("controlBottomRight");
    id_controlLeftTop = program->uniformLocation("controlLeftTop");
    id_controlLeftBottom = program->uniformLocation("controlLeftBottom");
    id_controlRightTop = program->uniformLocation("controlRightTop");
    id_controlRightBottom = program->uniformLocation("controlRightBottom");
    Q_ASSERT(
               id_topLeft != -1
            && id_topRight != -1
            && id_bottomLeft != -1
            && id_bottomRight != -1
            && id_controlTopLeft != -1
            && id_controlTopRight != -1
            && id_controlBottomLeft != -1
            && id_controlBottomRight != -1
            && id_controlLeftTop != -1
            && id_controlLeftBottom != -1
            && id_controlRightTop != -1
            && id_controlRightBottom != -1
            );
}

SolidBeziergonShader::SolidBeziergonShader() {
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":bezier.vert"));
    // fragment shader from parent constructor
}

void SolidBeziergonShader::updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) {
    SolidShader::updateState(state, newMaterial, oldMaterial);
    BeziergonShaderAspect::updateState(program(), static_cast<SolidBeziergonMaterial*>(newMaterial));
}

void SolidBeziergonShader::initialize() {
    SolidShader::initialize();
    BeziergonShaderAspect::initialize(program());
}

SampledBeziergonShader::SampledBeziergonShader() {
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":bezier.vert"));
    // fragment shader from parent constructor
}

void SampledBeziergonShader::updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) {
    SampledShader::updateState(state, newMaterial, oldMaterial);
    BeziergonShaderAspect::updateState(program(), static_cast<SampledBeziergonMaterial*>(newMaterial));
}

void SampledBeziergonShader::initialize() {
    SampledShader::initialize();
    BeziergonShaderAspect::initialize(program());
}
#endif

/*
 * faster shader
 */

SimpleSampledBeziergonShader::SimpleSampledBeziergonShader() {
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    setShaderFileName(VertexStage, QStringLiteral(":bezier.vert"));
#else
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":bezier.vert"));
#endif
    // fragment shader from parent constructor
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
void SimpleSampledBeziergonShader::updateUniformBlock(UniformWriter &uniformWriter) {
    SimpleSampledShader::updateUniformBlock(uniformWriter);
    BeziergonShaderAspect::updateState(uniformWriter, static_cast<SampledBeziergonMaterial*>(uniformWriter.newMaterial));
}
#else
void SimpleSampledBeziergonShader::updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) {
    SimpleSampledShader::updateState(state, newMaterial, oldMaterial);
    BeziergonShaderAspect::updateState(program(), static_cast<SampledBeziergonMaterial*>(newMaterial));
}

void SimpleSampledBeziergonShader::initialize() {
    SimpleSampledShader::initialize();
    BeziergonShaderAspect::initialize(program());
}
#endif

Beziergon::Beziergon(QQuickItem *parent)
    : Item(parent)
    , m_resolution(QPoint(4,4))
{
    connect(this, SIGNAL(widthChanged()), this, SLOT(calculateTopRight()));
    connect(this, SIGNAL(widthChanged()), this, SLOT(calculateBottomRight()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(calculateBottomLeft()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(calculateBottomRight()));

    // calculate default values for control points
    // these get disconnected when a setter has been called on the property
    // so after being set once, they don't work anymore.
    connect(this, SIGNAL(topLeftChanged(QPointF)), this, SLOT(calculateControlTopRight()));
    connect(this, SIGNAL(topLeftChanged(QPointF)), this, SLOT(calculateControlTopLeft()));
    connect(this, SIGNAL(topLeftChanged(QPointF)), this, SLOT(calculateControlLeftTop()));
    connect(this, SIGNAL(topLeftChanged(QPointF)), this, SLOT(calculateControlLeftBottom()));

    connect(this, SIGNAL(topRightChanged(QPointF)), this, SLOT(calculateControlTopRight()));
    connect(this, SIGNAL(topRightChanged(QPointF)), this, SLOT(calculateControlTopLeft()));
    connect(this, SIGNAL(topRightChanged(QPointF)), this, SLOT(calculateControlRightTop()));
    connect(this, SIGNAL(topRightChanged(QPointF)), this, SLOT(calculateControlRightBottom()));

    connect(this, SIGNAL(bottomLeftChanged(QPointF)), this, SLOT(calculateControlBottomRight()));
    connect(this, SIGNAL(bottomLeftChanged(QPointF)), this, SLOT(calculateControlBottomLeft()));
    connect(this, SIGNAL(bottomLeftChanged(QPointF)), this, SLOT(calculateControlLeftTop()));
    connect(this, SIGNAL(bottomLeftChanged(QPointF)), this, SLOT(calculateControlLeftBottom()));

    connect(this, SIGNAL(bottomRightChanged(QPointF)), this, SLOT(calculateControlBottomRight()));
    connect(this, SIGNAL(bottomRightChanged(QPointF)), this, SLOT(calculateControlBottomLeft()));
    connect(this, SIGNAL(bottomRightChanged(QPointF)), this, SLOT(calculateControlRightTop()));
    connect(this, SIGNAL(bottomRightChanged(QPointF)), this, SLOT(calculateControlRightBottom()));

    connect(this, SIGNAL(controlTopLeftChanged(QPointF)),    this, SLOT(calculateControlTopRight()));
    connect(this, SIGNAL(controlBottomLeftChanged(QPointF)), this, SLOT(calculateControlBottomRight()));
    connect(this, SIGNAL(controlLeftTopChanged(QPointF)),    this, SLOT(calculateControlLeftBottom()));
    connect(this, SIGNAL(controlRightTopChanged(QPointF)),   this, SLOT(calculateControlRightBottom()));
}

Beziergon::~Beziergon()
{
}

void Beziergon::updateBeziergonState(BeziergonState* state) {
    state->m_topLeft = m_topLeft;
    state->m_topRight = m_topRight;
    state->m_bottomLeft = m_bottomLeft;
    state->m_bottomRight = m_bottomRight;
    state->m_controlTopLeft = m_controlTopLeft;
    state->m_controlTopRight = m_controlTopRight;
    state->m_controlBottomLeft = m_controlBottomLeft;
    state->m_controlBottomRight = m_controlBottomRight;
    state->m_controlLeftTop = m_controlLeftTop;
    state->m_controlLeftBottom = m_controlLeftBottom;
    state->m_controlRightTop = m_controlRightTop;
    state->m_controlRightBottom = m_controlRightBottom;
}

void Beziergon::updateSolidMaterial(GeometryNode* node) {
    Item::updateSolidMaterial(node);
    updateBeziergonState(static_cast<SolidBeziergonMaterial*>(node->solidMaterial()));
}

void Beziergon::updateSampledMaterial(GeometryNode* node) {
    Item::updateSampledMaterial(node);
    updateBeziergonState(static_cast<SampledBeziergonMaterial*>(node->sampledMaterial()));
}

SolidMaterial* Beziergon::createSolidMaterial() {
    return new SolidBeziergonMaterial();
}

SampledMaterial* Beziergon::createSampledMaterial() {
    // if the dest rect is bigger than the screen, we can safely use the faster shader.
    // TODO another optimization is if all control points lie within the dest rect, but
    // it is more complex to update all the time, as we usually animate these.
    if (m_dest.contains(QRectF(QPoint(0,0), window()->size())) || m_clampToEdge)
        return new SimpleSampledBeziergonMaterial();
    else
        return new SampledBeziergonMaterial();
}

QSGGeometry* Beziergon::generateBodyGeometry(QSGGeometry* old) {
    QSGGeometry* geometry = old;
    /*    resolution 0,0
     *    at least: 1 center quad
     *    0--1
     *    | /|
     *    |/ |
     *    2--3
     *
     *    resolution 2,2
     *    0--1--2--3
     *    | /| /| /|
     *    |/ |/ |/ |
     *    4--5--6--7
     *    | /| /| /|
     *    |/ |/ |/ |
     *    8--9--10-11
     *    | /| /| /|
     *    |/ |/ |/ |
     *    12-13-14-15
     */

    // at least two vertices in each direction
    int xVertices = 2 + m_resolution.x();
    int yVertices = 2 + m_resolution.y();
    int vertexCount = xVertices * yVertices;
    int numTriangles = (xVertices - 1) * (yVertices - 1) * 2;
    int indexCount = numTriangles * 3;

    if(!geometry) {
        geometry = new QSGGeometry(meshAttributes(), vertexCount, indexCount);
        geometry->setDrawingMode(GL_TRIANGLES);
    } else {
        geometry->allocate(vertexCount, indexCount);
    }

    Vertex* vertex = (Vertex*) geometry->vertexData();
    quint16* index = geometry->indexDataAsUShort();
    int vindex = 0;
    int iindex = 0;
    for(int y = 0; y < yVertices; y++) {
        for(int x = 0; x < xVertices; x++) {
            float vx = float(x) / float(xVertices - 1); // range 0.0 - 1.0
            float vy = float(y) / float(yVertices - 1); // range 0.0 - 1.0
            float coverage = 1.0;

            float xoff = 0.0f;
            float yoff = 0.0f;
            if(antialiasing()) {
                if (x == 0)
                    xoff = 1.0f;
                else if (x == xVertices-1)
                    xoff = -1.0f;

                if (y == 0)
                    yoff = 1.0f;
                else if (y == yVertices-1)
                    yoff = -1.0f;
            }

            vertex[vindex++].set(vx, vy, xoff, yoff, coverage);
            // generate triangles
            if (y < yVertices - 1 && x < xVertices - 1) {
                index[iindex++] =  y      * xVertices + x;
                index[iindex++] =  y      * xVertices + x + 1;
                index[iindex++] = (y + 1) * xVertices + x;

                index[iindex++] = (y + 1) * xVertices + x;
                index[iindex++] = (y + 1) * xVertices + x + 1;
                index[iindex++] =  y      * xVertices + x + 1;
            }
        }
    }
    Q_ASSERT(vindex == vertexCount);
    Q_ASSERT(iindex == indexCount);
    return geometry;
}


QSGGeometry* Beziergon::generateFringeGeometry(QSGGeometry* old) {
    QSGGeometry* geometry = old;
    /*    0--2--4--6
     *    | /| /| /|
     *    |/ |/ |/ |
     *    1--3--5--7
     *
     *    16-17  20-21
     *    | /|   | /|
     *    |/ |   |/ |
     *    18-19  22-23
     *
     *    8--10-12-14
     *    | /| /| /|
     *    |/ |/ |/ |
     *    9--11-13-15
     */

    int vertexCount = 2 * (6 + 2 * m_resolution.x())
                    + 2 * (6 + 2 * m_resolution.y());

    int numTriangles = 2 * (6 + 2 * m_resolution.x())
                     + 2 * (2 + 2 * m_resolution.y());
    int indexCount = numTriangles * 3;
    if(!geometry) {
        geometry = new QSGGeometry(meshAttributes(), vertexCount, indexCount);
        geometry->setDrawingMode(GL_TRIANGLES);
    } else {
        geometry->allocate(vertexCount, indexCount);
    }

    Vertex* vertex = (Vertex*) geometry->vertexData();
    quint16* index = geometry->indexDataAsUShort();
    int iindex = 0;
    int vindex = 0;

    printf("\n");
    float vx, vy;

    // top (y==0) and bottom(y==1) edges, each looking like this:
    //-.5 +.5       -.5 +.5
    // o---o---...---o---o -.5
    // |   |         |   |
    // o---o---...---o---o +.5
    for(int y = 0; y < 2; y++) {
        vx = 0.0f;
        vy = y;
        float alpha0 = y == 0 ? 0.0f : 1.0f;
        float alpha1 = 1.0f - alpha0;
        
        // 0--2-
        // |  |  the left end of the strip
        // 1--3-
        vertex[vindex++].set(vx, vy, -1.0f, -1.0f, 0.0f);
        vertex[vindex++].set(vx, vy, -1.0f,  1.0f, 0.0f);
        vertex[vindex++].set(vx, vy,  1.0f, -1.0f, alpha0);
        vertex[vindex++].set(vx, vy,  1.0f,  1.0f, alpha1);
        for(int x = 0; x < m_resolution.x(); x++) {
            vx = float (x + 1) / float( m_resolution.x()+1);
            vertex[vindex++].set(vx, vy, 0.0f, -1.0f, alpha0);
            vertex[vindex++].set(vx, vy, 0.0f,  1.0f, alpha1);
        }
        vx = 1.0f;
        // -0--2
        //  |  |  the right end of the strip
        // -1--3
        vertex[vindex++].set(vx, vy, -1.0f, -1.0f, alpha0);
        vertex[vindex++].set(vx, vy, -1.0f,  1.0f, alpha1);
        vertex[vindex++].set(vx, vy,  1.0f, -1.0f, 0.0f);
        vertex[vindex++].set(vx, vy,  1.0f,  1.0f, 0.0f);
        int base = y * 2 * (m_resolution.x() + 4);
        for(int x = 0; x < m_resolution.x() + 3; x++) {
            index[iindex++] = base + (x*2);
            index[iindex++] = base + (x*2)+2;
            index[iindex++] = base + (x*2)+1;
            index[iindex++] = base + (x*2)+1;
            index[iindex++] = base + (x*2)+2;
            index[iindex++] = base + (x*2)+3;
        }

    }
    // left (x==0) and right (x==1) edges
    for(int x = 0; x < 2; x++) {
        vx = x;
        vy = 0.0f;
        float alpha0 = x == 0 ? 0.0f : 1.0f;
        float alpha1 = 1.0f - alpha0;
        // 0---1 top end of strip
        // |   |
        vertex[vindex++].set(vx, vy, -1.0f,  1.0f, alpha0);
        vertex[vindex++].set(vx, vy,  1.0f,  1.0f, alpha1);
        for(int y = 0; y < m_resolution.y(); y++) {
            vy = float (y + 1) / float( m_resolution.y() + 1);
            vertex[vindex++].set(vx, vy, -1.0f,  0.0f, alpha0);
            vertex[vindex++].set(vx, vy,  1.0f,  0.0f, alpha1);
        }
        // |   | bottom end of strip
        // 0---1
        vy = 1.0f;
        vertex[vindex++].set(vx, vy, -1.0f, -1.0f, alpha0);
        vertex[vindex++].set(vx, vy,  1.0f, -1.0f, alpha1);
        int base = 4 * (m_resolution.x() + 4)
                 + x * (4 + m_resolution.y() * 2);
        for(int y = 0; y < m_resolution.y() + 1; y++) {
            index[iindex++] = base + (y*2);
            index[iindex++] = base + (y*2)+2;
            index[iindex++] = base + (y*2)+1;
            index[iindex++] = base + (y*2)+1;
            index[iindex++] = base + (y*2)+2;
            index[iindex++] = base + (y*2)+3;
        }
    }

    Q_ASSERT(iindex == indexCount);
    Q_ASSERT(vindex == vertexCount);
    return geometry;
}

SETTER(Beziergon, QPoint, resolution, Resolution, geometry)

SETTERTRISTATE(Beziergon, QPointF, topLeft, TopLeft, material, QPointF(0, 0))
SETTERTRISTATE(Beziergon, QPointF, topRight, TopRight, material, QPointF(width(), 0))
SETTERTRISTATE(Beziergon, QPointF, bottomLeft, BottomLeft, material, QPointF(0, height()))
SETTERTRISTATE(Beziergon, QPointF, bottomRight, BottomRight, material, QPointF(width(), height()))

SETTERTRISTATE(Beziergon, QPointF, controlTopLeft, ControlTopLeft, material,           (m_topLeft + m_topRight) * 0.5f)
SETTERTRISTATE(Beziergon, QPointF, controlTopRight, ControlTopRight, material,         m_controlTopLeft)
SETTERTRISTATE(Beziergon, QPointF, controlBottomLeft, ControlBottomLeft, material,     (m_bottomLeft + m_bottomRight) * 0.5f)
SETTERTRISTATE(Beziergon, QPointF, controlBottomRight, ControlBottomRight, material,   m_controlBottomLeft)

SETTERTRISTATE(Beziergon, QPointF, controlLeftTop, ControlLeftTop, material,           (m_topLeft + m_bottomLeft) * 0.5f)
SETTERTRISTATE(Beziergon, QPointF, controlLeftBottom, ControlLeftBottom, material,     m_controlLeftTop)
SETTERTRISTATE(Beziergon, QPointF, controlRightTop, ControlRightTop, material,         (m_topRight + m_bottomRight) * 0.5f)
SETTERTRISTATE(Beziergon, QPointF, controlRightBottom, ControlRightBottom, material,   m_controlRightTop)

} //namespace
