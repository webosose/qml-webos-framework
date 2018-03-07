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
import Eos.Style 0.1

Item {
    id: root

    property int minValue: 0
    property int maxValue: 100
    property int value: 50

    signal currentValueChanged(int value)

    property variant style: SliderStyle{}

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    width: 200
    height: 60

    QtObject {
        id: internal

        property int currentValue: (handleWrapper.x / root.width) * (Math.abs(root.maxValue) - Math.abs(root.minValue))
    }

    Rectangle {
        id: sliderGroove

        anchors.left: root.left
        anchors.leftMargin: root.height / 2
        anchors.right: root.right
        anchors.rightMargin: root.height / 2
        anchors.verticalCenter: root.verticalCenter
        height: root.height / 8
        radius: height / 2
        color: root.style.sliderGrooveColor
        antialiasing: true;

        Item {
            id: handleWrapper

            x: sliderGroove.width * (root.value / (Math.abs(root.maxValue) - Math.abs(root.minValue)))
            anchors.verticalCenter: parent.verticalCenter
            width: 1

            Rectangle {
                id: sliderHandle

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: root.height
                width: height
                radius: height / 2
                color: root.focusedColor ? root.focusedColor : root.style.sliderHandleColor
                antialiasing: true;

                MouseArea {
                    enabled: root.enabled
                    anchors.fill: parent

                    drag.axis: Drag.XAxis
                    drag.target: handleWrapper
                    drag.minimumX: 0
                    drag.maximumX: sliderGroove.width

                    onPositionChanged: root.currentValueChanged(internal.currentValue);
                }
            }
        }
    }
}
