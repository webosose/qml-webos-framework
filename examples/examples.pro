# Copyright (c) 2012-2021 LG Electronics, Inc.
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

TEMPLATE = subdirs

MOC_DIR = .moc
OBJECTS_DIR = .obj

CONFIG += qt debug

SUBDIRS = \
    bare-eos \
    com.webos.exampleapp.canvastablet \
    com.webos.exampleapp.tabletevent \
    com.webos.exampleapp.qmllocalization \
    gallery \
    overlay-window \
    vkb-overlay
