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

    Image {
        id: bgImage
        anchors { top: parent.top; right: parent.right; margins: -10 }
        width: System.Screen.width
        height: System.Screen.height
        source: "../images/big-buck-bunny.jpg"
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
            title: "QuickSettings:"
            width: root.width
        }

        Column {
            id: buttonColumn

            anchors.right: parent.right
            anchors.rightMargin: 70

            function closePopupsWithoutFocus() {
                for(var i = 0; i < buttonColumn.children.length; ++i) {
                    var item = buttonColumn.children[i];
                    if (!item.focus && item.contextualPopup) item.contextualPopup.state = "closed"
                }
            }

            Button {
                id: button1
                iconSource: checked ? Qt.resolvedUrl("../images/icon_settings.png") : Qt.resolvedUrl("../images/icon_close.png")
                focus: true
                checkable: true
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#4d4d4d" }
                onClicked: {
                    buttonColumn.state = buttonColumn.state == "opened" ? "closed" : "opened"
                    resultText.showResult(this)
                    buttonColumn.closePopupsWithoutFocus()
                }
                KeyNavigation.down: button2
                z: parent.children.length
            }
            Button {
                id: button2
                iconSource: Qt.resolvedUrl("../images/icon_picture.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#459fec" }
                contextualPopup: QuickSettingsContextualPopup {
                    QuickSettingsDotPicker {
                        anchors.fill: parent
                        model:  ListModel {
                            ListElement { name: "Vivid" }
                            ListElement { name: "Standard" }
                            ListElement { name: "Eco" }
                            ListElement { name: "Cinema" }
                            ListElement { name: "Sports" }
                            ListElement { name: "Photo" }
                        }
                    }
                    Keys.onPressed: (event) => { if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) state = "closed"; }
                    onOpenedChanged: if (opened) buttonColumn.closePopupsWithoutFocus();
                }
                onClicked: resultText.showResult(this)
                KeyNavigation.down: button3

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Picture"
                }
            }
            Button {
                id: button3
                iconSource: Qt.resolvedUrl("../images/icon_sound.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#f55c5e" }
                contextualPopup: QuickSettingsContextualPopup {
                    QuickSettingsDotPicker {
                        anchors.fill: parent
                        model: ListModel {
                            ListElement { name: "Standard" }
                            ListElement { name: "News" }
                            ListElement { name: "Music" }
                            ListElement { name: "Cinema" }
                            ListElement { name: "Sports" }
                            ListElement { name: "Game" }
                        }
                    }
                    Keys.onPressed: (event) => { if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) state = "closed"; }
                    onOpenedChanged: if (opened) buttonColumn.closePopupsWithoutFocus();
                }
                onClicked: resultText.showResult(this)
                KeyNavigation.down: button4

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Sound"
                }
            }
            Button {
                id: button4
                iconSource: Qt.resolvedUrl("../images/icon_aspect_ratio.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#e7ad10"}
                contextualPopup: QuickSettingsContextualPopup {
                    QuickSettingsDotPicker {
                        anchors.fill: parent
                        model: ListModel {
                            ListElement { name: "16:9" }
                            ListElement { name: "JustScan" }
                            ListElement { name: "Set by Program" }
                            ListElement { name: "4:3" }
                            ListElement { name: "Zoom" }
                            ListElement { name: "Cinema Zoom" }
                        }
                    }
                    Keys.onPressed: (event) => { if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) state = "closed"; }
                    onOpenedChanged: if (opened) buttonColumn.closePopupsWithoutFocus();
                }
                onClicked: resultText.showResult(this)
                KeyNavigation.down: button5

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Aspect Ratio"
                }
            }
            Button {
                id: button5
                iconSource: Qt.resolvedUrl("../images/icon_sleep.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#73b905" }
                contextualPopup: QuickSettingsContextualPopup {
                    QuickSettingsDotPicker {
                        anchors.fill: parent
                        model: ListModel {
                            ListElement { name: "120mins" }
                            ListElement { name: "90mins" }
                            ListElement { name: "60mins" }
                            ListElement { name: "30mins" }
                        }
                    }
                    Keys.onPressed: (event) => { if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) state = "closed"; }
                    onOpenedChanged: if (opened) buttonColumn.closePopupsWithoutFocus();
                }
                onClicked: resultText.showResult(this)
                KeyNavigation.down: button6

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Sleep"
                }
            }
            Button {
                id: button6
                iconSource: Qt.resolvedUrl("../images/icon_secure.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#9266cc" }
                contextualPopup: QuickSettingsContextualPopup {
                    QuickSettingsDotPicker {
                        anchors.fill: parent
                        model: ListModel {
                            ListElement { name: "On" }
                            ListElement { name: "Off" }
                        }
                    }
                    Keys.onPressed: (event) => { if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) state = "closed"; }
                    onOpenedChanged: if (opened) buttonColumn.closePopupsWithoutFocus();
                }
                onClicked: resultText.showResult(this)
                KeyNavigation.down: button7

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Secure"
                }
            }
            Button {
                id: button7
                iconSource: Qt.resolvedUrl("../images/icon_advanced.png")
                style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#4d4d4d" }
                onClicked: {
                    buttonColumn.state = "closed"
                    resultText.showResult(this)
                    buttonColumn.closePopupsWithoutFocus()
                }

                CaptionDecorator {
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.hovered
                    text: "Advanced"
                }
            }

            states: [
                State {
                    name: "opened"
                    PropertyChanges { target: buttonColumn; spacing: 80 }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: buttonColumn; spacing: -button1.height }
                }
            ]

            state: "closed"

            transitions: [
                Transition {
                    from: "*"; to: "*"
                    reversible: true

                    NumberAnimation {
                        id: accordionAnimation
                        target: buttonColumn
                        property: "spacing"
                        duration: 200
                        easing.type: Easing.OutQuart
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
