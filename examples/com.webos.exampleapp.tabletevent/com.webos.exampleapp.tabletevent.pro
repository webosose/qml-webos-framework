# Copyright (c) 2018-2020 LG Electronics, Inc.
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

TEMPLATE = app
TARGET = com.webos.exampleapp.tabletevent

QT = core gui quick

SOURCES += \
    main.cpp \
    tabletitem.cpp \

HEADERS += \
    tabletitem.h \

INSTALL_BINDIR = $$WEBOS_INSTALL_WEBOS_APPLICATIONSDIR/com.webos.exampleapp.tabletevent
INSTALL_APPDIR = $$WEBOS_INSTALL_WEBOS_APPLICATIONSDIR/com.webos.exampleapp.tabletevent

RESOURCES += \
    com.webos.exampleapp.tabletevent.qrc

OBJECTS_DIR = .obj
MOC_DIR = .moc
RCC_DIR = .rcc

QMAKE_CLEAN += $(TARGET)

target.path = $$INSTALL_BINDIR

metadata.files = $$files(webos-metadata/*)
metadata.path = $$INSTALL_APPDIR

INSTALLS += target metadata
