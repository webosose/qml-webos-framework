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
import QtQuick.Window 2.2
import Eos.Items 0.1
import "style.js" as Style

Rectangle {
    id: root

    color: "darkgray"

    MouseArea {
        // mouseArea above the list for testing the list's wheelScroll method
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: list.top
        }
        onWheel: (wheel) => { list.wheelScroll(wheel.angleDelta.y); }
    }

    EditableListView {
        id: list

        height: Style.launchPoint.height
        headerWidth: headerItem.width
        hotspotWidth: Style.ribbonHotspot.width
        largeDelegates: false
        // Maximizing the borderControl area to avoid "stuck" hotspot on quick hover
        leftHotspot.borderControlWidth: root.width/2 - leftHotspot.width
        rightHotspot.borderControlWidth: root.width/2 - rightHotspot.width

        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            left: parent.left
            right: parent.right
        }

        spacing: Style.launchPoint.spacing

        delegate: LauncherDelegate {
            width: Style.launchPoint.width
            height: Style.launchPoint.height

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => { console.log("click in actual delegate"); }
            }
        }

        header: Item {
            id: headerItem
            width: 590 //list.currentIndex === 0 ? 500 : Style.ribbonHotspot.width
            height: parent.height

            Rectangle {
                id: card_zero
                color: "lightgray"
                width: 370
                height: 300
                anchors {
                    right: parent.right
                    rightMargin: 20
                }
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 32
                    text: "Card Zero"
                }
            }

            Rectangle {
                color: "white"
                width: 180
                height: 300
                anchors {
                    right: card_zero.left
                    rightMargin: 20
                }
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 32
                    text: "Channels"
                }
            }
        }

        footer: Item {
            width: Style.ribbonHotspot.width
            height: parent.height
        }

        model: m

        focus: true
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
