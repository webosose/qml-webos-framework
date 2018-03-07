// Copyright (c) 2014-2018 LG Electronics, Inc.
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
uniform highp vec4 dest;
uniform mediump vec4 sourceSubRect;

varying highp vec2 qt_TexCoord0;
varying highp vec2 qt_TexCoord1;
varying lowp float vcoverage;

void main() {
    gl_Position = qt_Matrix * vertex;
    qt_TexCoord0 = sourceSubRect.xy + sourceSubRect.zw * ((vertex.xy - dest.xy) / dest.zw);
    vcoverage = coverage;
}
