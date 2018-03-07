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

/*!
    \qmltype Button
    \since Eos 0.1
    \brief The Button element provides a clickable button.
*/
FocusScope {
    id: root

    /*!
        \qmlproperty string text

        The text displayed on the button. By default the string is empty.
        If the string is empty the button will show no text.
    */
    property string text

    /*!
        \qmlproperty url iconSource

        The url for the icon displayed on the button. By default the
        iconSource property is empty. If the url is empty the button will
        show no icon.
    */
    property url iconSource

    /*!
        \qmlproperty bool hovered

        Indicates whether the button is hovered by the pointing device.
    */
    property bool hovered: mouseArea.containsMouse

    /*!
        \qmlproperty bool pressed

        Allows to check whether the button is pressed.
    */
    property bool pressed: false

    /*!
        \qmlproperty bool checkable

        This property determines whether the button can be toggled.
    */
    property bool checkable: false

    /*!
        \qmlproperty bool checked

        Allows to determine whether a checkable button is checked.
    */
    property bool checked: false

    /*!
        \qmlproperty variant style

        Points to a button style element that describes the styling
        of the button.
    */
    property variant style: ButtonStyle{}

    /*!
        \qmlproperty color color

        Background color of the button.
    */
    property color color

    /*!
        \qmlproperty color textColor

        Provides the color of the button's text label.
    */
    property color textColor

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    /*!
        \qmlproperty QtObject border

        This property group describes the look and feel of the
        button's border: The width and the color of the border.
    */
    property QtObject border: QtObject {
        property real width: root.style.buttonBorderWidth
        property color color
    }

    /*!
        \qmlproperty Item backgroundItem

        This item holds the implementation for the background.
        By default the background consists of a rounded
        rectangle with a border.
    */
    property Item backgroundItem: style.backgroundItem

    /*!
        \qmlproperty Item backgroundItem

        This item holds the implementation for the tooltip
        which appears when the mouse hovers the button.
    */
    property Item tooltipDelegate: DefaultTooltip {}

    /*!
        \qmlproperty string tooltip

        Allows to easily set the text inside a tooltip.
    */
    property string tooltip

    /*!
        \qmlproperty Item contextualPopup

        The item associated with this property allows
        to assign a contextualPopup to the button.
    */
    property Item contextualPopup

    /*!
        \qmlsignal clicked(var mouse)

        This signal is emitted whenever a user clicks
        the button: This requires that the button is
        pressed and released. The "mouse" paremeter is
        MouseEvent passed from MouseArea event, or null
        if the signal was triggered by Key event.
    */
    signal clicked(var mouse)

    /*!
        \qmlsignal pressAndHold(var mouse)

        If the user presses the button and keeps pressing for a while
        then this signal is emitted. The "mouse" paremeter is
        MouseEvent passed from MouseArea event.
    */
    signal pressAndHold(var mouse)

    /*!
        \qmlsignal toggled(bool checked)

        A checkable button emits the toggle signal every time the checked
        property changes. The value of the checked property is carried
        as a parameter of the signal.
    */
    signal toggled(bool checked)

    /*!
        \qmlproperty bool cursorHidden

        We get signal on entered when button appears under hidden cursor.
        We need to force active focus when cursor is on screen (visible).
    */
    property bool cursorHidden: false

    enabled: true

    onTooltipDelegateChanged: {
        tooltipDelegate.parent = tooltipContainer
    }

    onBackgroundItemChanged: {
        backgroundItem.parent = backgroundContainer
    }

    onContextualPopupChanged: {
        contextualPopup.parent = contextualPopupContainer
    }

    onClicked: {
        if (contextualPopup) {
            contextualPopup.parent = contextualPopupContainer
            contextualPopup.state = (contextualPopup.state == "opened") ? "closed" : "opened"
            contextualPopup.focus = contextualPopup.state == "opened"
        }
    }

    onFocusChanged: {
        tooltipDelegate.parent = tooltipContainer
        tooltipDelegate.text = root.tooltip
        if (focus) {
            tooltipDelegate.state = "opened"
        } else {
            tooltipDelegate.state = "closed"
            root.pressed = false
        }
    }

    Connections {
        target: contextualPopup
        onStateChanged: if (contextualPopup.state == "closed") root.focus = true
    }

    Item {
        id: tooltipContainer
        anchors.fill: parent
    }
    Item {
        id: contextualPopupContainer
        anchors.fill: parent
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (!root.checkable) {
                root.pressed = true
            }
        }
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.checkable) {
                root.checked = !root.checked
                root.toggled(root.checked)
            } else {
                root.pressed = false
            }
            root.clicked(null)
        }
    }

    implicitHeight: Math.max(buttonText.paintedHeight, buttonIcon.height) + 2 * style.buttonVerticalPadding;
    implicitWidth: buttonIcon.width + content.appliedSpacing + buttonText.paintedWidth + 2 * style.buttonHorizontalPadding


    // prevent the button from getting too small
    onImplicitHeightChanged: d.checkHeight();
    onImplicitWidthChanged: d.checkWidth();
    onWidthChanged: d.checkWidth();
    onHeightChanged: d.checkHeight();
    onTextChanged: { d.checkHeight(); d.checkWidth(); }

    QtObject {
        id: d

        function checkWidth() {
            if (width == 0)
                return;
            if (implicitWidth < implicitHeight) {
                if (width < implicitHeight) {
                    width = implicitHeight
                }
            } else if (width < implicitWidth) {
                width = implicitWidth;
            }
        }

        function checkHeight() {
            if (height != 0 && height < implicitHeight ) {
                height = implicitHeight
            }
        }
    }


    states: [
        State {
            name: "normal"
            when: enabled && !focus && !checked && !pressed
            PropertyChanges { target: root;
                color: style.buttonBackgroundColor
                textColor: style.buttonForegroundColor
                border.color: style.buttonBorderColor
            }
        },
        State {
            name: "pressed"
            when: enabled && (checked || pressed)
            PropertyChanges { target: root;
                color: style.buttonBackgroundPressedColor
                textColor: style.buttonForegroundPressedColor
                border.color: root.focusedColor ? root.focusedColor : style.buttonBorderPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && focus
            PropertyChanges { target: root;
                color: root.focusedColor ? root.focusedColor : style.buttonBackgroundFocusedColor
                textColor: style.buttonForegroundFocusedColor
                border.color: root.focusedColor ? root.focusedColor : style.buttonBorderFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root;
                color: style.buttonBackgroundDisabledColor
                textColor: style.buttonForegroundDisabledColor
                border.color: style.buttonBorderDisabledColor
            }
        }
    ]

    Item {
        id: backgroundContainer
        anchors.fill: parent
    }

    Item {
        id: content
        anchors.centerIn: parent

        property real appliedSpacing: (buttonIcon.width > 0 && buttonText.implicitWidth > 0) ? style.buttonSpacing : 0

        Image {
            id: buttonIcon
            source: root.iconSource
            anchors.right: buttonText.left
            anchors.rightMargin: content.appliedSpacing
            anchors.verticalCenter: parent.verticalCenter

            onWidthChanged: d.checkWidth()
            onHeightChanged: d.checkHeight()
            asynchronous: true
        }

        Text {
            id: buttonText

            text: root.text
            color: root.textColor

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (buttonIcon.width + content.appliedSpacing) / 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: root.style.buttonFontSize
            font.family: root.style.buttonFont
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase

            elide: Text.ElideRight

            onPaintedWidthChanged: d.checkWidth()
            onPaintedHeightChanged: d.checkHeight()
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: root
        enabled: root.enabled
        hoverEnabled: true

        onClicked: root.clicked(mouse);
        onPressed: {
            if (!root.checkable) {
                root.pressed = true
            }
        }
        onReleased: {
            if (root.checkable) {
                root.checked = !root.checked
                root.toggled(root.checked)
            } else {
                root.pressed = false
            }
        }
        onPressAndHold: root.pressAndHold(mouse);
        onEntered: {
            if (!cursorHidden) { //See cursorHidden description
                root.forceActiveFocus()
            }
        }
    }
}
