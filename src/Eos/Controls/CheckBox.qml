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

    style: CheckBoxStyle{}

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the CheckBox
    */
    property var focusedColor

    textFont: root.style.checkBoxFont
    textFontSize: root.style.checkBoxFontSize

    spacing: root.style.checkBoxSpacing
    horizontalPadding: root.style.checkBoxHorizontalPadding
    verticalPadding: root.style.checkBoxVerticalPadding

    indicator: CheckBoxIcon {
        checked: root.checked

        foregroundColor: root.checkMarkColor
        backgroundColor: checkMarkBackground ? root.checkMarkBackgroundColor : "transparent"

        anchors.fill: parent
    }

    indicatorSize: root.style.checkBoxIndicatorSize

    states: [
        State {
            name: "normal"
            when: enabled && !activeFocus && !down
            PropertyChanges { target: root
                checkMarkColor: style.checkBoxCheckMarkColor
                checkMarkBackgroundColor: style.checkBoxCheckMarkBackgroundColor
                textColor: style.checkBoxTextColor
            }
        },
        State {
            name: "pressed"
            when: enabled && !activeFocus && down
            PropertyChanges { target: root
                checkMarkColor: style.checkBoxCheckMarkPressedColor
                checkMarkBackgroundColor: style.checkBoxCheckMarkBackgroundPressedColor
                textColor: style.checkBoxTextPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && activeFocus
            PropertyChanges { target: root;
                checkMarkColor: style.checkBoxCheckMarkFocusedColor
                checkMarkBackgroundColor: root.focusedColor ? root.focusedColor : style.checkBoxCheckMarkBackgroundFocusedColor
                textColor: style.checkBoxTextFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root
                checkMarkColor: style.checkBoxCheckMarkDisabledColor
                checkMarkBackgroundColor: style.checkBoxCheckMarkBackgroundDisabledColor
                textColor: style.checkBoxTextDisabledColor
            }
        }
    ]
}
