/* @@@LICENSE
 *
 * Copyright (c) 2019 LG Electronics, Inc.
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

    property string label1
    property string label2
    property string label3
    property string label4

    Canvas {
        id: mycanvas
        anchors.fill: parent

        property var items: [
            {points: [], style: "red", uid: "", pressed: false},
            {points: [], style: "blue", uid: "", pressed: false},
            {points: [], style: "green", uid: "", pressed: false},
            {points: [], style: "lightcoral", uid: "", pressed: false},
            {points: [], style: "plum", uid: "", pressed: false},
            {points: [], style: "gray", uid: "", pressed: false},
            {points: [], style: "greenyellow", uid: "", pressed: false}
        ];
        property var nextIndex: 1;
        property var colorIndex: {
            "0": 0,
            "-1": 0,
            "1": 0
        };

        property bool doClear: false;

        onPaint: {
            var ctx = getContext('2d');

            if (doClear) {
                ctx.fillStyle = "White";
                ctx.fillRect(0, 0, root.width, root.height);
                doClear = false;
                return;
            }

            var textMargin = 10;
            if (!!items) {
                for (var i = 0; i < items.length; i++) {
                    ctx.fillStyle = items[i].style;
                    var item = items[i];
                    for (var j = 0; j < item.points.length; j++) {
                        var point = item.points[j];
                        ctx.fillRect(point.x - 1, point.y - 1, point.size, point.size);
                        if (point.type == 'P' || point.type == 'R') {
                            var oldFillStyle = ctx.fillStyle;
                            ctx.fillStyle = 'Black';
                            ctx.fillText(point.type, point.x + textMargin, point.y + textMargin);
                            ctx.fillStyle = oldFillStyle;
                        }
                    }
                    items[i].points = [];
                }
            }
        }

        TabletItem {
            id: tabletItem
            anchors.fill: parent

            property var items: mycanvas.items

            function indexFromUniqueId(uid) {
                var idx = 0;
                if (uid in mycanvas.colorIndex) {
                    idx = mycanvas.colorIndex[uid];
                } else {
                    mycanvas.colorIndex[uid] = mycanvas.nextIndex;
                    mycanvas.nextIndex += 1;
                    idx = mycanvas.colorIndex[uid];
                }
                return idx;
            }

            function savePoint(uid, pos, type, size) {
                var idx = indexFromUniqueId(uid);

                var point = {
                    x: pos.x,
                    y: pos.y,
                    type: 'M',
                    size: 3
                };
                if (type === "pressed") {
                    items[idx].pressed = true;
                    point.size = 10;
                    point.type = 'P';
                } else if (type === "released") {
                    items[idx].pressed = false;
                    point.size = 10;
                    point.type = 'R';
                }

                items[idx].points.push(point);
                var output = type + ": " + pos.x + ", " + pos.y + " " + (items[idx].pressed ? "Pressed" : "");
                switch (idx) {
                case 0:
                    root.label1 = output;
                    break;
                case 1:
                    root.label2 = output;
                    break;
                case 2:
                    root.label3 = output;
                    break;
                case 3:
                    root.label4 = output;
                    break;
                default:
                    root.label1 = output;
                    break;
                }
            }

            onMoved: {
                var uid = Number(uniqueId).toString();
                var type = "moved";
                var size = 3;
                savePoint(uid, pos, type, size);
                mycanvas.requestPaint();
            }

            onPressed: {
                var uid = Number(uniqueId).toString();
                var type = "pressed";
                var size = 10;
                savePoint(uid, pos, type, size);
                mycanvas.requestPaint();
            }

            onReleased: {
                var uid = Number(uniqueId).toString();
                var type = "released";
                var size = 10;
                savePoint(uid, pos, type, size);
                mycanvas.requestPaint();
            }
            onTouchUpdated: {
                var uid = 0;
                var size = 0;
                var touchType = "moved";
                var pos = {
                    x: xTouch,
                    y: yTouch
                };
                switch (eventType) {
                case "TouchBegin":
                    touchType = "pressed";
                    size = 10;
                    break;
                case "TouchEnd":
                    touchType = "released";
                    size = 10;
                    break;
                case "TouchUpdate":
                    touchType = "moved";
                    size = 3;
                    break;
                }
                savePoint(uid, pos, touchType, size);
                mycanvas.requestPaint();
            }
        }
    }

    Text {
        id: textLabel1
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 40
        text: root.label1
        font.pixelSize: 30
    }

    Text {
        id: textLabel2
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 500
        text: root.label2
        font.pixelSize: 30
    }

    Text {
        id: textLabel3
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 960
        text: root.label3
        font.pixelSize: 30
    }

    Text {
        id: textLabel4
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 1520
        text: root.label4
        font.pixelSize: 30
    }

    Rectangle {
        id: clearButton
        color: "steelblue"
        border.color: "black"
        border.width: 5
        radius: 10
        width: 200
        height: 100

        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.right: parent.right
        anchors.rightMargin: 40

        Text {
            id: clearLabel
            text: "Clear"
            font.pixelSize: 30
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mycanvas.doClear = true;
                mycanvas.requestPaint();
            }
        }
    }
}
