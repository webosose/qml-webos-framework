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

    style: ToggleItemStyle{}

    textFont: root.style.toggleItemFont
    textFontSize: root.style.toggleItemFontSize

    spacing: root.style.toggleItemSpacing
    horizontalPadding: root.style.toggleItemHorizontalPadding
    verticalPadding: root.style.toggleItemVerticalPadding

    indicator: ToggleItemIcon {
        checked: root.checked

        foregroundColor: root.textColor
        backgroundColor: "transparent"

        fontFamily: root.textFont
        fontSize: root.textFontSize

        anchors.fill: parent
    }

    indicatorSize: root.style.toggleItemIndicatorSize

    states: [
        State {
            name: "normal"
            when: enabled && !activeFocus && !down
            PropertyChanges { target: root
                textColor: style.toggleItemTextColor
            }
        },
        State {
            name: "pressed"
            when: enabled && !activeFocus && down
            PropertyChanges { target: root
                textColor: style.toggleItemTextPressedColor
            }
        },
        State {
            name: "focused"
            when: enabled && activeFocus
            PropertyChanges { target: root;
                textColor: style.toggleItemTextFocusedColor
            }
        },
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: root
                textColor: style.toggleItemTextDisabledColor
            }
        }
    ]
}
