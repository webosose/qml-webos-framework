# Copyright (c) 2018 LG Electronics, Inc.
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

QT += qml quick

CONFIG += qt plugin c++11
TARGET = eosvirtualkeyboardoverlay

include(../../common/common.pri)

uri = Eos.VirtualKeyboardOverlay

FRAMEWORK_VERSION_MAJOR = 0
FRAMEWORK_VERSION_MINOR = 1

DEFINES += "FRAMEWORK_VERSION_MAJOR=$$FRAMEWORK_VERSION_MAJOR"
DEFINES += "FRAMEWORK_VERSION_MINOR=$$FRAMEWORK_VERSION_MINOR"

SOURCES += $$files(*.cpp)
HEADERS += $$files(*.h)
OTHER_FILES = qmldir

!defined(WEBOS_INSTALL_QML, var) {
    instbase = $$[QT_INSTALL_QML]
} else {
    instbase = $$WEBOS_INSTALL_QML
}

target.path = $$instbase/$$replace(uri, \\., /)

pluginqmldir.base = $$_PRO_FILE_PWD_
pluginqmldir.path = $$instbase/$$replace(uri, \\., /)
pluginqmldir.files = qmldir

INSTALLS += target pluginqmldir
