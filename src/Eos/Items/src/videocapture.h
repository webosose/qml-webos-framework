// Copyright (c) 2016-2018 LG Electronics, Inc.
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

#ifndef VIDEOCAPTURE_H
#define VIDEOCAPTURE_H

#include <vt/vt_openapi.h>

#include <GLES2/gl2.h>

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QTime>
#include <QMutex>
#include <QSGTexture>

class VideoCapture : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(VideoCapture)

private:
    static void OnEvent(VT_EVENT_TYPE_T type, void* data, void* user_data);
    void recordPaintBegin();
    void recordPaintEnd();

private slots:
    void enabledChanged();
    bool initialize();
    void terminate();
    void acquireVideoTexture();

protected:
    virtual QSGNode * updatePaintNode(QSGNode * oldNode, UpdatePaintNodeData * updatePaintNodeData);
    virtual void itemChange(ItemChange change, const ItemChangeData &);


public:
    explicit VideoCapture(QQuickItem *parent = Q_NULLPTR);
    ~VideoCapture();

signals:
    void videoFrameChanged();

private:
    bool m_initialized;
    bool m_isVTAvailable;

    VT_VIDEO_WINDOW_ID window_id;
    VT_RESOURCE_ID resource_id;
    VT_CONTEXT_ID context_id;
    GLuint currentTextureId;
    GLuint nextTextureId;
    QSGTexture *currentTexture;

    QTime m_paintBeginTime;
    int m_frameCount;

    static QMutex mutex;
};

#endif // VIDEOCAPTURE_H
