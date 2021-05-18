// Copyright (c) 2013-2021 LG Electronics, Inc.
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

FocusScope {
    id: root

    property alias text: label.text
    property alias font: label.font

    property bool hovered: mouseArea.containsMouse
    property bool down: false

    property bool checked: false

    property variant style

    property color checkMarkColor
    property color checkMarkBackgroundColor
    property string textFont
    property real textFontSize
    property color textColor

    property Item backgroundItem
    property bool checkMarkBackground: false

    property real spacing: 10
    property real horizontalPadding: 10
    property real verticalPadding: 10

    property ExclusiveGroup exclusiveGroup

    property Item indicator
    property real indicatorSize: 50

    signal toggled(bool checked, Item sender)
    signal clicked
    signal pressed
    signal released
    signal pressAndHold

    enabled: true

    onBackgroundItemChanged: {
        if (backgroundItem) backgroundItem.parent = backgroundContainer
    }

    Item {
        id: backgroundContainer
        anchors.fill: parent
    }

    Component.onCompleted: {
        if (indicator) indicator.parent = indicatorContainer
    }

    onExclusiveGroupChanged: exclusiveGroup.bindCheckable(root)

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            root.down = true;
            root.pressed();
        }
    }
    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.checked == false) root.checked = true;
            else if (root.checked == true && root.exclusiveGroup == null) root.checked = false;

            root.toggled(root.checked, root);
            root.down = false;
            root.released();
            root.clicked();
        }
    }

    implicitHeight: Math.max(label.paintedHeight, indicatorSize) + 2 * root.verticalPadding
    implicitWidth: indicatorContainer.width + root.spacing + label.implicitWidth + 2 * root.horizontalPadding

    // prevent the button from getting too small
    onWidthChanged: d.checkWidth()
    onHeightChanged: d.checkHeight()
    onIndicatorChanged: {
        indicator.parent = indicatorContainer
        d.checkHeight();
        d.checkWidth();
    }

    onTextChanged: { d.checkHeight(); d.checkWidth(); }

    QtObject {
        id: d

        function checkWidth() {
            if (width != 0 && width < implicitWidth) {
                width = implicitWidth;
            }
        }

        function checkHeight() {
            if (height != 0 && height < implicitHeight ) {
                height = implicitHeight
            }
        }
    }

    Rectangle {
        id: indicatorContainer

        width: root.indicatorSize
        height: root.indicatorSize

        anchors.left: (spacing >= 0) ? root.left : undefined
        anchors.right: (spacing >= 0) ? undefined : root.right
        anchors.verticalCenter: parent.verticalCenter

        color: "transparent"
    }

    Text {
        id: label

        color: root.textColor

        anchors.verticalCenter: indicatorContainer.verticalCenter
        anchors.left: (spacing >= 0) ? indicatorContainer.right : root.left
        anchors.right: (spacing >= 0) ? root.right : indicatorContainer.left
        anchors.leftMargin: (spacing >= 0) ? root.spacing : 0
        anchors.rightMargin: (spacing >= 0) ? 0 : root.spacing

        font.family: root.textFont
        font.pixelSize: root.textFontSize

        elide: Text.ElideRight

        visible: text.length > 0
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true

//        onClicked: root.clicked() //We call clicked twice!!! (second time onReleased) - it is incorrect
        onPressed: (mouse) => {
            root.down = true;
            root.pressed();
        }
        onReleased: (mouse) => {
            if (root.checked == false) root.checked = true;
            else if (root.checked == true && root.exclusiveGroup == null) root.checked = false;

            root.down = false;
            root.toggled(root.checked, root);
            root.released();
            root.clicked();
        }
        onPressAndHold: (mouse) => { root.pressAndHold(); }
        onEntered: root.forceActiveFocus()
    }
}
