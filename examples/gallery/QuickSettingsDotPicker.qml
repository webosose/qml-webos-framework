// Copyright (c) 2013-2021 LG Electronics, Inc.
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
import Eos.Controls 0.1

Picker {
    id: root

    property color color: "white"

    signal exited()

    clip: true

    focus: true

    PathView {
        id: label

        clip: true
        model: root.model

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode:  PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem
        pathItemCount: 3

        path: Path {
            startX: -label.width
            startY: label.height
            PathLine { x: 2 * label.width; y: label.height }
        }

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.bottom: parent.verticalCenter
        interactive: false

        currentIndex: root.currentIndex

        delegate: Text {
            text: name
            color: root.color
            font.family: "Museo Sans"
            font.pixelSize: 22
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            width: label.width
            anchors.bottom: parent.bottom
        }
    }


    DotIndicator {
        anchors.top: label.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        color: root.color
        itemCount: model !== undefined ? model.count : 0
        currentIndex: root.currentIndex
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (mouse) => { incrementCurrentIndex(); }
        onExited: root.exited()
    }

    Keys.onEnterPressed: (event) => { incrementCurrentIndex(); }
    Keys.onReturnPressed: (event) => { incrementCurrentIndex(); }
}
