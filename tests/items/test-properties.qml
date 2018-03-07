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
    id: root
    property real wobble: 0
    anchors.fill: parent
    Component.onCompleted: {
        started();
    }
    signal done()
    signal started()


    Text {
        id: description
        text: "animating properties"
        font.pixelSize: 24
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 40
        }
    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        PropertyAnimation { target: root; property: "wobble"; from: 0; to: 100; easing.type: Easing.OutElastic }
        PropertyAnimation { target: root; property: "wobble"; from: 100; to: 0; easing.type: Easing.OutElastic }
    }

    Grid {
        columns: 4
        spacing: 100
        anchors {
            right: parent.right
            top: description.bottom
            bottom: parent.bottom
            margins: 40
        }

        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram {
                angle: root.wobble / 10;
                anchors.fill: parent;
                color: "green";
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram {
                width: 100+wobble
                height:200
                angle: 10;
                color: "green";
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram {
                height: 100+wobble
                width: 200
                angle: 10;
                color: "green";
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram {
                height: 100+wobble
                width: 100+wobble
                angle: 10;
                color: "green";
            }
        }

        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon {
                anchors.fill: parent;
                color: "green";
                topLeft:Qt.point(0,wobble)
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon {
                anchors.fill: parent;
                color: "green";
                controlTopLeft:Qt.point(width / 2 , wobble)
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon {
                anchors.fill: parent;
                color: "green";
                controlLeftTop:Qt.point(wobble, height / 2)
            }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon {
                anchors.fill: parent;
                color: "green";
                topLeft:Qt.point(0,wobble)
                topRight:Qt.point(width,wobble)
                controlTopLeft:Qt.point(width/2, 100 - wobble)
            }
        }
    }
}
