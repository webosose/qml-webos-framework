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

import QtQuick 2.4
import QtGraphicalEffects 1.0

Item {
    id: root

    property real radius: 50

    property bool clipTopLeft: true
    property bool clipTopRight: true
    property bool clipBottomLeft: true
    property bool clipBottomRight: true

    property color color: "red"

    QtObject {
        id: d
        property real cappedRadius: Math.min(root.radius, root.height / 2)
        property real topClipping: clipTopLeft || clipTopRight
        property real bottomClipping: clipBottomLeft || clipBottomRight
        property real clipping: topClipping || bottomClipping
        property real realRadius: clipping ? cappedRadius : 0
    }

    Rectangle {
        id: source
        color: root.color
        visible: false
        clip: true
        width: d.realRadius * 2
        height: width
    }

    Rectangle {
        id: mask
        color: root.color
        width: d.realRadius * 2
        height: width
        radius: d.realRadius
        smooth: true
        visible: false
    }

    Item {
        id: topSection
        transform: Translate { x: -d.realRadius; y: -d.realRadius }
        height: clipTopRight || clipTopLeft ? d.realRadius : 0

        anchors {
            top: root.top
            left: root.left
            right: root.right
        }

        Item {
            id: topLeftClipper
            clip: true
            width: d.realRadius * 2
            height: width
            visible: root.clipTopLeft

            OpacityMask {
                source: source
                width: d.realRadius * 2
                height: width
                maskSource: mask
                transform: Translate { x: d.realRadius; y: d.realRadius }
            }
        }

        Rectangle {
            id: topCenterSection
            height: d.realRadius
            anchors {
                left: root.clipTopLeft ? topLeftClipper.right : topSection.left
                leftMargin: root.clipTopLeft ? 0 : d.realRadius
                right: topSection.right
                rightMargin: root.clipTopRight ? 0 : -d.realRadius
                bottom: topLeftClipper.bottom
            }
            color: root.color
        }

        Item {
            id: topRightClipper
            clip: true
            width: d.realRadius * 2
            height: width
            visible: root.clipTopRight
            anchors {
                left: topSection.right
            }

            OpacityMask {
                source: source
                width: d.realRadius * 2
                height: width
                maskSource: mask
                transform: Translate { x: -d.realRadius; y: d.realRadius }
            }
        }
    }

    Rectangle {
        id: centerFullSection
        color: root.color

        anchors {
            top: topSection.bottom
            topMargin: d.topClipping ? 0 : d.realRadius
            bottom: bottomSection.top
            left: root.left
            right: root.right
        }
    }

    Item {
        id: bottomSection
        transform: Translate { x: -d.realRadius; y: 0 }
        height: d.realRadius

        anchors {
            bottom: root.bottom
            left: root.left
            right: root.right
        }

        Item {
            id: bottomLeftClipper
            clip: true
            width: d.realRadius * 2
            height: width
            visible: root.clipBottomLeft
            anchors {
                left: bottomSection.left
            }

            OpacityMask {
                source: source
                width: d.realRadius * 2
                height: width
                maskSource: mask
                transform: Translate { x: d.realRadius; y: -d.realRadius }
            }
        }

        Rectangle {
            id: bottomCenterSection
            height: d.realRadius
            anchors {
                left: root.clipBottomLeft ? bottomLeftClipper.right : bottomSection.left
                leftMargin: root.clipBottomLeft ? 0 : d.realRadius
                right: bottomSection.right
                rightMargin: root.clipBottomRight ? 0 : -d.realRadius
                top: bottomLeftClipper.top
            }
            color: root.color
        }

        Item {
            id: bottomRightClipper
            clip: true
            width: d.realRadius * 2
            height: width
            visible: root.clipBottomRight
            anchors {
                left: bottomSection.right
            }

            OpacityMask {
                source: source
                width: d.realRadius * 2
                height: width
                maskSource: mask
                transform: Translate { x: -d.realRadius; y: -d.realRadius }
            }
        }
    }
}
