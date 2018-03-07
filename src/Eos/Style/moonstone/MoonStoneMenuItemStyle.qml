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

Item {
    id: root

    property color menuItemCheckMarkBackgroundColor: "white"
    property color menuItemCheckMarkColor: "#888888"
    property color menuItemTextColor: "white"

    property color menuItemCheckMarkBackgroundPressedColor: "#404040"
    property color menuItemCheckMarkPressedColor: "#a6a6a6"
    property color menuItemTextPressedColor: "#a6a6a6"

    property color menuItemCheckMarkBackgroundFocusedColor: "#cf0652"
    property color menuItemCheckMarkFocusedColor: "white"
    property color menuItemTextFocusedColor: "#a6a6a6"

    property color menuItemCheckMarkBackgroundDisabledColor: "#262626"
    property color menuItemCheckMarkDisabledColor: "#363636"
    property color menuItemTextDisabledColor: "#666666"

    property string menuItemFont: "MuseoSans Bold"
    property real menuItemFontSize: 24

    property real menuItemSpacing: 20
    property real menuItemVerticalPadding: 10
    property real menuItemHorizontalPadding: 10

    property real menuItemIndicatorSize: 25
}
