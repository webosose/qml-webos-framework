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
import Eos.Window 0.1

WebOSWindow {
    id: overlay

    width: 1920 / 2
    height: 1080
    windowType: "_WEBOS_WINDOW_TYPE_OVERLAY"
    locationHint: WebOSWindow.LocationHintEast
    visible: true
    appId: "eos.overlay"
    title: "eos.overlay"

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#80ffffff"
        border { color: "#fff"; width: 4 }
    }

    Text {
        anchors.centerIn: parent
        text: "Eos overlay " + overlay.width + "x" + overlay.height
        color: "white"
    }
}
