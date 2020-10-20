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

#ifndef MATERIAL_H
#define MATERIAL_H
#include <QColor>
#include <QSGMaterial>
#include <QSGMaterialShader>
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <qopengl.h>
#endif

class QSGTextureProvider;

namespace SamplerGeometry {

class SolidShader: public virtual QSGMaterialShader {
public:
    SolidShader();

    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;

    char const *const *attributeNames() const Q_DECL_OVERRIDE;
    void initialize() Q_DECL_OVERRIDE;
    int id_color = 0;
    int id_matrix = 0;
    int id_opacity = 0;
    static QSGMaterialType type;
    static const char* attribs[];
};

class SampledShader: public SolidShader {
public:
    SampledShader();
    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;
    void initialize() Q_DECL_OVERRIDE;
    int id_dest = 0;
    int id_texture = 0;
    int id_sourceSubRect = 0; //FIXME
    int id_rotation = 0;
    int id_xScale = 0;
    int id_yScale = 0;

    static QSGMaterialType type;
};

class SolidMaterial: public QSGMaterial {
    friend class SolidShader;
public:
    explicit SolidMaterial();
    virtual ~SolidMaterial();

    virtual QSGMaterialType *type() const Q_DECL_OVERRIDE;
    virtual int compare(const QSGMaterial *other) const Q_DECL_OVERRIDE;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override;
#else
    virtual QSGMaterialShader *createShader() const override;
#endif
    //protected: //used by Item updateMaterial..?
    QColor m_color;
private:
};

class SampledMaterial: public SolidMaterial {
    friend class SampledShader;
public:
    explicit SampledMaterial();
    virtual ~SampledMaterial();
    void updateTextureProvider() const;

    virtual QSGMaterialType *type() const Q_DECL_OVERRIDE;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override;
#else
    virtual QSGMaterialShader *createShader() const override;
#endif

    QSGTextureProvider* textureProvider() {
        return m_textureProvider;
    }
    void invalidateTextureProvider() {
        m_textureProvider = nullptr;
    }
    //protected: //used by Item updateMaterial..?
    QRectF m_dest;
    GLint m_rotation = 0;
    GLfloat m_xScale = 1.0;
    GLfloat m_yScale = 1.0;
    QSGTextureProvider* m_textureProvider;
};

// this is a faster version that does not check fragments for lying
// outside the dest rectangle. It should be used when dest is the
// default value or if dest is bigger than the item.

class SimpleSampledShader: public SampledShader {
public:
    SimpleSampledShader();
    static QSGMaterialType type;
};

class SimpleSampledMaterial: public SampledMaterial {
    friend class SampledShader;
public:
    explicit SimpleSampledMaterial();
    virtual ~SimpleSampledMaterial();

    virtual QSGMaterialType *type() const Q_DECL_OVERRIDE;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override;
#else
    virtual QSGMaterialShader *createShader() const override;
#endif
};

} //namespace SamplerGeometry

#endif /* MATERIAL_H */
