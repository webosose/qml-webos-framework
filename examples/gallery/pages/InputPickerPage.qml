// Copyright (c) 2013-2021 LG Electronics, Inc.
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
import "../"

GalleryPage {

    id: root

    property url imageRoot: Qt.resolvedUrl("../images") + "/";

    anchors.fill: parent

    Row {
        spacing: 40

        Column {
            spacing: 30

            width: root.width / 4

            Header {
                id: inputHeader
                headerText: "Inputs"
                headerFontSize: 80
                width: parent.width
                height: liveTvHeader.height
            }

            Timer {
                interval: 500
                running: true
                onTriggered: {
                    spinner.visible = false
                    inputList.visible = true
                }
            }

            Spinner {
                id: spinner
                text: "Loading ..."
                running: true
            }

            List {
                id: inputList
                width: parent.width
                height: 500
                clip: true

                visible: false

                model: ListModel {
                    ListElement { name: "Live TV"; icon: "icon_livetv.png"; placement: "In Launcher"}
                    ListElement { name: "HDMI1"; icon: "icon_device.png"; placement: "Not in Launcher" }
                    ListElement { name: "HDMI2"; icon: "icon_device.png"; placement: "Not in Launcher" }
                    ListElement { name: "HDMI3"; icon: "icon_device.png"; placement: "Not in Launcher" }
                    ListElement { name: "Component"; icon: "icon_component.png"; placement: "Not in Launcher" }
                    ListElement { name: "AV"; icon: "icon_component.png"; placement: "Not in Launcher" }
                }

                section.delegate: Component {
                    GroupHeader {
                        width: inputList.width
                        title: section
                    }
                }
                section.property: "placement"

                delegate: Component {
                    ListItem {
                        text: name
                        iconSource: imageRoot + icon
                    }
                }

                KeyNavigation.right: closeButton
            }
        }
        Column {
            spacing: 30

            width: 3/4 * root.width - parent.spacing

            Header {
                id: liveTvHeader
                headerText: "LIVE TV"
                subHeaderText: "Tuner"
                width: parent.width

                Button {
                    id: closeButton
                    iconSource: Qt.resolvedUrl("../images/icon_close.png")
                    style: QuickSettingsButtonStyle{ buttonBackgroundColor: "#4d4d4d" }
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 10

                    KeyNavigation.down: button1
                }
            }

            Row {

                spacing: 30

                Rectangle {
                    width: 600
                    height: 400
                    color: "gray"
                }

                Column {
                    spacing: 30

                    Button {
                        id: button1
                        text: "Edit"
                        style: SmallButtonStyle {}
                        KeyNavigation.down: button2
                    }
                    Button {
                        id: button2
                        text: "Edit"
                        style: SmallButtonStyle {}
                        KeyNavigation.down: button3
                    }
                    Button {
                        id: button3
                        text: "Remove from Launcher"
                        style: SmallButtonStyle {}
                        KeyNavigation.down: button4
                    }
                    Button {
                        id: button4
                        text: "Set Up Universal Control"
                        style: SmallButtonStyle {}
                    }
                }
            }
        }
    }
}
