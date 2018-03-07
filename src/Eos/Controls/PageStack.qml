// Copyright (c) 2013-2018 LG Electronics, Inc.
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

FocusScope {
    id: container

    property var pageStack: []
    property Item currentPage: null
    property int length: { return pageStack.length }
    property bool busy: false
    property PageStackDelegate delegate: PageStackDelegate {}

    onDelegateChanged: delegate.pageStack = container

    signal creationFailed(var uri, var errMsg)

    // Keep this read-only by making it a getter so that we encourage sticking to the standard API
    function currentPageUrl() {
        return pageContainer.currentPageUrl
    }

    QtObject {
        id: d
        // must be property, otherwise could be collected by GC before calling onStatusChanged
        property var incubator: []
    }


    function push(pageUrl, properties) {
        var pUrl = pageUrl;
        var pushAtPos = container.pageStack.length;
        var pushAtZ = properties.z ? {z: properties.z} : {}
        var component = createComponent(pageUrl);
        if (component.status === Component.Error) {
            container.creationFailed(pUrl, component.errorString());
            return;
        }
        container.pageStack[pushAtPos] = null;
        pageContainer.currentPageUrl = pageUrl;
        // incubate without setting the parent, we're going to do that after we have created
        // the page wrapper
        d.incubator[pushAtPos] = component.incubateObject(0, properties);

        function wrap(status) {
            if (status === Component.Error) {
                if (pushAtPos === container.pageStack.length-1)
                    container.pageStack.length--;
                else
                    container.pageStack[pushAtPos] = undefined; //Set undefined to remove at future pop()

                container.creationFailed(pUrl, component.errorString());
                return;
            }
            if (status !== Component.Ready)
                return
            var wrapper = pageWrapper.createObject(pageContainer, pushAtZ);
            var theObject = d.incubator[pushAtPos].object;
            // parent the page into the wrapper
            theObject.parent = wrapper;
            // save reference to the wrapper
            theObject.__wrapper = wrapper;
            // save the page reference to the stack
            container.pageStack[pushAtPos] = theObject;
            // keep the 'length' and 'currentPage' updated
            container.length = container.pageStack.length;
            if (pushAtPos === container.pageStack.length-1) //Make "last pushed page" as current
                container.currentPage = theObject;

            container.delegate.enterItem = container.currentPage
            container.delegate.exitItem = container.pageStack[container.length-1]
            if (container.delegate.pushTransition) {
                var pushAnimation = container.delegate.pushTransition.createObject(theObject.__wrapper, {})
                container.busy = true
                pushAnimation.stopped.connect(function(){
                    container.busy = false;
                })
                pushAnimation.start()
            }
            // allow to be collected by GC
            d.incubator[pushAtPos] = null;
        }

        if (d.incubator[pushAtPos].status === Component.Ready) {
            wrap(Component.Ready);
        } else {
            d.incubator[pushAtPos].onStatusChanged = wrap;
        }
    }

    function getObjectsNumber() {
        var nmb = 0;
        for (var i=0; i < container.pageStack.length; i++) {
            if (container.pageStack[i] !== undefined ) nmb++;
        }
        return nmb;
    }

    function removeUndefined() { // remove top failed objects
        for (var i=container.pageStack.length-1; i >= 0; i--) {
            if (container.pageStack[i] === undefined)
                container.pageStack.length--;
            else
                return;
        }
    }

    function pop() {
        if (container.length < 2 || getObjectsNumber() < 2) {
            return;
        }

        var object = container.pageStack.pop();
        removeUndefined(); // Skip objects which are failed in incubator
        container.length = container.pageStack.length;
        container.delegate.exitItem = object
        container.delegate.enterItem = container.pageStack[container.length-1]
        if (container.delegate.popTransition) {
            var popAnimation = container.delegate.popTransition.createObject(object.__wrapper, {})
            container.busy = true
            popAnimation.stopped.connect(function(){
                object.destroy();
                container.busy = false;
            })
            popAnimation.start()
        }
        else {
            object.destroy()
        }
        container.currentPage = container.pageStack[container.length-1];
    }

    // replace the current page with a different one
    function replace(pageUrl, properties) {
        if (container.length == 0) return
        pageContainer.currentPageUrl = pageUrl;
        var index = container.length - 1;
        // create new page
        var component = createComponent(pageUrl);
        // incubate without setting the parent, we're going to do that after we have created the page wrapper
        var incubator = component.incubateObject(0, properties);
        var theObject;
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    // we're going to reuse the wrapper of the old page
                    var wrapper = container.pageStack[index].__wrapper;
                    container.delegate.exitItem = container.pageStack[index]
                    theObject = incubator.object;
                    // parent the page into the wrapper
                    theObject.parent = wrapper;
                    // save reference to the wrapper
                    theObject.__wrapper = wrapper;
                    // save the reference of the new page in the stack
                    container.currentPage = theObject;
                    container.delegate.enterItem = theObject

                    if (container.delegate.exitItem) {
                        if (container.delegate.replaceTransition) {
                            var replaceAnimation = container.delegate.replaceTransition.createObject(theObject.__wrapper, {})
                            container.busy = true
                            replaceAnimation.stopped.connect(function(){
                                container.pageStack[length-1] = currentPage;
                                container.delegate.exitItem.destroy()
                                busy = false;
                            })
                            replaceAnimation.restart()
                        }
                        else {
                            container.delegate.exitItem.destroy()
                        }
                    }
                }
            }
        } else {
            var wrapper = pageWrapper.createObject(pageContainer, {});
            theObject = incubator.object;
            theObject.parent = wrapper;
            // save reference to the wrapper
            theObject.__wrapper = wrapper;
            // save the reference of the new page in the stack
            container.currentPage = theObject;
            container.delegate.enterItem = theObject
            container.delegate.exitItem = container.pageStack[index]

            if (container.delegate.exitItem) {
                if (container.delegate.replaceTransition) {
                    var replaceAnimation = container.delegate.replaceTransition.createObject(theObject.__wrapper, {})
                    replaceAnimation.scheduleDestruction = true
                    container.busy = true
                    replaceAnimation.stopped.connect(function(){
                        container.pageStack[length-1] = currentPage;
                        container.delegate.exitItem.destroy()
                        busy = false;
                    })
                    replaceAnimation.restart()
                }
                else {
                    container.delegate.exitItem.destroy()
                }
            }
        }
    }

    // Utility function to log possible errors when creating a component
    function createComponent(component) {
        var c = Qt.createComponent(component);
        if (c.status == Component.Error) {
            console.warn("Error loading component", c, c.errorString());
        }
        return c;
    }

    function remove(from, to) {
        var rest = pageStack.slice((to || from) + 1 || pageStack.length);
        pageStack.length = from < 0 ? pageStack.length + from : from;
        pageStack.push.apply(pageStack, rest);
    }

    function clear() {
        pageStack.clear();
    }

    Component {
        id: pageWrapper

        Item {
            id: innerWrapper
            width: pageContainer.width
            height: pageContainer.height
        }
    }

    Item {
        id: pageContainer

        clip: true
        anchors.fill: parent

        property string currentPageUrl
    }
}
