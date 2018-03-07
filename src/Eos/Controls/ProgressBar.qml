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
import Eos.Style 0.1

Item {
    id: root

    property real value
    property real minimumValue: 0
    property real maximumValue: 100

    Item {
        id: grooveContainer
        anchors.fill: parent

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 5
            color: "gray"
            radius: height/2
            antialiasing: true
        }
    }

    Item {
        id: barContainer
        anchors.fill: parent

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / (root.maximumValue - root.minimumValue) * root.value
            height: 5
            color: "white"
            radius: height/2
            antialiasing: true
        }
    }
}
