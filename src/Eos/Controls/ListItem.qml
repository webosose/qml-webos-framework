// Copyright (c) 2014-2018 LG Electronics, Inc.
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

    style: ListItemStyle{}

    signal triggered()

    width: parent.width

    property string iconSource

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    indicator: Image {
        source : root.iconSource
        width: 50
        height: 50
        asynchronous: true
    }

    textFont: root.style.listItemFont
    textFontSize: root.style.listItemFontSize

    spacing: root.style.listItemSpacing
    horizontalPadding: root.style.listItemHorizontalPadding
    verticalPadding: root.style.listItemVerticalPadding

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

        color: checked ? "#cf0652" : ( (root.state == "focused") ? Qt.rgba(0.811, 0.023, 0.321, 0.5 ) : "transparent" )
    }

    states: [
        State {
            name: "normal"
            when: enabled && !activeFocus && !down
            PropertyChanges { target: root
                checkMarkColor: style.listItemCheckMarkColor
                checkMarkBackgroundColor: style.listItemCheckMarkBackgroundColor
                textColor: style.listItemTextColor
            }
        },
        State {
            name: "pressed"
            when: enabled && !activeFocus && down
            PropertyChanges { target: root
                checkMarkColor: style.listItemCheckMarkPressedColor
                checkMarkBackgroundColor: style.listItemCheckMarkBackgroundPressedColor
                textColor: style.listItemTextPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && activeFocus
            PropertyChanges { target: root;
                checkMarkColor: style.listItemCheckMarkFocusedColor
                checkMarkBackgroundColor: root.focusedColor ? root.focusedColor : style.listItemCheckMarkBackgroundFocusedColor
                textColor: style.listItemTextFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root
                checkMarkColor: style.listItemCheckMarkDisabledColor
                checkMarkBackgroundColor: style.listItemCheckMarkBackgroundDisabledColor
                textColor: style.listItemTextDisabledColor
            }
        }
    ]
}
