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
import Eos.Items 0.1 as Eos
/* A fast and small implementation of a parallelogram that allows for clipping of
   any QML Items (images, gradients, windows, mouse events).
   The parallelogram borders can be deformed as bezier curves. */

Item {
    id: root
    property Item source                 // arbitrary item clipped by the parallelogram shape
    property real blur: 2                // blur from left and right side for parallelogram
    property real angle
    property real offset: height * __tan
    property real __tan:  Math.tan(angle * Math.PI/180)

    /* A note on why we are splitting into two properties for optimization:
     *
     * QML has two binding evaluators: an optimized one that can do simple stuff like 
     * multiplications or additons, and a full-blown JS engine.  When it sees a binding 
     * that involves anything JS-looking it will have to use the JS engine.

     * Secondly by separating the Math.XXX parts into properties, they only have to be 
     * invoked once during creation as the angle never changes at runtime in our current design. 
     * So from that moment on it can just do a simple multiplication of two variables instead 
     * of invoking the whole expression
     */

    property color color: "transparent"  // background color of the parallelogram
    property real bottomWidth: width - offset // width of bottom edge
    property bool curvedEdges: false     // allows for enabling bezier borders
    property Item shape                  // handle to the beziergon to access control points
    property int resolution: 10          // resolution of the bezier curve borders

    // horizontal clipping: positive values clip off on the right side, negative values on the left side
    property real horizontalClipMargin: 0

    /* A parallelogram implementation that allows for bent bezier borders.
       This implementation is dynamically loaded if the curvedEdges property is set. */
    Component {
        id: beziergonImplementation

        Item {
            Eos.Beziergon {
                id: bezier
                anchors.fill: parent
                color: root.color
                resolution: root.resolution
                sourceItem: root.source

                // synchronize beziergon node positions with parallelogram geometry
                function updateNodes() {
                    bezier.topLeft = Qt.point(root.offset,0)
                    bezier.topRight = Qt.point(root.width,0)
                    bezier.bottomLeft = Qt.point(0,root.height)
                    bezier.bottomRight = Qt.point(root.width-root.offset,root.height)
                }

                Connections {
                    target: root
                    Component.onCompleted: { root.shape = bezier; bezier.updateNodes(); }
                    onAngleChanged: bezier.updateNodes()
                    onWidthChanged: bezier.updateNodes()
                    onHeightChanged: bezier.updateNodes()
                }
            }
        }
    }
    Loader {
        id: beziergonLoader
        sourceComponent: curvedEdges ? beziergonImplementation : undefined
        anchors.fill: root
        onLoaded: if (root.source) root.source.visible = false
    }

    /* A fast parallelogram implementation that clips any QML items and their events
       (including images, gradients, windows, mouse areas, etc.) to the parallelogram shape.
       It also supports horizontal clipping.
       This implementation is dynamically loaded if the curvedEdges property is set to false. */

    Component {
        id: simpleImplementation

        Rectangle {
            property real angle: root.angle
            property real __sin:  Math.sin(angle * Math.PI/180)
            property real __cos:  Math.cos(angle * Math.PI/180)
            property real bottomWidth: width - height * __tan // width of bottom edge

            id: outerClipRect
            color: "transparent"
            width: root.width; height: root.height

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: root.horizontalClipMargin

            clip: true // for clipping off top and bottom

            Rectangle {
                id: innerClipRect
                // blur shader introduces image shrinking, have to compensate width and position
                x: -root.blur / 2
                width:  parent.width * __cos - parent.height * __sin + root.blur
                height: root.width + root.height // this is an upper bound, not an accurate value
                                                 // we don't need this rectangle to be exact as it is clipped off top and bottom anyways
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -root.horizontalClipMargin

                rotation: root.angle
                color: root.blur > 0 ? "transparent" : root.color
                clip:  true // for clipping off the slanted edges left and right
                antialiasing:true // anti-aliasing for the slanted edges

                ShaderEffect {
                    width: innerClipRect.width
                    height: innerClipRect.height
                    property real blur: (1.0 / innerClipRect.width * root.blur)
                    property color color: root.color

                    enabled: root.blur > 0;

                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform highp vec4 color;
                        uniform highp float qt_Opacity;
                        uniform highp float blur;
                        void main(void) {
                            highp float blurR = 1.0 - blur;
                            highp float x = qt_TexCoord0.x;
                            if (x >= 0.0 && x <= blur) {
                                gl_FragColor = color * smoothstep(0.0, blur, x) * qt_Opacity;
                            } else if (x >= blurR && x <= 1.0) {
                                gl_FragColor = color * (1.0 - smoothstep(blurR, 1.0, x)) * qt_Opacity;
                            } else {
                                gl_FragColor = color * qt_Opacity;
                            }
                        }"
                }

                Item {
                    id: sourceContainer
                    width: root.width; height: root.height
                    anchors.centerIn: parent
                    rotation: -root.angle
                }
            }

            Connections {
                target: root
                onSourceChanged: if (root.source) root.source.parent = sourceContainer
                Component.onCompleted: if (root.source) root.source.parent = sourceContainer
            }
        }
    }
    Loader {
        id: simpleLoader
        sourceComponent: curvedEdges ? undefined : simpleImplementation
        anchors.centerIn: root
        onLoaded: if (root.source) root.source.visible = true
    }
}
