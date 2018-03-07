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

.pragma library

var angle = 10;

var _tan = Math.tan(angle * Math.PI / 180);
var _sin = Math.sin((90 - angle) * Math.PI / 180);

function parallelogramGeometry(angle, base, height) {
    /*
         |-offset-|-------base-------|
      _
      |           /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/
      |          /                  /
      |         / \                /
      |        /    innerWidth    /
    height    /                \ /
      |      /                  /
      |     /              angle
      |    /                | /
      |   /_________________|/
      ¯
         |-----------width-----------|
     */
    var width = base + height * _tan;
    var innerWidth = base * _sin;

    return {
        angle: angle,
        base: base,
        height: height,
        width: width,
        offset: width - base,
        innerWidth: innerWidth,
        tan: _tan
    };
}

var launchPoint = {
    spacing: 2,
    color: "gray",
    geometry: parallelogramGeometry(angle, 140, 300) // angle, base, height
};

var navigationButton = {
    color: "white",
    geometry: parallelogramGeometry(angle, 180, 300) // angle, base, height
};

var recentsCard = {
    color: "lightgray",
    geometry: parallelogramGeometry(angle, 370, 300) // angle, base, height
};

var ribbonHotspot = {
    width: launchPoint.geometry.base
};

var colors = [];
for (var i = 0; i < 16; ++i) {
    colors.push(Qt.rgba((Math.random() + 1) / 1.5 - 0.4,
                        (Math.random() + 1) / 1.5 - 0.4,
                        (Math.random() + 1) / 1.5 - 0.4));
};
