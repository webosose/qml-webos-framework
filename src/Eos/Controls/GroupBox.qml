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
import Eos.Style 0.1

FocusScope {
    id: root

    property Item contentItem
    property string title

    property variant style: GroupBoxStyle{}

    property real margin: style.groupBoxMargin

    onChildrenChanged: {
        for (var i = 0; i < root.children.length; ++i) {
            if (root.children[i].objectName !== "__internalContainer") {
                root.children[i].parent = contentItemContainer;
            }
        }
        d.checkWidth()
        d.checkHeight()
    }

    onActiveFocusChanged: d.focusToPreferredChild()

    implicitWidth: Math.max(groupHeader.implicitWidth, contentItemContainer.childrenRect.width )
    implicitHeight: groupHeader.height + contentItemContainer.height

    QtObject {
        id: d

        function checkWidth() {
            if (width != 0 && width < implicitWidth) {
                width = implicitWidth
            }
        }

        function checkHeight() {
            if (height != 0 && height < implicitHeight ) {
                height = implicitHeight
            }
        }

        function focusToPreferredChild(){

            // Automatically transfer the keyboard focus on to the right child
            // Yes, this isn't pretty

            if (activeFocus) {
                var firstItem;
                var firstItemContainer
                for (var i = 0; i < contentItemContainer.children.length; ++i) {
                    if (contentItemContainer.children[i].checked !== undefined) {
                        firstItem = contentItemContainer.children[i];
                        break;
                    }
                    if (contentItemContainer.children[i].spacing != undefined) {
                        firstItemContainer = contentItemContainer.children[i];
                        break;
                    }
                }
                if (firstItemContainer !== undefined) {
                    for (var i = 0; i < firstItemContainer.children.length; ++i) {
                        if (firstItemContainer.children[i].checked !== undefined) {
                            if (firstItem  === undefined) {
                                firstItem = firstItemContainer.children[i];
                            }
                            if (firstItemContainer.children[i].focus) {
                                firstItem = firstItemContainer.children[i];
                                break;
                            }
                        }
                    }
                }
                if (firstItem !== undefined) firstItem.forceActiveFocus()
            }
        }
    }

    Item {
        anchors.fill: parent

        objectName: "__internalContainer"

        GroupHeader {
            id: groupHeader

            title: root.title

            titleColor: root.style.groupBoxTitleColor
            titleFontFamily: root.style.groupBoxTitleFont
            titleFontSize: root.style.groupBoxTitleFontSize
            titleFontItalic: root.style.groupBoxTitleFontItalic

            dividerColor: root.style.groupBoxDividerColor
            dividerHeight: root.style.groupBoxDividerHeight

            anchors.left: parent.left
            anchors.right: parent.right
        }

        Item {
            id: contentItemContainer

            anchors.top: groupHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            height: childrenRect.height

            anchors.topMargin: root.margin
            anchors.leftMargin: root.margin
            anchors.rightMargin: root.margin
            anchors.bottomMargin: root.margin

            focus: true
        }
    }
}
