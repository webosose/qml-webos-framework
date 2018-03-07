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


    Text {
        id: description
        text: "these should look the same as the reference"
        font.pixelSize: 24
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 40
        }
    }

    Grid {
        columns: 12
        spacing: 20
        anchors {
            right: parent.right
            left: parent.left
            top: description.top
            bottom: parent.bottom
            margins: 40
        }
        Item {width:1; height: 1;}
        Text { text: "1"}
        Text { text: "2"}
        Text { text: "3"}
        Text { text: "4"}
        Text { text: "5"}
        Text { text: "6"}
        Text { text: "7"}
        Text { text: "8"}
        Text { text: "9"}
        Text { text: "10"}
        Text { text: "11"}
        
        Text { text:"reference" }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon1
                source: "../../examples/gallery/images/icon_livetv.png"
                width: 64; height: 64;
            }
        }

        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon2
                source: "../../examples/gallery/images/icon_picture.png"
                width: 64; height: 64;
            }
        }

        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon3
                source: "../../examples/gallery/images/icon_settings.png"
                width: 64; height: 64;
            }
        }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon4
                source: "../../examples/gallery/images/icon_sound.png"
                width: 64; height: 64;
            }
        }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon5
                source: "../../examples/gallery/images/icon_sleep.png"
                width: 64; height: 64;
            }
        }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon6
                source: "../../examples/gallery/images/icon_secure.png"
                width: 64; height: 64;
            }
        }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: icon7
                source: "../../examples/gallery/images/icon_usb.png"
                width: 64; height: 64;
            }
        }
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Image {
                id: bigImage
                width: 64; height: 64
                source: "uv-test.png"
            }
        }
        // dest test : centered destination
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            clip: true
            Image {
                width: 32; height: 32
                x: 16; y: 16
                source: "../../examples/gallery/images/icon_settings.png"
            }
        }
        // dest test: clip
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            clip: true
            Image {
                width: 256; height: 256
                source: "uv-test.png"
                x:-196; y:-196
            }
        }
        // dest test: atlas clip
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            clip: true
            Image {
                width: 128; height: 128
                x: -64; y: -64
                source: "../../examples/gallery/images/icon_settings.png"
            }
        }

        Text { text:"parallelogram" }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon1
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon2
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon3
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon4
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon5
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon6
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: icon7
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                sourceItem: bigImage
            }
        }
        // dest test : centered destination
        Rectangle {
            color: "white"; width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                dest: Qt.rect(16,16,32,32)
                sourceItem: icon3
            }
        }
        // dest test: clip
        Rectangle {
            color: "white"
            width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "red";
                sourceItem: bigImage
                dest: Qt.rect(-192,-192,256,256)
            }
        }
        // dest test: atlas clip
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            FastParallelogram {
                anchors.fill: parent; angle: 0; color: "darkgray";
                dest: Qt.rect(-64,-64,128,128)
                sourceItem: icon3
            }
        }


        //beziergon
        Text { text:"beziergon" }

        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon1
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon2
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon3
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon4
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon5
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon6
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: icon7
            }
        }
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                color: "darkgray";
                sourceItem: bigImage
            }
        }
        // dest test : centered destination
        Rectangle {
            color: "white"; width: 64; height: 64
            Beziergon {
                width: 64; height: 64
                dest: Qt.rect(16,16,32,32)
                color: "darkgray";
                sourceItem: icon3
            }
        }
        // dest test: clip
        Rectangle {
            color: "white"
            width: 64; height: 64
            Beziergon {
                anchors.fill: parent;
                sourceItem: bigImage
                color: "red";
                dest: Qt.rect(-192,-192,256,256)
            }
        }
        // dest test: atlas clip
        Rectangle {
            color: "darkgray"; width: 64; height: 64
            Beziergon {
                width: 64; height: 64
                dest: Qt.rect(-64,-64, 128, 128)
                color: "darkgray";
                sourceItem: icon3
            }
        }
    }
}
