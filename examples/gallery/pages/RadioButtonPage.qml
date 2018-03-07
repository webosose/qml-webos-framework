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
import "../"

GalleryPage {
    Column {
        spacing: 10

        anchors.fill: parent
        anchors.margins: 10


        GroupBox {
            id: radioButtonGroupBox
            title: "Radio Buttons ..."

            anchors.left: parent.left
            anchors.right: parent.right

            focus: true

            Row {
                ExclusiveGroup { id: group }
                RadioButton {
                    id: radioButton1
                    text: "Cat"

                    checked: true

                    exclusiveGroup: group

                    KeyNavigation.right: radioButton2
                }
                RadioButton {
                    id: radioButton2
                    text: "Dog"

                    exclusiveGroup: group

                    KeyNavigation.right: radioButton3
                }
                RadioButton {
                    id: radioButton3
                    text: "Whale"
                    enabled: false

                    exclusiveGroup: group

                    KeyNavigation.right: radioButton4
                }
                RadioButton {
                    id: radioButton4
                    text: "Toad"

                    exclusiveGroup: group
                }

            }
        }
    }
}
