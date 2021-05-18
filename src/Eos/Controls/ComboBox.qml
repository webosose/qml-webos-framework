// Copyright (c) 2015-2021 LG Electronics, Inc.
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
import Eos.Items 0.1

/*!
    \qmltype ComboBox
    \since Eos 0.1
    \brief This is a drop down list control with pre-defined model
*/
FocusScope {
    id: root

    /*!
     \qmlsignal selected(int index)

     This signal is emited every time we select item from the list.
     Index of the item is passed as a parameter.
     */
    signal selected(int index)

    /*!
     \qmlproperty headerText holds the header of the combo box

     Width of the widget is automatically adjusted based on the lenght
     of this string
     */
    property string headerText

    /*!
     \qmlproperty Index of the currently checked index

     This is and integer index of the checked item
     First item is selected by default
     */
    property int selectedIndex: -1

    /*!
     \qmlproperty Index of the currently select index

     This is and integer index of the selected item
     First item is selected by default
     */
    property int currentIndex: comboList.currentIndex

    /*!
     \qmlproperty model property holds the model with possible options

     This model can be updated on the fly
     */
    property alias model: comboList.model

    /*!
     \qmlproperty count property holds number of items in drop down list

     This is read only value, available for simplicity
     */
    readonly property int count: comboList.count

    /*!
     \qmlproperty defines should the field be highlited regardless
     of the mouse in the area
     */
    property bool mustHighlight : false

    /*!
     \qmlproperty variant style

     Points to a ComboBox style element that describes the styling
     of the combo box.
     */
    property variant style: ComboBoxStyle{}

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    /*!
     \qmlmethod expand(bool toggle)

     Expands or collapses drop down list
     */
    function expand(toggle) {
        if (toggle) {
            root.state = "expanded";
            comboList.currentIndex = 0;
            comboList.forceActiveFocus();
        } else {
            root.state = "folded";
        }
    }

    /*!
     * The default width
     */
    width: root.style.comboWidth
    height: root.style.comboItemHeight + root.style.comboHeaderHeight

    QtObject {
        id: d
        property Item header: null
        property bool roundTopCorners: true
        property bool roundTopItem: true
        property bool canShowCheckMark: false
        property bool focusHeader: true
    }

    onSelectedIndexChanged: {
        if (root.state === "folded") {
            comboList.currentIndex = selectedIndex;
            comboList.positionViewAtIndex(root.selectedIndex, ListView.End);
        }
    }

    ListView {
        id: comboList

        anchors.top: root.top
        width: root.width

        orientation: Qt.Vertical
        interactive: false
        highlightFollowsCurrentItem: false

        // Always show the header and clip to hide the top parts when the selection
        // is scrolled visible when folded
        headerPositioning: ListView.OverlayHeader
        clip: true
        focus: true

        onActiveFocusChanged: {
            if (activeFocus) {
                d.focusHeader = true;
                d.header.forceActiveFocus();
            } else {
                reset();
            }
        }

        header: RoundedRectangle {
            id: header
            height: root.style.comboHeaderHeight
            width: comboList.width

            color: activeFocus ? (root.focusedColor ? root.focusedColor : root.style.comboFocusColor) : root.style.comboBgColor;
            radius: root.style.comboCornerRadius
            clipBottomLeft: false
            clipBottomRight: false
            // Make sure that the header is on top of all of the items in the model
            // See comment for header positioning
            z: comboList.count

            Text {
                id: comboHeaderText
                text: root.headerText

                anchors.topMargin: root.style.comboVerticalMargin - 10
                anchors.leftMargin: root.style.comboHorizontalMargin

                font.family: root.style.comboHeaderFontFamiliy
                font.pixelSize: root.style.comboHeaderFontSize

                color: root.style.comboHeaderColor

                opacity: 0.5

                anchors.top: parent.top
                anchors.left: parent.left
            }

            ComboBoxIcon {
                id: comboIcon
                property real rotate: 0.0

                backgroundColor: "transparent"

                width: 46
                height: 46

                anchors.right: parent.right
                anchors.rightMargin: 2/3 * root.style.comboHorizontalMargin
                anchors.top: parent.top
                anchors.topMargin: 0.5 * root.style.comboVerticalMargin
                rotation: root.state === "folded" ? 0 : -180

                Behavior on rotation {
                    NumberAnimation { }
                }
            }

            property alias area: area
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true;
                onEntered: header.forceActiveFocus();
                onClicked: (mouse) => { root.state = (root.state == "folded") ? "expanded" : "folded"; }
            }

            Keys.onReleased: (event) => {
                switch (event.key) {
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    root.state = (root.state == "folded") ? "expanded" : "folded";
                    break;
                default:
                    event.accepted = false;
                }
            }

            Keys.onDownPressed: (event) => {
                if (root.state === "expanded") {
                    comboList.currentIndex = 0;
                    comboList.currentItem.forceActiveFocus();
                    event.accepted = false;
                } else {
                    root.Keys.downPressed(event);
                }
            }

            Component.onCompleted: {
                d.header = header;
            }
        }

        delegate: comboListItem

        onModelChanged: {
            if (model.count || (Array.isArray(model) && model.length)) {
                root.selectedIndex = 0;
                currentIndex = 0;
            }
        }

        Keys.onDownPressed: (event) => {
            if (root.state === "folded") {
                event.accepted = false;
                return;
            }
            if (currentIndex == count-1) {
                event.accepted = false;
            }
            if (currentIndex >= 0) {
                incrementCurrentIndex();
            }
        }

        Keys.onUpPressed: (event) => {
            if (root.state === "folded") {
                event.accepted = false;
                return;
            }
            if (currentIndex > 0) {
                decrementCurrentIndex();
            } else {
                event.accepted = false;
            }
        }

        Keys.onLeftPressed: (event) => {
            if (root.state === "expanded") {
                return;
            }
            event.accepted = false;
            reset();
        }

        Keys.onRightPressed: (event) => {
            if (root.state === "expanded") {
                return;
            }
            event.accepted = false;
            reset();
        }

        function reset() {
            d.focusHeader = false;
            root.state = "folded";
        }

        KeyNavigation.up: d.header
    }

    Component {
        id: comboListItem

        RoundedRectangle {
            id: comboItem
            color: ((activeFocus && root.state === "expanded") || (d.header.activeFocus && root.state === "folded")) ? root.style.comboFocusColor : root.style.comboBgColor;
            focus: true

            width: root.width
            height: root.style.comboItemHeight

            radius: root.style.comboCornerRadius
            clipTopLeft: d.roundTopCorners
            clipTopRight: clipTopLeft
            clipBottomLeft: d.roundTopItem || (model.index === comboList.count - 1)
            clipBottomRight: clipBottomLeft

            CheckBoxIcon {
                id: comboItemIcon

                backgroundColor: "transparent"

                visible: model.index == root.selectedIndex && d.canShowCheckMark

                width: d.canShowCheckMark ? 30 : 0
                height: 30

                anchors.left: comboItem.left
                anchors.leftMargin: root.style.comboHorizontalMargin / 2

                anchors.verticalCenter: comboItemCaption.verticalCenter
            }

            Text {
                id: comboItemCaption
                text: modelData

                font.family: root.style.comboItemFontFamiliy
                font.pixelSize: root.style.comboItemFontSize

                color: root.style.comboItemColor

                elide: Text.ElideRight

                anchors.verticalCenter: comboItem.verticalCenter

                anchors.left: comboItemIcon.right
                anchors.leftMargin: root.style.comboHorizontalMargin/2

                anchors.right: comboItem.right
                anchors.rightMargin: root.style.comboHorizontalMargin
            }

            ComboBoxIcon {
                id: comboIcon
                property real rotate: 0.0

                backgroundColor: "transparent"

                width: 46
                height: 46

                anchors.right: parent.right
                anchors.rightMargin: 2/3 * root.style.comboHorizontalMargin
                anchors.top: parent.top
                anchors.topMargin: 0.5 * root.style.comboVerticalMargin
                visible: root.state === "folded" &&
                         root.selectedIndex == index && !d.canShowCheckMark
            }

            property MouseArea area : area
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true

                onClicked: (mouse) => {
                    if (root.state === "expanded") {
                        root.selectedIndex = index;
                        root.state = "folded";
                    } else {
                        root.expand(true);
                    }
                }

                onEntered: {
                    if (root.state === "folded") {
                        d.header.forceActiveFocus();
                    } else {
                        comboItem.forceActiveFocus();
                        comboList.currentIndex = model.index;
                    }
                }
            }

            Keys.onReleased: (event) => {
                switch (event.key) {
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    root.selectedIndex = index;
                    root.state = "folded";
                    event.accepted = true;
                    break;
                default:
                    event.accepted = false;
                }
            }
        }
    }

    state: "folded"

    states: [
        State {
            name: "folded"
            PropertyChanges { target: comboList; height: root.style.comboItemHeight }
            PropertyChanges { target: d.header; visible: false }
            PropertyChanges { target: d; roundTopItem: true }
            PropertyChanges { target: d; roundTopCorners: true }
            PropertyChanges { target: d; canShowCheckMark: false }
        },
        State {
            name: "expanded"
            PropertyChanges { target: comboList; height: root.style.comboItemHeight * comboList.count  + root.style.comboHeaderHeight }
            PropertyChanges { target: d.header; visible: true }
            PropertyChanges { target: d; roundTopItem: false }
            PropertyChanges { target: d; roundTopCorners: false }
            PropertyChanges { target: d; canShowCheckMark: true }
        }
    ]

    transitions: [
        Transition {
            from: "folded"
            to: "expanded"
            SequentialAnimation {
                id: expnadAnimation
                PropertyAction { target: d; properties: "roundTopItem, canShowCheckMark, roundTopCorners" }
                PropertyAction { target: d.header; property: "visible" }
                PropertyAnimation {
                    target: comboList
                    property: "height"
                    duration: root.style.comboAnimationTime
                    easing.type: Easing.InOutCubic
                }
            }
        },
        Transition {
            from: "expanded"
            to: "folded"
            SequentialAnimation {
                id: foldAnimation
                // Briefly pause to show the tick mark on the selected item
                PauseAnimation { duration: 50 }
                PropertyAnimation {
                    target: comboList
                    property: "height"
                    duration: root.style.comboAnimationTime
                    easing.type: Easing.InOutCubic
                }
                PropertyAction { target: d.header; property: "visible" }
                PropertyAction { target: d; properties: "roundTopItem, canShowCheckMark, roundTopCorners" }
                ScriptAction {
                    script: {
                        comboList.positionViewAtIndex(root.selectedIndex, ListView.End);
                        if (d.focusHeader) {
                            d.header.forceActiveFocus();
                        }
                    }
                }
            }
        }
    ]

    Component.onCompleted: {
        comboList.positionViewAtIndex(selectedIndex, ListView.End);
    }
}
