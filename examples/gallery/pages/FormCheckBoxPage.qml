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
                id: checkBoxGroupBox
                title: "Form Checkbox Items (Default)"

                anchors.left: parent.left
                anchors.right: parent.right

                focus: true

                Column {

                    CheckBox {
                        id: checkBox1
                        text: "Option 1"

                        checked: true
                        checkMarkBackground: true

                        KeyNavigation.down: checkBox2
                    }

                    CheckBox {
                        id: checkBox2
                        text: "Option 2"

                        checkMarkBackground: true

                        KeyNavigation.down: checkBox3
                    }

                    CheckBox {
                        id: checkBox3
                        text: "Disabled"

                        enabled: false

                        checkMarkBackground: true

                        KeyNavigation.down: checkBox4
                    }

                    CheckBox {
                        id: checkBox4
                        text: "Option 4"

                        checked: true

                        checkMarkBackground: true
                    }
                }
            }
    }
}
