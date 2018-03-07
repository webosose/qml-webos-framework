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

    property real currentIndex: 0
    property real itemCount: 6
    property color color: "white"

    implicitWidth: dotRow.childrenRect.width
    implicitHeight: dotRow.childrenRect.height

    Row {
        id: dotRow

        spacing: 0

        Item {
            width: currentIndex == 0 ? 0 : 2
            height: 12
        }

        Repeater {
            model: itemCount

            Row {
                Rectangle {
                    id: dot
                    color: root.color
                    width: (index == root.currentIndex) ? 10 : 6
                    height: width
                    radius: height / 2
                    anchors.verticalCenter: spacer.verticalCenter
                }
                Rectangle {
                    id: spacer
                    color: "transparent"
                    width: (index == root.currentIndex || index == root.currentIndex - 1) ? 10 : 12 //( (index == root.itemCount-1) ? 0 : 12 )
                    height: 12
                }
            }
        }
    }
}
