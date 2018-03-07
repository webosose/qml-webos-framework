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

Item {
    id: root

    width: 100
    height: 100

    property color backgroundColor: "gray"
    property color foregroundColor: "white"

    Rectangle {
        id: background

        anchors.fill: parent
        color: root.backgroundColor
        antialiasing: true

        rotation: 45

        radius: height/2

        Rectangle {
            id: checkMarkRightSide
            width: root.width * 1/6
            height: root.height/2

            color: root.foregroundColor
            antialiasing: true

            radius: width/2

            anchors.horizontalCenterOffset: width

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: checkMarkLeftSide
            width: root.height/2
            height: root.width * 1/6

            color: root.foregroundColor
            antialiasing: true

            radius: width/2

            anchors.bottom: checkMarkRightSide.bottom
            anchors.right: checkMarkRightSide.right
        }
    }
}
