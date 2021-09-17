// Copyright (c) 2021 LG Electronics, Inc.
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

import QtQuick 2.4
import Eos.Window 0.1
import WebOSServices 1.0
import WebOS.Global 1.0

WebOSWindow {
    id: root
    title: "Localization"
    width: 1920
    height: 1080
    visible: true
    color: "white"

    LocaleService {
        id: localeService
        appId: "com.webos.exampleapp.qmllocalization-l10n"
        l10nFileNameBase: "qml-webos-framework"
        l10nDirName: WebOS.localizationDir + "/" + l10nFileNameBase

        Component.onCompleted: {
            subscribe();
        }

        onCurrentLocaleChanged: console.info("Localization: currentLocale: " + localeService.currentLocale);
        onL10nLoadSucceeded: (file) => { console.info("Localization: Loaded", file); }
        onL10nInstallSucceeded: (file) => { console.info("Localization: Installed", file); }
        onL10nLoadFailed: (file) => { console.warn("Localization: Failed to load", file); }
        onL10nInstallFailed: (file) => { console.warn("Localization: Failed to install", file); }
        onError: (errorCode, errorText, token) => { console.warn("Localization: An error occurred,", errorText); }
    }

    Text {
        id: infoLabel
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        color: "blue"
        font.pixelSize: 32
        text: "currentLocale:" + localeService.currentLocale + "\n"
            + "l10nFileNameBase: " + localeService.l10nFileNameBase + "\n"
            + "l10nDirName: " + localeService.l10nDirName + "\n"
            + "l10nPluginImports: " + localeService.l10nPluginImports.toString()
    }

    Text {
        id: localizedText1
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: infoLabel.bottom
        text: qsTr("Hello") + localeService.emptyString
        color: "black"
        font.pixelSize: 100
    }

    Text {
        id: localizedText2
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: localizedText1.bottom
        text: qsTr("Goodbye") + localeService.emptyString
        color: "black"
        font.pixelSize: 100
    }
}
