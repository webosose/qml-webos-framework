# Copyright (c) 2014-2020 LG Electronics, Inc.
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

TEMPLATE = lib
CONFIG += staticlib c++11
TARGET = webosqmlframeworkcommon

QT += qml quick gui-private quick-private

no_webos_platform {
    DEFINES += NO_WEBOS_PLATFORM
} else {
    CONFIG += link_pkgconfig
    PKGCONFIG += webos-platform-interface
}

# OE Core recipe exports the MACHINE variable
TARGET_MACHINE = $$(MACHINE)
isEmpty(TARGET_MACHINE) {
    DEFINES += NO_WINDOW_TRANSPARENCY
}

SOURCES += webosquickwindow.cpp
HEADERS += webosquickwindow.h

SOURCES += eosregionrect.cpp eosregion.cpp
HEADERS += eosregionrect.h eosregion.h
