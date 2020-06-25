--
-- prints a "hierarchial" view of the element and it's children
--
-- this can be extremely slow and produce a *lot* of output for elements with a lot of descendants
-- for Safari with one window displaying the DuckDuckGo search page, it took 134 seconds and
-- output 88,375 lines
--
--       h = dofile("axh.lua") -- adjust if not at the root of your hs.configdir
--       hs.console.clearConsole()
--       local s = os.time()
--       -- change to Safari and you better go get a cup of coffee... or beer
--       h.hierarchy(hs.axuielement.applicationElement("Dock"))
--       print("Run time: ", os.time() - s)
--

local module = {}
local ax      = require("hs.axuielement")
local fnutils = require("hs.fnutils")
local inspect = require("hs.inspect")

local hierarchy
hierarchy = function(obj, indent, seen)
    indent = indent or 0
    seen = seen or {}
    if getmetatable(obj) == hs.getObjectMetatable("hs.axuielement") then
    if coroutine.isyieldable() then coroutine.applicationYield() end
        if fnutils.find(seen, function(_) return _ == obj end) then return end -- probably not necessary, but be safe
        table.insert(seen, obj)

        print(string.format("%s%s", string.rep(" ", indent), obj.AXRole))
        for _, attrName in ipairs(obj:attributeNames()) do
            if attrName == ax.attributes.parent then
                print(string.format("%s%s: <parent>", string.rep(" ", indent + 4), attrName))
            elseif attrName == ax.attributes.topLevelUIElement then
                print(string.format("%s%s: <topLevelUIElement>", string.rep(" ", indent + 4), attrName))
            else
                local attrValue = obj:attributeValue(attrName)
                if getmetatable(attrValue) == hs.getObjectMetatable("hs.axuielement") then
                    if fnutils.find(seen, function(_) return _ == obj end) then
                        print(string.format("%s%s: <seen before>", string.rep(" ", indent + 4), attrName))
                    else
                        print(string.format("%s%s:", string.rep(" ", indent + 4), attrName))
                        hierarchy(attrValue, indent + 4, seen)
                    end
                elseif type(attrValue) == "table" then
                    if #attrValue == 0 then
                        print(string.format("%s%s = %s", string.rep(" ", indent + 4), attrName, inspect(attrValue):gsub("[\r\n]"," "):gsub("%s+", " ")))
                    else
                        print(string.format("%s%s {", string.rep(" ", indent + 4), attrName))
                        hierarchy(attrValue, indent + 8, seen)
                        print(string.format("%s}", string.rep(" ", indent + 4))) ;
                    end
                else
                    print(string.format("%s%s = %s", string.rep(" ", indent + 4), attrName, inspect(attrValue)))
                end
            end
        end
    elseif type(obj) == "table" then
        for i, v in ipairs(obj) do hierarchy(v, indent, seen) end
    end
end

module.hierarchy = hierarchy
return module
