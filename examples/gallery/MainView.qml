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
import Eos.Controls 0.1
import Eos.Style 0.1

import "./pages"

Item {
    id: root

    Menu {
        id: menu

        clip: true

        width: 300
        height: parent.height

        Rectangle {
            color: "#606060"
            width: parent.width
            height: parent.height
            z: -1
        }

        ExclusiveGroup {
            id: menuGroup
        }

        MenuItem {
            id: quickSettingsMenuItem
            text: "QuickSettings"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/QuickSettingsPage.qml"), {}) }
            KeyNavigation.down: inputPickerMenuItem
            exclusiveGroup: menuGroup

            Component.onCompleted: {
                quickSettingsMenuItem.forceActiveFocus()
                pageStack.push(Qt.resolvedUrl("pages/QuickSettingsPage.qml"), {})
            }
        }

        MenuItem {
            id: inputPickerMenuItem
            text: "Input Picker"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/InputPickerOverlayPage.qml"), {}) }
            KeyNavigation.up: quickSettingsMenuItem
            exclusiveGroup: menuGroup
        }

        MenuItem {
            id: liveTvMenuItem
            text: "Live TV"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/LiveTvAppPage.qml"), {}) }
            KeyNavigation.up: inputPickerMenuItem
            exclusiveGroup: menuGroup
        }

        MenuItem {
            id: inputAppMenuItem
            text: "Input App"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/InputAppPage.qml"), {}) }
            KeyNavigation.up: liveTvMenuItem
            exclusiveGroup: menuGroup
        }

        MenuItem {
            id: roundedRectMenuItem
            text: "Rounded Rectangle"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/RoundedRectanglePage.qml"), {}) }
            KeyNavigation.up: inputAppMenuItem
            exclusiveGroup: menuGroup
        }


        MenuItem {
            id: comboBoxMenuItem
            text: "ComboBox"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/ComboBoxPage.qml"), {}) }
            KeyNavigation.up: roundedRectMenuItem
            exclusiveGroup: menuGroup
        }

/*
        MenuItem {
            id: inputsMenuItem
            text: "Input Hub"
            onTriggered: { viewSourceCodeButton.checked = false; pageStack.replace(Qt.resolvedUrl("pages/InputPickerPage.qml"), {}) }
            KeyNavigation.up: inputAppMenuItem
            exclusiveGroup: menuGroup
        }
*/
        KeyNavigation.right: pageStack.currentPage
        KeyNavigation.down: viewSourceCodeButton
    }

    Item {
        id: pageStackContainer

        anchors.left: menu.right
        anchors.right: root.right
        anchors.top: root.top
        anchors.bottom: bottomPanel.top

        PageStack {
            id: pageStack

            delegate: PageStackDelegate {
                id: pageStackDelegate

                replaceTransition: PageStackTransition {
                        NumberAnimation {
                            target: pageStackDelegate.enterItem;
                            property: "x"
                            from: pageStack.width
                            to: 0
                            duration: 200
                        }
                        NumberAnimation {
                            target: pageStackDelegate.exitItem;
                            property: "x"
                            from: 0
                            to: -pageStack.width
                            duration: 200
                        }
                    }
            }

            anchors.fill: parent
        }
    }

    Rectangle {
        id: bottomPanel

        property real padding: 10

        anchors.left: menu.right
        anchors.right: root.right
        anchors.bottom: root.bottom
        height: viewSourceCodeButton.height + 2 * padding

        color: "#333333"

        Button {
            id: viewSourceCodeButton
            text: "View Source"

            checkable: true
            checked: false

            style: SmallButtonStyle {}

            onCheckedChanged: {
                if (checked) {
                    var myUrl = pageStack.currentPageUrl();
                    pageStack.push(Qt.resolvedUrl("pages/SourceCodePage.qml"), {"sourceUrl": myUrl})
                }
                else pageStack.pop();
            }

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: bottomPanel.right
            anchors.margins: 10
        }

    }

    Component.onCompleted: console.debug("MainView.qml component completed")
}
