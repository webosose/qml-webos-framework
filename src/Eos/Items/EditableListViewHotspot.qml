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

MouseArea {
    id: root

    property bool blocked: true
    property alias resumeScrollDelay: resumeScrollTimer.interval
    // Make sure that the borderControlWidth is maximized so that even on quick
    // hover some events get sampled (otherwise the hotspot will appear "stuck").
    property real borderControlWidth: root.width * 2
    property string location: "left"
    signal advance

    propagateComposedEvents: true

    function resumeScrolling() {
        resumeScrollTimer.restart()
    }

    Timer {
        id: resumeScrollTimer
        running: false
        interval: 100
        onTriggered: {
            if (!blocked && root.containsMouse) {
                root.advance();
            }
        }
    }

    onEntered: {
        if (!blocked && root.containsMouse) {
            root.advance();
        }
    }

    // This mouse area ensures that the main mousearea only becomes activated
    // when crossing the edge on the screen center side.
    MouseArea {
        id: border
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.borderControlWidth
        anchors.left: root.location === "left" ? parent.right : undefined
        anchors.right: root.location === "left" ? undefined : parent.left
        hoverEnabled: enabled
        onEntered: {
            border.enabled = false;
            root.blocked = false;
        }
    }
}
