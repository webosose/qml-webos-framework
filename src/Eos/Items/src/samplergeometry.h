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

#ifndef SAMPLERGEOMETRY_H
#define SAMPLERGEOMETRY_H

#include <QtQuick/QQuickItem>
#include <QtQuick/private/qquickmousearea_p.h>
#include <QColor>
#include <QPoint>
#include <QtQuick/qsgnode.h>

#include "material.h"

class QSGTextureProvider;
namespace SamplerGeometry {
class ComposedNode;
class GeometryNode;

class Item: public QQuickMouseArea
{
    Q_OBJECT;
public:
    Item(QQuickItem* parent);
    ~Item();
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(bool blending READ blending WRITE setBlending NOTIFY blendingChanged)
    Q_PROPERTY(bool antialiasing READ antialiasing WRITE setAntialiasing NOTIFY antialiasingChanged)
    Q_PROPERTY(bool clampToEdge READ clampToEdge WRITE setClampToEdge NOTIFY clampToEdgeChanged)
    Q_PROPERTY(QQuickItem* sourceItem READ sourceItem WRITE setSourceItem NOTIFY sourceItemChanged)
    Q_PROPERTY(QRectF dest READ dest WRITE setDest NOTIFY destChanged)

    QColor color() const { return m_color; }
    bool blending() const { return m_blending; }
    bool antialiasing() const { return m_antialiasing; }
    bool clampToEdge() const { return m_clampToEdge; }
    QQuickItem* sourceItem() const { return m_sourceItem; }
    QRectF dest() const { return m_dest; }

    void setColor(const QColor& col);
    void setBlending(bool blending);
    void setAntialiasing(bool antialiasing);
    void setClampToEdge(bool clampToEdge);
    void setSourceItem(QQuickItem* sourceItem);
    void setDest( const QRectF& sourceItem);
signals:
    void blendingChanged(bool b);
    void antialiasingChanged(bool a);
    void clampToEdgeChanged(bool a);
    void colorChanged(QColor c);
    void sourceItemChanged(QQuickItem* sourceItem);
    void destChanged(QRectF dest);
protected slots:
    void calculateDest();
    void calculateBlending();
    void sourceItemDestroyed(QObject* obj);
    void markDirtyMaterial() { m_materialDirty = true; update(); }
    void markDirtyGeometry() { m_geometryDirty = true; update(); }

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) Q_DECL_OVERRIDE;

    virtual SolidMaterial* createSolidMaterial() = 0;
    virtual SampledMaterial* createSampledMaterial() = 0;
    virtual void updateSolidMaterial(GeometryNode* newNode);
    virtual void updateSampledMaterial(GeometryNode* newNode);
    void updateBlending(bool blending);

    virtual QSGGeometry* generateFringeGeometry(QSGGeometry* old) = 0;
    virtual QSGGeometry* generateBodyGeometry(QSGGeometry* old) = 0;
    QSGNode* updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) Q_DECL_FINAL Q_DECL_OVERRIDE;

    QColor m_color;
    bool m_blending;
    bool m_antialiasing;
    bool m_clampToEdge;
    QQuickItem* m_sourceItem;
    QRectF m_dest;

    bool m_geometryDirty;
    bool m_materialDirty;
    bool m_newMaterial;

private:
    QMetaObject::Connection m_textureChangedToItemMarkDirty;
    QMetaObject::Connection m_textureChangedToNodeMarkDirty;
    QMetaObject::Connection m_destroyedToItemMarkDirty;
    QMetaObject::Connection m_destroyedToNodeSourceDestroyed;

public:
    struct Vertex {
        float x, y;
        float tx, ty;
        float coverage;
        inline void set(float xx, float yy, float cc) {
            x = xx; y = yy;
            tx = xx; ty = yy;
            coverage = cc;
        }
        inline void set(float xx, float yy, float txx, float tyy, float cc) {
            x = xx; y = yy;
            tx = txx; ty = tyy;
            coverage = cc;
        }
    };
    static const QSGGeometry::AttributeSet &meshAttributes();
};

/*
 * A GeometryNode represents a visual part of our QuickItems. they have a sampled and solid material
 * which they decide in the rpeprocess callback to use wether a sampler source is available or not
 */
class GeometryNode
    : public QObject
    , public QSGGeometryNode
{
    Q_OBJECT
public:
    GeometryNode();
    virtual ~GeometryNode();
    virtual void preprocess() Q_DECL_OVERRIDE;
    bool sampling() const;
    void setSolidMaterial(SolidMaterial* mat);
    void setSampledMaterial(SampledMaterial* mat);
    SolidMaterial* solidMaterial() { return m_solidMaterial; }
    SampledMaterial* sampledMaterial() { return m_sampledMaterial; }

public slots:
    void markDirtyMaterial();
    void sourceProviderDestroyed(QObject* obj);
private:
    SolidMaterial* m_solidMaterial;
    SampledMaterial* m_sampledMaterial;
};

/*
 * This SceneGraph node holds the body and the fringe, so that we can use different materials
 * for each. this allows us to have the fringe blended, and the body without blending,
 * increasing render performance.
 */
class ComposedNode
    : public QSGNode
{
public:
    ComposedNode();
    virtual ~ComposedNode();
    GeometryNode* body() { return m_body; };
    GeometryNode* fringe() { return m_fringe; };
    void enableFringe();
    void disableFringe();
private:
    GeometryNode* m_body;
    GeometryNode* m_fringe;
};

#define SETTER(CLASS, type, member, Member, dirty) \
void CLASS::set##Member(const type& member)\
{ \
    if (m_##member == member) \
        return; \
    m_##member = member; \
    m_##dirty##Dirty = true; \
    emit member##Changed(m_##member); \
    update(); \
}

// this setter disconnects the default value calculation when being called.
// the calculate function below provides convenience values for the control points
// similar to QML bindings
#define SETTERTRISTATE(CLASS, type, member, Member, dirty, interpolation) \
void CLASS::set##Member(const type& member)\
{ \
    disconnect(this, 0, this, SLOT(calculate##Member())); \
    if (m_##member == member) \
        return; \
    m_##member = member; \
    m_##dirty##Dirty = true; \
    emit member##Changed(m_##member); \
    update(); \
} \
 \
void CLASS::calculate##Member() \
{ \
    m_##member = interpolation; \
    emit member##Changed(m_##member); \
}

} // namespace
#endif /* SAMPLERGEOMETRY_H */
