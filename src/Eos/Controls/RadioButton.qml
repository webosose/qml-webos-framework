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

    style: RadioButtonStyle{}

    /*!
        \qmlproperty var focusedColor

        Provides the focused color of the button
    */
    property var focusedColor

    textFont: root.style.radioButtonFont
    textFontSize: root.style.radioButtonFontSize

    spacing: root.style.radioButtonSpacing
    horizontalPadding: root.style.radioButtonHorizontalPadding
    verticalPadding: root.style.radioButtonVerticalPadding

    indicator: RadioButtonIcon {
        checked: root.checked

        foregroundColor: root.checkMarkColor
        backgroundColor: root.checkMarkBackgroundColor

        anchors.fill: parent
    }

    indicatorSize: root.style.radioButtonIndicatorSize

    states: [
        State {
            name: "normal"
            when: enabled && !activeFocus && !down
            PropertyChanges { target: root
                checkMarkColor: style.radioButtonCheckMarkColor
                checkMarkBackgroundColor: style.radioButtonCheckMarkBackgroundColor
                textColor: style.radioButtonTextColor
            }
        },
        State {
            name: "pressed"
            when: enabled && !activeFocus && down
            PropertyChanges { target: root
                checkMarkColor: style.radioButtonCheckMarkPressedColor
                checkMarkBackgroundColor: style.radioButtonCheckMarkBackgroundPressedColor
                textColor: style.radioButtonTextPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && activeFocus
            PropertyChanges { target: root;
                checkMarkColor: style.radioButtonCheckMarkFocusedColor
                checkMarkBackgroundColor: root.focusedColor ? root.focusedColor : style.radioButtonCheckMarkBackgroundFocusedColor
                textColor: style.radioButtonTextFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root
                checkMarkColor: style.radioButtonCheckMarkDisabledColor
                checkMarkBackgroundColor: style.radioButtonCheckMarkBackgroundDisabledColor
                textColor: style.radioButtonTextDisabledColor
            }
        }
    ]
}
