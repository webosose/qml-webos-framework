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

#ifndef EOS_VIRTUAL_KEYBOARD_OVERLAY_H
#define EOS_VIRTUAL_KEYBOARD_OVERLAY_H

#include <QObject>
#include <QQuickItem>
#include <QRect>

class QQuickWindow;

class EosVirtualKeyboardOverlay : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *target READ targetItem WRITE setTargetItem NOTIFY targetChanged DESIGNABLE false FINAL)

public:
    EosVirtualKeyboardOverlay(QQuickItem *parent = 0);
    ~EosVirtualKeyboardOverlay();

    QQuickItem* targetItem() const { return m_targetTextElement; }
    void setTargetItem(QQuickItem *target);

Q_SIGNALS:
    void targetChanged(const QQuickItem* textElement);

public Q_SLOTS:
    void updateBoundingRectOnScene();
    void handleWindowChanged(const QQuickWindow*);

private:
    const QQuickWindow* m_activeWindow = nullptr;
    QQuickItem* m_targetTextElement = nullptr;
    bool m_targetEnabled = false;
    QRect m_boundingRectOnScene;
};
#endif
