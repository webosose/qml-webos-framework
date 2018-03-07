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

ParallelAnimation {
    // This set of animations describes the rotation movement of the cross
    SequentialAnimation {
        PauseAnimation {
            duration: root.state == "hovered" ? 5 * frameDuration : frameDuration
        }
        ParallelAnimation {
            PropertyAnimation {
                target: crossSlash
                property: "width"
                from: root.state == "hovered" ? 0.8 * button.width : 0.425 * root.buttonWidth
                to: root.state == "hovered" ? 0.425 * root.buttonWidth : 0.8 * button.width
                duration: root.state == "hovered" ? 7 * frameDuration : frameDuration
            }
            PropertyAnimation {
                target: crossBackSlash
                property: "width"
                from: root.state == "hovered" ? 0.8 * button.width : 0.425 * root.buttonWidth
                to: root.state == "hovered" ? 0.425 * root.buttonWidth : 0.8 * button.width
                duration: root.state == "hovered" ? 7 * frameDuration : frameDuration
            }
            PropertyAnimation {
                target: crossSlashOutline
                property: "width"
                from: root.state == "hovered" ? 0.8 * button.width : 0.425 * root.buttonWidth
                to: root.state == "hovered" ? 0.425 * root.buttonWidth : 0.8 * button.width
                duration: root.state == "hovered" ? 7 * frameDuration : frameDuration
            }
            PropertyAnimation {
                target: crossBackSlashOutline
                property: "width"
                from: root.state == "hovered" ? 0.8 * button.width : 0.425 * root.buttonWidth
                to: root.state == "hovered" ? 0.425 * root.buttonWidth : 0.8 * button.width
                duration: root.state == "hovered" ? 7 * frameDuration : frameDuration
            }
        }

        PauseAnimation {
            duration: root.state == "hovered" ? 25 * frameDuration : frameDuration
        }
    }

    ParallelAnimation {
        SequentialAnimation {
            // Initialize values so that they reach the correct
            // value during reverse animations in the end.
            PropertyAction {
                target: skullCircle
                property: "source"
                value: "./images/skull2.png"
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: false
            }
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: false
            }
            PropertyAction {
                target: nose;
                property: "visible";
                value: false
            }
            // Skull upwards movement
            NumberAnimation {
                target: skullCircle
                properties: "anchors.bottomMargin"
                from: root.state == "hovered" ? 0 : 1.3 * root.buttonHeight
                to: root.state == "hovered" ? 1.3 * root.buttonHeight : 0
                duration: root.state == "hovered" ? 6 * frameDuration : 3 * frameDuration
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: nose;
                property: "visible";
                value: true
            }
            // This set of animations describes the movement of eyes and nose
            ParallelAnimation {
                PropertyAnimation {
                    target: skullCircle
                    property: "anchors.bottomMargin"
                    from: root.state == "hovered" ? 1.3 * root.buttonHeight : 0.85 * root.buttonHeight
                    to: root.state == "hovered" ? 0.85 * root.buttonHeight : 1.3 * root.buttonHeight
                    easing.type: Easing.OutBack
                    duration: root.state == "hovered" ? 10 * frameDuration : 5 * frameDuration
                }
                // Bouncing eyes and nose
                PropertyAnimation {
                    target: leftEye
                    property: "anchors.bottomMargin"
                    from: root.state == "hovered" ? button.width * 0.1 : -button.width * 0.15
                    to: root.state == "hovered" ? -button.width * 0.15 : button.width * 0.1
                    easing.type: Easing.InBack
                    duration: root.state == "hovered" ? 10 * frameDuration : frameDuration
                }
                PropertyAnimation {
                    target: rightEye
                    property: "anchors.bottomMargin"
                    from: root.state == "hovered" ? button.width * 0.1 : -button.width * 0.15
                    to: root.state == "hovered" ? -button.width * 0.15 : button.width * 0.1
                    easing.type: Easing.InBack
                    duration: root.state == "hovered" ? 10 * frameDuration : frameDuration
                }
                PropertyAnimation {
                    target: nose
                    property: "anchors.verticalCenterOffset"
                    from: -button.width * 0.4
                    to: 0
                    easing.type: Easing.InOutBack
                    duration: root.state == "hovered" ? 10 * frameDuration : frameDuration
                }
                // Open eyes
                SequentialAnimation {
                    PropertyAnimation {
                        target: leftEye
                        property: "height"
                        from: root.state == "hovered" ? 0 : button.width * 0.275
                        to: root.state == "hovered" ? button.width * 0.275 : 0
                        duration: root.state == "hovered" ? 6 * frameDuration : frameDuration
                    }
                    PauseAnimation {
                        duration: root.state == "hovered" ? 4 * frameDuration : frameDuration
                    }
                }
                SequentialAnimation {
                    PropertyAnimation {
                        target: rightEye
                        property: "height"
                        from: root.state == "hovered" ? 0 : button.width * 0.275
                        to: root.state == "hovered" ? button.width * 0.275 : 0
                        duration: root.state == "hovered" ? 6 * frameDuration : frameDuration
                    }
                    PauseAnimation {
                        duration: root.state == "hovered" ? 4 * frameDuration : frameDuration
                    }
                }
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 10 * frameDuration : frameDuration
            }
            // First eyeblink
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: false
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 2 * frameDuration : 0
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: false
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 2 * frameDuration : 0
            }
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: rightEye;
                property: "height";
                value: button.width * 0.225
            }
            PauseAnimation {
                duration: root.state == "hovered" ? frameDuration : 0
            }
            PropertyAction {
                target: rightEye;
                property: "height";
                value: button.width * 0.275
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: leftEye;
                property: "height";
                value: button.width * 0.225
            }
            PauseAnimation {
                duration: root.state == "hovered" ? frameDuration : 0
            }
            PropertyAction {
                target: leftEye;
                property: "height";
                value: button.width * 0.275
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 10 * frameDuration : 0 // 42
            }
            // Second eyeblink
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: false
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 2 * frameDuration : 0
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: false
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 2 * frameDuration : 0
            }
            PropertyAction {
                target: rightEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: rightEye;
                property: "height";
                value: button.width * 0.225
            }
            PauseAnimation {
                duration: root.state == "hovered" ? frameDuration : 0
            }
            PropertyAction {
                target: rightEye;
                property: "height";
                value: button.width * 0.275
            }
            PropertyAction {
                target: leftEye;
                property: "visible";
                value: true
            }
            PropertyAction {
                target: leftEye;
                property: "height";
                value: button.width * 0.225
            }
            PauseAnimation {
                duration: root.state == "hovered" ? frameDuration : 0 // 48
            }
            PropertyAction {
                target: leftEye;
                property: "height";
                value: button.width * 0.275
            }
        }
        // This set of animations describes the squeezing and
        // stretching of the skull during the up and down skull movement
        SequentialAnimation {
            ParallelAnimation {
                // Squeezing upwards
                PropertyAnimation {
                    target: skullCircle
                    property: "height"
                    from: root.state == "hovered" ? 40 : 2 * root.buttonHeight
                    to: root.state == "hovered" ? 2 * root.buttonHeight : 40
                    easing.type: Easing.OutCubic
                    duration: root.state == "hovered" ? 4 * frameDuration : 2 * frameDuration
                }
                PropertyAnimation {
                    target: skullCircle
                    property: "width"
                    from: root.state == "hovered" ? 40 : 0.6 * root.buttonHeight
                    to: root.state == "hovered" ? 0.6 * root.buttonHeight : 40
                    easing.type: Easing.OutCubic
                    duration: root.state == "hovered" ? 4 * frameDuration : 2 * frameDuration
                }
            }
            ParallelAnimation {
                // Squeezing downwards

                PropertyAnimation {
                    target: skullCircle
                    property: "height"
                    from: root.state == "hovered" ? 2 * root.buttonHeight : 36
                    to: root.state == "hovered" ? 36 : 2 * root.buttonHeight
                    easing.type: Easing.InCubic
                    duration: root.state == "hovered" ? 4 * frameDuration : 2 * frameDuration
                }
                PropertyAnimation {
                    target: skullCircle
                    property: "width"
                    from: root.state == "hovered" ? 0.6 * root.buttonHeight : 36
                    to: root.state == "hovered" ? 36 : 0.6 * root.buttonHeight
                    easing.type: Easing.OutBack
                    duration: root.state == "hovered" ? 4 * frameDuration : 2 * frameDuration
                }
            }
            PauseAnimation {
                duration: root.state == "hovered" ? 40 * frameDuration : frameDuration
            }
            // Ensure usage of the skull image during the start of the reverse animation.
            PropertyAction {
                target: skullCircle
                property: "source"
                value: "./images/skull2.png"
            }
        }
    }
} // end of ParallelAnimation
