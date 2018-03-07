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
import Eos.Controls 0.1
import Eos.Style 0.1
import "../"

GalleryPage {

    id: root

    Column {
        spacing: 10

        GroupHeader {
            title: "Buttons:"
            width: root.width
        }

        Flow {
            id: buttonRow
            spacing: 10

            width: root.width

            Button {
                id: button1
                text: "Button"
                focus: true

                tooltip: "I'm a tooltip for a button."
                KeyNavigation.right: button2
                onClicked: resultText.showResult(this)
            }

            Button {
                id: button2
                text: "Toggle"
                checkable: true
                KeyNavigation.right: button3
                onClicked: resultText.showResult(this)
            }

            Button {
                id: button3
                text: "1"
                KeyNavigation.right: button4
                onClicked: resultText.showResult(this)
            }

            Button {
                id: button4
                iconSource: "../images/icon_home.png"
                KeyNavigation.right: button5
                onClicked: resultText.showResult(this)
            }

            Button {
                id: button5
                iconSource: "../images/icon_home.png"
                text: "Icon"
                enabled: false
                KeyNavigation.right: smallButton1
                onClicked: resultText.showResult(this)
            }

        }

        Flow {
            id: smallButtonRow
            spacing: 10

            width: root.width

            Button {
                id: smallButton1
                text: "Button"
                style: SmallButtonStyle {}

                tooltip: "I'm a tooltip for a button."
                KeyNavigation.right: smallButton2
                onClicked: resultText.showResult(this)
            }

            Button {
                id: smallButton2
                text: "Toggle"
                style: SmallButtonStyle {}

                checkable: true
                KeyNavigation.right: smallButton3
                onClicked: resultText.showResult(this)
            }

            Button {
                id: smallButton3
                text: "1"
                style: SmallButtonStyle {}

                KeyNavigation.right: smallButton4
                onClicked: resultText.showResult(this)
            }

            Button {
                id: smallButton4
                iconSource: "../images/icon_home.png"
                style: SmallButtonStyle {}

                KeyNavigation.right: smallButton5
                onClicked: resultText.showResult(this)
            }

            Button {
                id: smallButton5
                iconSource: "../images/icon_home.png"
                text: "Icon"
                style: SmallButtonStyle {}

                enabled: false
                onClicked: resultText.showResult(this)
            }
        }

        Item {
            width: 50; height: 100
        }

        GroupHeader {
            title: "Results:"
            width: root.width
        }

        BodyText {
            id: resultText
            text: "No button pressed yet."
            function showResult(control) {
                // TODO: use arguments.callee.caller.toString()
                // (since that only works with 5.1 but not with the new 5.2 JS engine)
                text = control + " (" + control.text + ") triggered."
            }
        }

    }

    Component.onCompleted: console.debug("ButtonPage.qml component completed")
}
