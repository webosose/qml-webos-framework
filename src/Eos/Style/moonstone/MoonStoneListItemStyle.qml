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

Item {
    id: root

    property color listItemCheckMarkBackgroundColor: "white"
    property color listItemCheckMarkColor: "#888888"
    property color listItemTextColor: "white"

    property color listItemCheckMarkBackgroundPressedColor: "#404040"
    property color listItemCheckMarkPressedColor: "#a6a6a6"
    property color listItemTextPressedColor: "#a6a6a6"

    property color listItemCheckMarkBackgroundFocusedColor: "#cf0652"
    property color listItemCheckMarkFocusedColor: "white"
    property color listItemTextFocusedColor: "#a6a6a6"

    property color listItemCheckMarkBackgroundDisabledColor: "#262626"
    property color listItemCheckMarkDisabledColor: "#363636"
    property color listItemTextDisabledColor: "#666666"

    property string listItemFont: "MuseoSans Bold"
    property real listItemFontSize: 24

    property real listItemSpacing: 20
    property real listItemVerticalPadding: 10
    property real listItemHorizontalPadding: 10

    property real listItemIndicatorSize: 25
}
