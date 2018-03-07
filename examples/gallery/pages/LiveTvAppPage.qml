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
import QtQuick.Window 2.2 as System
import Eos.Controls 0.1
import Eos.Style 0.1
import "../"

GalleryPage {

    id: root

    Image {
        id: bgImage
        anchors { top: parent.top; right: parent.right; margins: -10 }
        width: System.Screen.width
        height: System.Screen.height
        source: "../images/big-buck-bunny.jpg"
    }

    Panel {
        id: panel
        width: 400

        state: mouseArea.containsMouse ? "opened" : "closed"


        Column {
            spacing: 40

            Header {
                id: liveTvAppHeader
                headerText: "Channel"
                subHeaderText: "Now | Cable | All"
            }

            List {
                id: inputList
                width: parent.width
                height: panel.height * 0.65
                clip: true

                model: ListModel {
                    ListElement { channelName: "LG One"; channelTitle: "Life's Good"; channelValue: "29";  }
                    ListElement { channelName: "LG Two"; channelTitle: "Life of Brian"; channelValue: "4";  }
                    ListElement { channelName: "LG News"; channelTitle: "LG programmers invent new framework"; channelValue: "62";  }
                    ListElement { channelName: "LG Weather"; channelTitle: "Weather is sunny in SunnyVale"; channelValue: "33";  }
                    ListElement { channelName: "LG Astro"; channelTitle: "The future of Eos is written in the stars"; channelValue: "86";  }
                }

                delegate: Component {
                    Item {
                        id: channelContainer
                        width: parent.width - 2 * inputList.scrollDecorator.width
                        height: childrenRect.height + 30

                        Column {
                            spacing: 10

                            BodyText {
                                id: channelNumber
                                text: index
                                color: "white"
                                font.pixelSize: 60

                                BodyText {
                                    anchors.left: parent.right
                                    anchors.baseline: parent.baseline
                                    text: channelName
                                    color: "dimgray"
                                }
                            }

                            BodyText {
                                text: channelTitle
                                font.bold: true
                                width: channelContainer.width
                                clip: true
                            }

                            ProgressBar {
                                width: channelContainer.width
                                height: 20
                                value: channelValue
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: -10
        width: panel.width
        hoverEnabled: true
    }
}
