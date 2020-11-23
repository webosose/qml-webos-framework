# Copyright (c) 2014-2021 LG Electronics, Inc.
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

QT += qml quick quick-private core-private gui-private qml-private
CONFIG += qt plugin c++11

TARGET = $$qtLibraryTarget($$TARGET)
uri = Eos.Items
include($$PWD/../shader.pri)

SOURCES += $$files(src/*.cpp)
HEADERS += $$files(src/*.h)
versionAtLeast(QT_VERSION, 6.0.0) {
    system($$PWD/../shaderconversion.sh 6 \"$$PWD/src/shaders/qt6/\" \"$$PWD/src/shaders/qt6/\")
    RESOURCES = src/shaders/qt6/beziergon.qrc
} else {
    RESOURCES = src/shaders/qt5/beziergon.qrc
}

libvt {
    LIBS += -lvt
    DEFINES += USE_LIBVT
} else {
    SOURCES -= src/videocapture.cpp
    HEADERS -= src/videocapture.h
}

QML_FILES = \
    qmldir \
    $$files(*.qml) \
    $$files(*.js)

OTHER_FILES += QML_FILES

!defined(WEBOS_INSTALL_QML, var) {
    instbase = $$[QT_INSTALL_QML]
} else {
    instbase = $$WEBOS_INSTALL_QML
}

target.path = $$instbase/$$replace(uri, \\., /)

component.base = $$_PRO_FILE_PWD_
component.files = $$QML_FILES $$SHADER_FILES
component.path = $$instbase/$$replace(uri, \\., /)

INSTALLS += target component
