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

Rectangle {
    id: lineEdit

    property bool enabled: true
    property bool enableOnClick: false
    property alias text: textInput.text
    property alias font: textInput.font
    property alias inputMask: textInput.inputMask
    property alias horizontalAlignment: textInput.horizontalAlignment

    height: textInput.font.pixelSize * 2
    radius: height / 2
    width: textInput.implicitWidth + height
    implicitWidth: textInput.implicitWidth + height

    color: enabled ? "white" : "transparent"
    border.width: enabled ? 3 : 0
    border.color: enabled ? (textInput.activeFocus ? "#FFCC00" : "#5D5D5D") : "transparent"
    antialiasing: true;

    // prevent the lineedit from getting too small
    //onWidthChanged: __checkWidth()
    onHeightChanged: __checkHeight()
    onFocusChanged: { if(focus) textInput.forceActiveFocus() }

    states: State {
        name: "disabled"; when: !enabled
        PropertyChanges {
            target: textInput;
            anchors.left: lineEdit.left
            anchors.leftMargin: 0
            restoreEntryValues: true
        }
    }

    function __checkWidth() {
        if (width < height + radius)
            width = height + radius
    }

    function __checkHeight() {
        if (height < textInput.font.pixelSize * 2)
            height = textInput.font.pixelSize * 2
    }

    TextInput {
        id: textInput

        anchors.verticalCenter: lineEdit.verticalCenter
        anchors.left: lineEdit.left
        anchors.leftMargin: lineEdit.radius
        clip: true
        enabled: lineEdit.enabled

        horizontalAlignment: inputMask.length < 1 ? TextInput.AlignLeft : TextInput.AlignHCenter;
        color: "black"
        font.family: tvSettingsApp.style.baseFont.name
        font.pixelSize: tvSettingsApp.style.baseFontSize

        onFocusChanged: {
            if (!focus && lineEdit.enableOnClick)
                lineEdit.enabled = false;

            clickEater.enabled = (!focus && lineEdit.enableOnClick);
        }
    }

    MouseArea {
        id: clickEater
        anchors.fill: parent

        enabled: lineEdit.enableOnClick
        onClicked: { lineEdit.enabled = true; lineEdit.forceActiveFocus() }
    }
}
