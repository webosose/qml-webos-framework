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
import QtQuick.Window 2.2
import "style.js" as Style
import Eos.Items 0.1 as Eos
import Eos.Controls 0.1 as Controls

Window {
    id: root

    visible: true

    color: "#333"

    Controls.Button {
        width: 30
        height: width
        text: "start"

        anchors.top: parent.top
        anchors.left: parent.left

        onClicked: launcher_ribbon.ensureIndexVisible(0)
    }

    Controls.Button {
        width: 30
        height: width
        text: "end"

        anchors.top: parent.top
        anchors.right: parent.right

        onClicked: launcher_ribbon.ensureIndexVisible(launcher_ribbon.count - 1)
    }

    Eos.RibbonEditor {
        id: editor
        anchors.fill: parent

        editTransform: Translate { x: Style.launchPoint.geometry.tan * 20; y: -20 }

        onMoved: {
            console.log("MOVE from:", from , "to:", to);
        }

        Eos.Ribbon {
            id: launcher_ribbon

            height: Style.launchPoint.geometry.height
            anchors {
                bottom: parent.bottom
                bottomMargin: 20
                left: parent.left
                right: parent.right
            }

            spacing: Style.launchPoint.spacing - Style.launchPoint.geometry.offset
            scrollStep: Style.launchPoint.geometry.width + spacing
            layoutDirection: Qt.RightToLeft

            model: m

            Keys.onLeftPressed: {
                if (!event.accepted) {
                    event.accepted = true;
                    //headerItem.cardZero.forceActiveFocus();
                }
            }

            Keys.onRightPressed: {
                if (!event.accepted) {
                    event.accepted = true;
                    footerItem.forceActiveFocus();
                }
            }

            delegate: RibbonTile {
                id: content

                editing: ListView.view.editing

                geometry: Style.launchPoint.geometry
                focus: true

                label {
                    text: model.name
                    color: "white"
                    font.pixelSize: 32
                }

                Keys.onUpPressed: launcher_ribbon.startEditing();
                Keys.onDownPressed: launcher_ribbon.endEditing();

                onActiveFocusChanged: {
                    if (activeFocus)
                        ListView.view.currentIndex = model.index;
                }

                onSelected: {
                    editor.editCurrentItem();
                }

                onDeselected: {
                    editor.stopEdit();
                }


                Component.onCompleted: {
                    // assign the color here to prevent it from changing when moving
                    background.color = Style.colors[model.index % Style.colors.length]
                }
            }

            /*
             header: FocusScope {
                 id: header
                 width: 590 - Style.navigationButton.geometry.offset
                 height: parent.height

                 property alias cardZero: card_zero
                 property alias navButton: nav_button

                 RibbonTile {
                     id: nav_button

                     anchors {
                         right: card_zero.left
                         rightMargin: 20 - Style.navigationButton.geometry.offset
                     }

                     slide {
                         x: nav_button.activeFocus ? 10 : 0
                         y: 0 // horizontal-only
                     }

                     geometry: Style.navigationButton.geometry
                     background.color: Style.navigationButton.color

                     label.text: qsTr("Channels")

                     KeyNavigation.left: card_zero
                     Keys.onLeftPressed: {}
                     onActivated: {
                         console.log("goto-channels");
                     }
                 }

                 CardTile {
                     id: card_zero

                     anchors {
                         right: parent.right
                         rightMargin: 20 - Style.recentsCard.geometry.offset
                     }

                     label.text: qsTr("Card Zero")

                     KeyNavigation.left: nav_button
                     Keys.onRightPressed: {
                         launcher_ribbon.currentIndex = 0;
                         launcher_ribbon.currentItem.forceActiveFocus();
                     }
                     onActivated: {
                         console.log("goto-card-zero");
                     }
                 }
             }
             */

            footer: FocusScope {
                width: Style.navigationButton.geometry.base
                - (Style.navigationButton.geometry.offset - Style.launchPoint.spacing)
                height: parent.height
                RibbonTile {
                    focus: true
                    anchors {
                        left: parent.left
                        leftMargin: -(Style.navigationButton.geometry.offset - Style.launchPoint.spacing)
                    }
                    geometry: Style.navigationButton.geometry
                    background.color: Style.navigationButton.color
                    label.text: qsTr("Edit")
                    Keys.onLeftPressed: {
                        launcher_ribbon.currentIndex = launcher_ribbon.count - 1;
                        launcher_ribbon.currentItem.forceActiveFocus();
                    }
                }
            }

            MouseArea {
                id: left_hotspot
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: -20 }
                width: Style.ribbonHotspot.width
                hoverEnabled: enabled && !launcher_ribbon.atXBeginning
                acceptedButtons: MouseArea.NoButton
                onEntered: {
                    launcher_ribbon.scrollToLeft();
                }
                onExited: {
                    launcher_ribbon.stopScrolling();
                }
            }

            MouseArea {
                id: right_hotspot
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: -20 }
                width: Style.ribbonHotspot.width
                hoverEnabled: enabled && !launcher_ribbon.atXEnd
                acceptedButtons: MouseArea.NoButton
                onEntered: {
                    launcher_ribbon.scrollToRight();
                }
                onExited: {
                    launcher_ribbon.stopScrolling();
                }
            }
        }

        MouseArea {
            id: wheel_area
            anchors.fill: parent
            enabled: !launcher_ribbon.autoScrolling
            acceptedButtons: MouseArea.NoButton
            onWheel: {
                launcher_ribbon.scrollBy(-wheel.angleDelta.y / 120);
            }
        }

        ListModel {
            id: m

            ListElement { name: "Apple" }
            ListElement { name: "Orange" }
            ListElement { name: "Bananas" }
            ListElement { name: "are" }
            ListElement { name: "for" }
            ListElement { name: "Monkeys" }
            ListElement { name: "Peach" }
            ListElement { name: "Kiwi" }
            ListElement { name: "Passion" }
            ListElement { name: "Apricot" }
            ListElement { name: "Blueberry" }
            ListElement { name: "Lingon" }
            ListElement { name: "Fruit" }
            ListElement { name: "Mercury" }
            ListElement { name: "Venus" }
            ListElement { name: "Earth" }
            ListElement { name: "Mars" }
            ListElement { name: "Jupiter" }
            ListElement { name: "Saturn" }
            ListElement { name: "Uranus" }
            ListElement { name: "Neptune" }
        }
    }
}
