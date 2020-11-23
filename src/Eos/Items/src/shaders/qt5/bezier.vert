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

attribute highp vec4 vertex;
attribute highp vec2 texture0;
attribute highp float coverage;

uniform highp mat4 qt_Matrix;

varying highp vec2 qt_TexCoord0;
varying highp vec2 qt_TexCoord1;
varying lowp float vcoverage;

// control points for top edge
uniform highp vec2 controlTopLeft;
uniform highp vec2 controlTopRight;

// control points for bottom edge
uniform highp vec2 controlBottomLeft;
uniform highp vec2 controlBottomRight;

// control points for left edge
uniform highp vec2 controlLeftTop;
uniform highp vec2 controlLeftBottom;

// control points for right edge
uniform highp vec2 controlRightTop;
uniform highp vec2 controlRightBottom;

// corner points
uniform highp vec2 topLeft;
uniform highp vec2 topRight;
uniform highp vec2 bottomLeft;
uniform highp vec2 bottomRight;

uniform highp vec4 dest;
uniform mediump vec4 sourceSubRect;

void main() {

    //cubic de casteljau along top edge
    highp vec2 topP00 = mix(topLeft, controlTopLeft, vertex.x);
    highp vec2 topP01 = mix(controlTopLeft, controlTopRight, vertex.x);
    highp vec2 topP02 = mix(controlTopRight, topRight, vertex.x);

    highp vec2 topP10 = mix(topP00, topP01, vertex.x);
    highp vec2 topP11 = mix(topP01, topP02, vertex.x);

    highp vec2 top = mix(topP10, topP11, vertex.x);

    // de casteljau along bottom edge
    highp vec2 bottomP00 = mix(bottomLeft, controlBottomLeft, vertex.x);
    highp vec2 bottomP01 = mix(controlBottomLeft, controlBottomRight, vertex.x);
    highp vec2 bottomP02 = mix(controlBottomRight, bottomRight, vertex.x);

    highp vec2 bottomP10 = mix(bottomP00, bottomP01, vertex.x);
    highp vec2 bottomP11 = mix(bottomP01, bottomP02, vertex.x);

    highp vec2 bottom = mix(bottomP10, bottomP11, vertex.x);

    // also interpolate the controlpoints
    highp vec2 topControl = top + mix(controlLeftTop - topLeft, controlRightTop - topRight, vertex.x);
    highp vec2 bottomControl = bottom + mix(controlLeftBottom - bottomLeft, controlRightBottom - bottomRight, vertex.x);

    //finally de casteljau from top to bottom
    highp vec2 midP00 = mix(top, topControl, vertex.y);
    highp vec2 midP01 = mix(topControl, bottomControl, vertex.y);
    highp vec2 midP02 = mix(bottomControl, bottom, vertex.y);

    highp vec2 midP10 = mix(midP00, midP01, vertex.y);
    highp vec2 midP11 = mix(midP01, midP02, vertex.y);

    vec4 pos = vec4(mix(midP10, midP11, vertex.y), 0.0, 1.0);

    // antialiasing: the mesh contains a ring of vertices with coverage=0
    // this ring gets moved out from the original positions by half a pixel with alpha values set to transparent
    // and the next inner ring of vertices gets moved half a pixel inwards
    // => a 1px ring of semi-transparent fragments can be rendered.

    pos.xy += texture0.xy;

    gl_Position = qt_Matrix * pos;
    qt_TexCoord0 = sourceSubRect.xy + sourceSubRect.zw * ((pos.xy - dest.xy) / dest.zw);
    qt_TexCoord1 = texture0.xy;
    vcoverage = coverage;
}
