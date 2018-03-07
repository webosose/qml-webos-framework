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

    property color toggleItemTextColor: "#a6a6a6"

    property color toggleItemTextPressedColor: "#a6a6a6"

    property color toggleItemTextFocusedColor: "white"

    property color toggleItemTextDisabledColor: "#4d4d4d"

    property string toggleItemFont: "MuseoSans Bold"
    property real toggleItemFontSize: 36

    property real toggleItemSpacing: -30
    property real toggleItemVerticalPadding: 10
    property real toggleItemHorizontalPadding: 10

    property real toggleItemIndicatorSize: 30
}
