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
.import QtQuick.Window 2.2 as System

var angle = 10;

var launchPoint = {
    height: 300,
    width: 140,
    padding: Math.tan(Math.PI / 180 * angle) * 300,  // tan*height
    spacing: 1
};

var ribbonHotspot = {
    width: 1920 % (launchPoint.width + launchPoint.spacing) / 2
};
