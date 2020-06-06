--
-- Uses hs.chooser to browse an objects attributes and children
--
-- Example use:
--
--      -- Copy this file into your Hammerspoon config dir, usually ~/.hammerspoon. Then:
--      axbrowse = require("axbrowse")
--      axbrowse.browse(hs.axuielement.applicationElement(hs.application("Safari")))
--
-- When you select an end node, or escape out, you can return to the last place you were
-- at with `axbrowse.browse()`
--
-- axbrowse.browse(nil) will browse the frontmost application as determined by
-- `hs.axuielement.systemWideElement()("AXFocusedApplication")` -- which will be
-- Hammerspoon if you're doing this from the console.
--
--      -- add the following to your `init.lua` file to make a hotkey to pull up the
--      -- browser in the frontmost application:
--      local axbrowse = require("axbrowse")
--      local lastApp
--      hs.hotkey.bind({"cmd", "alt", "ctrl"}, "b", function()
--          local currentApp = hs.axuielement.systemWideElement()("AXFocusedApplication")
--          if currentApp == lastApp then
--              axbrowse.browse() -- try to continue from where we left off
--          else
--              lastApp = currentApp
--              axbrowse.browse(nil) -- new app, so start over
--          end
--      end)
--
-- As you select elements in the chooser window, a line will be printed to the console
-- which shows the path to the end node or action you finally select. These lines can
-- be copied into your own scripts and only the initial text "object" needs to be
-- replaced with the actual element you started browsing from.
--

local ax       = require("hs.axuielement")
local chooser  = require("hs.chooser")
local fnutils  = require("hs.fnutils")
local inspect  = require("hs.inspect")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")

local axmetatable = hs.getObjectMetatable("hs.axuielement")

local module = {}

-- Useful as a single word shorthand when testing callbacks functions.
local cbinspect = function(...)
    local args = table.pack(...)
    if args.n == 1 and type(args[1]) == "table" then
        args = args[1]
    else
        args.n = nil -- supress the count from table.pack
    end

    local date = timer.secondsSinceEpoch()
    local timestamp = os.date("%F %T" .. string.format("%-5s", ((tostring(date):match("(%.%d+)$")) or "")), math.floor(date))

    print(timestamp .. ":: " .. inspect(args, { newline = " ", indent = "" }))
end

local storage
local _chooser


