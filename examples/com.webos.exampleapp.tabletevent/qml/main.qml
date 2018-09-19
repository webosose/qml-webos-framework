/* @@@LICENSE
*
* Copyright (c) 2018 LG Electronics, Inc.
*
* Confidential computer software. Valid license from LG required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

import QtQuick 2.4
import Eos.Window 0.1
import TabletItem 1.0

WebOSWindow {
    id: root
    width: 1920
    height: 1080
    visible: true

    windowType: "_WEBOS_WINDOW_TYPE_CARD"

    property string label

    TabletItem {
        id: tabletItem
        anchors.fill: parent

        onMoved: {
            printOutput("Moved");
        }

        onPressed: {
            printOutput("Pressed");
        }

        onReleased: {
            printOutput("Released");
        }

        function printOutput(str) {
            var output;
            output = "Event\n";
            output += "Device: " + device + "\n";
            output += "Type: " + type + "\n";
            output += "Action: " + str + "\n";
            output += "x: " + pos.x + "\n";
            output += "y: " + pos.y + "\n";
            output += "z: " + z + "\n";
            output += "xTilt: " + xTilt + "\n";
            output += "yTilt: " + yTilt + "\n";
            output += "Pressure: " + pressure + "\n";

            root.label = output;
        }
    }

    Text {
        id: myText
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 40
        text: root.label
        font.pixelSize: 30
    }
}
