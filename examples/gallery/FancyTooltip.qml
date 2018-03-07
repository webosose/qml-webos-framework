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

Tooltip {
    id: root

    offsetX: (visualParent !== null ) ? - width + visualParent.width : 0
    offsetY: (visualParent !== null ) ? visualParent.height + 5 : 0

    implicitWidth: label.implicitWidth + 40
    implicitHeight: label.implicitHeight + 20

    Rectangle {
        id: background

        clip: true

        color: "green"
        radius: height/2

        anchors.fill: parent

        visible: label.text != ""

        Text {
            id: label

            text: root.text
            color: "white"

            font.family: "Museo Sans"
            font.pixelSize: 30

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    transitions: [
        Transition {
            from: "closed" ;to: "opened"
            PropertyAnimation { target: root
                                properties: "opacity";
                                from: "0.0";
                                to: "1.0"
                                duration: 500 }
            PropertyAnimation { target: label
                                properties: "anchors.horizontalCenterOffset"
                                from: "300"
                                to: "0"
                                easing.type: Easing.OutBounce
                                duration: 1000
            }
            PropertyAnimation { target: label
                                properties: "opacity"
                                from: "0.0"
                                to: "1.0"
                                easing.type: Easing.OutBounce
                                duration: 1000
            }
        },
        Transition {
            from: "opened" ;to: "closed"
            SequentialAnimation {
                PropertyAnimation { target: root
                                    properties: "opacity";
                                    from: "1.0";
                                    to: "0.0"
                                    duration: 200 }
                ScriptAction { scriptName: "closeMethod" }
            }
        }

    ]
}
