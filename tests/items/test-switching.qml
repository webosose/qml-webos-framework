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
import Eos.Items 0.1
import Eos.Controls 0.1

Page {
    anchors.fill: parent
    Component.onCompleted: {
        started();
    }
    signal done()
    signal started()

    Image {
        x: -width;
        width: 200
        height: 200
        id: theImage
        source: "uv-test.png"
    }

    Image {
        x: -width;
        width: 200
        height: 200
        id: asyncImage
        asynchronous: true
        source: "ok-green.png"
    }

    Text {
        id: description
        text: "switching through some sources repeatedly"
        font.pixelSize: 24
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 40
        }
    }
    Column {
        id: sources
        spacing: 20
        anchors {
            top: description.bottom
            left: parent.left
            margins: 40
        }
        Image {
            width: 200
            height: 200
            id: image1
            source: "uv-test.png"
        }
        Image {
            width: 200
            height: 200
            id: image2
            source: "ok-green.png"
        }
        Image {
            width: 200
            height: 200
            id: image3
            source: "ok-transparent.png"
        }
        Rectangle {
            color: "green"
            width:200; height: 200
        }
        property Item activeSource

    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        PropertyAction { target: sources; property: "activeSource"; value: image1 }
        PauseAnimation { duration:200 }
        PropertyAction { target: sources; property: "activeSource"; value: image2 }
        PauseAnimation { duration:200 }
        PropertyAction { target: sources; property: "activeSource"; value: image3 }
        PauseAnimation { duration:200 }
        ScriptAction { script:{ sources.activeSource = null; } }
        PauseAnimation { duration:200 }
    }

    Grid {
        columns: 2
        spacing: 40
        anchors {
            right: parent.right
            left: sources.right
            top: description.top
            bottom: parent.bottom
            margins: 40
        }

        Rectangle {
            color: "white"
            width: 200; height: 200
            Rectangle { color: "red"; anchors {fill: parent; margins:20 }}
            FastParallelogram {
                angle: 10;
                anchors.fill: parent;
                color: "green";
                sourceItem:  sources.activeSource

            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Rectangle { color: "red"; anchors {fill: parent; margins:20 }}
            Beziergon {
                anchors.fill: parent;
                color: "green";
                sourceItem:  sources.activeSource
            }
        }
    }
}
