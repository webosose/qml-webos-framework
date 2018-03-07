// Copyright (c) 2014-2018 LG Electronics, Inc.
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

Item {
    id: root

    property real animationWidth: 60

    implicitWidth: animationWidth + label.anchors.leftMargin + label.paintedWidth + height
    implicitHeight: Math.max(animationWidth + 20, label.paintedHeight + 20)

    Rectangle {
        color: root.parent.parent.color

        anchors.fill: parent
        radius: height/2

        Component {
            id: dot

            Item {
                id: spinner
                width: animationWidth
                height: animationWidth

                states: [
                    State {
                        name: "first"
                        PropertyChanges {
                            target: spinner
                            rotation: 195
                        }
                    },
                    State {
                        name: "rotating"
                        PropertyChanges {
                            target: spinner
                            rotation: 135
                        }
                    },
                    State {
                        name: "last"
                        PropertyChanges {
                            target: spinner
                            rotation: 165
                        }
                    }
                ]

                state: parent.state

                transitions: [
                    Transition {
                        from: "first" ; to: "rotating"
                        RotationAnimation {
                            property: "rotation"
                            easing.type: Easing.InOutQuad
                            duration: 800
                            direction: RotationAnimation.Clockwise
                        }
                    },
                    Transition {
                        from: "rotating" ; to: "last"
                        RotationAnimation {
                            property: "rotation"
                            duration: 200
                            easing.type: Easing.OutBack
                            direction: RotationAnimation.Clockwise
                        }
                    },
                    Transition {
                        from: "last" ; to: "first"
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 200
                            }
                            RotationAnimation {
                                property: "rotation"
                                duration: 200
                                easing.type: Easing.OutBack
                                direction: RotationAnimation.Clockwise
                            }
                        }
                    }
                ]

                Rectangle {
                    x: parent.height/2 - height/2
                    y: 5
                    width: 10
                    height: 10
                    color: bulletColor
                    radius: height/2
                }
            }
        }

        Loader {
            id: bulletOne
            anchors.left: parent.left
            anchors.leftMargin: root.height / 4
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: dot
            property color bulletColor: "#ffb80d"
            state: "first"
        }

        Loader {
            id: bulletTwo
            anchors.left: parent.left
            anchors.leftMargin: root.height / 4
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: dot
            property color bulletColor: "#69cdff"
            state: "last"
        }

        Loader {
            id: bulletThree
            anchors.left: parent.left
            anchors.leftMargin: root.height / 4
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: dot
            property color bulletColor: "#ff4a4a"
            state: "rotating"
        }


        Timer {
            repeat: true
            interval: 800
            running: true
            triggeredOnStart: true
            onTriggered: {
                bulletOne.state = increaseState(bulletOne.state);
                bulletTwo.state = increaseState(bulletTwo.state);
                bulletThree.state = increaseState(bulletThree.state);
            }

            function increaseState( status) {
                if (status === "first") status = "rotating"
                else if (status === "rotating") status = "last"
                else status = "first"
                return status
            }
        }


        Text {
            id: label
            text: root.parent.parent.text
            color: "white"
            font.family: "Museo Sans"
            font.pixelSize: 26
            font.bold: true
            anchors.left: bulletOne.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
