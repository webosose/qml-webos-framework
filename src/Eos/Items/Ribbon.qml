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

ListView {
    id: ribbon

    readonly property bool scrolling: scrollAni.running || afterScrollAni.running
    readonly property bool wheelScrolling: scrollAni.wheelScrolling
    property bool autoScrolling
    property real pixelsPerSecond: 1800
    property real scrollStep: 100
    property real leftEnsureBound: 0
    property real rightEnsureBound: width
    property real safeEnsureSpacing: 200

    property Item targetItem: null

    signal autoScrollStop
    signal autoScrolledToEnd
    signal autoScrolledToBeginning
    signal editableAreaMousePositionChanged(var mouse, var scrollBoundary)
    signal editableAreaMouseReleased(var mouse)

    property bool editing: false
    property bool editEnabled: false

    readonly property alias indexPosition: scrollAni.indexPosition

    // easingCurve could be replace from outside depends on ribbon length or ...
    property var easingCurve: [ 0,   0,
                                0.1, 0,
                                0.1, 0.03,
                                0.9, 0.97,
                                0.9, 1,
                                1,   1 ]
    property var defaultEasing: Easing.Linear
    property var customEasing: Easing.Linear

    property real editableAreaScrollEdgeLeft: NaN
    property real editableAreaScrollEdgeRight: NaN
    readonly property bool smoothAutoscroll: !isNaN(editableAreaScrollEdgeLeft) && !isNaN(editableAreaScrollEdgeRight)

    // cursorPosition is valid only when cursorVisible is true
    property bool cursorVisible: false
    property point cursorPosition: Qt.point(0, 0)

    function setIndexEditable(index, editable) {
        var uneditableList = []
        for (var i = 0; i < d.uneditableIndexes.length; ++i) {
            if (d.uneditableIndexes[i] !== index) {
                uneditableList.push(d.uneditableIndexes[i]);
            }
        }
        if (!editable) {
            uneditableList.push(index)
        }
        d.uneditableIndexes = uneditableList
    }

    function removeIndexEditable(index) {
        if (index === undefined) { // Clear all
            d.uneditableIndexes = [];
        }

        var uneditableList = []
        for (var i = 0; i < d.uneditableIndexes.length; ++i) {
            if (d.uneditableIndexes[i] !== index) {
                uneditableList.push(d.uneditableIndexes[i]);
            }
        }
        d.uneditableIndexes = uneditableList
    }

    function indexEditable(index) {
        for (var i = 0; i < d.uneditableIndexes.length; ++i) {
            if (d.uneditableIndexes[i] === index) {
                return false
            }
        }
        return true
    }

    // deprecated
    function startEditing(item) { editing = true; }

    // deprecated
    function endEditing(item) { editing = false; }

    // deprecated
    function ensureIndexVisible(index) {
        var bound = Math.max(0, Math.min(index, count - 1));
        var averageItemWidth = contentWidth / count;
        var pos = bound * averageItemWidth;
        var item = {
            x: pos,
            width: averageItemWidth
        }
        ensureItemVisible(item);
    }

    function scrollBy(steps, wheel) {
        // Workaround for "originX BUG" (fixed in v5.4)
        if (layoutDirection === Qt.RightToLeft && contentWidth < width)
            return;

        var pos = scrollAni.running ? scrollAni.to : contentX;
        var to = d.clamp(pos + steps * scrollStep);

        var diff = Math.abs(to - contentX);
        if (diff <= 0) {
            return;
        }

        if (to === 0) to = 1; //Difference with auto-scroll
        else if (to === ribbon.width) to = to -1; //Difference with auto-scroll
        scrollAni.to = to;
        scrollAni.duration = 350;
        scrollAni.easing.type = Easing.Linear;
        scrollAni.restart();
        scrollAni.wheelScrolling = !wheel ? false : true;
        var newIndexPosition = !wheel ? width/2 : wheel.x;
        scrollAni.indexPosition = newIndexPosition;
    }

    function gotoState(newState) {
        if (newState === state)
            return;

        if (newState === "autoscrolling-left" || newState === "autoscrolling-right") {
            scrollAni.stop();
        }

        state = newState;
    }

    function scrollingActive() {
        // If we are in chain started fron scrollAni.onRunningChanged;
        // ribbon.scrolling is not set yet
        return scrollAni.running;
    }

    function scrollToRight() {
        if (!atXEnd && state !== "autoscrolling-right") {
            gotoState("autoscrolling-right");
            return true;
        } else if (!atXEnd && state === "autoscrolling-right") {
            return true;
        }
        return false;
    }

    function scrollToLeft() {
        if (!atXBeginning && state !== "autoscrolling-left") {
            gotoState("autoscrolling-left");
            return true;
        } else  if (!atXBeginning && state === "autoscrolling-left") {
            return true;
        }
        return false;
    }

    function stopScrolling() {
        if (state !== "")
            gotoState("");
        else
            scrollAni.indexPosition = NaN;
    }

    function boundingRect(item) {
        return item? contentItem.mapFromItem(item,
                             Math.min(item.childrenRect.x, 0), Math.min(item.childrenRect.y, 0),
                             Math.max(item.childrenRect.width, item.width), Math.max(item.childrenRect.height, item.height))
                             : Qt.rect(0,0,0,0);
    }

    function checkBounds(item, lBound, rBound) {
        var leftBound = lBound !== undefined ? lBound : leftEnsureBound
        var rightBound = rBound !== undefined ? rBound : rightEnsureBound
        var br = boundingRect(item);
        if (br.x - contentX < leftBound)
            return -1; // Hidden on left side
        else if (br.x + br.width - contentX > rightBound )
            return 1; // Hidden on right side
        else
            return 0;  // On screen
    }

    function ensureItemVisible(item) {
        var br = boundingRect(item);
        var bounds = checkBounds(item);
        if (bounds < 0) {
            scrollAni.indexPosition = NaN;
            scrollAni.scrollTo(br.x + spacing - safeEnsureSpacing);
        } else if (bounds > 0) {
            scrollAni.indexPosition = NaN;
            scrollAni.scrollTo(br.x + br.width - width - spacing + safeEnsureSpacing);
        } else {
            scrollAni.runPostponed();
        }
    }

    function forceItemVisible(item) {
        var br = boundingRect(item);
        var bounds = checkBounds(item);
        if (bounds < 0) {
            afterScrollAni.indexPosition = NaN;
            afterScrollAni.scrollTo(br.x + spacing - safeEnsureSpacing);
        } else if (bounds > 0) {
            afterScrollAni.indexPosition = NaN;
            afterScrollAni.scrollTo(br.x + br.width - width - spacing + safeEnsureSpacing);
        } else {
            scrollAni.runPostponed();
        }
    }

    function decrementEditable(index) {
        if (index > count-1 || index < 0)
            return -1
        while (!indexEditable(index) && index >= 0)
            --index;
        return index;
    }

    function incrementEditable(index) {
        if (index > count-1 || index < 0)
            return -1
        while (!indexEditable(index) && index <= count-1)
            ++index;
        if (index !== count) {
            return index;
        } else {
            return -1;
        }
    }

    QtObject {
        id: d
        property bool editModeOn: editing || editEnabled //Need for backward compatibility
        property bool scrollByKey: false

        function clamp(position) {
            var ltr_offset = layoutDirection === Qt.RightToLeft ?
                        Math.max(0, width - contentWidth) : 0;
            var left = originX - ltr_offset;
            var right = contentWidth + originX - width;
            return Math.max(left, Math.min(right, position));
        }

        function scrollToPrevIndex(event) {
            if (count === 0 || currentIndex <= 0 || autoScrolling) {
                if (event && currentIndex <= 0)
                    event.accepted = false;
                scrollAni.clearPostponed();
                return;
            }
            if (scrollAni.running) {
                scrollAni.addPostponed(scrollToPrevIndex);
                return;
            }
            if (d.editModeOn && !indexEditable(currentIndex - 1)) {
                if (layoutDirection === Qt.RightToLeft)
                    scrollToRight();
                else
                    scrollToLeft();
            }
            if (d.editModeOn) {
                var testIndex = decrementEditable(currentIndex - 1);
                if (testIndex !== -1)
                    currentIndex = testIndex;
                else
                    return;
            } else {
                decrementCurrentIndex();
            }
            ensureItemVisible(currentItem);
        }

        function scrollToNextIndex(event) {
            if (count === 0 || currentIndex === count - 1 || autoScrolling) {
                if (event && currentIndex === count - 1)
                    event.accepted = false;
                scrollAni.clearPostponed();
                return;
            }
            if (scrollAni.running) {
                scrollAni.addPostponed(scrollToNextIndex);
                return;
            }
            if (d.editModeOn && !indexEditable(currentIndex + 1))
                scrollAni.scrollTo(contentWidth + originX);
            if (d.editModeOn) {
                var testIndex = incrementEditable(currentIndex + 1);
                if (testIndex !== -1)
                    currentIndex = testIndex;
                else
                    return;
            } else {
                incrementCurrentIndex();
            }
            ensureItemVisible(currentItem);
        }

        property var uneditableIndexes: []
    }

    orientation: Qt.Horizontal
    boundsBehavior: Flickable.StopAtBounds
    interactive: false

    // This animation will animate the item when they are moved in the model
    property var displacedEasing: (smoothAutoscroll && autoScrolling)? Easing.Linear : Easing.InQuad
    property var moveEasing: (smoothAutoscroll && autoScrolling)? Easing.Linear : Easing.OutQuad
    property int displacedDuration: (smoothAutoscroll && autoScrolling)? 100 : 200
    property int moveDuration: (smoothAutoscroll && autoScrolling)? 100 : 200
    property bool moveAnimationEnabled: editing
    moveDisplaced: Transition {
        id: displacedTransition
        enabled: moveAnimationEnabled
        NumberAnimation { property: "x"; easing.type: displacedEasing; duration: displacedDuration; }
    }
    move: Transition {
        id: moveTransition
        enabled: moveAnimationEnabled
        NumberAnimation { property: "x"; easing.type: moveEasing; duration: moveDuration; }
        onRunningChanged: {
            if (!running) {
                moveDuration = Qt.binding(function(){return (smoothAutoscroll && autoScrolling)? 100 : 200});
            }
        }
    }


    // FIXME: highlightFollowsCurrentItem:false has this bug: if currentItem is off-screen,
    // the ListView will immediatly change contentX to force the highlight item to be fully visible.
    // The current workaround is to set the highlight item's anchors to "inverted fill" so it will
    // be always "inside" the viewport.
    highlightFollowsCurrentItem: false
    highlight: Item { width: -contentWidth; x: originX + contentWidth }

    // NOTE: contentWidth could be often changed during flicking (especially if delegate size may
    // vary), so we need to apply corrections to running animation.
    onContentWidthChanged: {
        if (scrollAni.running) {
            switch (state) {
            case "autoscrolling-right":
                scrollAni.scrollTo(contentWidth + originX - width);
                break;
            case "autoscrolling-left":
                scrollAni.scrollTo(originX);
                break;
            }
        }
    }

    function updateCurrentIndex() {
        var indexPosition = scrollAni.indexPosition;
        if (cursorVisible && !d.editModeOn)
            indexPosition = mapFromItem(null, cursorPosition.x, cursorPosition.y).x;
        if (isNaN(indexPosition))
            return;
        var idx = indexAt(contentX + indexPosition, contentY)
        if (idx !== -1) {
            if (!d.editModeOn || (d.editModeOn && indexEditable(idx)))
               currentIndex = idx;
        }
    }

    // TODO: subscribing to contentXChanged is probably expensive, as it will be called for every
    // animation frame. It would be nice to have some other way to update currentIndex.
    onContentXChanged: {
        if (!autoScrolling || cursorVisible || d.scrollByKey)
            updateCurrentIndex();
    }

    onScrollingChanged: {
        if (!scrolling)
            updateCurrentIndex();
    }

    // NOTE: If currentIndex cannot be effectively changed, event.accepted must be set to false.
    // This will allow client code to react on this event (e.g. move focus outside the ribbon, etc.).
    function leftKeyPressed(event) { // We can call this function outside to simulate key press event
        var inBounds = currentItem? checkBounds(currentItem, currentItem.width * 1.5, width - currentItem.width * 1.5) : -1;
        if (event.isAutoRepeat && inBounds < 0) {
            if (scrollToLeft()) {
                d.scrollByKey = true;
                return;
            }
        }
        d.scrollByKey = false;
        if (layoutDirection === Qt.RightToLeft)
            d.scrollToNextIndex(event);
        else
            d.scrollToPrevIndex(event);
    }

    Keys.onLeftPressed: (event) => {
        if (scrolling && ribbon.state === "autoscrolling-right") {
            stopScrollingByKey(event);
            return;
        }
        leftKeyPressed(event);
    }

    function rightKeyPressed(event) { // We can call this function outside to simulate key press event
        var inBounds = currentItem? checkBounds(currentItem, currentItem.width * 1.5, width - currentItem.width * 1.5) : 1;
        if (event.isAutoRepeat && inBounds > 0) {
            if (scrollToRight()) {
                d.scrollByKey = true;
                return;
            }
        }
        d.scrollByKey = false;
        if (layoutDirection === Qt.RightToLeft)
            d.scrollToPrevIndex(event);
        else
            d.scrollToNextIndex(event);
    }

    Keys.onRightPressed: (event) => {
        if (scrolling && ribbon.state === "autoscrolling-left") {
            stopScrollingByKey(event);
            return;
        }
        rightKeyPressed(event);
    }

    Keys.onReleased: (event) => {
        switch (event.key) {
        case Qt.Key_Left:
        case Qt.Key_Right:
            stopScrollingByKey(event);
            break;
        }
    }

    function stopScrollingByKey(event) {
        d.scrollByKey = false;
        if (!event.isAutoRepeat && autoScrolling) {
            scrollAni.stopByKey = true;
            stopScrolling();
        }
    }

    function allowedMoveInModel(from, to) {
        if (!scrollingActive() || d.scrollByKey || !autoScrolling)
            return true;

        if (layoutDirection === Qt.LeftToRight) {
            if (state === "autoscrolling-right" && from <= to)
                return true;
            if (state === "autoscrolling-left" && from >= to)
                return true;
        } else if (layoutDirection === Qt.RightToLeft) {
            if (state === "autoscrolling-right" && from >= to)
                return true;
            if (state === "autoscrolling-left" && from <= to)
                return true;
        } else {
            return true;
        }

        return false;
    }

    // TODO: Built-in easing cannot be used, as it will be visually different for extreme short
    // and long scrolling. This could be implemented in state transitions.
    property alias scrollAnimation: scrollAni
    NumberAnimation {
        id: scrollAni
        target: ribbon; property: "contentX"
        property real indexPosition: NaN
        property var postponedActions: []
        easing.type: defaultEasing
        property bool wheelScrolling: false
        property bool stopByKey: false

        function clearPostponed(forceStop) {
            postponedActions.length = 0;
            if (forceStop)
                stop();
        }

        function addPostponed(action) {
            if (!action)
                return;
            if (postponedActions.length === 0 || postponedActions[0].callback === action) {
                postponedActions.push({'callback':action} );
            } else {
                postponedActions = [{'callback':action}];
            }
        }

        function getBezierCurve(type) {
            if (type === Easing.Bezier)
                return easingCurve;
            return [];
        }

        function scrollTo(pos, easingType) {
            // Workaround for "originX BUG" (fixed in v5.4)
            if (layoutDirection === Qt.RightToLeft && contentWidth < width)
                return;
            to = d.clamp(pos);
            var diff = Math.abs(to - contentX);
            duration = diff / pixelsPerSecond * 1000;
            easing.type = easingType ? easingType : defaultEasing;
            easing.bezierCurve = getBezierCurve(easing.type);
            // Call restart instead of start as we need to account for changes in the
            // target position while the animation is running
            restart();
        }

        function runPostponed() {
            if (postponedActions.length > 0) {
                var action = postponedActions.shift();
                action.callback();
            }
        }

        onRunningChanged: {
            if (running) {
                stopByKey = false;
                targetItem = null;
                return;
            }
            wheelScrolling = false;

            if (ribbon.editing) {
                // TODO: Not 100% sure this is correct place to call forceItemVisible
                if (isNaN(indexPosition) || indexPosition === 0 || indexPosition === ribbon.width) { //Do not ensure item visible while wheel scrolling
                    forceItemVisible(targetItem && !stopByKey? targetItem : currentItem); //Temporary snaping
                }
                if (ribbon.contentX === to)
                    ribbon.stopScrolling();
                runPostponed();
            } else if (ribbon.contentX === to) {
                if (state === "autoscrolling-right") {
                    ribbon.autoScrolledToEnd();
                } else if (state === "autoscrolling-left") {
                    ribbon.autoScrolledToBeginning();
                }

                if (state === "autoscrolling-right" || state === "autoscrolling-left")
                    ribbon.stopScrolling();
                else
                    runPostponed();
            } else {
                //Possible break auto-scrolling
                if (stopByKey)
                    forceItemVisible(targetItem? targetItem : currentItem);
            }
            stopByKey = false;
        }
    }

    NumberAnimation {
        id: afterScrollAni
        target: ribbon; property: "contentX"
        property real indexPosition: NaN

        function scrollTo(pos) {
            // Workaround for "originX BUG" (fixed in v5.4)
            if (layoutDirection === Qt.RightToLeft && contentWidth < width)
                return;
            to = d.clamp(pos);
            var diff = Math.abs(to - contentX);
            duration = diff / pixelsPerSecond * 1000;
            // Call restart instead of start as we need to account for changes in the
            // target position while the animation is running
            restart();
        }
    }

    states: [
        State {
            name: ""
            PropertyChanges { target: ribbon; autoScrolling: false }
            PropertyChanges { target: scrollAni; indexPosition: NaN }
            StateChangeScript { script: {
                    scrollAni.stop();
                } }
        },
        State {
            name: "autoscrolling"
            PropertyChanges { target: ribbon; autoScrolling: true }
        },
        State {
            name: "autoscrolling-right"; extend: "autoscrolling"
            PropertyChanges { target: scrollAni; indexPosition: ribbon.width }
            StateChangeScript { script: {
                    scrollAni.scrollTo(contentWidth + originX - width, customEasing); } }
        },
        State {
            name: "autoscrolling-left"; extend: "autoscrolling"
            PropertyChanges { target: scrollAni; indexPosition: 0 }
            StateChangeScript { script: {
                    scrollAni.scrollTo(originX, customEasing); } }
        }
    ]
}
