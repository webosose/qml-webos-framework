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
    anchors.fill:parent
    Component.onCompleted: {
        timer.start();
        started();
    }
    signal done()
    signal started()
    Column {
        id: sources
        Image {
            width:200
            height: 200
            id:theImage
            source: "uv-test.png"
        }

        Item {
            id: foo
            width: 200; height: 200
            Rectangle { x: 5; y: 5; width: 60; height: 60; color: "red" }
            Rectangle { x: 20; y: 20; width: 60; height: 60; color: "orange"
                RotationAnimation on rotation { from: 0; to: 360; duration: 10000; loops: Animation.Infinite }
            }
            Rectangle { x: 35; y: 35; width: 60; height: 60; color: "yellow" }
        }
    }

    ShaderEffectSource {
        id: theSource
        width: 200; height: 200
        sourceItem: foo
    }

    Timer {
        id: timer
        interval: 100
        running:true
        repeat: true
        property var loaders: [
            solidPara, solidBez,
            sampleImagePara, sampleImageBez,
            sampleSourcePara, sampleSourceBez,
            sampleInlineSourcePara, sampleInlineSourceBez
        ]

        property var i: 0
        onTriggered: {
            if (i>0) {
//                loaders[i-1].active = false;
            }
            if (i == loaders.length) {
                running = false;
                console.log("end of test!");
                return;
            }
            console.log("["+i+"] activating loader...");
            loaders[i].active = true;
            i++;
        }
    }

    Grid {
        columns: 2
        spacing: 40
        anchors.left: sources.right

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: solidPara; active: false; anchors.fill:parent; sourceComponent: Component {
                FastParallelogram { color:"orange" }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: solidBez; active: false; anchors.fill:parent; sourceComponent: Component {
                Beziergon { color:"lime" }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleImagePara; active: false; anchors.fill:parent; sourceComponent: Component {
                FastParallelogram { color:"orange"; sourceItem: theImage }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleImageBez; active: false; anchors.fill:parent; sourceComponent: Component {
                Beziergon { color:"lime"; sourceItem: theImage }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleSourcePara; active: false; anchors.fill:parent; sourceComponent: Component {
                FastParallelogram { color:"orange"; sourceItem: theSource }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleSourceBez; active: false; anchors.fill:parent; sourceComponent: Component {
                Beziergon { color:"lime"; sourceItem: theSource }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleInlineSourcePara; active: false; anchors.fill:parent; sourceComponent: Component {
                FastParallelogram {
                    color:"orange"
                    sourceItem: ShaderEffectSource {
                        width: 200; height: 200
                        sourceItem: foo
                    }
                }
            }}
        }

        Rectangle { 
            color: "white"
            width:200; height:200
            Loader { id: sampleInlineSourceBez; active: false; anchors.fill:parent; sourceComponent: Component {
                Beziergon {
                    color:"lime"
                    sourceItem: ShaderEffectSource {
                        width: 200; height: 200
                        sourceItem: foo
                    }
                }
            }}
        }
    }
}
