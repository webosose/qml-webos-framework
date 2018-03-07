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

// Item that alternates between two wipers
Item {
    id: root
    property Item sourceItemA
    property Item sourceItemB

    property Item nextWiper: startOpen ? wiperB: wiperA
    property Item nextSource: nextWiper == wiperA? sourceItemA : sourceItemB
    property Item lastSource: nextWiper == wiperA? sourceItemB : sourceItemA
    property bool startOpen: false
    property bool openFromLeft: false
    property bool forceBeziergon: false

    property real openTime: 600
    Wiper {
        state: root.startOpen ? "open" : (openFromLeft ? "closed-left" : "closed")
        id: wiperA
        anchors.fill: parent
        sourceItem: sourceItemA
        openTime: root.openTime
        forceBeziergon: root.forceBeziergon
        onOpened: {
            // if the other wiper is in flight, don't hide it
            // as it will go above us and hide us
            if(!wiperB.transitioning)
                wiperB.visible = false
        }

    }
    Wiper {
        id: wiperB
        anchors.fill: parent
        sourceItem: sourceItemB
        openTime: root.openTime
        forceBeziergon: root.forceBeziergon
        onOpened: {
            // if the other wiper is in flight, don't hide it
            // as it will go above us and hide us
            if(!wiperA.transitioning)
                wiperA.visible = false
        }
    }

    function advance() {
        nextWiper.visible = true
        nextWiper.z = 1
        // make sure it is closed before you kick off a new transition
        // otherwise it will not transition at all
        nextWiper.state = openFromLeft ? "closed-left" : "closed"
        nextWiper.open()

        if(nextWiper == wiperA) {
            nextWiper = wiperB
        } else {
            nextWiper = wiperA
        }
        nextWiper.z = 0
    }

    function close() {
        wiperA.state = openFromLeft ? "closed-left" : "closed"
        wiperB.state = openFromLeft ? "closed-left" : "closed"
    }

    onOpenFromLeftChanged: {
        if(openFromLeft && nextWiper.state != "closed-left")
            nextWiper.skipToClosedLeft();
        else if(!openFromLeft && nextWiper.state != "closed")
            nextWiper.skipToClosedRight();
    }
}
