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

    anchors.fill: parent
    hoverEnabled: true

    // The list that manages the delegates
    property Ribbon ribbon: null

    // The offset is used to determine a visual offset. As an example for a
    // rectangular item if the move should happen when the item has moved half
    // its width the offset should be half the items width. For a parallelogram
    // its should roughly be the offset + base / 2
    property real offset: 0

    // If the client wishes to handle the moving of the item in the model manually
    // then set to false
    property bool autoMove: true

    // The index of the item in the model
    property int index: -1

    // The scroll boundary is the number of pixels from either the left or right
    // side of the ribbon when to start scrolling the list during the edit operation
    // NOTE: When determining whether the boundary has been crossed the offset value is taken
    //       into consideration as well
    property real scrollBoundary: 100

    QtObject {
        id: d
        // Since the moved item will be reparented to the list we need to keep
        // track of the previous parent (== delegate) in order to put it back
        property Item owner: null
        // Keep track of the list's cache buffer
        property int originalCacheBuffer: -1
    }

    onPressAndHold: (mouse) => {
        if (ribbon === null) {
            console.warn("No ListView set, not starting drag");
            return;
        }

        if (index === -1) {
            console.warn("No index has been set, not starting drag");
            return;
        }

        d.originalCacheBuffer = ribbon.cacheBuffer;
        ribbon.cacheBuffer = ribbon.count * width;
        var pos = root.mapToItem(ribbon.contentItem);
        d.owner = parent.parent;
        parent.parent = ribbon;
        // Setting this will interfere with possible animations in the delegate
        // TODO: Need to be worked around
        parent.x = pos.x - ribbon.contentX;
        parent.y = pos.y;
        drag.target = parent;
        drag.axis = Drag.XAxis;
        ribbon.startEditing();
    }

    onReleased: (mouse) => {
        if (ribbon === null || drag.target === null) {
            return;
        }
        parent.parent = d.owner;
        d.owner = null;
        parent.x = 0;
        parent.y = 0;
        drag.target = null;
        ribbon.cacheBuffer = d.originalCacheBuffer;
        ribbon.endEditing();
    }

    // Bind to the item which we are moving and automatically move its
    // position in the model. To disable this set the 'autoMove' to false
    Connections {
        target: root.parent

        function onXChanged() {
            if (root.drag.target !== parent || !autoMove) {
                return;
            }
            // We assume that the mouse area occupies the whole delegate
            // hence it will suffice to use that as the 'reference' for
            // getting the item position in the list
            var pos = root.mapToItem(ribbon.contentItem);
            var target = ribbon.indexAt(pos.x + offset, 0);
            if (target !== -1 && target !== root.index && !ribbon.autoScrolling) {
                ribbon.model.move(root.index, target, 1);
                ribbon.currentIndex = target;
            }

            // Trigger the scrolling in either direction if we have crossed to boundary
            if ((ribbon.width + ribbon.contentX) - (pos.x + offset) < root.scrollBoundary) {
                ribbon.scrollToRight();
            } else if ((pos.x + offset) - ribbon.contentX < root.scrollBoundary) {
                ribbon.scrollToLeft();
            } else {
                ribbon.stopScrolling();
            }
        }
    }
}
