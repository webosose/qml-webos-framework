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
import Eos.Controls 0.1
import "../"

GalleryPage {

    id: root

    property string sourceUrl

    Rectangle {

        id: background

        color: "white"
        anchors.fill: parent

        radius: 10

        Flickable {
            id: flick

            contentWidth: textEdit.paintedWidth
            contentHeight: textEdit.paintedHeight
            clip: true

            boundsBehavior: Flickable.StopAtBounds

            anchors.fill: parent
            anchors.margins: 10

            TextEdit {
                id: textEdit

                width: flick.width
                height: flick.height

                text: "import SourceCode \n \n Here you will be able to see the source code ... yet to be implemented .."
                wrapMode: TextEdit.Wrap
                font.family: "Museo Sans"
                font.pixelSize: 20
            }
        }
    }

   onSourceUrlChanged: {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                textEdit.text = doc.responseText
            }
        }
        doc.open("GET", root.sourceUrl);
        doc.send()
    }
}
