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

/* A simple animation of a prerendered set of images.
   This implementation is specific to the skull animation. */

SequentialAnimation {
    property Item target
    property real frameDuration: 40

    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull3.png"
    }
    PauseAnimation {
        duration: frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull4.png"
    }
    PauseAnimation {
        duration: frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull5.png"
    }
    PauseAnimation {
        duration: frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull6.png"
    }
    PauseAnimation {
        duration: frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull7.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull9.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull11.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull13.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull15.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull17.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
    PropertyAction {
        target: target
        property: "source"
        value: "./images/skull19.png"
    }
    PauseAnimation {
        duration: 2 * frameDuration
    }
}
