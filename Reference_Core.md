hs.axuielement
===================

This module allows you to access the accessibility objects of running applications, their windows, menus, and other user interface elements that support the OS X accessibility API.

This module works through the use of axuielementObjects, which is the Hammerspoon representation for an accessibility object.  An accessibility object represents any object or component of an OS X application which can be manipulated through the OS X Accessibility API -- it can be an application, a window, a button, selected text, etc.  As such, it can only support those features and objects within an application that the application developers make available through the Accessibility API.

The basic methods available to determine what attributes and actions are available for a given object are described in this reference documentation.  In addition, the module will dynamically add methods for the attributes and actions appropriate to the object, but these will differ between object roles and applications -- again we are limited by what the target application developers provide us.

The dynamically generated methods will follow one of the following templates:
 * `object:<attribute>()`            - this will return the value for the specified attribute (see [hs.axuielement:attributeValue](#attributeValue) for the generic function this is based on). If the element does not have this specific attribute, an error will be generated.
 * `object("<attribute>")`           - this will return the value for the specified attribute. Returns nil if the element does not have this specific attribute instead of generating an error.
 * `object:set<attribute>(value)`    - this will set the specified attribute to the given value (see [hs.axuielement:setAttributeValue](#setAttributeValue) for the generic function this is based on). If the element does not have this specific attribute or if it is not settable, an error will be generated.
 * `object("set<attribute>", value)` - this will set the specified attribute to the given value. If the element does not have this specific attribute or if it is not settable, an error will be generated.
 * `object:do<action>()`             - this request that the specified action is performed by the object (see [hs.axuielement:performAction](#performAction) for the generic function this is based on). If the element does not respond to this action, an error will be generated.
 * `object("do<action>")`            - this request that the specified action is performed by the object. If the element does not respond to this action, an error will be generated.

Where `<action>` and `<attribute>` can be the formal Accessibility version of the attribute or action name (a string usually prefixed with "AX") or without the "AX" prefix.  When the prefix is left off, the first letter of the action or attribute can be uppercase or lowercase.

The module also dynamically supports treating the axuielementObject useradata as an array, to access it's children (i.e. `#object` will return a number, indicating the number of direct children the object has, and `object[1]` is equivalent to `object:children()[1]` or, more formally, `object:attributeValue("AXChildren")[1]`).

You can also treat the axuielementObject userdata as a table of key-value pairs to generate a list of the dynamically generated functions: `for k, v in pairs(object) do print(k, v) end` (this is essentially what [hs.axuielement:dynamicMethods](#dynamicMethods) does).

### Usage
~~~lua
axuielement = require("hs.axuielement")
~~~

### Contents


##### Module Constructors
* <a href="#applicationElement">axuielement.applicationElement(applicationObject) -> axuielementObject</a>
* <a href="#applicationElementForPID">axuielement.applicationElementForPID(pid) -> axuielementObject</a>
* <a href="#systemElementAtPosition">axuielement.systemElementAtPosition(x, y | pointTable) -> axuielementObject</a>
* <a href="#systemWideElement">axuielement.systemWideElement() -> axuielementObject</a>
* <a href="#windowElement">axuielement.windowElement(windowObject) -> axuielementObject</a>

##### Module Methods
* <a href="#actionDescription">axuielement:actionDescription(action) -> string</a>
* <a href="#actionNames">axuielement:actionNames() -> table</a>
* <a href="#allAttributeValues">axuielement:allAttributeValues([includeErrors]) -> table</a>
* <a href="#allChildElements">axuielement:allChildElements(callback, [withParents]) -> childElementsObject</a>
* <a href="#asHSApplication">axuielement:asHSApplication() -> hs.application object | nil</a>
* <a href="#asHSWindow">axuielement:asHSWindow() -> hs.window object | nil</a>
* <a href="#attributeNames">axuielement:attributeNames() -> table</a>
* <a href="#attributeValue">axuielement:attributeValue(attribute) -> value</a>
* <a href="#attributeValueCount">axuielement:attributeValueCount(attribute) -> integer</a>
* <a href="#buildTree">axuielement:buildTree(callback, [depth], [withParents]) -> buildTreeObject</a>
* <a href="#copy">axuielement:copy() -> axuielementObject</a>
* <a href="#dynamicMethods">axuielement:dynamicMethods([keyValueTable]) -> table</a>
* <a href="#elementAtPosition">axuielement:elementAtPosition(x, y | pointTable) -> axuielementObject</a>
* <a href="#elementSearch">axuielement:elementSearch(callback, [criteria], [namedModifiers]) -> elementSearchObject</a>
* <a href="#isAttributeSettable">axuielement:isAttributeSettable(attribute) -> boolean</a>
* <a href="#isValid">axuielement:isValid() -> boolean</a>
* <a href="#matchesCriteria">axuielement:matchesCriteria(criteria, [isPattern]) -> boolean</a>
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
Returns the accessibility object at the specified position on the screen. The top-left corner of the primary screen is 0, 0.

Parameters:
 * `x`, `y`     - the x and y coordinates of the screen location to test, provided as separate parameters
 * `pointTable` - the x and y coordinates of the screen location to test, provided as a point-table, like the one returned by `hs.mouse.getAbsolutePosition`. A point-table is a table with key-value pairs for keys `x` and `y`.

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

<a name="allChildElements"></a>
~~~lua
axuielement:allChildElements(callback, [withParents]) -> elementSearchObject
~~~
Query the accessibility object for all child accessibility objects (and their children...).

Paramters:
 * `callback`    - a required function which should expect two arguments: a `msg` string specifying how the search ended, and a table containing the discovered child elements. `msg` will be "completed" when the traversal has completed normally and will contain a string starting with "**" if it terminates early for some reason (see Notes: section for more information)
 * `withParents` - an optional boolean, default false, indicating that the parent of objects (and their children) should be collected as well.

Returns:
 * an elementSearchObject as described in [hs.axuielement:elementSearch](#elementSearch)

Notes:
 * This method is syntactic sugar for `hs.axuielement:elementSearch(callback, { [includeParents = withParents] })`. Please refer to [hs.axuielement:elementSearch](#elementSearch) for details about the returned object and callback arguments.

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
axuielement:buildTree(callback, [depth], [withParents]) -> elementSearchObject
~~~
Captures all of the available information for the accessibility object and its children and returns it in a table for inspection.

Parameters:
 * `callback` - a required function which should expect two arguments: a `msg` string specifying how the search ended, and a table containing the recorded information. `msg` will be "completed" when the search has completed normally (or reached the specified depth) and will contain a string starting with "**" if it terminates early for some reason (see Notes: section for more information)
 * `depth`    - an optional integer, default `math.huge`, specifying the maximum depth from the initial accessibility object that should be visited to identify child elements and their attributes.
 * `withParents` - an optional boolean, default false, specifying whether or not an element's (or child's) attributes for `AXParent` and `AXTopLevelUIElement` should also be visited when identifying additional elements to include in the results table.

Returns:
 * an elementSearchObject as described in [hs.axuielement:elementSearch](#elementSearch)

Notes:
 * The format of the `results` table passed to the callback for this method is primarily for debugging and exploratory purposes and may not be arranged for easy programatic evaluation.

 * This method is syntactic sugar for `hs.axuielement:elementSearch(callback, { objectOnly = false, asTree = true, [maxDepth = depth], [includeParents = withParents] })`. Please refer to [hs.axuielement:elementSearch](#elementSearch) for details about the returned object and callback arguments.

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
 * `keyValueTable` - an optional boolean, default false, indicating whether or not the result should be an array (false) or a table of key-value pairs (true).

Returns:
 * If `keyValueTable` is true, this method returns a table of key-value pairs with each key being the name of a dynamically generated method, and the value being the corresponding function.  Otherwise, this method returns an array of the dynamically generated method names.

Notes:
 * the dynamically generated methods are described more fully in the reference documentation header, but basically provide shortcuts for getting and setting attribute values as well as perform actions supported by the Accessibility object the axuielementObject represents.

- - -

<a name="elementAtPosition"></a>
~~~lua
axuielement:elementAtPosition(x, y | { x, y }) -> axuielementObject
~~~
Returns the accessibility object at the specified position on the screen. The top-left corner of the primary screen is 0, 0.

Parameters:
 * `x`, `y`     - the x and y coordinates of the screen location to test, provided as separate parameters
 * `pointTable` - the x and y coordinates of the screen location to test, provided as a point-table, like the one returned by `hs.mouse.getAbsolutePosition`. A point-table is a table with key-value pairs for keys `x` and `y`.

Returns:
 * an axuielementObject for the object at the specified coordinates, or nil if no object could be identified.

Notes:
 * This method can only be called on an axuielementObject that represents an application or the system-wide element (see [hs.axuielement.systemWideElement](#systemWideElement)).

 * This function does hit-testing based on window z-order (that is, layering). If one window is on top of another window, the returned accessibility object comes from whichever window is topmost at the specified location.
 * If this method is called on an axuielementObject representing an application, the search is restricted to the application.
 * If this method is called on an axuielementObject representing the system-wide element, the search is not restricted to any particular application.  See [hs.axuielement.systemElementAtPosition](#systemElementAtPosition).

- - -

<a name="elementSearch"></a>
~~~lua
axuielement:elementSearch(callback, [criteria], [namedModifiers]) -> elementSearchObject
~~~
Search for and generate a table of the accessibility elements for the attributes and children of this object based on the specified criteria.

Parameters:
 * `callback`       - a required function which will receive the results of this search. The callback should expect two arguments and return none. The arguments to the callback function will be `msg`, a string specifying how the search ended and `results`, a table containing the requested results. `msg` will be "completed" if the search completes normally, or a string starting with "**" if it is terminated early (see Returns: and Notes: for more details).
 * `criteria`       - an optional table or string which will be passed to [hs.axuielement:matchesCriteria](#matchesCriteria) to determine if the discovered element should be included in the final result set. This criteria does not prune the search, it just determines if the element will be included in the results.
 * `namedModifiers` - an optional table specifying key-value pairs that further modify or control the search. This table may contain 0 or more of the following keys:
   * `isPattern`      - a boolean, default false, specifying whether or not all string values in `criteria` should be evaluated as patterns (true) or as literal strings to be matched (false). This value is passed to [hs.axuielement:matchesCriteria](#matchesCriteria) when `criteria` is specified and has no effect otherwise.
   * `includeParents` - a boolean, default false, specifying whether or not parent attributes (`AXParent` and `AXTopLevelUIElement`) should be examined during the search. Note that in most cases, setting this value to true will end up traversing the entire Accessibility structure for the target application and may significantly slow down the search.
   * `maxDepth`       - an optional integer, default `math.huge`, specifying the maximum number of steps from the initial accessibility element the search should visit. If you know that your desired element(s) are relatively close to your starting element, setting this to a lower value can significantly speed up the search.
   * `objectOnly`     - an optional boolean, default true, specifying whether each result in the final table will be the accessibility element discovered (true) or a table containing details about the element include the attribute names, actions, etc. for the element (false). This latter format is primarily for debugging and exploratory purposes and may not be arranged for easy programatic evaluation.
   * `asTree`         - an optional boolean, default false, and is ignored if `criteria` is specified and non-empty or `objectOnly` is true. This modifier specifies whether the search results should return as an array table of tables containing each element's details (false) or as a tree where in which the root node details are the key-value pairs of the returned table and child elements are likewise described in subtables attached to the attribute name they belong to (true). This format is primarily for debugging and exploratory purposes and may not be arranged for easy programatic evaluation.
   * `noCallback`     - an optional boolean, default false, allowing you to specify nil as the callback when set to true. This feature requires setting this named argumennt to true and specifying the callback field as nil because starting a query from an element with a lot of descendants **WILL** block Hammerspoon and slow down the responsiveness of your computer (I've seen blocking for over 5 minutes in extreme cases) and should be used *only* when you know you are starting from close to the end of the element heirarchy. When this is true, this method returns just the results table. Ignored if `callback` is not also nil.

Returns:
 * an elementSearchObject which contains metamethods allowing you to check to see if the process has completed and cancel it early if desired. The methods include:
   * `elementSearchObject:cancel([reason])` - cancels the current search and invokes the callback with the partial results already collected. If you specify `reason`, the `msg` parameter for the callback will be `** <reason>`; otherwise it will be "** cancelled".
   * `elementSearchObject:isRunning()`      - returns true if the search is still ongoing or false if it has completed or been cancelled
   * `elementSearchObject:matched()`        - returns an integer specifying the number of elements which have already been found that meet the specified criteria.
   * `elementSearchObject:visited()`        - returns an integer specifying the number of elements which have been examined during the search so far.
   * `elementSearchObject:runTime()`        - returns an integer specifying the number of seconds since this search was started. Note that this is *not* an accurate measure of how much time has been spent *specifically* in the search because it will be greatly affected by how much other activity is occurring within Hammerspoon and on the users computer. Once the callback has been invoked, this will return the total time in seconds between when the search began and when it completed.

Notes:
 * This method utilizes coroutines to keep Hammerspoon responsive, but may be slow to complete if `includeParents` is true, if you do not specify `maxDepth`, or if you start from an element that has a lot of children or has children with many elements (e.g. the application element for a web browser). This is dependent entirely upon how many active accessibility elements the target application defines and where you begin your search and cannot reliably be determined up front, so you may need to experiment to find the best balance for your specific requirements.

* The search performed is a breadth-first search, so in general earlier elements in the results table will be "closer" in the Accessibility hierarchy to the starting point than later elements.

* If `asTree` is false, the `results` table will be generated with metamethods allowing you to further filter the results by applying additional criteria. The following method is defined:
  * `results:filter([criteria], [isPattern], [callback]) -> table`
    * `criteria`  - an optional table or string which will be passed to [hs.axuielement:matchesCriteria](#matchesCriteria) to determine if the element should be included in the filtered result set.
    * `isPattern` - an optional boolean, default false, specifying whether strings in the specified criteria should be treated as patterns (see [hs.axuielement:matchesCriteria](#matchesCriteria))
    * `callback`  - an optional callback which should expect two arguments and return none. The arguments will be a message indicating how the filter terminated and the filtered results table. If this field is specified, the `filter` method will return a filterObject with the same metamethods as the `elementSearchObject` described above.

  * By default, the filter method returns the filtered results table with the same metatable attached (fort further filtering). However, if your table is exceptionally large (for example if you used [hs.axuielement:allChildElements](#allChildElements) on an application like Safari), it may be better to use a callback here as well to keep Hammerspoon responsive.

* [hs.axuielement:allChildElements](#allChildElements) is syntactic sugar for `hs.axuielement:elementSearch(callback, { [includeParents = withParents] })`
* [hs.axuielement:buildTree](#buildTree) is syntactic sugar for `hs.axuielement:elementSearch(callback, { objectOnly = false, asTree = true, [maxDepth = depth], [includeParents = withParents] })`

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

Notes:
 * an accessibilityObject can become invalid for a variety of reasons, including but not limited to the element referred to no longer being available (e.g. an element referring to a window or one of its children that has been closed) or the application terminating.

- - -

<a name="matchesCriteria"></a>
~~~lua
axuielement:matchesCriteria(criteria, [isPattern]) -> boolean
~~~
Returns true if the axuielementObject matches the specified criteria or false if it does not.

Paramters:
 * `criteria`  - the criteria to compare against the accessibility object
 * `isPattern` - an optional boolean, default false, specifying whether or not the strings in the search criteria should be considered as Lua patterns (true) or as absolute string matches (false).

Returns:
 * true if the axuielementObject matches the criteria, false if it does not.

Notes:
 * if `isPattern` is specified and is true, all string comparisons are done with `string.match`.  See the Lua manual, section 6.4.1 (`help.lua._man._6_4_1` in the Hammerspoon console).
 * the `criteria` parameter must be one of the following:
   * a single string, specifying the AXRole value the axuielementObject's AXRole attribute must equal for the match to return true
   * an array of strings, specifying a list of AXRoles for which the match should return true
   * a table of key-value pairs specifying a more complex match criteria.  This table will be evaluated as follows:
     * each key-value pair is treated as a separate test and the object *must* match as true for all tests
     * each key is a string specifying an attribute to evaluate.  This attribute may be specified with its formal name (e.g. "AXRole") or the informal version (e.g. "role" or "Role").
     * each value may be a string, a number, a boolean, or an axuielementObject userdata object, or an array (table) of such.  If the value is an array, then the test will match as true if the object matches any of the supplied values for the attribute specified by the key.
       * Put another way: key-value pairs are "and'ed" together while the values for a specific key-value pair are "or'ed" together.

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
 * Changing the timeout value for an axuielement object only changes the value for that specific element -- other axuieleement objects that may refer to the identical accessibiity item are not affected.

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
 * `attributedStrings`
 * `cell`
 * `dock`
 * `general`
 * `grid`
 * `layout`
 * `level`
 * `matte`
 * `menu`
 * `misc`
 * `obsolete`
 * `outline`
 * `ruler`
 * `searchField`
 * `system`
 * `table`
 * `text`
 * `window`

Notes:
 * this table is provided for reference only and is not intended to be comprehensive.
 * the category name suggests the type of accessibility object likely to contain the member elements.

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

