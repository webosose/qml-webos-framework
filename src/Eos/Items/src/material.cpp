// Copyright (c) 2015-2021 LG Electronics, Inc.
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

#include "material.h"
#include <QtQuick/private/qsgmaterialshader_p.h>
#include <QSGDynamicTexture>
#include <QSGTextureProvider>
#include <QDebug>
#include <QOpenGLFunctions>
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QOpenGLShaderProgram>
#endif

namespace SamplerGeometry {

QSGMaterialType SolidShader::type;
QSGMaterialType SampledShader::type;
QSGMaterialType SimpleSampledShader::type;

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
SolidShader::SolidShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate(this))
#else
SolidShader::SolidShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate)
#endif
{
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":parallelogram.vert"));
    setShaderSourceFile(QOpenGLShader::Fragment, QStringLiteral(":solid.frag"));
}

void SolidShader::updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial)  {
    Q_UNUSED(oldMaterial);
    if (state.isMatrixDirty())
        program()->setUniformValue(id_matrix, state.combinedMatrix());
    if (state.isOpacityDirty() && id_opacity >= 0)
        program()->setUniformValue(id_opacity, state.opacity());

    SolidMaterial* mat = static_cast<SolidMaterial*>(newMaterial);

    const QColor& c = mat->m_color;
    QVector4D v(c.redF() * c.alphaF(),
                c.greenF() * c.alphaF(),
                c.blueF() * c.alphaF(),
                c.alphaF());

    program()->setUniformValue(id_color, v);
};

const char* SolidShader::attribs[] = {"vertex", "texture0", "coverage", nullptr};
char const *const * SolidShader::attributeNames() const {
    return attribs;
}

void SolidShader::initialize()  {
    QSGMaterialShader::initialize();
    id_matrix = program()->uniformLocation("qt_Matrix");
    id_opacity = program()->uniformLocation("qt_Opacity");
    id_color = program()->uniformLocation("color");
    Q_ASSERT(id_matrix != -1);
    Q_ASSERT(id_opacity != -1);
    Q_ASSERT(id_color != -1);
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
SampledShader::SampledShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate(this))
#else
SampledShader::SampledShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate)
#endif
{
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":parallelogram.vert"));
    QStringList frag;
    if(qEnvironmentVariableIsSet("QWF_DEBUG_SHADERS")) frag << QStringLiteral(":debug.frag");
    frag << QStringLiteral(":sampler-dest.frag");
    setShaderSourceFiles(QOpenGLShader::Fragment, frag);
}

void SampledShader::updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial)  {
    Q_UNUSED(state);
    Q_UNUSED(oldMaterial);
    SolidShader::updateState(state, newMaterial, oldMaterial);
    SampledMaterial* mat = static_cast<SampledMaterial*>(newMaterial);
    QVector4D dest(mat->m_dest.x(),mat->m_dest.y(), mat->m_dest.width(), mat->m_dest.height());
    program()->setUniformValue(id_dest, dest);
    int idx = 0;
    QOpenGLFunctions glFuncs(QOpenGLContext::currentContext());
    glFuncs.glActiveTexture(GL_TEXTURE0 + idx);
    QSGTextureProvider* tp = mat->textureProvider();
    if (tp) {
        QSGTexture *texture = tp->texture();
        if (texture) {
            texture->bind();
            // should be fine for the non-clamp case as it is clamped in the shader
            texture->setVerticalWrapMode(QSGTexture::ClampToEdge);
            texture->setHorizontalWrapMode(QSGTexture::ClampToEdge);
            program()->setUniformValue(id_texture, idx);
            QRectF r = texture->normalizedTextureSubRect();
            program()->setUniformValue(id_sourceSubRect, QVector4D(r.x(), r.y(), r.width(), r.height() ));

            program()->setUniformValue(id_rotation, mat->m_rotation);
            program()->setUniformValue(id_xScale, mat->m_xScale);
            program()->setUniformValue(id_yScale, mat->m_yScale);
        } else {
            qDebug()<<"NO texture from provider!";
        }
    } else {
        qDebug()<<"NO textureProvider!";
    }
}

void SampledShader::initialize()  {
    SolidShader::initialize();
    id_texture = program()->uniformLocation("source");
    id_dest = program()->uniformLocation("dest");
    id_sourceSubRect = program()->uniformLocation("sourceSubRect");

    id_rotation = program()->uniformLocation("rotation");
    id_xScale = program()->uniformLocation("xScale");
    id_yScale = program()->uniformLocation("yScale");

    Q_ASSERT(id_texture != -1);
    Q_ASSERT(id_dest!= -1);
    Q_ASSERT(id_sourceSubRect != -1);

    Q_ASSERT(id_rotation != -1);
    Q_ASSERT(id_xScale != -1);
    Q_ASSERT(id_yScale != -1);
}

SolidMaterial::SolidMaterial() {
}

SolidMaterial::~SolidMaterial() {
}

QSGMaterialType *SolidMaterial::type() const {
    return &SolidShader::type;;
}

int SolidMaterial::compare(const QSGMaterial *other) const {
    return this - dynamic_cast<const SolidMaterial *>(other);
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
QSGMaterialShader *SolidMaterial::createShader(QSGRendererInterface::RenderMode renderMode) const
#else
QSGMaterialShader *SolidMaterial::createShader() const
#endif
{
    return new SolidShader();
}

SampledMaterial::SampledMaterial()
        : SolidMaterial()
        , m_textureProvider(nullptr) {
}

SampledMaterial::~SampledMaterial() {
}

void SampledMaterial::updateTextureProvider() const {
    if (QSGDynamicTexture *texture = qobject_cast<QSGDynamicTexture *>(m_textureProvider->texture()))
        texture->updateTexture();
}

QSGMaterialType *SampledMaterial::type() const {
    return &SampledShader::type;
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
QSGMaterialShader *SampledMaterial::createShader(QSGRendererInterface::RenderMode renderMode) const
#else
QSGMaterialShader *SampledMaterial::createShader() const
#endif
{
    return new SampledShader();
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
SimpleSampledShader::SimpleSampledShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate(this))
#else
SimpleSampledShader::SimpleSampledShader(): QSGMaterialShader(*new QSGMaterialShaderPrivate)
#endif
{
    setShaderSourceFile(QOpenGLShader::Vertex, QStringLiteral(":parallelogram.vert"));
    QStringList frag;
    if(qEnvironmentVariableIsSet("QWF_DEBUG_SHADERS")) frag << QStringLiteral(":debug.frag");
    frag << QStringLiteral(":sampler.frag");
    setShaderSourceFiles(QOpenGLShader::Fragment, frag);
}

SimpleSampledMaterial::SimpleSampledMaterial()
        : SampledMaterial() {
}

SimpleSampledMaterial::~SimpleSampledMaterial() {
}

QSGMaterialType *SimpleSampledMaterial::type() const {
    return &SimpleSampledShader::type;
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
QSGMaterialShader *SimpleSampledMaterial::createShader(QSGRendererInterface::RenderMode renderMode) const
#else
QSGMaterialShader *SimpleSampledMaterial::createShader() const
#endif
{
    return new SimpleSampledShader();
}

}// namespace
