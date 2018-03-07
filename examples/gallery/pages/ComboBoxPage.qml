// Copyright (c) 2015-2018 LG Electronics, Inc.
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
        anchors.left: parent.left
        anchors.top: parent.top

        anchors.leftMargin: 100
        anchors.topMargin: 100

        Button {
            width: vege.width
            height: 100
            text: "Increment idx"

            onClicked: {
                vege.selectedIndex = (vege.selectedIndex + 1) % vege.count
            }
        }

        ComboBox {
            id: vege
            headerText: qsTr("Vegan's Meal")

            model: ["Tomato", "Potato", "Corn", "Garlic"]

        }

        KeyNavigation.right: combo
    }

    ComboBox {
        id: combo

        headerText: qsTr("Select Source")

        model: ListModel {
            ListElement {
                text: "Antena TV"
            }
            ListElement {
                text: "Settop Box1"
            }
            ListElement {
                text: "Settop Box2"
            }
            ListElement {
                text: "Cable"
            }
        }

        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 100
        anchors.topMargin: 100

        KeyNavigation.left: vege
    }
}
