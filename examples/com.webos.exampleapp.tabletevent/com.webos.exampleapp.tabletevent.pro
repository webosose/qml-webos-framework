# @@@LICENSE
#
# (c) Copyright 2018 LG Electronics
#
# Confidential computer software. Valid license from LG Electronics required for
# possession, use or copying. Consistent with FAR 12.211 and 12.212,
# Commercial Computer Software, Computer Software Documentation, and
# Technical Data for Commercial Items are licensed to the U.S. Government
# under vendor's standard commercial license.
#
# LICENSE@@@

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
