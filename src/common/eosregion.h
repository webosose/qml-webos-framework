// Copyright (c) 2015-2018 LG Electronics, Inc.
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

#ifndef EOS_REGION_H
#define EOS_REGION_H

#include <QDebug>
#include <QObject>
#include <QQmlParserStatus>
#include <QQmlListProperty>

#include <QRegion>

#include "eosregionrect.h"

class EosRegion : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<EosRect> regionRects READ regionRects)
    Q_INTERFACES(QQmlParserStatus)

public:
    EosRegion(QObject *parent = 0);
    ~EosRegion();

    virtual void classBegin();
    virtual void componentComplete();

    QQmlListProperty<EosRect> regionRects();

    QRegion region() { return m_Region; }

protected:
    QRegion m_Region;
    QList<EosRect *> m_regionRects;
};

#endif // EOS_REGION_H
