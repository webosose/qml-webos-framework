// Copyright (c) 2014-2019 LG Electronics, Inc.
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
import Eos.Window 0.1
import QtQuick.Window 2.2

WebOSWindow {
    id: root
    title: "Bare Eos Window"
    displayAffinity: params["displayAffinity"]
    width: 1920
    height: 1080
    visible: true
    color: "yellow"

    Text {
        id: txt1
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.right: parent.right
        anchors.rightMargin: 40
        text: "Eos window " + root.width + "x" + root.height + "   State:" + windowState
        font.pixelSize: 30
    }
    Text {
        id: txt2
        anchors.top: txt1.bottom
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 40
        text: "Screen " + Screen.width + "x" + Screen.height
        font.pixelSize: 30
    }
    Text {
        id: txt3
        anchors.top: txt2.bottom
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 40
        text: "Screen name: "+Screen.name+"  orientation: "+Screen.orientation+"   primaryOrientation: "+Screen.primaryOrientation+"   devicePixelRatio: "+Screen.devicePixelRatio
        font.pixelSize: 30
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.top: txt3.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: parent.width / 2
        border.width: 2
        border.color: "black"
        clip: true
        Text {
            id: dbgOutput
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text: ""
            font.pixelSize: 30
        }
        MouseArea {
            anchors.fill: parent
            onClicked: dbgOutput.text = "";
        }
    }

    onWidthChanged: dbgOutput.text += ("\n"+"Width: "+root.width + "   State:" + windowState);
    onHeightChanged: dbgOutput.text += ("\n"+"Height: "+root.height + "   State:" + windowState);

    onWindowStateChanged: console.log("Window state changed:" + windowState );
}
