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

#include "samplergeometry.h"
#include <QtQuick/private/qquickitem_p.h>
#include <QtQuick/private/qsgtexture_p.h>
#include <QtQuick/qsgtextureprovider.h>
#include <QtQuick/private/qquickimage_p.h>

namespace SamplerGeometry {

Item::Item(QQuickItem* parent)
    : QQuickMouseArea(parent)
    , m_color(Qt::transparent)
    , m_blending(false)
    , m_antialiasing(true)
    , m_clampToEdge(false)
    , m_sourceItem(nullptr)
    , m_geometryDirty(false)
    , m_materialDirty(false)
    , m_newMaterial(false)
{
    setFlag(ItemHasContents, true);
    // sadly we need to use old style connect because otherwise the disconnect won't work
    connect(this, SIGNAL(widthChanged()), this, SLOT(calculateDest()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(calculateDest()));
    connect(this, SIGNAL(colorChanged(QColor)), this, SLOT(calculateBlending()));

    // by default, no mouse handling
    setEnabled(false);
}

Item::~Item() {
}

void Item::setSourceItem(QQuickItem* sourceItem) {
    if(sourceItem && !sourceItem->isTextureProvider()) {
        qWarning()<<"sourceItem item"<<sourceItem<<"is not a texture provider (Image, ShaderEffectSource or layer)!";
        sourceItem = nullptr;
    }

    if (m_sourceItem == sourceItem)
        return;
    if ((sourceItem && !m_sourceItem)
     || (m_sourceItem && !sourceItem)) {
        // switched from no sourceItem to sourceItem or back
        m_newMaterial = true;
    }

    if(m_sourceItem) {
        if (window()) QQuickItemPrivate::get(m_sourceItem)->derefWindow();
        QObject::disconnect(m_sourceItem, &QObject::destroyed, this, &Item::sourceItemDestroyed);
    }
    if (sourceItem) {
        // this comment taken from qquickshadereffect.cpp:
        // 'sourceItem' needs a window to get a scene graph node. It usually gets one through its
        // parent, but if the sourceItem item is "inline" rather than a reference -- i.e.
        // "property variant sourceItem: Image { }" instead of "property variant sourceItem: foo" -- it
        // will not get a parent. In those cases, 'sourceItem' should get the window from 'item'.
        if (window()) QQuickItemPrivate::get(sourceItem)->refWindow(window());
        QObject::connect(sourceItem, &QObject::destroyed, this, &Item::sourceItemDestroyed);
    }

    m_sourceItem = sourceItem;

    m_materialDirty = true;
    emit sourceItemChanged(m_sourceItem);
    update();
}

void Item::sourceItemDestroyed(QObject* object) {
    Q_UNUSED(object);
    setSourceItem(nullptr);
}

void Item::itemChange(ItemChange change, const ItemChangeData &value) {
    if (change == QQuickItem::ItemSceneChange) {
        if(m_sourceItem) {
            if (value.window)
                QQuickItemPrivate::get(m_sourceItem)->refWindow(value.window);
            else
                QQuickItemPrivate::get(m_sourceItem)->derefWindow();
        }
    }
    QQuickItem::itemChange(change, value);
}

void Item::setAntialiasing(bool antialiasing) {
    if(antialiasing == m_antialiasing) return;

    m_antialiasing = antialiasing;
    m_geometryDirty = true;
    m_newMaterial = true;
    emit antialiasingChanged(antialiasing);
}

void Item::setClampToEdge(bool clamp) {
    if(clamp == m_clampToEdge) return;

    m_clampToEdge = clamp;
    m_newMaterial = true;
    emit clampToEdgeChanged(clamp);
}

// internal only
void Item::updateBlending(bool blending) {
    if (m_blending != blending) {
        m_blending = blending;
        m_materialDirty = true;
        // to disable the antialiasing fringe
        m_geometryDirty = true;
        emit blendingChanged(blending);
    }
}

void Item::calculateBlending() {
    // color has alpha transparency - set blending accordingly
    // can still be overriden by setting blending manually
    updateBlending(m_color.alphaF() < 1.0f);
}

void Item::setBlending(bool blending) {
    // blending was set manually - don't calculate from color anymore
    disconnect(this, 0, this, SLOT(calculateBlending()));
    updateBlending(blending);
}

const QSGGeometry::AttributeSet& Item::meshAttributes()
{
    static QSGGeometry::Attribute attr[] = {
        QSGGeometry::Attribute::create(0, 2, GL_FLOAT, true), // pos
        QSGGeometry::Attribute::create(1, 2, GL_FLOAT),       // tex
        QSGGeometry::Attribute::create(2, 1, GL_FLOAT)        // coverage
    };
    static QSGGeometry::AttributeSet set = { 3, sizeof(Vertex), attr };
    return set;
}

QSGNode* Item::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
    ComposedNode *node = static_cast<ComposedNode*>(oldNode);

    if (!node) {
        node = new ComposedNode();
        m_newMaterial = true;
        m_materialDirty = true;
        m_geometryDirty = true;
    }

    if (m_geometryDirty) {
        m_geometryDirty = false;

        QSGGeometry *bodyGeometry = generateBodyGeometry(node->body()->geometry());
        if(bodyGeometry != node->body()->geometry()) // Qt bug https://codereview.qt-project.org/#/c/104259/1
            node->body()->setGeometry(bodyGeometry);
        node->body()->markDirty(QSGNode::DirtyGeometry);

        if(m_antialiasing) {
            node->enableFringe();
            QSGGeometry *fringeGeometry = generateFringeGeometry(node->fringe()->geometry());
            if(fringeGeometry != node->fringe()->geometry()) // Qt bug https://codereview.qt-project.org/#/c/104259/1
                node->fringe()->setGeometry(fringeGeometry);
            node->fringe()->markDirty(QSGNode::DirtyGeometry);
        } else {
            node->disableFringe();
        }
    }

    if(m_newMaterial) {
        node->body()->setSolidMaterial(createSolidMaterial());
        node->body()->setSampledMaterial(createSampledMaterial());
        node->body()->setMaterial(node->body()->solidMaterial());
        if(m_antialiasing) {
            node->fringe()->setSolidMaterial(createSolidMaterial());
            node->fringe()->setSampledMaterial(createSampledMaterial());
            node->fringe()->setMaterial(node->fringe()->solidMaterial());
        }
        m_materialDirty = true;
    }

    if (m_materialDirty) {
        m_materialDirty = false;

        updateSolidMaterial(node->body());
        updateSampledMaterial(node->body());
        node->body()->solidMaterial()->setFlag(QSGMaterial::Blending, m_blending);
        node->body()->sampledMaterial()->setFlag(QSGMaterial::Blending, m_blending);
        node->body()->markDirty(QSGNode::DirtyMaterial);

        if(m_antialiasing) {
            if(!node->fringe()) qFatal("should have fringe!");
            updateSolidMaterial(node->fringe());
            updateSampledMaterial(node->fringe());
            node->fringe()->sampledMaterial()->setFlag(QSGMaterial::Blending, true);
            node->fringe()->solidMaterial()->setFlag(QSGMaterial::Blending, true);
            node->fringe()->markDirty(QSGNode::DirtyMaterial);
        }
    }
    return node;
}

void Item::updateSampledMaterial(GeometryNode* node) {
    SampledMaterial* mat = node->sampledMaterial();
    mat->m_color = m_color;
    mat->m_dest = m_dest;

    if (m_sourceItem && m_sourceItem->textureProvider() != mat->m_textureProvider) {
        if (m_textureChangedToNodeMarkDirty)
            QObject::disconnect(m_textureChangedToNodeMarkDirty);
        if (m_destroyedToNodeSourceDestroyed)
            QObject::disconnect(m_destroyedToNodeSourceDestroyed);
        if (m_destroyedToItemMarkDirty)
            QObject::disconnect(m_destroyedToItemMarkDirty);

        mat->m_textureProvider = m_sourceItem->textureProvider();
        if (mat->m_textureProvider) {
            m_textureChangedToNodeMarkDirty  = QObject::connect(mat->m_textureProvider, &QSGTextureProvider::textureChanged,
                                                                node, &GeometryNode::markDirtyMaterial);
            m_destroyedToNodeSourceDestroyed = QObject::connect(mat->m_textureProvider, &QSGTextureProvider::destroyed,
                                                                node, &GeometryNode::sourceProviderDestroyed);
            m_destroyedToItemMarkDirty       = QObject::connect(mat->m_textureProvider, &QSGTextureProvider::destroyed,
                                                                this, &Item::markDirtyMaterial);

            mat->m_rotation = (GLint)(m_sourceItem->rotation() >= 0 ?
                              (int)m_sourceItem->rotation() % 360 :
                              (int)m_sourceItem->rotation() % 360 + 360);
            QSize sourceSize = mat->textureProvider()->texture() ?
                               mat->textureProvider()->texture()->textureSize() : QSize();
            if (!sourceSize.isEmpty() && m_dest.width() > 0 && m_dest.height() > 0 ) {
                sourceSize *= m_sourceItem->scale();
                // Translate to device-independent pixels to get a correct scale factors.
                // Note that QQuickImage doesn't need this translation since its texture
                // size already appears in device-independent pixels.
                QQuickImage *image = qobject_cast<QQuickImage *>(m_sourceItem);
                if (image == 0) {
                    if (!qFuzzyCompare(m_sourceItem->width(), sourceSize.width()) ||
                        !qFuzzyCompare(m_sourceItem->height(), sourceSize.height())) {
                        sourceSize = QSize(width(), height());
                    } else {
                        sourceSize = sourceSize / window()->devicePixelRatio();
                    }
                } else {
                    if (image->fillMode() == QQuickImage::Stretch)
                        sourceSize = QSize(width(), height());
                }

                if (mat->m_rotation % 180) {
                    mat->m_xScale = (GLfloat) m_dest.height() / sourceSize.width();
                    mat->m_yScale = (GLfloat) m_dest.width()  / sourceSize.height();
                } else {
                    mat->m_xScale = (GLfloat) m_dest.width()  / sourceSize.width();
                    mat->m_yScale = (GLfloat) m_dest.height() / sourceSize.height();
                }
            } else {
                mat->m_xScale = mat->m_yScale = (GLfloat)1.0;
            }
        }
    } else if (!m_sourceItem) {
        // source item was un-set, we don't want to hear from its
        // texture update anymore
        if (m_textureChangedToNodeMarkDirty)
            QObject::disconnect(m_textureChangedToNodeMarkDirty);
        if (m_destroyedToNodeSourceDestroyed)
            QObject::disconnect(m_destroyedToNodeSourceDestroyed);
        if (m_destroyedToItemMarkDirty)
            QObject::disconnect(m_destroyedToItemMarkDirty);
    }
}

void Item::updateSolidMaterial(GeometryNode* node) {
    SolidMaterial* mat = node->solidMaterial();
    mat->m_color = m_color;
}

GeometryNode::GeometryNode()
    : m_solidMaterial(nullptr)
    , m_sampledMaterial(nullptr) {
    QSGGeometryNode::setFlag(UsePreprocess, true);
    // we manage the materials
    QSGGeometryNode::setFlag(OwnsMaterial, false);
    // QSG manages geometry
    QSGGeometryNode::setFlag(OwnsGeometry, true);
}

GeometryNode::~GeometryNode() {
    delete m_solidMaterial;
    delete m_sampledMaterial;
}

void GeometryNode::preprocess() {
    if (sampling()) {
        if(material() != m_sampledMaterial)
            setMaterial(m_sampledMaterial);
        m_sampledMaterial->updateTextureProvider();
    } else {
        if(material() != m_solidMaterial)
            setMaterial(m_solidMaterial);
    }
}

bool GeometryNode::sampling() const {
    return m_sampledMaterial
        && m_sampledMaterial->textureProvider()
        && m_sampledMaterial->textureProvider()->texture();
}

void GeometryNode::markDirtyMaterial() {
    markDirty(DirtyMaterial);
}

void GeometryNode::sourceProviderDestroyed(QObject* object) {
    Q_UNUSED(object);
    if(m_sampledMaterial)
        m_sampledMaterial->invalidateTextureProvider();
}

void GeometryNode::setSolidMaterial(SolidMaterial* mat) {
    if(mat != m_solidMaterial) {
        if(material() == m_solidMaterial)
            setMaterial(mat);
        delete m_solidMaterial;

        mat->setFlag(QSGMaterial::RequiresFullMatrix);
        m_solidMaterial = mat;
        markDirty(DirtyMaterial);
    }
}

void GeometryNode::setSampledMaterial(SampledMaterial* mat) {
    if(mat != m_sampledMaterial) {
        if(material() == m_sampledMaterial)
            setMaterial(mat);
        delete m_sampledMaterial;
        mat->setFlag(QSGMaterial::RequiresFullMatrix);
        m_sampledMaterial = mat;
        markDirty(DirtyMaterial);
    }
}

SETTER(Item, QColor, color, Color, material)
SETTERTRISTATE(Item, QRectF, dest, Dest, material, QRectF(0,0, width(), height()))

ComposedNode::ComposedNode()
    : m_fringe(nullptr) {
    m_body = new GeometryNode();
    m_body->setFlag(OwnedByParent, false);
    appendChildNode(m_body);
}

void ComposedNode::enableFringe() {
    if(m_fringe) return;
    m_fringe = new GeometryNode();
    m_fringe->setFlag(OwnedByParent, false);
    appendChildNode(m_fringe);
}

void ComposedNode::disableFringe() {
    if(!m_fringe) return;
    removeChildNode(m_fringe);
    delete m_fringe;
    m_fringe = nullptr;
}

ComposedNode::~ComposedNode() {
    delete m_body;
    delete m_fringe;
}

} //namespace
