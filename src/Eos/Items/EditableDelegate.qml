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

FocusScope {
    id: delegate

    property bool current: ListView.view.currentItem === this
    property bool mouseEditing: false
    property int index: model.index

    // Should be set from the actual deriving delegate. This need to be
    // able to move freely when using the pointer to re-order items
    // and will be anchored to the mouse area on top of the list
    property Item contentItem: Item {}

    // set to transparent/remove once working... this is for
    // debug purposes
    Rectangle {
        id: filler
        color: "red"
        anchors.fill: parent
    }

    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges { target: delegate; y: 0 }
        },
        State {
            name: "current"
            when: delegate.current
            PropertyChanges { target: delegate; y: -20 }
            PropertyChanges { target: contentItem; y: 0 }
        },
        State {
            name: "editing"
            PropertyChanges { target: delegate; y: -40 }
            PropertyChanges { target: contentItem; y: mouseEditing ? -40 : 0 }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "current"
            NumberAnimation {
                targets: [delegate, contentItem]
                property: "y"
                easing.type: Easing.OutQuad
                duration: 150
            }
        }
    ]
}
