// Copyright (c) 2018 LG Electronics, Inc.
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

#include "eosvirtualkeyboardoverlay.h"

#include <QQuickWindow>

#include <webosinputpanellocator.h>
#include <webosplatform.h>

EosVirtualKeyboardOverlay::EosVirtualKeyboardOverlay(QQuickItem *parent)
    : QQuickItem(parent)
{
    setEnabled(false);
    connect(this, &QQuickItem::windowChanged,
            this, &EosVirtualKeyboardOverlay::handleWindowChanged);
}

EosVirtualKeyboardOverlay::~EosVirtualKeyboardOverlay()
{
}

void EosVirtualKeyboardOverlay::setTargetItem(QQuickItem* targetTextElement)
{
    if (m_targetTextElement != targetTextElement) {
        if (m_targetTextElement)
            disconnect(m_targetTextElement, 0, this, 0);

        m_targetTextElement = targetTextElement;
        emit targetChanged(m_targetTextElement);
    }
}

void EosVirtualKeyboardOverlay::updateBoundingRectOnScene()
{
    const QRect& alignedRectOnScene = mapRectToScene(boundingRect()).toAlignedRect();
    if (m_targetTextElement && m_boundingRectOnScene != alignedRectOnScene) {
        m_boundingRectOnScene = alignedRectOnScene;
        WebOSPlatform::instance()->inputPanelLocator()->setInputPanelRect(
            m_targetTextElement, m_boundingRectOnScene.x(), m_boundingRectOnScene.y(),
            m_boundingRectOnScene.width(), m_boundingRectOnScene.height());
    }
}

void EosVirtualKeyboardOverlay::handleWindowChanged(const QQuickWindow* window)
{
    if (window && window != m_activeWindow) {
        if (m_activeWindow)
            disconnect(m_activeWindow, 0, this, 0);
        m_activeWindow = window;
        connect(m_activeWindow, &QQuickWindow::afterRendering,
                this, &EosVirtualKeyboardOverlay::updateBoundingRectOnScene);
    }
}
