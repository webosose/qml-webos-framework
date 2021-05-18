// Copyright (c) 2015-2021 LG Electronics, Inc.
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
import Eos.Items 0.1 as Eos

FocusScope {
    id: root

    signal activated()
    signal selected()
    signal deselected();

    property alias label: label
    property alias background: background
    property alias slide: slide
    property var geometry: ({})

    property bool editing: false
    property real editMode: editing ? 10 : 0
    property real offset: 20 + editMode

    width: geometry.width
    height: geometry.height

    transform: Translate {
        id: slide
        x: activeFocus ? geometry.tan * root.offset : 0
        y: activeFocus ? -root.offset : 0
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Eos.FastParallelogram {
        id: background
        width: geometry.width
        height: geometry.height
        anchors { centerIn: parent }
        angle: geometry.angle
        enabled: true
        hoverEnabled: true
        onClicked: (mouse) => { root.activated(); }
        onPressAndHold: (mouse) => { root.selected(); }
        onEntered: { root.forceActiveFocus(); }
        onReleased: (mouse) => { root.deselected(); }
    }

    Text {
        id: label
        anchors.centerIn: parent
        font.pixelSize: 32
    }
}
