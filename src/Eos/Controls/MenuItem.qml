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

CheckableItem {
    id: root

    style: MenuItemStyle{}

    signal triggered()

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    width: parent.width

    textFont: root.style.menuItemFont
    textFontSize: root.style.menuItemFontSize

    spacing: root.style.menuItemSpacing
    horizontalPadding: root.style.menuItemHorizontalPadding
    verticalPadding: root.style.menuItemVerticalPadding

    onClicked: triggered()

    function trigger() {
        root.checked = true;
        triggered()
    }

    backgroundItem: Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1

        color: checked ? "#226b9a" : ( (root.state == "focused") ? "#2a4f67" : "#333333" )
    }

    states: [
        State {
            name: "normal"
            when: enabled && !activeFocus && !down
            PropertyChanges { target: root
                checkMarkColor: style.menuItemCheckMarkColor
                checkMarkBackgroundColor: style.menuItemCheckMarkBackgroundColor
                textColor: style.menuItemTextColor
            }
        },
        State {
            name: "pressed"
            when: enabled && !activeFocus && down
            PropertyChanges { target: root
                checkMarkColor: style.menuItemCheckMarkPressedColor
                checkMarkBackgroundColor: style.menuItemCheckMarkBackgroundPressedColor
                textColor: style.menuItemTextPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && activeFocus
            PropertyChanges { target: root;
                checkMarkColor: style.menuItemCheckMarkFocusedColor
                checkMarkBackgroundColor: root.focusedColor ? root.focusedColor : style.menuItemCheckMarkBackgroundFocusedColor
                textColor: style.menuItemTextFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root
                checkMarkColor: style.menuItemCheckMarkDisabledColor
                checkMarkBackgroundColor: style.menuItemCheckMarkBackgroundDisabledColor
                textColor: style.menuItemTextDisabledColor
            }
        }
    ]
}
