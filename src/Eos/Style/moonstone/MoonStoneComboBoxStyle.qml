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

    property real   comboWidth: 351
    property real   comboItemHeight: 100
    property string comboFocusColor: "#CF0652"
    property string comboBgColor: "#323232"

    property real comboVerticalMargin: 40
    property real comboHorizontalMargin: 35

    property real comboCornerRadius: 25

    property int    comboHeaderFontSize : 32
    property string comboHeaderFontFamiliy : "Museo Sans"
    property color  comboHeaderColor : "white"
    property real   comboHeaderHeight: 80

    property int    comboItemFontSize : 38
    property string comboItemFontFamiliy : "Museo Sans"
    property color  comboItemColor : "white"

    property int comboAnimationTime: 250
}
