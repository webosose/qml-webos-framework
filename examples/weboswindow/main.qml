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

WebOSWindow {
    id: root
    width: 500
    height: 1920

    // Sets the window as transparent, the color can be any color if you do not
    // need or want transparency (This do not work on Desktop)
    color: "transparent"

    // Toggles the visibility of the window
    visible: true

    title: "Testing the title"
    subtitle: "Testing the subtitle"
    windowType: "_WEBOS_WINDOW_TYPE_POPUP"
    appId: "com.webos.app.examplewindow"
    displayAffinity: params["displayAffinity"]

    /*!
     * The location hint can be of
     * 1) WebOSWindow.LocationHintEast
     * 2) WebOSWindow.LocationHintSouth
     * 3) WebOSWindow.LocationHintNorth
     * 4) WebOSWindow.LocationHintWest
     * Or a logical bitwise OR of them
     *
     * The WebOSWindow.LocationHintCenter value is exclusive and does not apply
     * with the others.
     *
     * If no value is specified LocationHintCenter is assumed
     *
     * NOTE: Currently only applies to window type _WEBOS_WINDOW_TYPE_POPUP
     */
    locationHint: WebOSWindow.LocationHintEast

    Item {
        id: view
        anchors.fill: parent
        opacity: 0

        function open() {
            state = "open";
        }

        function close() {
            state = "closed";
        }

        states: [
            State {
                name: "open"
                PropertyChanges { target: view; opacity: 1 }
            },
            State {
                name: "closed"
                PropertyChanges { target: view; opacity: 0 }
                StateChangeScript { name: "close"; script: root.close(); }
            }
        ]
        transitions: [
            Transition {
                from: "*"; to: "open"
                SequentialAnimation {
                    PauseAnimation { duration: 300 }
                    NumberAnimation { target: view; property: "opacity"; duration: 600 }
                }
            },
            Transition {
                from: "*"; to: "closed"
                SequentialAnimation {
                    NumberAnimation { target: view; property: "opacity"; duration: 600 }
                    ScriptAction { scriptName: "close" }
                }
            }
        ]

        Rectangle {
            anchors.fill: parent
            color: "green"
            opacity: 0.2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 50
            height: 50
            color: "red"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: view.close();
        }
    }

    /*!
     * Called when the compositor has requested to window to be closed.
     * Well behaving client should do some quick clean up here and then call
     * WebOSWindow::close()
     */
    onWindowCloseRequested: {
        console.log("Window was requested to be closed");
        event.accepted = false;
        view.close();
    }

    Component.onCompleted: {
        if (root.visible) {
            console.log("Window is visible, changing vew state to open");
            view.open();
        }
    }

    /*!
     * The state changes only apply to window type _WEBOS_WINDOW_TYPE_CARD
     */
    onWindowStateChanged: console.log("Window state changed", windowState);

    onCursorVisibleChanged: console.log("Cursor visibility changed " + cursorVisible);
}
