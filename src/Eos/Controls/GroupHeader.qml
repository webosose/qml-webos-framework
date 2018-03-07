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

    property string title

    property variant style: GroupHeaderStyle{}

    property color titleColor: root.style.groupHeaderTitleColor
    property string titleFontFamily: root.style.groupHeaderTitleFont
    property real titleFontSize: root.style.groupHeaderTitleFontSize
    property bool titleFontItalic: root.style.groupHeaderTitleFontItalic

    property color dividerColor: root.style.groupHeaderDividerColor
    property real dividerHeight: root.style.groupHeaderDividerHeight

    implicitWidth: titleText.paintedWidth
    implicitHeight: titleText.paintedHeight + divider.height

    onHeightChanged: d.checkHeight()

    QtObject {
        id: d

        function checkHeight() {
            if (height < implicitHeight ) {
                height = implicitHeight
            }
        }
    }

    Text {
        id: titleText
        text: root.title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        color: titleColor

        height: paintedHeight

        font.family: root.titleFontFamily
        font.pixelSize: root.titleFontSize
        font.italic: root.titleFontItalic
    }

    Rectangle {
        id: divider

        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: root.dividerHeight

        color: root.dividerColor
    }
}
