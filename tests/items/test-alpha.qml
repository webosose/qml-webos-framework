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
import Eos.Controls 0.1

Page {
    anchors.fill: parent
    Component.onCompleted: {
        started();
    }
    signal done()
    signal started()

    Grid {
        columns: 5
        spacing: 40
        anchors.left: sources.right

        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram { anchors.fill: parent; color: Qt.rgba(255,0,0,1.0) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram { anchors.fill: parent; color: Qt.rgba(255,0,0,0.5) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram { anchors.fill: parent; color: Qt.rgba(255,0,0,0.0) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram { anchors.fill: parent; color: Qt.rgba(255,0,0,0.5); blending: false}
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            FastParallelogram { anchors.fill: parent; color: Qt.rgba(255,0,0,1.0); blending: true }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon { anchors.fill: parent; color: Qt.rgba(255,0,0,1.0) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon { anchors.fill: parent; color: Qt.rgba(255,0,0,0.5) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon { anchors.fill: parent; color: Qt.rgba(255,0,0,0.0) }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon { anchors.fill: parent; color: Qt.rgba(255,0,0,0.5); blending: false }
        }
        Rectangle {
            color: "white"
            width: 200; height: 200
            Beziergon { anchors.fill: parent; color: Qt.rgba(255,0,0,1.0); blending: true }
        }
    }
}
