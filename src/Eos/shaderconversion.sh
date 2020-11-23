#!/bin/sh
# Copyright (c) 2021 LG Electronics, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

qtVersion=$1
sourceDir=$2
destDir=$3

mkdir -p "$destDir"
shaderFiles=""
if [ $qtVersion -eq 6 ]; then
    for shader in $sourceDir/*.qt6
    do
        qsbShader="$destDir/$(basename ${shader} .qt6)"
        cp "${shader}" "$qsbShader" > /dev/null 2>&1
        qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 "$qsbShader" -o "$qsbShader" > /dev/null 2>&1
        shaderFiles="$shaderFiles $qsbShader"
    done
else
    for shader in $sourceDir/*.qt5
    do
        qsbShader="$destDir/$(basename ${shader} .qt5)"
        cp "${shader}" "$qsbShader" > /dev/null 2>&1
        shaderFiles="$shaderFiles $qsbShader"
    done
fi

echo "$shaderFiles"
