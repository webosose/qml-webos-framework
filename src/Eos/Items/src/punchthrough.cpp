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

#include "punchthrough.h"

#include <QtQuick/QSGSimpleRectNode>

PunchThrough::PunchThrough(QQuickItem *parent):
    QQuickItem(parent)
{
    setFlags(ItemHasContents);
}

QSGNode *PunchThrough::updatePaintNode(QSGNode *node, UpdatePaintNodeData *)
{
    QSGSimpleRectNode *rectNode = static_cast<QSGSimpleRectNode *>(node);
    if (rectNode) {
        rectNode->setRect(boundingRect());
    } else {
        rectNode = new QSGSimpleRectNode(boundingRect(), Qt::transparent);
        rectNode->material()->setFlag(QSGMaterial::Blending, false);
    }
    return rectNode;
}
