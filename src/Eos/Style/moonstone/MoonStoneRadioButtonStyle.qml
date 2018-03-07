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

    property color radioButtonCheckMarkBackgroundColor: "white"
    property color radioButtonCheckMarkColor: "#888888"
    property color radioButtonTextColor: "#a6a6a6"

    property color radioButtonCheckMarkBackgroundPressedColor: "#404040"
    property color radioButtonCheckMarkPressedColor: "#a6a6a6"
    property color radioButtonTextPressedColor: "#a6a6a6"

    property color radioButtonCheckMarkBackgroundFocusedColor: "#cf0652"
    property color radioButtonCheckMarkFocusedColor: "white"
    property color radioButtonTextFocusedColor: "white"

    property color radioButtonCheckMarkBackgroundDisabledColor: "#262626"
    property color radioButtonCheckMarkDisabledColor: "#363636"
    property color radioButtonTextDisabledColor: "#666666"

    property string radioButtonFont: "MuseoSans Bold"
    property real radioButtonFontSize: 36

    property real radioButtonSpacing: 20
    property real radioButtonVerticalPadding: 10
    property real radioButtonHorizontalPadding: 10

    property real radioButtonIndicatorSize: 25
}
