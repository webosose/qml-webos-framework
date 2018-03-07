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

#include <QtCore/QString>
#include <QtCore/QMessageLogContext>
#include <PmLogLib.h>
#include "logger.h"

namespace {

void pmlogMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    static PmLogContext pmlog_ctx;
    static bool contextCreated = false;
    if (!contextCreated) {
        contextCreated = true;
        PmLogGetContext("boosterd", &pmlog_ctx);
    }

    // Keep a reference for converted msg, otherwise it will be freed immediately.
    const QByteArray utf8 (msg.toUtf8());

    // http://wiki.lgsvl.com/display/TechDoc/Managing+logging+for+webOS+for+smart+TV
    switch (type) {
    case QtDebugMsg:
        PmLogInfo(pmlog_ctx, context.category, 1,
                  PMLOGKS("FUNCTION", context.function),
                  "%s", utf8.constData());
        break;
    case QtInfoMsg:
        PmLogInfo(pmlog_ctx, context.category, 1,
                     PMLOGKS("FUNCTION", context.function),
                     "%s", utf8.constData());
        break;
    case QtWarningMsg:
        PmLogWarning(pmlog_ctx, context.category, 1,
                     PMLOGKS("FUNCTION", context.function),
                     "%s", utf8.constData());
        break;
    case QtCriticalMsg:
        PmLogError(pmlog_ctx, context.category, 3,
                   PMLOGKS("FUNCTION", context.function),
                   PMLOGKS("FILE", context.file),
                   PMLOGKFV("LINE","%d", context.line),
                   "%s", utf8.constData());
        break;
    case QtFatalMsg:
        PmLogCritical(pmlog_ctx, context.category, 3,
                      PMLOGKS("FUNCTION", context.function),
                      PMLOGKS("FILE", context.file),
                      PMLOGKFV("LINE","%d", context.line),
                      "%s", utf8.constData());
        abort();
    }
}

} // namespace

void initLogger()
{
    qInstallMessageHandler(pmlogMessageHandler);
}
