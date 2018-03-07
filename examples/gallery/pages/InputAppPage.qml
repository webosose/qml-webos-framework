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
import QtQuick.Window 2.2 as System
import Eos.Items 0.1
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

    Panel {
        id: panel

        anchors { top: parent.top; right: parent.right; margins: -10 }
        width: System.Screen.width - menu.width
        color: "transparent"

        state: "opened"


        Parallelogram {
            id: titleField
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: - offset
            width: 1000
            height: 250
            angle: 10

            color: "black"

            BodyText {
                text: "Big Buck Bunny"
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10 + parent.offset
                font.pixelSize: 100
                font.family: "Miso"
                font.capitalization: Font.AllUppercase
            }
        }

        Parallelogram {
            id: clockField
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: -offset
            anchors.bottom: liveMenuButton.top
            anchors.bottomMargin: 20
            width: Math.max( timeField.width, dateField.width) + 6 * offset
            angle: 10

            color: "black"

            BodyText {
                id: timeField
                text: Qt.formatTime(new Date(), "hh:mm")
                font.bold: false
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 60
                font.family: "Miso"
                font.capitalization: Font.AllUppercase
            }
            BodyText {
                id: dateField
                text: Qt.formatDateTime(new Date(), "MMMM dd")
                font.bold: false
                anchors.top: timeField.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: timeField.horizontalCenter
                font.pixelSize: 40
                font.family: "Miso"
                font.capitalization: Font.AllUppercase
            }
        }

        Button {
            id: liveMenuButton
            text: "Live Menu"

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: titleField.bottom

            focus: true
        }
    }
}
