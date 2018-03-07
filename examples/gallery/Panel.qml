// Copyright (c) 2013-2018 LG Electronics, Inc.
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

ButtonPopup {
    id: root

    property color color: "black"
    property real margins: 50

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.margins: root.margins
    width: 200
    opacity: 0.75

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.color
        anchors.margins: -root.margins
        opacity: root.opacity
    }

    transitions: [
        Transition {
            from: "closed"
            to: "opened"

            NumberAnimation {
                target: root
                property: "anchors.rightMargin"
                from: -root.width
                to: 0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "opened"
            to: "closed"

            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "anchors.rightMargin"
                    from: 0
                    to: -root.width
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ScriptAction { scriptName: "closeMethod" }
            }
        }
    ]
}
