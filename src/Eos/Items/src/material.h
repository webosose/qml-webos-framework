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
#include <vector>
#endif

class QSGTextureProvider;

namespace SamplerGeometry {

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
struct UniformWriter
{
    UniformWriter(QSGMaterialShader::RenderState &state, QSGMaterial *newMat, QSGMaterial *oldMat)
        : newMaterial(newMat), oldMaterial(oldMat)
    {
        QByteArray *buf = state.uniformData();
        m_buf = buf->data();
        m_offset = 0;
        m_size = buf->size();
    }

    void write(const QVector4D &v)
    {
        align(4*sizeof(GLfloat));
        writeFloats(v, 4);
    }

    void write(GLfloat f)
    {
        writeFloat(f);
    }

    void write(GLint f)
    {
        writeData(&f, sizeof(GLint));
    }

    void write(const QPointF &value)
    {
        align(2*sizeof(GLfloat));
        writeFloat(value.x());writeFloat(value.y());
    }

    void write(const QMatrix4x4 &m)
    {
        align(4*sizeof(GLfloat));
        writeData(m.constData(), 64);
    }

    QSGMaterial *newMaterial = nullptr, *oldMaterial = nullptr;
    char *m_buf = nullptr;
    size_t m_offset = 0, m_size = 0;

private:

    void align(size_t n)
    {
        m_offset += n - 1;
        m_offset -= m_offset%n;
    }

    void writeData(const void* data, size_t size)
    {
        if ((m_offset + size) > m_size) {
            qWarning("Not enough space to store uniform in Uniform block, maximum %lu, used %lu, asked %lu", m_size, m_offset, size);
            return;
        }
        memcpy(m_buf + m_offset, data, size);
        m_offset += size;
    }

    template<typename T> void writeFloats(const T &value, unsigned int n)
    {
        for(unsigned int i = 0; i < n; ++i)
               writeFloat(value[i]);
    }

    void writeFloat(GLfloat f)
    {
        writeData(&f, sizeof(GLfloat));
    }

};
#endif

class SolidShader: public virtual QSGMaterialShader {
public:
    SolidShader();

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual void updateUniformBlock(UniformWriter &uniformWriter);

    bool updateUniformData(QSGMaterialShader::RenderState &state,
                           QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;

    void updateSampledImage(QSGMaterialShader::RenderState &state,
                            int binding, QSGTexture **texture, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;

    void setShaderFileName(QSGMaterialShader::Stage stage, const QString &filename)
    {
        if (stage == VertexStage)
            m_debugVertexShaderName = filename;
        else
            m_debugFragmentShaderName = filename;
        QSGMaterialShader::setShaderFileName(stage, filename);
    }
#else
    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;

    char const *const *attributeNames() const override;
    void initialize() override;
    int id_color = 0;
    int id_matrix = 0;
    int id_opacity = 0;
#endif
    static QSGMaterialType type;
    static const char* attribs[];

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
private:
    QString m_debugVertexShaderName;
    QString m_debugFragmentShaderName;
#endif
};

class SampledShader: public SolidShader {
public:
    SampledShader();
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual void updateUniformBlock(UniformWriter &uniformWriter) override;
#else
    void updateState(const RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
    void initialize() override;
    int id_dest = 0;
    int id_texture = 0;
    int id_sourceSubRect = 0; //FIXME
    int id_rotation = 0;
    int id_xScale = 0;
    int id_yScale = 0;
#endif
    static QSGMaterialType type;
};

class SolidMaterial: public QSGMaterial
{
    friend class SolidShader;
public:
    explicit SolidMaterial();
    virtual ~SolidMaterial();

    virtual QSGMaterialType *type() const override;
    virtual int compare(const QSGMaterial *other) const override;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    struct Uniforms
    {
        QVector4D dest;
        QVector4D sourceSubRect;
        QVector4D color;
        int rotation;
        float xScale;
        float yScale;
    } m_baseUniforms;

    virtual QSGTextureProvider* textureProvider()
    {
        return nullptr;
    }

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

    virtual QSGMaterialType *type() const override;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override;

    QSGTextureProvider* textureProvider() override
#else
    virtual QSGMaterialShader *createShader() const override;

    QSGTextureProvider* textureProvider()
#endif
    {
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

    virtual QSGMaterialType *type() const override;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    virtual QSGMaterialShader *createShader(QSGRendererInterface::RenderMode renderMode) const override;
#else
    virtual QSGMaterialShader *createShader() const override;
#endif
};

} //namespace SamplerGeometry

#endif /* MATERIAL_H */