local buildChoicesForObject = function(obj)
    local aav        = {}
    local textPrefix = ""
    local choices    = {}

    local objIsTable       = (type(obj) == "table")
    local objIsAXUIElement = (getmetatable(obj) == axmetatable)

    if #storage > 0 then
        table.insert(choices, { text = "<-- Go back" })
    end

    if objIsAXUIElement then
        local actions = obj:actionNames()
        if actions then
            table.sort(actions)
            for i,v in ipairs(actions) do
                table.insert(choices, {
                    text        = "Action: " .. v,
                    subText     = (obj:actionDescription(v) or "no description") .. ", hold down ⌘ when selecting to perform",
                    action      = v,
                    cmdAddition = [[("do]] .. v .. [[")]],
                    cmdNoAdd = true,
                })
            end
        end
    end

    table.insert(storage, {
        element = obj,
    })

    if objIsAXUIElement then
        aav = obj:allAttributeValues()
        textPrefix = "Attribute: "
    end

    if objIsTable then
        storage[#storage].element   = storage[#storage - 1].element
        storage[#storage].attribute = storage[#storage - 1].tableAttribute or storage[#storage - 1].attribute
        storage[#storage].path      = {}
        for i,v in ipairs(storage[#storage - 1].path or {}) do storage[#storage].path[i] = v end
        aav = obj
    end

    for k,v in fnutils.sortByKeys(aav) do
        local entry = {}
        if type(v) == "table" then
            entry.text = textPrefix .. k .. " { ... }"
            if #v == 0 and next(v) then
                entry.subText = "key-value table"
            else
                entry.subText = tostring(#v) .. " entries"
            end
            entry[(objIsTable and "index" or "attribute")] = k
        elseif getmetatable(v) == axmetatable then
            if objIsTable then
                entry.text = tostring(k) .. ": " .. tostring(v("role"))
                entry.index = k
            else
                entry.text = textPrefix .. k
                entry.attribute = k
            end
            entry.subText = "Role: " .. tostring(v("role")) .. ", Subrole: " .. tostring(v("subrole")) .. ", Description: " .. tostring(v("valueDescription") or v("description") or v("roleDescription"))
        else
            entry.text     = textPrefix .. k
            entry.subText  = "Value: " .. tostring(v)
            entry.cmdNoAdd = true
        end
        if objIsAXUIElement and obj:isAttributeSettable(k) then
            entry.subText = entry.subText .. ", is settable (hold down ⌘ when selecting to see format)"
            entry.settable = true
        end

        if objIsTable then
            local quote = (type(k) == "number") and "" or '"'
            entry.cmdAddition = "[" .. quote .. tostring(k) .. quote .. "]"
        else
            entry.cmdAddition = [[("]] .. k .. [[")]]
            if entry.settable then entry.altCmd = [[("set]] .. k .. [[", ...)]] end
        end
        table.insert(choices, entry)
    end

    if objIsAXUIElement then
        local pAttributes = obj:parameterizedAttributeNames()
        if pAttributes then
            table.sort(pAttributes)
            for i,v in ipairs(pAttributes) do
                table.insert(choices, {
                    text        = "Parameterized Attribute: " .. v,
                    subText     = "",
                    cmdAddition = [[("]] .. v .. [[", ...)]],
                    cmdNoAdd = true,
                })
            end
        end
    end

    return choices
end

local chooserCallback = function(item)
    if module.debugCallback then
        cbinspect(item)
        cbinspect(storage)
    end

    if type(item) == "nil" then return end

    local obj
    local objDetails = storage[#storage]

    if item.text:match("^<--") then
        table.remove(storage)              -- remove the one we displayed
        objDetails = table.remove(storage) -- remove the one we're now at because it will be recreated
        obj = objDetails.element
        if objDetails.attribute then obj = obj(objDetails.attribute) end
        if objDetails.path then
            table.remove(objDetails.path)
            for i,v in ipairs(objDetails.path) do obj = obj[v] end
        end
        storage._path = storage._path:match("^(.+)[%[%(].+[%)%]]$")
    end

    if item.attribute then
        if item.settable and eventtap.checkKeyboardModifiers().cmd then
            obj = nil
            item.cmdAddition = item.altCmd
            item.cmdNoAdd = true
        else
            obj = objDetails.element(item.attribute)
            if type(obj) == "table" then objDetails.tableAttribute = item.attribute end
        end
    end

    if item.index then
        table.insert(objDetails.path, item.index)
        obj = objDetails.element(objDetails.attribute)
        for i,v in ipairs(objDetails.path) do obj = obj[v] end
        local quote = (type(item.label) == "number") and "" or '"'
    end

    if obj then
        _chooser:choices(buildChoicesForObject(obj)):show()
    else
        if item.action and eventtap.checkKeyboardModifiers().cmd then
            objDetails.element("do" .. item.action)
        end
    end

    -- to simplify removal when going back (see above), every step is bracket by parens or
    -- brackets; however I prefer using `.key` to `["key"]` when accessing tables
    print(((storage._path .. (item.cmdAddition or "")):gsub("%[\"(%w+)\"%]", ".%1")))
    if not item.cmdNoAdd then storage._path = storage._path .. (item.cmdAddition or "") end
end

_chooser = chooser.new(chooserCallback):searchSubText(true)
-- module._chooser = _chooser

module.debugCallback = false

module.browse = function(...)
    local args = table.pack(...)
    if (args.n > 0) then
        obj = args[1]
        storage = { _path = "object" }
        if obj then
            _chooser:choices(buildChoicesForObject(obj))
        end
    end

    if not storage or #storage == 0 then
        storage = { _path = "object" }
        _chooser:choices(buildChoicesForObject(ax.systemWideElement()("AXFocusedApplication")))
    end

    _chooser:show()
end

return module
