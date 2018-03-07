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

import Eos.Window 0.1
import QtQuick 2.4
import Eos.Controls 0.1

WebOSWindow {
    id: root
    width: 1920
    height: 1080

    // Toggles the visibility of the window
    visible: true
    title: "Testing the title"
    subtitle: "Testing the subtitle"
    windowType: "_WEBOS_WINDOW_TYPE_POPUP"
    appId: "com.webos.app.examplewindow"

    color: "lightsteelblue"

    onWindowCloseRequested: {
        console.log("Window was requested to be closed");
        root.close();
    }


    Menu {
        id: menu
        clip: true
        width:400
        anchors {
            top: parent.top
            bottom:parent.bottom
            left: parent.left
            margins:10
        }

        ExclusiveGroup {
            id: menuGroup
        }

        MenuItem {
            id: solidTestMenuItem
            text: "simple usecases test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-simple.qml"), {}); console.log("foo"); }
            KeyNavigation.down: atlasTestMenuItem
            exclusiveGroup: menuGroup
            Component.onCompleted: {
                pageStack.push(Qt.resolvedUrl("dummy.qml"), {});
                forceActiveFocus();
            }
        }

        MenuItem {
            id: atlasTestMenuItem
            text: "texture atlas test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-atlas.qml"), {}) }
            exclusiveGroup: menuGroup
            KeyNavigation.down: missingTestMenuItem
        }
        MenuItem {
            id: missingTestMenuItem
            text: "missing image test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-missing.qml"), {}) }
            exclusiveGroup: menuGroup
            KeyNavigation.down: switchingTestMenuItem
        }
        MenuItem {
            id: switchingTestMenuItem
            text: "switching sources test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-switching.qml"), {}) }
            exclusiveGroup: menuGroup
            KeyNavigation.down: shapeTestMenuItem
        }
        MenuItem {
            id: shapeTestMenuItem
            text: "testing shape animations"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-properties.qml"), {}) }
            exclusiveGroup: menuGroup
            KeyNavigation.down: mouseTestMenuItem
        }
        MenuItem {
            id: mouseTestMenuItem
            text: "mouse test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-mouse.qml"), {}) }
            exclusiveGroup: menuGroup
            KeyNavigation.down: alphaTestMenuItem
        }
        MenuItem {
            id: alphaTestMenuItem
            text: "transparency test"
            onTriggered: { pageStack.replace(Qt.resolvedUrl("test-alpha.qml"), {}) }
            exclusiveGroup: menuGroup
        }
    }

    Rectangle {
        id:testArea
        border.color: "black"
        anchors {
            top:parent.top
            bottom:parent.bottom
            left: menu.right
            right:parent.right
            margins: 10
        }
        color:"white"
        PageStack {
            id: pageStack
            anchors.fill: parent
            delegate: PageStackDelegate {
                id: pageStackDelegate
                replaceTransition: PageStackTransition { }
            }

        }
    }
}
