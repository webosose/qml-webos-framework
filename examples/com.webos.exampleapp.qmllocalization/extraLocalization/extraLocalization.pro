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

TEMPLATE = aux

!load(webos-variables):error("Cannot load webos-variables.prf")

defined(WEBOS_INSTALL_WEBOS_APPLICATIONSDIR, var) {
    CONFIG += lrelease
    EXTRA_TRANSLATIONS = qml-webos-framework_en.ts
    QM_FILES_INSTALL_PATH = $$WEBOS_INSTALL_DATADIR/qml/locales/qml-webos-framework/resources_0
    # QTBUG-77398
    versionAtMost(QT_VERSION, 5.14.1): qm_files.CONFIG = no_check_exist
}
