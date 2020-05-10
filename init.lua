--- === hs._asm.axuielement ===
---
--- This module allows you to access the accessibility objects of running applications, their windows, menus, and other user interface elements that support the OS X accessibility API.
---
--- This is very much a work in progress, so bugs and comments are welcome.
---
--- This module works through the use of axuielementObjects, which is the Hammerspoon representation for an accessibility object.  An accessibility object represents any object or component of an OS X application which can be manipulated through the OS X Accessibility API -- it can be an application, a window, a button, selected text, etc.  As such, it can only support those features and objects within an application that the application developers make available through the Accessibility API.
---
--- The basic methods available to determine what attributes and actions are available for a given object are described in this reference documentation.  In addition, the module will dynamically add methods for the attributes and actions appropriate to the object, but these will differ between object roles and applications -- again we are limited by what the target application developers provide us.
---
--- The dynamically generated methods will follow one of the following templates:
---  * `object:*attribute*()`         - this will return the value for the specified attribute (see [hs._asm.axuielement:attributeValue](#attributeValue) for the generic function this is based on).
---  * `object:set*attribute*(value)` - this will set the specified attribute to the given value (see [hs._asm.axuielement:setAttributeValue](#setAttributeValue) for the generic function this is based on).
---  * `object:do*action*()`          - this request that the specified action is performed by the object (see [hs._asm.axuielement:performAction](#performAction) for the generic function this is based on).
---
--- Where *action* and *attribute* can be the formal Accessibility version of the attribute or action name (a string usually prefixed with "AX") or without the "AX" prefix.  When the prefix is left off, the first letter of the action or attribute can be uppercase or lowercase.
---
--- The module also dynamically supports treating the axuielementObject useradata as an array, to access it's children (i.e. `#object` will return a number, indicating the number of direct children the object has, and `object[1]` is equivalent to `object:children()[1]` or, more formally, `object:attributeValue("AXChildren")[1]`).
---
--- You can also treat the axuielementObject userdata as a table of key-value pairs to generate a list of the dynamically generated functions: `for k, v in pairs(object) do print(k, v) end` (this is essentially what [hs._asm.axuielement:dynamicMethods](#dynamicMethods) does).
---
---
--- Limited support for parameterized attributes is provided, but is not yet complete.  This is expected to see updates in the future.

local USERDATA_TAG = "hs._asm.axuielement"

if not hs.accessibilityState(true) then
    hs.luaSkinLog.ef("%s - module requires accessibility to be enabled; fix in SystemPreferences -> Privacy & Security and restart Hammerspoon", USERDATA_TAG)
    return nil
end

local module       = require(USERDATA_TAG..".internal")

local basePath = package.searchpath(USERDATA_TAG, package.path)
if basePath then
    basePath = basePath:match("^(.+)/init.lua$")
    if require"hs.fs".attributes(basePath .. "/docs.json") then
        require"hs.doc".registerJSONFile(basePath .. "/docs.json")
    end
end

local log  = require("hs.logger").new(USERDATA_TAG, require"hs.settings".get(USERDATA_TAG .. ".logLevel") or "warning")
module.log = log

local fnutils = require("hs.fnutils")
local inspect = require("hs.inspect")

require("hs.styledtext")

local objectMT = hs.getObjectMetatable(USERDATA_TAG)

local parentLabels = { module.attributes.general.parent, module.attributes.general.topLevelUIElement }

-- private variables and methods -----------------------------------------

-- Public interface ------------------------------------------------------

module.roles                   = ls.makeConstantsTable(module.roles)
module.subroles                = ls.makeConstantsTable(module.subroles)
module.parameterizedAttributes = ls.makeConstantsTable(module.parameterizedAttributes)
module.actions                 = ls.makeConstantsTable(module.actions)
module.attributes              = ls.makeConstantsTable(module.attributes)
module.directions              = ls.makeConstantsTable(module.directions)

module.observer.notifications  = ls.makeConstantsTable(module.observer.notifications)

--- hs._asm.axuielement.systemElementAtPosition(x, y | { x, y }) -> axuielementObject
--- Constructor
--- Returns the accessibility object at the specified position in top-left relative screen coordinates.
---
--- Parameters:
---  * `x`, `y`   - the x and y coordinates of the screen location to test, provided as separate parameters
---  * `{ x, y }` - the x and y coordinates of the screen location to test, provided as a point-table, like the one returned by `hs.mouse.getAbsolutePosition`.
---
--- Returns:
---  * an axuielementObject for the object at the specified coordinates, or nil if no object could be identified.
---
--- Notes:
---  * See also [hs._asm.axuielement:elementAtPosition](#elementAtPosition) -- this function is a shortcut for `hs._asm.axuielement.systemWideElement():elementAtPosition(...)`.
---
---  * This function does hit-testing based on window z-order (that is, layering). If one window is on top of another window, the returned accessibility object comes from whichever window is topmost at the specified location.
module.systemElementAtPosition = function(...)
    return module.systemWideElement():elementAtPosition(...)
end

-- build up the "correct" object metatable methods

objectMT.__index = function(self, _)
    if type(_) == "string" then
        -- take care of the internally defined items first so we can get out of here quickly if its one of them
        if objectMT[_] then return objectMT[_] end

        -- Now for the dynamically generated methods...

        local matchName = _:match("^set(.+)$")
        if not matchName then matchName = _:match("^do(.+)$") end
        if not matchName then matchName = _:match("^(.+)WithParameter$") end
        if not matchName then matchName = _ end
        local formalName = matchName:match("^AX[%w%d_]+$") and matchName or "AX"..matchName:sub(1,1):upper()..matchName:sub(2)

        -- check for setters
        if _:match("^set%u") then

             -- check attributes
             for i, v in ipairs(objectMT.attributeNames(self) or {}) do
                if v == formalName and objectMT.isAttributeSettable(self, formalName) then
                    return function(self, ...) return objectMT.setAttributeValue(self, formalName, ...) end
                end
            end

        -- check for doers
        elseif _:match("^do%u") then

            -- check actions
            for i, v in ipairs(objectMT.actionNames(self) or {}) do
                if v == formalName then
                    return function(self, ...) return objectMT.performAction(self, formalName, ...) end
                end
            end

        -- getter or bust
        else

            -- check attributes
            for i, v in ipairs(objectMT.attributeNames(self) or {}) do
                if v == formalName then
                    return function(self, ...) return objectMT.attributeValue(self, formalName, ...) end
                end
            end

            -- check paramaterizedAttributes
            for i, v in ipairs(objectMT.parameterizedAttributeNames(self) or {}) do
                if v == formalName then
                    return function(self, ...) return objectMT.parameterizedAttributeValue(self, formalName, ...) end
                end
            end
        end

        -- guess it doesn't exist
        return nil
    elseif type(_) == "number" then
        local children = objectMT.attributeValue(self, "AXChildren")
        if children then
            return children[_]
        else
            return nil
        end
    else
        return nil
    end
end

objectMT.__call = function(_, cmd, ...)
    local fn = objectMT.__index(_, cmd)
    if fn and type(fn) == "function" then
        return fn(_, ...)
    elseif fn then
        return fn
    elseif cmd:match("^do%u") then
        error(tostring(cmd) .. " is not a recognized action", 2)
    elseif cmd:match("^set%u") then
        error(tostring(cmd) .. " is not a recognized attribute", 2)
    else
        return nil
    end
end

objectMT.__pairs = function(_)
    local keys = {}

     -- getters and setters for attributeNames
    for i, v in ipairs(objectMT.attributeNames(_) or {}) do
        local partialName = v:match("^AX(.*)")
        keys[partialName:sub(1,1):lower() .. partialName:sub(2)] = true
        if objectMT.isAttributeSettable(_, v) then
            keys["set" .. partialName] = true
        end
    end

    -- getters for paramaterizedAttributes
    for i, v in ipairs(objectMT.parameterizedAttributeNames(_) or {}) do
        local partialName = v:match("^AX(.*)")
        keys[partialName:sub(1,1):lower() .. partialName:sub(2) .. "WithParameter"] = true
    end

    -- doers for actionNames
    for i, v in ipairs(objectMT.actionNames(_) or {}) do
        local partialName = v:match("^AX(.*)")
        keys["do" .. partialName] = true
    end

    return function(_, k)
            local v
            k, v = next(keys, k)
            if k then v = _[k] end
            return k, v
        end, _, nil
end

objectMT.__len = function(self)
    local children = objectMT.attributeValue(self, "AXChildren")
    if children then
        return #children
    else
        return 0
    end
end

--- hs._asm.axuielement:dynamicMethods([keyValueTable]) -> table
--- Method
--- Returns a list of the dynamic methods (short cuts) created by this module for the object
---
--- Parameters:
---  * `keyValueTable` - an optional boolean, default false, indicating whether or not the result should be an array or a table of key-value pairs.
---
--- Returns:
---  * If `keyValueTable` is true, this method returns a table of key-value pairs with each key being the name of a dynamically generated method, and the value being the corresponding function.  Otherwise, this method returns an array of the dynamically generated method names.
---
--- Notes:
---  * the dynamically generated methods are described more fully in the reference documentation header, but basically provide shortcuts for getting and setting attribute values as well as perform actions supported by the Accessibility object the axuielementObject represents.
objectMT.dynamicMethods = function(self, asKV)
    local results = {}
    for k, v in pairs(self) do
        if asKV then
            results[k] = v
        else
            table.insert(results, k)
        end
    end
    if not asKV then table.sort(results) end
    return ls.makeConstantsTable(results)
end

--- hs._asm.axuielement:path() -> table
--- Method
--- Returns a table of axuielements tracing this object through its parent objects to the root for this element, most likely an application object or the system wide object.
---
--- Parameters:
---  * None
---
--- Returns:
---  * a table containing this object and 0 or more parent objects representing the path from the root object to this element.
---
--- Notes:
---  * this object will always exist as the last element in the table (e.g. at `table[#table]`) with its most imemdiate parent at `#table - 1`, etc. until the rootmost object for this element is reached at index position 1.
---
---  * an axuielement object representing an application or the system wide object is its own rootmost object and will return a table containing only itself (i.e. `#table` will equal 1)
objectMT.path = function(self)
    local results, current = { self }, self
    while current:attributeValue("AXParent") do
        current = current("parent")
        table.insert(results, 1, current)
    end
    return results
end

-- Return Module Object --------------------------------------------------

if module.types then module.types = ls.makeConstantsTable(module.types) end
return module
