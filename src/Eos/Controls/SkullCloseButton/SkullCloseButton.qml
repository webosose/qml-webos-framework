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
import WebOS.Global 1.0

/*!
    \qmltype SkullCloseButton
    \since Eos 0.1
    \brief An animated skull close button.

    An animated close button that turns into a skull when hovered by the mouse pointer.
    The skull explodes once it's clicked.
*/

Item {
    id: root

    /*!
        \qmlproperty color color

        Color of cross mark(X) on the button.
    */
    property color color: "white"

    /*!
        \qmlproperty color backgroundColor

        Background color of the button.
    */
    property color backgroundColor: "black"

    /*!
        \qmlproperty color outlineColor

        Outline color of the button.
    */
    property color outlineColor: "#2e2e2e"

    /*!
        \qmlproperty real buttonWidth

        Width of the button.
    */
    property real buttonWidth: 50

    /*!
        \qmlproperty real buttonHeight

        Height of the button.
    */
    property real buttonHeight: 50

    /*!
        \qmlproperty real frameDuration

        The amount of ms for the duration of a single frameDuration.
        Increase this value to slow down the animation.
    */
    property real frameDuration: 40

    /*!
        \qmlproperty real closeButtonActiveMargin

        Margin for mouse event sensing area.
    */
    property real closeButtonActiveMargin: 30

    /*!
        \qmlproperty alias containsMouse

        Alias of internal MouseArea's containsMouse property.
    */
    property alias containsMouse: mouseArea.containsMouse

    /*!
        \qmlproperty real outlineColor

        Outline width of the button.
    */
    property real outlineWidth: 1

    /*!
        \qmlproperty bool cursorVisible

        Bind this to a property that reflects the cursor visibility.
    */
    property bool cursorVisible: true

    /*!
        \qmlsignal clicked

        Emitted when the button is clicked.
    */
    signal clicked

    /*!
        \qmlsignal closeAnimCompleted

        Emitted when the button close animation is completed.
    */
    signal closeAnimCompleted

    /*!
        \qmlsignal entered

        Emitted when the mouse enters into the button.
    */
    signal entered

    /*!
        \qmlsignal exited

        Emitted when the mouse exits from the button.
    */
    signal exited

    // Button element, all measurements are relative to this one
    Item {
        id: button
        objectName: "closeButton"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.buttonWidth
        height: root.buttonHeight

        // Circle which turns into a skull and later on into an animation
        // All movable elements inside (eyes, nose, etc.) are provided as
        // rounded rectangles to make the color configurable

        Image {
            id: skullCircle
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height
            source: "./images/skull1.png"
            smooth: true

            Rectangle {
                id: leftEye
                visible: false
                width: button.width * 0.1
                height: button.width * 0.275
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -button.width * 0.15
                anchors.left: parent.left
                anchors.leftMargin: button.width * 0.20
                color: root.backgroundColor
                radius: width * 0.5
                smooth: true
                antialiasing: true
            }

            Rectangle {
                id: rightEye
                visible: false
                width: button.width * 0.1
                height: button.width * 0.275
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -button.width * 0.15
                anchors.right: parent.right
                anchors.rightMargin: button.width * 0.22
                color: root.backgroundColor
                radius: width * 0.5
                smooth: true
                antialiasing: true
            }

            Item {
                id: nose
                width: parent.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false

                Rectangle {
                    id: leftNostril
                    visible: true
                    width: button.width * 0.09
                    height: button.width * 0.05
                    rotation: -45
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: parent.height * 0.22
                    anchors.right: parent.horizontalCenter
                    anchors.rightMargin: -width * 0.25
                    color: root.backgroundColor
                    radius: width * 0.5
                    smooth: true
                    antialiasing: true
                }
                Rectangle {
                    id: rightNostril
                    visible: true
                    width: button.width * 0.09
                    height: button.width * 0.05
                    rotation: 45
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: parent.height * 0.22
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: -width * 0.25
                    color: root.backgroundColor
                    radius: width * 0.5
                    smooth: true
                    antialiasing: true
                }
            }
        }
        Rectangle {
            id: crossSlashOutline
            width: button.width * 0.8 + outlineWidth
            height: button.width * 0.1 + outlineWidth
            anchors.centerIn: button
            color: root.outlineColor
            radius: height / 2
            clip: false
            rotation: -45
            smooth: true
            antialiasing: true
        }
        Rectangle {
            id: crossBackSlashOutline
            width: button.width * 0.8 + outlineWidth
            height: button.width * 0.1 + outlineWidth
            anchors.centerIn: button
            color: root.outlineColor
            radius: height / 2
            clip: false
            rotation: 45
            smooth: true
            antialiasing: true
        }

        Rectangle {
            id: crossSlash
            width: button.width * 0.8
            height: button.width * 0.1
            anchors.centerIn: button
            color: root.color
            radius: height / 2
            clip: false
            rotation: -45
            smooth: true
            antialiasing: true
        }
        Rectangle {
            id: crossBackSlash
            width: button.width * 0.8
            height: button.width * 0.1
            anchors.centerIn: button
            color: root.color
            radius: height / 2
            clip: false
            rotation: 45
            smooth: true
            antialiasing: true
        }

        WebOSMouseArea {
            id: mouseArea
            cursorVisible: root.cursorVisible
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: -root.closeButtonActiveMargin
            anchors.bottomMargin: -root.closeButtonActiveMargin
            anchors.leftMargin: -root.closeButtonActiveMargin
            anchors.rightMargin: -root.closeButtonActiveMargin

            hoverEnabled: root.state !== "noFocus"
            Component.onCompleted: {
                clicked.connect(root.clicked)
                entered.connect(root.entered)
                exited.connect(root.exited)
            }
        }
    }

    state: "noFocus"

    states: [
        State {
            name: "noFocus"
            PropertyChanges {
                         target: button
                         height: root.buttonHeight
                         anchors.verticalCenterOffset: 0.6 * root.height
                         rotation: -180
                         opacity: 0.0
            }
            PropertyChanges {
                         target: skullCircle
                         source: "./images/skull1.png"
                         width: 40
                         height: 40
            }
            PropertyChanges {
                target: leftEye
                visible: false
            }
            PropertyChanges {
                target: rightEye
                visible: false
            }
            PropertyChanges {
                target: nose
                visible: false
            }
        },
        State {
            name: "focused"
            PropertyChanges {
                         target: button
                         height: root.buttonHeight
                         anchors.verticalCenterOffset: 0
                         rotation: 0
                         opacity: 1.0
            }
            PropertyChanges {
                         target: skullCircle
                         rotation: 0
                         source: "./images/skull1.png"
                         width: 40
                         height: 40
                         anchors.bottomMargin: 0
            }
            PropertyChanges {
                         target: crossSlash
                         width: button.width * 0.8
            }
            PropertyChanges {
                         target: crossBackSlash
                         width: button.width * 0.8
            }
            PropertyChanges {
                         target: crossSlashOutline
                         width: button.width * 0.8
            }
            PropertyChanges {
                         target: crossBackSlashOutline
                         width: button.width * 0.8
            }
            PropertyChanges {
                target: leftEye
                height: button.width * 0.275
                visible: false
            }
            PropertyChanges {
                target: rightEye
                height: button.width * 0.275
                visible: false
            }
            PropertyChanges {
                target: nose
                visible: false
            }
        },
        State {
            name: "hovered"
            PropertyChanges {
                         target: button
                         height: root.buttonHeight
                         anchors.verticalCenterOffset: 0
                         rotation: 0
                         opacity: 1.0
            }
            PropertyChanges {
                         target: skullCircle
                         rotation: 0
                         width: 36
                         height: 36
                         source: "./images/skull2.png"
                         anchors.bottomMargin: 0
            }
            PropertyChanges {
                         target: crossSlash
                         explicit: true
                         width: 0.425 * root.buttonWidth
            }
            PropertyChanges {
                         target: crossBackSlash
                         explicit: true
                         width: 0.425 * root.buttonHeight
            }
            PropertyChanges {
                         target: crossSlashOutline
                         explicit: true
                         width: 0.425 * root.buttonWidth
            }
            PropertyChanges {
                         target: crossBackSlashOutline
                         explicit: true
                         width: 0.425 * root.buttonHeight
            }
            PropertyChanges {
                target: leftEye
                height: button.width * 0.275
                visible: true
            }
            PropertyChanges {
                target: rightEye
                height: button.width * 0.275
                visible: true
            }
            PropertyChanges {
                target: nose
                visible: true
            }
        },
        State {
            name: "clicked"

            PropertyChanges {
                         target: button
                         anchors.verticalCenterOffset: 0
                         rotation: 0
                         opacity: 1.0
            }
            PropertyChanges {
                         target: skullCircle
                         rotation: 0
                         width: 197
                         height: 227
                         source: "./images/skull19.png"
                         anchors.bottomMargin: -56
            }
            PropertyChanges {
                         target: crossSlash
                         visible: false
            }
            PropertyChanges {
                         target: crossBackSlash
                         visible: false
            }
            PropertyChanges {
                         target: crossSlashOutline
                         visible: false
            }
            PropertyChanges {
                         target: crossBackSlashOutline
                         visible: false
            }
            PropertyChanges {
                target: leftEye
                visible: false
            }
            PropertyChanges {
                target: rightEye
                visible: false
            }
            PropertyChanges {
                target: nose
                visible: false
            }
        }
    ]
    transitions: [
        Transition {
            from: "noFocus" ; to: "focused"
            SequentialAnimation {
                PropertyAction { target: button; property: "opacity" }
                ParallelAnimation {
                    SequentialAnimation {
                        PropertyAnimation {
                            target: button
                            property: "anchors.verticalCenterOffset"
                            easing.type: "OutBack"
                            duration: 13 * frameDuration
                        }
                    }
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 7 * frameDuration
                        }
                        ParallelAnimation {
                            PropertyAnimation {
                                target: crossSlash
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossBackSlash
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossSlashOutline
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossBackSlashOutline
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                        }
                    }
                }
            }
        },
        Transition {
            from: "focused" ; to: "noFocus"
            SequentialAnimation {
                ParallelAnimation {
                    SequentialAnimation {
                        PropertyAnimation {
                            target: button
                            property: "anchors.verticalCenterOffset"
                            easing.type: "OutBack"
                            duration: 13 * frameDuration
                        }
                    }
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 7 * frameDuration
                        }
                        ParallelAnimation {
                            PropertyAnimation {
                                target: crossSlash
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossBackSlash
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossSlashOutline
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                            PropertyAnimation {
                                target: crossBackSlashOutline
                                properties: "width"
                                duration: 6 * frameDuration
                            }
                        }
                    }
                }
                PropertyAction { target: button; property: "opacity" }
            }
        },
        Transition {
            from: "focused" ; to: "hovered"
            reversible: true

            FocusedToHoveredAnimation {}
        },
        Transition {
            from: "hovered" ; to: "clicked"
            reversible: true
            HoveredToClickedAnimation {
                onAnimCompleted: closeAnimCompleted();
            }
        },
        Transition {
            from: "focused" ; to: "clicked"
            reversible: true
            HoveredToClickedAnimation {
                onAnimCompleted: closeAnimCompleted();
            }
        }
    ]
}
