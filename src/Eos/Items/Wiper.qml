// Copyright (c) 2014-2021 LG Electronics, Inc.
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

Item {
    id: root

    signal opening()
    signal closing()

    signal opened()
    signal closed()

    function open() { state = "open" }
    function close() { state = "closed" }

    // functions to skip animations and go to this state directly
    function skipToClosedLeft() {
        // no transition leading to or from the default state
        curtainEdgeLeft.state = ""
        curtainEdgeRight.state = ""
        state = "closed-left"
    }

    function skipToClosedRight() {
        curtainEdgeLeft.state = ""
        curtainEdgeRight.state = ""
        state = "closed"
    }

    property Item sourceItem
    property bool isOpen: false
    property bool forceBeziergon: false

    property var previousSource: null
    onSourceItemChanged: {
        if (previousSource) {
            // restore previous item since we don't show it anymore
           previousSource.visible = true;
        }

        previousSource = sourceItem;

        if (sourceItem) { // hide the one we now show
            sourceItem.parent = root;
            sourceItem.visible = !transitioning && isOpen;
        }
    }

    property bool transitioning: openToClosed.running || closedToOpen.running || openToClosedLeft.running || closedLeftToOpen.running

    property real openTime: 500
    property real closeTime: 0

    Eos.Beziergon {
        id: curtain
        color: root.sourceItem && root.sourceItem.color || "transparent"
        blending: false
        anchors.fill: parent
        objectName: parent.objectName+"-beziergon"

        visible: transitioning || forceBeziergon
        sourceItem: ShaderEffectSource {
            sourceItem: (transitioning || forceBeziergon) ? (root.sourceItem || null) : null
        }

        dest: root.sourceItem && root.sourceItem.fillMode === Image.Pad ?
                     Qt.rect((width - root.sourceItem.sourceSize.width) / 2.0,
                     (height - root.sourceItem.sourceSize.height) / 2.0,
                      root.sourceItem.sourceSize.width,
                      root.sourceItem.sourceSize.height) :
                      Qt.rect(0, 0, width, height)
        resolution: Qt.point(0,20)
        antialiasing: false
    }
    /*
     * debug helpers: show rectangles around control points
    Rectangle { x: curtain.topRight.x-25;    y: curtain.topRight.y-25;    width: 50; height: 50 }
    Rectangle { x: curtain.topLeft.x-25;     y: curtain.topLeft.y-25;     width: 50; height: 50 }
    Rectangle { x: curtain.bottomRight.x-25; y: curtain.bottomRight.y-25; width: 50; height: 50 }
    Rectangle { x: curtain.bottomLeft.x-25;  y: curtain.bottomLeft.y-25;  width: 50; height: 50 }

    Rectangle { x: curtain.controlRightTop.x-25;   y: curtain.controlRightTop.y-25;   width: 50; height: 50; color: "green"}
    Rectangle { x: curtain.controlLeftTop.x-25;    y: curtain.controlLeftTop.y-25;    width: 50; height: 50; color: "green"}
    Rectangle { x: curtain.controlTopLeft.x-25;    y: curtain.controlTopLeft.y-25;    width: 50; height: 50; color: "green"}
    Rectangle { x: curtain.controlBottomLeft.x-25; y: curtain.controlBottomLeft.y-25; width: 50; height: 50; color: "green"}
    */

    // Animate the left and right edge of the curtain independently.
    // This allows us to have them in-flight at the same time
    Item {
        id: curtainEdgeLeft
        states: [
            State {
                name: "left"
                PropertyChanges {
                    target: curtain
                    topLeft: Qt.point(0,0)
                    bottomLeft: Qt.point(0,height)
                    controlLeftTop: Qt.point(0, height/2)
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: curtain
                    topLeft: Qt.point(width,0)
                    bottomLeft: Qt.point(width,height)
                    controlLeftTop: Qt.point(width, height/2)
                }
            }
        ]
        transitions: [
            Transition {
                from: "right"
                to: "left"
                PropertyAnimation {
                    target: curtain; properties: "topLeft, bottomLeft";
                    duration: root.openTime / 4
                }
                PropertyAnimation {
                    target: curtain; properties: "controlLeftTop";
                    duration: root.openTime;
                    easing.type: Easing.OutElastic
                    easing.period: 0.6
                }
            },
            Transition {
                from: "left"
                to: "right"
                PropertyAnimation {
                    target: curtain; properties: "topLeft, bottomLeft";
                    duration: root.closeTime / 4
                }
                PropertyAnimation {
                    target: curtain; properties: "controlLeftTop";
                    duration: root.closeTime;
                    easing.type: Easing.OutElastic
                    easing.period: 0.6
                }
            }
        ]
    }

    Item {
        id: curtainEdgeRight
        states: [
            State {
                name: "right"
                PropertyChanges {
                    target: curtain
                    topRight: Qt.point(width,0)
                    bottomRight: Qt.point(width,height)
                    controlRightTop: Qt.point(width, height/2)
                }
            },
            State {
                name: "left"
                PropertyChanges {
                    target: curtain
                    topRight: Qt.point(0,0)
                    bottomRight: Qt.point(0,height)
                    controlRightTop: Qt.point(0, height/2)
                }
            }
        ]
        transitions: [
            Transition {
                from: "right"
                to: "left"
                PropertyAnimation {
                    target: curtain; properties: "topRight, bottomRight";
                    duration: root.closeTime / 4
                }
                PropertyAnimation {
                    target: curtain; properties: "controlRightTop";
                    duration: root.closeTime;
                    easing.type: Easing.OutElastic
                    easing.period: 0.6
                }
            },
            Transition {
                from: "left"
                to: "right"
                PropertyAnimation {
                    target: curtain; properties: "topRight, bottomRight";
                    duration: root.openTime / 4
                }
                PropertyAnimation {
                    target: curtain; properties: "controlRightTop";
                    duration: root.openTime;
                    easing.type: Easing.OutElastic
                    easing.period: 0.6
                }
            }
        ]
    }

    state: "closed"
    states: [
        State {
            name: "closed"
            // cannot have state change as part of a state definition
            StateChangeScript {
                script: {
                    curtainEdgeLeft.state = "right";
                    curtainEdgeRight.state = "right";
                }
            }
        },
        State {
            name: "open"
            StateChangeScript {
                script: {
                    curtainEdgeLeft.state = "left";
                    curtainEdgeRight.state = "right";
                }
            }
        },
        State {
            name: "closed-left"
            StateChangeScript {
                script: {
                    curtainEdgeLeft.state = "left";
                    curtainEdgeRight.state = "left"
                }
            }
        }
    ]

    transitions: [
        Transition {
            from: "closed"
            to: "open"
            id: closedToOpen
            SequentialAnimation {
                ScriptAction { script: root.opening() }
                PropertyAction { target: curtain; property: "visible"; value: true }
                PauseAnimation { duration: root.openTime }
                ScriptAction { script: { root.isOpen = true; root.opened();} }
                PropertyAction { target: sourceItem; property: "visible"; value: true }
            }
        },
        Transition {
            from: "open"
            to: "closed"
            id: openToClosed
            SequentialAnimation {
                PropertyAction { target: sourceItem; property: "visible"; value: false }
                ScriptAction { script: root.closing() }
                PauseAnimation { duration: root.closeTime }
                ScriptAction { script: { root.isOpen = false; root.closed();} }
            }
        },
        Transition {
            from: "open"
            to: "closed-left"
            id: openToClosedLeft
            SequentialAnimation {
                PropertyAction { target: sourceItem; property: "visible"; value: false }
                ScriptAction { script: root.closing() }
                PauseAnimation { duration: root.closeTime }
                ScriptAction { script: { root.isOpen = false; root.closed();} }
            }
        },
        Transition {
            from: "closed-left"
            to: "open"
            id: closedLeftToOpen
            SequentialAnimation {
                ScriptAction { script: root.opening() }
                PauseAnimation { duration: root.openTime }
                ScriptAction { script: { root.isOpen = true; root.opened();} }
                PropertyAction { target: sourceItem; property: "visible"; value: true }
            }
        },
        Transition {
            from: "closed"
            to: "closed-left"
            reversible: true
            SequentialAnimation {
                ScriptAction {
                    script: {
                        // this is supposed to be an invisible transition, so we use
                        // a state that no transition exists for in the edges
                        // this makes them flip without a visible transition
                        curtainEdgeLeft.state = "";
                        curtainEdgeRight.state = ""
                    }
                }
                ScriptAction {
                    script: {
                        // transition is reversible, figure out which side we should be on
                        curtainEdgeLeft.state = root.state == "closed-left" ? "left" : "right";
                        curtainEdgeRight.state = curtainEdgeLeft.state
                    }
                }
            }
        }
    ]
}
