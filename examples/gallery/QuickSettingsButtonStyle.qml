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

    property real buttonBorderWidth: 0

    property color buttonBackgroundColor: "#404040"
    property color buttonForegroundColor: "#a6a6a6"
    property color buttonBorderColor: "#404040"

    property color buttonBackgroundPressedColor: root.buttonBackgroundColor
    property color buttonForegroundPressedColor: root.buttonForegroundColor
    property color buttonBorderPressedColor: root.buttonBorderColor

    property color buttonBackgroundFocusedColor: root.buttonBackgroundColor
    property color buttonForegroundFocusedColor: root.buttonForegroundColor
    property color buttonBorderFocusedColor: root.buttonBorderColor

    property color buttonBackgroundDisabledColor: root.buttonBackgroundColor
    property color buttonForegroundDisabledColor: root.buttonForegroundColor
    property color buttonBorderDisabledColor: root.buttonBorderColor

    property string buttonFont: "Miso"
    property real buttonFontSize: 40

    property real buttonSpacing: 10
    property real buttonHorizontalPadding: 0
    property real buttonVerticalPadding: 0

    property Item backgroundItem: Rectangle {
        property Item controlRoot: (parent && parent.parent) ? parent.parent : null

        color: controlRoot != null ? controlRoot.color : "transparent"
        border.width: controlRoot != null ? controlRoot.border.width : 0
        border.color: controlRoot != null ? controlRoot.border.color : "transparent"

        anchors.centerIn: parent
        width: controlRoot.focus ? parent.width + 10 : parent.width
        height: controlRoot.focus ? parent.height + 10 : parent.height

        antialiasing: true

        radius: height / 2

    }
}
