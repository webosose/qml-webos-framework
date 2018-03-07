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

#ifndef MATERIAL_H
#define MATERIAL_H
#include <QColor>
#include <QSGMaterialShader>

class QSGTextureProvider;

namespace SamplerGeometry {

class SolidShader: public virtual QSGMaterialShader {
public:
    SolidShader();

    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;

    char const *const *attributeNames() const Q_DECL_OVERRIDE;
    void initialize() Q_DECL_OVERRIDE;
    int id_color;
    int id_matrix;
    int id_opacity;
    static QSGMaterialType type;
    static const char* attribs[];
};

class SampledShader: public SolidShader {
public:
    SampledShader();
    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) Q_DECL_OVERRIDE;
    void initialize() Q_DECL_OVERRIDE;
    int id_dest;
    int id_texture;
    int id_sourceSubRect; //FIXME
    int id_rotation;
    int id_xScale;
    int id_yScale;

    static QSGMaterialType type;
};

class SolidMaterial: public QSGMaterial {
    friend class SolidShader;
public:
    explicit SolidMaterial();
    virtual ~SolidMaterial();
    virtual QSGMaterialType *type() const Q_DECL_OVERRIDE;
    virtual int compare(const QSGMaterial *other) const Q_DECL_OVERRIDE;
    virtual QSGMaterialShader *createShader() const Q_DECL_OVERRIDE;

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
    virtual QSGMaterialShader *createShader() const Q_DECL_OVERRIDE;

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
    virtual QSGMaterialShader *createShader() const Q_DECL_OVERRIDE;
};

} //namespace SamplerGeometry

#endif /* MATERIAL_H */
