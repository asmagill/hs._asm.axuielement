hs.axuielement
===================

This module allows you to access the accessibility objects of running applications, their windows, menus, and other user interface elements that support the OS X accessibility API.

This is very much a work in progress, so bugs and comments are welcome.

This module works through the use of axuielementObjects, which is the Hammerspoon representation for an accessibility object.  An accessibility object represents any object or component of an OS X application which can be manipulated through the OS X Accessibility API -- it can be an application, a window, a button, selected text, etc.  As such, it can only support those features and objects within an application that the application developers make available through the Accessibility API.

The basic methods available to determine what attributes and actions are available for a given object are described in this reference documentation.  In addition, the module will dynamically add methods for the attributes and actions appropriate to the object, but these will differ between object roles and applications -- again we are limited by what the target application developers provide us.

The dynamically generated methods will follow one of the following templates:
 * `object:*attribute*()`         - this will return the value for the specified attribute (see [hs.axuielement:attributeValue](#attributeValue) for the generic function this is based on).
 * `object:set*attribute*(value)` - this will set the specified attribute to the given value (see [hs.axuielement:setAttributeValue](#setAttributeValue) for the generic function this is based on).
 * `object:do*action*()`          - this request that the specified action is performed by the object (see [hs.axuielement:performAction](#performAction) for the generic function this is based on).

Where *action* and *attribute* can be the formal Accessibility version of the attribute or action name (a string usually prefixed with "AX") or without the "AX" prefix.  When the prefix is left off, the first letter of the action or attribute can be uppercase or lowercase.

The module also dynamically supports treating the axuielementObject useradata as an array, to access it's children (i.e. `#object` will return a number, indicating the number of direct children the object has, and `object[1]` is equivalent to `object:children()[1]` or, more formally, `object:attributeValue("AXChildren")[1]`).

You can also treat the axuielementObject userdata as a table of key-value pairs to generate a list of the dynamically generated functions: `for k, v in pairs(object) do print(k, v) end` (this is essentially what [hs.axuielement:dynamicMethods](#dynamicMethods) does).


Limited support for parameterized attributes is provided, but is not yet complete.  This is expected to see updates in the future.

### Usage
~~~lua
axuielement = require("hs.axuielement")
~~~

### Contents


##### Module Constructors
* <a href="#applicationElement">axuielement.applicationElement(applicationObject) -> axuielementObject</a>
* <a href="#applicationElementForPID">axuielement.applicationElementForPID(pid) -> axuielementObject</a>
* <a href="#systemElementAtPosition">axuielement.systemElementAtPosition(x, y | { x, y }) -> axuielementObject</a>
* <a href="#systemWideElement">axuielement.systemWideElement() -> axuielementObject</a>
* <a href="#windowElement">axuielement.windowElement(windowObject) -> axuielementObject</a>

##### Module Methods
* <a href="#actionDescription">axuielement:actionDescription(action) -> string</a>
* <a href="#actionNames">axuielement:actionNames() -> table</a>
* <a href="#allAttributeValues">axuielement:allAttributeValues([includeErrors]) -> table</a>
* <a href="#asHSApplication">axuielement:asHSApplication() -> hs.application object | nil</a>
* <a href="#asHSWindow">axuielement:asHSWindow() -> hs.window object | nil</a>
* <a href="#attributeNames">axuielement:attributeNames() -> table</a>
* <a href="#attributeValue">axuielement:attributeValue(attribute) -> value</a>
* <a href="#attributeValueCount">axuielement:attributeValueCount(attribute) -> integer</a>
* <a href="#buildTree">axuielement:buildTree(callback, [depth], [withParents]) -> buildTreeObject</a>
* <a href="#copy">axuielement:copy() -> axuielementObject</a>
* <a href="#dynamicMethods">axuielement:dynamicMethods([keyValueTable]) -> table</a>
* <a href="#elementAtPosition">axuielement:elementAtPosition(x, y | { x, y }) -> axuielementObject</a>
* <a href="#isAttributeSettable">axuielement:isAttributeSettable(attribute) -> boolean</a>
* <a href="#isValid">axuielement:isValid() -> boolean</a>
* <a href="#parameterizedAttributeNames">axuielement:parameterizedAttributeNames() -> table</a>
* <a href="#parameterizedAttributeValue">axuielement:parameterizedAttributeValue(attribute, parameter) -> value</a>
* <a href="#path">axuielement:path() -> table</a>
* <a href="#performAction">axuielement:performAction(action) -> axuielement | false | nil</a>
* <a href="#pid">axuielement:pid() -> integer</a>
* <a href="#setAttributeValue">axuielement:setAttributeValue(attribute, value) -> axuielementObject | nil</a>
* <a href="#setTimeout">axuielement:setTimeout(value) -> axuielementObject</a>

##### Module Constants
* <a href="#actions">axuielement.actions[]</a>
* <a href="#attributes">axuielement.attributes[]</a>
* <a href="#directions">axuielement.directions[]</a>
* <a href="#parameterizedAttributes">axuielement.parameterizedAttributes[]</a>
* <a href="#roles">axuielement.roles[]</a>
* <a href="#subroles">axuielement.subroles[]</a>

- - -

### Module Constructors

<a name="applicationElement"></a>
~~~lua
axuielement.applicationElement(applicationObject) -> axuielementObject
~~~
Returns the top-level accessibility object for the application specified by the `hs.application` object.

Parameters:
 * `applicationObject` - the `hs.application` object for the Application.

Returns:
 * an axuielementObject for the application specified

- - -

<a name="applicationElementForPID"></a>
~~~lua
axuielement.applicationElementForPID(pid) -> axuielementObject
~~~
Returns the top-level accessibility object for the application with the specified process ID.

Parameters:
 * `pid` - the process ID of the application.

Returns:
 * an axuielementObject for the application specified, or nil if it cannot be determined

- - -

<a name="systemElementAtPosition"></a>
~~~lua
axuielement.systemElementAtPosition(x, y | { x, y }) -> axuielementObject
~~~
Returns the accessibility object at the specified position in top-left relative screen coordinates.

Parameters:
 * `x`, `y`   - the x and y coordinates of the screen location to test, provided as separate parameters
 * `{ x, y }` - the x and y coordinates of the screen location to test, provided as a point-table, like the one returned by `hs.mouse.getAbsolutePosition`.

Returns:
 * an axuielementObject for the object at the specified coordinates, or nil if no object could be identified.

Notes:
 * See also [hs.axuielement:elementAtPosition](#elementAtPosition) -- this function is a shortcut for `hs.axuielement.systemWideElement():elementAtPosition(...)`.

 * This function does hit-testing based on window z-order (that is, layering). If one window is on top of another window, the returned accessibility object comes from whichever window is topmost at the specified location.

- - -

<a name="systemWideElement"></a>
~~~lua
axuielement.systemWideElement() -> axuielementObject
~~~
Returns an accessibility object that provides access to system attributes.

Parameters:
 * None

Returns:
 * the axuielementObject for the system attributes

- - -

<a name="windowElement"></a>
~~~lua
axuielement.windowElement(windowObject) -> axuielementObject
~~~
Returns the accessibility object for the window specified by the `hs.window` object.

Parameters:
 * `windowObject` - the `hs.window` object for the window.

Returns:
 * an axuielementObject for the window specified

### Module Methods

<a name="actionDescription"></a>
~~~lua
axuielement:actionDescription(action) -> string
~~~
Returns a localized description of the specified accessibility object's action.

Parameters:
 * `action` - the name of the action, as specified by [hs.axuielement:actionNames](#actionNames).

Returns:
 * a string containing a description of the object's action

Notes:
 * The action descriptions are provided by the target application; as such their accuracy and usefulness rely on the target application's developers.

- - -

<a name="actionNames"></a>
~~~lua
axuielement:actionNames() -> table
~~~
Returns a list of all the actions the specified accessibility object can perform.

Parameters:
 * None

Returns:
 * an array of the names of all actions supported by the axuielementObject

Notes:
 * Common action names can be found in the [hs.axuielement.actions](#actions) table; however, this method will list only those names which are supported by this object, and is not limited to just those in the referenced table.

- - -

<a name="allAttributeValues"></a>
~~~lua
axuielement:allAttributeValues([includeErrors]) -> table
~~~
Returns a table containing key-value pairs for all attributes of the accessibility object.

Parameters:
 * `includeErrors` - an optional boolean, default false, that specifies whether attribute names which generate an error when retrieved are included in the returned results.

Returns:
 * a table with key-value pairs corresponding to the attributes of the accessibility object.

- - -

<a name="asHSApplication"></a>
~~~lua
axuielement:asHSApplication() -> hs.application object | nil
~~~
If the element referes to an application, return an `hs.application` object for the element.

Parameters:
 * None

Returns:
 * if the element refers to an application, return an `hs.application` object for the element ; otherwise return nil

Notes:
 * An element is considered an application by this method if it has an AXRole of AXApplication and has a process identifier (pid).

- - -

<a name="asHSWindow"></a>
~~~lua
axuielement:asHSWindow() -> hs.window object | nil
~~~
If the element referes to a window, return an `hs.window` object for the element.

Parameters:
 * None

Returns:
 * if the element refers to a window, return an `hs.window` object for the element ; otherwise return nil

Notes:
 * An element is considered a window by this method if it has an AXRole of AXWindow.

- - -

<a name="attributeNames"></a>
~~~lua
axuielement:attributeNames() -> table
~~~
Returns a list of all the attributes supported by the specified accessibility object.

Parameters:
 * None

Returns:
 * an array of the names of all attributes supported by the axuielementObject

Notes:
 * Common attribute names can be found in the [hs.axuielement.attributes](#attributes) tables; however, this method will list only those names which are supported by this object, and is not limited to just those in the referenced table.

- - -

<a name="attributeValue"></a>
~~~lua
axuielement:attributeValue(attribute) -> value
~~~
Returns the value of an accessibility object's attribute.

Parameters:
 * `attribute` - the name of the attribute, as specified by [hs.axuielement:attributeNames](#attributeNames).

Returns:
 * the current value of the attribute, or nil if the attribute has no value

- - -

<a name="attributeValueCount"></a>
~~~lua
axuielement:attributeValueCount(attribute) -> integer
~~~
Returns the count of the array of an accessibility object's attribute value.

Parameters:
 * `attribute` - the name of the attribute, as specified by [hs.axuielement:attributeNames](#attributeNames).

Returns:
 * the number of items in the value for the attribute, if it is an array, or nil if the value is not an array.

- - -

<a name="buildTree"></a>
~~~lua
axuielement:buildTree(callback, [depth], [withParents]) -> buildTreeObject
~~~
Captures all of the available information for the accessibility object and its children and returns it in a table for inspection.

Parameters:
 * `callback` - a required function which should expect two arguments: a `msg` string specifying how the search ended, and a table contiaining the recorded information. `msg` will be "completed" when the search has completed normally (or reached the specified depth) and will contain a string starting with "**" if it terminates early for some reason (see Returns: section)
 * `depth`    - an optional integer, default `math.huge`, specifying the maximum depth from the intial accessibility object that should be visited to identify child elements and their attributes.
 * `withParents` - an optional boolean, default false, specifying whether or not an element's (or child's) attributes for `AXParent` and `AXTopLevelUIElement` should also be visited when identifying additional elements to include in the results table.

Returns:
 * a `buildTreeObject` which contains metamethods allowing you to check to see if the build process has completed and cancel it early if desired:
   * `buildTreeObject:isRunning()` - will return true if the traversal is still ongoing, or false if it has completed or been cancelled
   * `buildTreeObject:cancel()`    - will cancel the currently running search and invoke the callback with the partial results already collected. The `msg` parameter for the calback will be "** cancelled".

Notes:
 * this method utilizes coroutines to keep Hammerspoon responsive, but can be slow to complete if you do not specifiy a depth or start from an element that has a lot of children or has children with many elements (e.g. the application element for a web browser).

 * The results of this method are not generally intended to be used in production programs; it is organized more for exploratory purposes when trying to understand how elements are related within a given application or to determine what elements might be worth targetting with more specific queries.

- - -

<a name="copy"></a>
~~~lua
axuielement:copy() -> axuielementObject
~~~
Return a duplicate userdata reference to the Accessibility object.

Parameters:
 * None

Returns:
 * a new userdata object representing a new reference to the Accessibility object.

- - -

<a name="dynamicMethods"></a>
~~~lua
axuielement:dynamicMethods([keyValueTable]) -> table
~~~
Returns a list of the dynamic methods (short cuts) created by this module for the object

Parameters:
 * `keyValueTable` - an optional boolean, default false, indicating whether or not the result should be an array or a table of key-value pairs.

Returns:
 * If `keyValueTable` is true, this method returns a table of key-value pairs with each key being the name of a dynamically generated method, and the value being the corresponding function.  Otherwise, this method returns an array of the dynamically generated method names.

Notes:
 * the dynamically generated methods are described more fully in the reference documentation header, but basically provide shortcuts for getting and setting attribute values as well as perform actions supported by the Accessibility object the axuielementObject represents.

- - -

<a name="elementAtPosition"></a>
~~~lua
axuielement:elementAtPosition(x, y | { x, y }) -> axuielementObject
~~~
Returns the accessibility object at the specified position in top-left relative screen coordinates.

Parameters:
 * `x`, `y`   - the x and y coordinates of the screen location to test, provided as separate parameters
 * `{ x, y }` - the x and y coordinates of the screen location to test, provided as a point-table, like the one returned by `hs.mouse.getAbsolutePosition`.

Returns:
 * an axuielementObject for the object at the specified coordinates, or nil if no object could be identified.

Notes:
 * This method can only be called on an axuielementObject that represents an application or the system-wide element (see [hs.axuielement.systemWideElement](#systemWideElement)).

 * This function does hit-testing based on window z-order (that is, layering). If one window is on top of another window, the returned accessibility object comes from whichever window is topmost at the specified location.
 * If this method is called on an axuielementObject representing an application, the search is restricted to the application.
 * If this method is called on an axuielementObject representing the system-wide element, the search is not restricted to any particular application.  See [hs.axuielement.systemElementAtPosition](#systemElementAtPosition).

- - -

<a name="isAttributeSettable"></a>
~~~lua
axuielement:isAttributeSettable(attribute) -> boolean
~~~
Returns whether the specified accessibility object's attribute can be modified.

Parameters:
 * `attribute` - the name of the attribute, as specified by [hs.axuielement:attributeNames](#attributeNames).

Returns:
 * a boolean value indicating whether or not the value of the parameter can be modified.

- - -

<a name="isValid"></a>
~~~lua
axuielement:isValid() -> boolean
~~~
Returns whether the specified accessibility object is still valid.

Parameters:
 * None

Returns:
 * a boolean value indicating whether or not the accessibility object is still valid.

- - -

<a name="parameterizedAttributeNames"></a>
~~~lua
axuielement:parameterizedAttributeNames() -> table
~~~
Returns a list of all the parameterized attributes supported by the specified accessibility object.

Parameters:
 * None

Returns:
 * an array of the names of all parameterized attributes supported by the axuielementObject

- - -

<a name="parameterizedAttributeValue"></a>
~~~lua
axuielement:parameterizedAttributeValue(attribute, parameter) -> value
~~~
Returns the value of an accessibility object's parameterized attribute.

Parameters:
 * `attribute` - the name of the attribute, as specified by [hs.axuielement:parameterizedAttributeNames](#parameterizedAttributeNames).
 * `parameter` - the parameter

Returns:
 * the current value of the parameterized attribute, or nil if it has no value

Notes:
 * Parameterized attribute support is still considered experimental and not fully supported yet.  Use with caution.

- - -

<a name="path"></a>
~~~lua
axuielement:path() -> table
~~~
Returns a table of axuielements tracing this object through its parent objects to the root for this element, most likely an application object or the system wide object.

Parameters:
 * None

Returns:
 * a table containing this object and 0 or more parent objects representing the path from the root object to this element.

Notes:
 * this object will always exist as the last element in the table (e.g. at `table[#table]`) with its most imemdiate parent at `#table - 1`, etc. until the rootmost object for this element is reached at index position 1.

 * an axuielement object representing an application or the system wide object is its own rootmost object and will return a table containing only itself (i.e. `#table` will equal 1)

- - -

<a name="performAction"></a>
~~~lua
axuielement:performAction(action) -> axuielement | false | nil
~~~
Requests that the specified accessibility object perform the specified action.

Parameters:
 * `action` - the name of the action, as specified by [hs.axuielement:actionNames](#actionNames).

Returns:
 * if the requested action was accepted by the target, returns the axuielementObject; if the requested action was rejected, returns false, otherwise returns nil on error.

Notes:
 * The return value only suggests success or failure, but is not a guarantee.  The receiving application may have internal logic which prevents the action from occurring at this time for some reason, even though this method returns success (the axuielementObject).  Contrawise, the requested action may trigger a requirement for a response from the user and thus appear to time out, causing this method to return false or nil.

- - -

<a name="pid"></a>
~~~lua
axuielement:pid() -> integer
~~~
Returns the process ID associated with the specified accessibility object.

Parameters:
 * None

Returns:
 * the process ID for the application to which the accessibility object ultimately belongs.

- - -

<a name="setAttributeValue"></a>
~~~lua
axuielement:setAttributeValue(attribute, value) -> axuielementObject | nil
~~~
Sets the accessibility object's attribute to the specified value.

Parameters:
 * `attribute` - the name of the attribute, as specified by [hs.axuielement:attributeNames](#attributeNames).
 * `value`     - the value to assign to the attribute

Returns:
 * the axuielementObject on success; nil if the attribute could not be set.

Notes:
 * This is still somewhat experimental and needs more testing; use with caution.

- - -

<a name="setTimeout"></a>
~~~lua
axuielement:setTimeout(value) -> axuielementObject
~~~
Sets the timeout value used accessibility queries performed from this element.

Parameters:
 * `value` - the number of seconds for the new timeout value.

Returns:
 * the axuielementObject

Notes:
 * To change the global timeout affecting all queries on elements which do not have a specific timeout set, use this method on the systemwide element (see [hs.axuielement.systemWideElement](#systemWideElement).
 * Changing the timeout value for an axuielement object only changes the value for that specific element -- other axuieleement objects that may refere to the identical accessibiity item are not affected.

 * Setting the value to 0.0 resets the timeout -- if applied to the `systemWideElement`, the global default will be reset to its default value; if applied to another axuielement object, the timeout will be reset to the current global value as applied to the systemWideElement.

### Module Constants

<a name="actions"></a>
~~~lua
axuielement.actions[]
~~~
A table of common accessibility object action names, provided for reference.

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.

- - -

<a name="attributes"></a>
~~~lua
axuielement.attributes[]
~~~
A table of common accessibility object attribute names, provided for reference. The names are grouped into the following subcategories (keys):

 * `application`
 * `dock`
 * `general`
 * `matte`
 * `menu`
 * `misc`
 * `system`
 * `table`
 * `text`
 * `window`

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.
 * the category name indicates the type of accessibility object likely to contain the member elements.

- - -

<a name="directions"></a>
~~~lua
axuielement.directions[]
~~~
A table of common directions which may be specified as the value of an accessibility object property, provided for reference.

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.

- - -

<a name="parameterizedAttributes"></a>
~~~lua
axuielement.parameterizedAttributes[]
~~~
A table of common accessibility object parameterized attribute names, provided for reference.

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.

- - -

<a name="roles"></a>
~~~lua
axuielement.roles[]
~~~
A table of common accessibility object roles, provided for reference.

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.

- - -

<a name="subroles"></a>
~~~lua
axuielement.subroles[]
~~~
A table of common accessibility object subroles, provided for reference.

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.

- - -

### License

>     The MIT License (MIT)
>
> Copyright (c) 2020 Aaron Magill
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
>

