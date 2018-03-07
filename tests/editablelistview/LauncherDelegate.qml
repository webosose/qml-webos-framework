// Copyright (c) 2015-2018 LG Electronics, Inc.
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
import Eos.Items 0.1
import "style.js" as Style

EditableDelegate {
    id: delegate

    // Indicate to the list what is the actual item to move around
    contentItem: c

    property bool current: ListView.view.currentItem === this
    onCurrentChanged: {
        if (current) {
            console.log(model.name);
        }
    }

    Rectangle {
        id: c
        x: 0
        y: 0
        width: Style.launchPoint.width
        height: Style.launchPoint.height

        color: "gray"
        Text {
            anchors.centerIn: parent
            text: name
            color: "white"
            font.pixelSize: 32
        }
    }
}
