// Copyright (c) 2014-2018 LG Electronics, Inc.
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

#include "plugin.h"
#include "punchthrough.h"
#include "beziergon.h"
#include "parallelogram.h"

#ifdef USE_LIBVT
#include "videocapture.h"
#endif //USE_LIBVT

#include <qqml.h>

void ItemsPlugin::registerTypes(const char *uri)
{
    // @uri Eos.Items
    qmlRegisterType<PunchThrough>(uri, 0, 1, "PunchThrough");
    qmlRegisterType<SamplerGeometry::Beziergon>(uri, 0, 1, "Beziergon");
    qmlRegisterType<SamplerGeometry::Parallelogram>(uri, 0, 1, "FastParallelogram");
#ifdef USE_LIBVT
    qmlRegisterType<VideoCapture>(uri, 0, 1, "VideoCapture");
#endif //USE_LIBVT
}
