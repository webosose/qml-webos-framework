// Copyright (c) 2015-2021 LG Electronics, Inc.
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

MouseArea {
    id: root

    signal moved(int from, int to)

    // The scroll boundary is the number of pixels from either the left or right
    // side of the ribbon when to start scrolling the list during the edit operation
    // NOTE: When determining whether the boundary has been crossed the offset value is taken
    //       into consideration as well
    property real scrollBoundary: 40

    // Indicate when the editing is active, note that drag.active is not the same as
    // it only becomes to true when the item moves
    readonly property bool active: fbo.sourceItem !== null

    // The transforms to apply when the editing starts
    property alias editTransform: fboContainer.transform

    property bool selectOnHover: true

    property var editedItem: null

    property bool keepEditItemAlive: false

    property bool animateEditItemDown: false

    // rename to dragCurrentItem()
    function editCurrentItem() {
        if (d.ribbon === null)
            throw new Error("No Ribbon component found!");
        if (!d.ribbon.indexEditable(d.ribbon.currentIndex)) return
        d.sourceIndex = d.targetIndex = d.ribbon.currentIndex;

        fbo.sourceItem = d.ribbon.currentItem;
        editedItem = d.ribbon.currentItem;
        fboContainer.x = editedItem.x;
        d.ribbon.ensureItemVisible(d.ribbon.currentItem);
        fbo.scheduleUpdate();
    }


    function finishEditing () {
//    if animateEditItemDown is true;
//    finishEditing should called like this:
//        editTransform: [
//            Translate {
//                id: editTranslation
//                property int upValue: -100
//                property int downValue: 0
//                x: root.style.__tan * -y;
//                y: launcherEditableArea.editedItem? upValue : downValue;
//                Behavior on y {
//                    NumberAnimation {
//                        duration: 200; easing.type: Easing.InOutQuad;
//                        onRunningChanged: {
//                            if (!running && editTranslation.y === editTranslation.downValue) {
//                                launcherEditableArea.finishEditing();
//                            }
//                        }
//                    }
//                }
//            }
//        ]

        fboContainer.y = 0;
        fbo.sourceItem = null;
        d.ribbon.currentItem.focus = true;
        if (d.sourceIndex !== d.targetIndex)
            moved(d.sourceIndex, d.targetIndex);
    }

    // rename to dropCurrentItem()
    function stopEdit() {
        if (active) {
            editedItem = null;
            if (!animateEditItemDown || !editTransform)
                finishEditing();
        }
    }

    //acceptedButtons: Qt.NoButton
    drag.axis: Drag.XAxis

    // HACK: When drag.filterChildren is false we will not receive clicked events,
    // that allow the user to cancel editing by clicking outside of the ribon
    drag.filterChildren: !active

    Rectangle {
        color: "transparent"//"magenta"
        id: fboContainer
        objectName: root.objectName + "fboContainer"
        z: d.ribbon.count  // Keep it on top of ListView/delegates.
        width: fbo.sourceItem && fbo.sourceItem.width || 0
        height: fbo.sourceItem && fbo.sourceItem.height || 0
        parent: d.ribbon.contentItem


        ShaderEffectSource {
            id: fbo
            x: sourceRect.x
            y: sourceRect.y
            width: sourceRect.width
            height: sourceRect.height
            sourceRect: fbo.sourceItem? Qt.rect(Math.min(fbo.sourceItem.childrenRect.x, 0), Math.min(fbo.sourceItem.childrenRect.y, 0),
                                            Math.max(fbo.sourceItem.childrenRect.width, fbo.sourceItem.width), Math.max(fbo.sourceItem.childrenRect.height, fbo.sourceItem.height)
                                           ) : Qt.rect(0,0,0,0)
            hideSource: true
            opacity: .75
            live: keepEditItemAlive
        }
    }

    function getFboPositionDuringScroll() {
        if (!d.ribbon.autoScrolling || isNaN(d.ribbon.indexPosition) || !d.ribbon.smoothAutoscroll)
            return fbo.sourceItem.x;

        var newPos = d.ribbon.contentX + d.ribbon.indexPosition;
        if (d.ribbon.state === "autoscrolling-right")
            newPos -= (fbo.width * 0.75);
        newPos = Math.min(Math.max(newPos, d.ribbon.editableAreaScrollEdgeLeft), d.ribbon.editableAreaScrollEdgeRight);
        return newPos;
    }

    Binding {
        id: binding
//        target: fboContainer; property: "x"; value: fbo.sourceItem? fbo.sourceItem.x : 0
        // FIXME: why it's trying to read currentItem.x even if "when" is false?
        target: fboContainer; property: "x"; value: fbo.sourceItem ? getFboPositionDuringScroll()
                                                                   :
                                                                     0 //No item selected
    }

    QtObject {
        id: d
        property Ribbon ribbon
        property int sourceIndex
        property int targetIndex

        function selectIndexUnderMouse(mouse) {
            if (d.ribbon.wheelScrolling)
                return;
            var p = root.mapToItem(d.ribbon.contentItem, mouse.x, mouse.y);
            var target_index = d.ribbon.indexAt(p.x, 0);
            var target_item = d.ribbon.contentItem.childAt(p.x, 0);
            // Trigger the scrolling in either direction if we have crossed the boundary
            if (mouse.x - d.ribbon.x  < scrollBoundary && d.ribbon.scrollToLeft()) {
                // scrollToLeft inside if and do nothing if scroll needed
            } else if (d.ribbon.x + d.ribbon.width - mouse.x < root.scrollBoundary && d.ribbon.scrollToRight()) {
                // scrollToRight inside if and do nothing if scroll needed
            } else {
                d.ribbon.stopScrolling();
                changeCurrentIndex(target_index, target_item);
            }
        }

        function changeCurrentIndex(target_index, target_item) {
            var newIndex = target_index;
            if (target_index !== -1 && target_index !== d.targetIndex && d.ribbon.indexEditable(target_index) && !d.ribbon.scrolling) {
                d.ribbon.currentIndex = newIndex; // will trigger model.move
            } else if (target_index === -1 && target_item !== null) {
                if (target_item === d.ribbon.headerItem) {
                    newIndex = d.ribbon.incrementEditable(0);
                    d.ribbon.currentIndex = newIndex;
                } else if (target_item === d.ribbon.footerItem) {
                    newIndex = d.ribbon.decrementEditable(d.ribbon.count-1);
                    d.ribbon.currentIndex = newIndex;
                }
            } else if (target_index !== -1 && !d.ribbon.indexEditable(target_index) && !d.ribbon.scrolling) {
                newIndex = d.ribbon.incrementEditable(0);
                d.ribbon.currentIndex = newIndex;
            }
        }

        function changeCurrentIndexAtAutoscrollEnd() {
            if (d.ribbon.wheelScrolling)
                return;

            var indexPosition = d.ribbon.indexPosition;
            if (isNaN(indexPosition))
                return;

            var target_index = d.ribbon.indexAt(d.ribbon.contentX + indexPosition, 0);
            var target_item = d.ribbon.contentItem.childAt(d.ribbon.contentX + indexPosition, 0);
            d.changeCurrentIndex(target_index, target_item);
        }
    }

    Connections {
        target: root.active ? d.ribbon : null
        function onCurrentIndexChanged() {
            if (d.targetIndex === d.ribbon.currentIndex) {
                return;
            }

            // HACK: to avoid ListView resetting currentIndex on model.move
            if (d.ribbon.currentIndex === -1) {
                d.ribbon.currentIndex = d.targetIndex;
                return;
            }

            if (!d.ribbon.autoScrolling) {
                //Check later it sould not be removed!!!
                //d.ribbon.scrollAnimation.addPostponed(moveInModel);
                d.ribbon.ensureItemVisible(d.ribbon.currentItem);
                //return;
            }

            moveInModel();
        }

        function onAutoScrollStop () {
            if (d.ribbon.editing)
                d.ribbon.moveDuration = 0;
            d.changeCurrentIndexAtAutoscrollEnd();
        }
    }

    function moveInModel() {
        if (!d.ribbon.indexEditable(d.targetIndex) ) return
        if (!d.ribbon.indexEditable(d.ribbon.currentIndex) ) return
        var current_index = d.ribbon.currentIndex;
        if (d.ribbon.editing)
            d.ribbon.targetItem = d.ribbon.currentItem;
        else
            d.ribbon.targetItem = null;

        d.ribbon.currentIndex = -1;

        if (!d.ribbon.allowedMoveInModel(d.targetIndex, current_index))
            return;

        d.ribbon.model.move(d.targetIndex, current_index, 1);

        d.targetIndex = current_index;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        visible: root.active && !root.drag.active
        z: d.ribbon.z + 1

        onPositionChanged: {
            if (root.selectOnHover) {
                d.selectIndexUnderMouse(mouse);
            }
        }

        onClicked: {
            stopEdit();
        }
    }

    onReleased: {
        if (!root.active && d.ribbon)
            d.ribbon.editableAreaMouseReleased(mouse);
    }

    onPositionChanged: {
        if (root.active)
            d.selectIndexUnderMouse(mouse);
        else if (d.ribbon)
            d.ribbon.editableAreaMousePositionChanged(mouse, scrollBoundary);
    }

    drag.onActiveChanged: {
        if (!drag.active)
            stopEdit();
    }

    onChildrenChanged: {
        for (var i = 0, len = children.length; i < len; ++i) {
            var item = children[i];
            if (item.autoScrolling !== undefined) {
                d.ribbon = item;
                return;
            }
        }
    }
}
