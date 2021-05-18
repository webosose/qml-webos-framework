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
import QtQuick.Window 2.2 as System
import Eos.Controls 0.1
import Eos.Style 0.1
import "../"

GalleryPage {

    id: root

    property url imageRoot: Qt.resolvedUrl("../images") + "/";

    Image {
        id: bgImage
        anchors { top: parent.top; right: parent.right; margins: -10 }
        width: System.Screen.width
        height: System.Screen.height
        source: imageRoot + "big-buck-bunny.jpg"
    }

    Rectangle {
        anchors.fill: bgImage
        color: "black"
        opacity: 0.6
    }

    Column {
        spacing: 10

        width: root.width

        GroupHeader {
            id: groupHeader
            title: "Input Picker:"
            width: root.width
        }

        Column {
            id: buttonColumn

            anchors.right: parent.right
            anchors.rightMargin: 70

            Button {
                id: button1
                iconSource: checked ? imageRoot + "icon_settings.png" : imageRoot + "icon_close.png"
                checkable: true
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#4d4d4d" }
                focus: true
                onClicked: {
                    buttonColumn.state = buttonColumn.state == "opened" ? "closed" : "opened"
                    resultText.showResult(this)
                }

                KeyNavigation.down: list

                z: parent.children.length
            }

            List {
                id: list
                width: 150
                height: root.height - button1.height - groupHeader.height - 200

                model: ListModel {
                    ListElement { name: "Live TV"; icon: "icon_livetv.png"}
                    ListElement { name: "HDMI 1"; icon: "icon_device.png"}
                    ListElement { name: "Playstation 4"; icon: "icon_device.png"}
                    ListElement { name: "BD Player"; icon: "icon_device.png"}
                    ListElement { name: "Chromecast"; icon: "icon_device.png"}
                    ListElement { name: "HDMI 2"; icon: "icon_device.png"}
                    ListElement { name: "HDMI 3"; icon: "icon_device.png"}
                    ListElement { name: "Xbox"; icon: "icon_device.png"}
                    ListElement { name: "Direct TV (San Francisco)"; icon: "icon_device.png"}
                    ListElement { name: "Component"; icon: "icon_component.png"}
                    ListElement { name: "USBdevicename1"; icon: "icon_usb.png"}
                    ListElement { name: "USBdevicename2"; icon: "icon_usb.png"}
                    ListElement { name: "USBdevicename3"; icon: "icon_usb.png"}
                    ListElement { name: "Input Hub"; icon: "icon_advanced.png"}
                }

                delegate: Button {
                    id: button

                    iconSource: imageRoot + icon
                    style: QuickSettingsButtonStyle{ buttonBackgroundColor: "transparent" }

                    Behavior on x {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuart
                        }
                    }
                    SequentialAnimation {
                        id: clickAnimation
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InCubic
                            target: button
                            property: "x"
                            to: -80
                        }
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutCubic
                            target: button
                            property: "x"
                            from: -80
                            to: 0
                        }
                    }
                    MouseArea {
                        anchors.left: captionDecorator.left
                        anchors.right: parent.right
                        anchors.rightMargin: -100
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        hoverEnabled: true
                        onContainsMouseChanged: parent.focus = true
                        onClicked: (mouse) => { clickAnimation.running = true; }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)
                            clickAnimation.running = true;
                    }

                    onFocusChanged: x = focus && !list.flicking ? -20 : 0

                    CaptionDecorator {
                        id: captionDecorator
                        anchors.right: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                    }
                }
            }

            states: [
                State {
                    name: "opened"
                    PropertyChanges { target: buttonColumn; spacing: 80 }
                    PropertyChanges { target: list; spacing: 80 }
                    PropertyChanges { target: list; opacity: 1.0 }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: buttonColumn; spacing: 40 }
                    PropertyChanges { target: list; spacing: 40 }
                    PropertyChanges { target: list; opacity: 0.0 }
                }
            ]

            state: "closed"

            transitions: [
                Transition {
                    from: "*"; to: "*"
                    reversible: true

                    ParallelAnimation {
                        NumberAnimation {
                            id: accordionAnimation
                            target: buttonColumn
                            property: "spacing"
                            duration: 400
                            easing.type: Easing.OutQuart
                        }
                        NumberAnimation {
                            id: listAnimation
                            target: list
                            properties: "spacing, opacity"
                            duration: 200
                            easing.type: Easing.OutQuart
                        }
                    }
                }

            ]

            Component.onCompleted: {
                buttonColumn.state = "opened"
            }
        }
    }

    Column {
        anchors.bottom: parent.bottom

        Item {
            width: 50; height: 100
        }

        GroupHeader {
            title: "Results:"
            width: root.width
        }

        BodyText {
            id: resultText
            text: "No button pressed yet."
            function showResult(control) {
                text = control + " (" + control.text + ") triggered."
            }
        }
    }
}
