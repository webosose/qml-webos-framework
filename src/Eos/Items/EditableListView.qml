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

// Scrolling is controlled by changing currentIndex. Tracking actual position is done using
// currentItem. This allow avoiding to calculate position manually and make it possible to
// use delegate items of different width (e.g. Promo Tiles).

ListView {
    id: ribbon

    property bool allowEditing: true
    // This controls the velocity (not duration) of the edge based scrolling
    property int scrollVelocity: 700
    property bool scrolling: false // returns whether the contentItem moves

    // The scrollInput allows to determine the current cause for scrolling:
    // "wheel", "keys" (5way) or "hover".
    // This property is needed e.g. for prioritizing scroll input (e.g. hotspot vs. wheel)
    // and for displaying the focus indicator according to spec (hides during wheel
    // scrolling while it stays visible for fiveway scrolling). If scrolling stops
    // or if no scrolling input has been provided recently then the value is "none".
    // The value is also "none" for any scrolling that is not triggered via the
    // known approaches.
    property string scrollInput: "none"

    // Input events can be either pointer-based mouse events or 5way-based key events.
    // The pointerMode indicates which has been captured last: If no key events were
    // captured after the latest mouse events then pointerMode returns true. Otherwise it
    // returns false. So unlike the scrollingState the pointerMode stays true even if no
    // scrolling or mouse events are happening at the moment.
    // The pointerMode is needed e.g. for drawing proper hover and focus indication.
    property bool pointerMode: true

    // These properties allow to specify borderWidths and resumeIntervals that are
    // sufficient for the use case.
    property alias leftHotspot: leftHotspot
    property alias rightHotspot: rightHotspot

    // If there is a header component the width needs to be provided explicity as the
    // the list cannot find that out internally as it is a component
    property real headerWidth: 0
    property real hotspotWidth: 200

    property bool largeDelegates: false

    QtObject {
        id: d
        property real previousContentX: 0
    }

    orientation: Qt.Horizontal
    boundsBehavior: Flickable.StopAtBounds
    interactive: false

    highlightMoveDuration: -1
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: ribbon.headerWidth
    preferredHighlightEnd: width - (currentItem ? currentItem.width / 2 : 0)

    // This animation will animate the item when they are moven in the model
    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 250
            easing.type: Easing.InOutQuint
        }
    }

    highlight: Item {
        x: currentItem ? currentItem.x : 0

        Behavior on x {
            SmoothedAnimation {
                velocity: ribbon.scrollVelocity
                reversingMode: SmoothedAnimation.Eased
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true
        propagateComposedEvents: true

        property real prevMouseX: 0
        property bool wheelTickTriggersMove: false // added here to keep it private

        // Mouse offset is used to prevent the reparented item from bouncing
        // when starting the move
        property real mouseOffset: 0

        // Keep track of the original parent as it will remain in the list view
        // and the model. It is also the one that gets moved around the model
        // and allows us to calculate the next position where the moved item
        // gets should be placed when the editing stops
        property Item owner: Item {}

        onPressAndHold: {
            ribbon.pointerMode = true

            if (ribbon.allowEditing) {
                currentItem.state = "editing";
                currentItem.mouseEditing = true;
                ribbon.state = "editing";
                prevMouseX = mouse.x;
                owner = currentItem;
                mouseOffset = mouseArea.mapToItem(currentItem, mouse.x, mouse.y).x;
                currentItem.contentItem.parent = mouseArea;
                currentItem.contentItem.x = mouse.x - mouseOffset;
            }
        }

        onPositionChanged: {
            ribbon.pointerMode = true
            ribbon.highlightRangeMode = ListView.NoHighlightRange

            if (ribbon.state === "editing") {
                var direction = mouse.x > prevMouseX ? 1 : -1;

                // The position of the owner item in the model in screen coordinates
                var ownerPos = owner.mapToItem(null, 0, 0).x;
                // The position of the detached item in screen coordinates
                var freePos = currentItem.contentItem.mapToItem(null, 0, 0).x;

                // As the coordinates are in screen coordinates just test if we have
                // moved enough to justify an actual model move in either direction
                // NOTE: The moved item will be the owner, not the free item
                if (Math.abs(ownerPos - freePos) > (currentItem.width / 2)) {
                    moveItem(currentIndex, currentIndex + direction);
                }

                currentItem.contentItem.x = mouse.x - mouseOffset;
                prevMouseX = mouse.x;
            } else {
                var x = mapFromItem(ribbon, mouse.x + ribbon.contentX, mouse.y);
                var i = ribbon.itemAt(x.x, x.y);
                if (i) {
                    ribbon.currentIndex = i.index;
                }
            }
            prevMouseX = mouse.x;
        }

        onReleased: {
            if (currentItem.state === "editing") {
                currentItem.contentItem.parent = owner;
                currentItem.contentItem.x = 0;
                currentItem.state = "current";
                currentItem.mouseEditing = false;
                ribbon.state = "";
            }
        }

        onWheel: wheelScroll(wheel.angleDelta.y)

    }

    function moveItem(from, to) {
        var bound = Math.max(0, Math.min(to, model.count -1));
        model.move(from, bound, 1);
    }

    function stepLeft() {
        if (ribbon.state === "editing") {
            moveItem(currentIndex, currentIndex - 1);
            return;
        }
        // decrementCurrentIndex up to -1
        if (currentIndex !== -1) {
            currentIndex -= 1;
        }
    }

    function stepRight() {
        if (ribbon.state === "editing") {
            moveItem(currentIndex, currentIndex + 1);
            return;
        }
        incrementCurrentIndex();
    }

    function wheelScroll(wheelY) {
        // for large tiles advance on odd wheel ticks and ignore even ticks (according to spec).
        ribbon.scrollInput = "wheel"
        ribbon.pointerMode = true
        scrollInputResetTimer.restart()
        mouseArea.wheelTickTriggersMove = !mouseArea.wheelTickTriggersMove
        if (largeDelegates && !mouseArea.wheelTickTriggersMove) {
            return
        }

        if (wheelY > 0) {
            stepLeft();
        } else {
            stepRight();
        }
    }

    function disablePointer() {
        preferredHighlightBegin = ribbon.headerWidth;
        highlightRangeMode = ListView.StrictlyEnforceRange;
        ribbon.pointerMode = false;
    }

    Timer {
        id: scrollInputResetTimer
        interval: 1000
        onTriggered: {
            if (scrollInput === "wheel") {
                mouseArea.wheelTickTriggersMove = false
            }
            if (!scrolling) {
                scrollInput = "none"
            }
        }
    }

    Timer {
        id: scrollDetectionTimer
        interval: 20
        repeat: false
        onTriggered: scrolling = false
    }

    onScrollInputChanged: {
        if (leftHotspot.containsMouse) leftHotspot.resumeScrolling()
        if (rightHotspot.containsMouse) rightHotspot.resumeScrolling()
    }

    EditableListViewHotspot {
        id: leftHotspot
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: ribbon.hotspotWidth
        hoverEnabled: enabled
        location: "left"
        visible: ribbon.pointerMode

        onAdvance: {
            if (ribbon.scrollInput === "none" && leftHotspot.containsMouse && ribbon.pointerMode) {
                ribbon.currentIndex = 0;
            }
        }
    }

    EditableListViewHotspot {
        id: rightHotspot
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: ribbon.hotspotWidth
        hoverEnabled: enabled
        location: "right"
        visible: ribbon.pointerMode

        onAdvance: {
            if (ribbon.scrollInput === "none" && rightHotspot.containsMouse && ribbon.pointerMode) {
                ribbon.currentIndex = count - 1;
            }
        }
    }

    Keys.onUpPressed: {
        if (currentIndex == -1 || !ribbon.allowEditing) {
            return;
        }
        ribbon.scrollInput = "keys"
        event.accepted = true;
        ribbon.state = "editing";
        currentItem.state = "editing";
    }

    Keys.onDownPressed: {
        if (ribbon.state !== "editing") {
            return;
        }
        ribbon.scrollInput = "keys"
        event.accepted = true;
        ribbon.state = "";
        currentItem.state = "current";
    }

    Keys.onLeftPressed: {
        ribbon.scrollInput = "keys"
        ribbon.disablePointer();
        scrollInputResetTimer.restart()
        ribbon.stepLeft();
    }
    Keys.onRightPressed: {
        ribbon.scrollInput = "keys"
        ribbon.disablePointer();
        scrollInputResetTimer.restart()
        ribbon.stepRight();
    }

    onContentXChanged: {
        if (Math.abs(contentX - d.previousContentX) < 1) return
        scrolling = true
        scrollDetectionTimer.restart()
        d.previousContentX = contentX
    }
    onScrollingChanged: {
        if (!scrolling) scrollInput = "none"
    }
}
