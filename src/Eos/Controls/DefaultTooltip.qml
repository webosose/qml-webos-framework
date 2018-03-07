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

Tooltip {
    id: root

    offsetX: (visualParent !== null ) ? visualParent.width * 2/5 : 0
    offsetY: (visualParent !== null ) ? visualParent.height + 10 : 0

    implicitWidth: label.implicitWidth + 2 * horizontalPadding
    implicitHeight: label.implicitHeight + 2 * verticalPadding

    property string text: "ToolTip"

    property real horizontalPadding: style.tooltipHorizontalPadding
    property real verticalPadding: style.tooltipVerticalPadding

    style: TooltipStyle{}

    Rectangle {
        id: background

        color: style.tooltipBackgroundColor
        radius: height/2

        anchors.fill: parent

        visible: label.text != ""

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            color: parent.color
            height: parent.height/2
            width: parent.height/2
        }

        Text {
            id: label

            text: root.text
            color: root.style.tooltipTextColor

            font.family: root.style.tooltipFont
            font.pixelSize: root.style.tooltipFontSize
            font.capitalization: Font.AllUppercase

            anchors.centerIn: parent
        }
    }

    transitions: [
        Transition {
            from: "closed" ;to: "opened"
            PropertyAnimation { target: root
                                properties: "opacity";
                                from: "0.0";
                                to: "1.0"
                                duration: 200 }
        },
        Transition {
            from: "opened" ;to: "closed"
            SequentialAnimation {
                PropertyAnimation { target: root
                                    properties: "opacity";
                                    from: "1.0";
                                    to: "0.0"
                                    duration: 200 }
                ScriptAction { scriptName: "closeMethod" }
            }
        }

    ]
}
