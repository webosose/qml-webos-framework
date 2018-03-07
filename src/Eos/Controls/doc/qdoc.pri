# Copyright (c) 2014-2018 LG Electronics, Inc.
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

# http://qt-project.org/doc/qt-5/qdoc-guide.html

!exists($$QMAKE_DOCS): error("Cannot find documentation specification file $$QMAKE_DOCS")

QMAKE_DOCS_BASE_OUTDIR = $$PWD/doc

QMAKE_DOCS_TARGET = $$replace(QMAKE_DOCS, ^(.*/)?(.*)\\.qdocconf$, \\2)
QMAKE_DOCS_OUTPUTDIR = $$QMAKE_DOCS_BASE_OUTDIR/$$QMAKE_DOCS_TARGET

qtPrepareTool(QDOC, qdoc)

html_docs.commands += $$QDOC $$QMAKE_DOCS
html_docs.target = docs

QMAKE_EXTRA_TARGETS += html_docs
PRE_TARGETDEPS += docs
