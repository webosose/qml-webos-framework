// Copyright (c) 2014-2021 LG Electronics, Inc.
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
import Eos.Style 0.1

Rectangle {
    id: root
    property var style: ScrollDecoratorStyle {}

    anchors { right: parent.right }
    y: parent.visibleArea.yPosition * parent.height

    width: style.width
    height: parent.visibleArea.heightRatio * parent.height
    radius: style.radius

    color: style.backgroundColor
    opacity: 0

    Behavior on opacity {
        NumberAnimation {
        }
    }

    onHeightChanged: {
        if (!parent.moving) {
            opacity = style.activeOpacity
            opacityTimer.interval = 1000
            opacityTimer.restart()
        }
    }

    Timer {
        id: opacityTimer
        onTriggered: {
            root.opacity = style.idleOpacity
        }
    }

    Connections {
        target: root.parent
        function onMovingChanged() {
            if (root.parent.moving) {
                opacityTimer.stop()
                root.opacity = style.activeOpacity
            }
            else {
                opacityTimer.interval = 200
                opacityTimer.restart()
            }
        }
    }
}
