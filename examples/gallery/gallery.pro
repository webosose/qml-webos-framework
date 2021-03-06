# Copyright (c) 2013-2018 LG Electronics, Inc.
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

TEMPLATE = aux
!load(webos-variables):error("Cannot load webos-variables.prf")

# for qtcreator cross-referencing qml types
OTHER_FILES += $$files(*.qml) $$files(pages/*.qml)
QML_IMPORT_PATH += ../../src

# install
defined(WEBOS_INSTALL_WEBOS_APPLICATIONSDIR, var) {
    base.path = $$WEBOS_INSTALL_WEBOS_APPLICATIONSDIR/eos.widgetgallery
    base.files = $$files(webos-metadata/*) $$files(*.qml)

    pages.path = $$WEBOS_INSTALL_WEBOS_APPLICATIONSDIR/eos.widgetgallery/pages
    pages.files = $$files(pages/*.qml)

    images.path = $$WEBOS_INSTALL_WEBOS_APPLICATIONSDIR/eos.widgetgallery/images
    images.files = $$files(images/*)

    INSTALLS += base pages images
}
