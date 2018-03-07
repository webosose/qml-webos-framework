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

    offsetX: (visualParent !== null ) ? visualParent.width - root.implicitWidth + 5 : 0
    offsetY: (visualParent !== null ) ? (visualParent.height - root.implicitHeight) / 2 : 0

    implicitWidth: 380
    implicitHeight: 110

    width: 380
    height: 110

    Rectangle {
        id: background

        anchors.verticalCenter: root.verticalCenter
        anchors.right: root.right

        color: (visualParent !== null) ? visualParent.parent.color : "white"
        radius: height/2

        state: root.state == "opened" ? "bubble" : "circle"

        states: [

            State {
                name: "bubble"

                PropertyChanges {
                    target: background
                    width: 380
                    height: 110
                }
            },
            State {
                name: "circle"

                PropertyChanges {
                    target: background
                    width: 20
                    height: 20
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "*"

                PropertyAnimation { target: background
                    properties: "width, height"
                    duration: 200
                }
            }
        ]
    }

    transitions: [
        Transition {
            from: "closed" ;to: "opened"

            PropertyAnimation { target: root
                                properties: "opacity";
                                from: "0.0";
                                to: "1.0"
                                duration: 200 }

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
