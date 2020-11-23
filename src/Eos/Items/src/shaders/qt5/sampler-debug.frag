// Copyright (c) 2014-2021 LG Electronics, Inc.
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

uniform lowp vec4 color;
uniform sampler2D source;
varying highp vec2 qt_TexCoord0;
uniform mediump vec4 sourceSubRect;
uniform lowp float qt_Opacity;
varying lowp float vcoverage;

uniform lowp int rotation;
uniform lowp float xScale;
uniform lowp float yScale;

void main() {
    highp float prevCoordX;
    highp float prevCoordY;
    highp float newCoordX;
    highp float newCoordY;
    lowp vec4 texel;

    if (rotation == 90) {
        prevCoordX = qt_TexCoord0.y;
        prevCoordY = 1.0 - qt_TexCoord0.x;
    } else if (rotation == 180) {
        prevCoordX = 1.0 - qt_TexCoord0.x;
        prevCoordY = 1.0 - qt_TexCoord0.y;
    } else if (rotation == 270) {
        prevCoordX = 1.0 - qt_TexCoord0.y;
        prevCoordY = qt_TexCoord0.x;
    } else {
        prevCoordX = qt_TexCoord0.x;
        prevCoordY = qt_TexCoord0.y;
    }

    newCoordX = (prevCoordX) * xScale  + (1.0 - xScale) / 2.0;
    newCoordY = (prevCoordY) * yScale  + (1.0 - yScale) / 2.0;

    if (newCoordX < 0.0 || newCoordX > 1.0 || newCoordY < 0.0 || newCoordY > 1.0)
        texel = color;
    else
        texel = texture2D(source, vec2(newCoordX , newCoordY));

    lowp vec4 sourceColor = texel + vec4(1.0 - texel.a) * color;

    sourceColor.rb *= vec2(0.1);

    gl_FragColor = sourceColor * qt_Opacity * vcoverage;
}
