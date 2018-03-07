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
import Eos.Controls 0.1
import Eos.Items 0.1
import Eos.Style 0.1
import "../"

GalleryPage {

    id: root

    Column {
        spacing: 20
        anchors.centerIn: parent
        opacity: 0.6

        RoundedRectangle {
            height: 200
            width: 400
            radius: 30
        }
        RoundedRectangle {
            height: 200
            width: 400
            clipTopLeft: false
            radius: 100
            Rectangle {
                color: "yellow"
                opacity: 0.5
                anchors.fill: parent
            }
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipTopRight: false
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipBottomRight: false
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipBottomLeft: false
            radius: 1000
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipTopLeft: false
            clipTopRight: false
            clipBottomLeft: false
            clipBottomRight: false
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipTopLeft: false
            clipTopRight: false
        }

        RoundedRectangle {
            height: 200
            width: 400
            clipBottomLeft: false
            clipBottomRight: false
        }

    }

}
