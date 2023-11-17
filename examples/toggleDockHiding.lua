toggleDockHiding = function()
    local axuielement = require("hs.axuielement")
    local timer       = require("hs.timer")
    local minFloat    = require("hs.math").minFloat

    local dockElement = axuielement.applicationElement("com.apple.dock")
    local separator = nil
    for _, child in ipairs(dockElement[1]) do
        if child.AXSubrole == "AXSeparatorDockItem" then
            separator = child
            break
        end
    end
    if separator then
        separator:doAXShowMenu()
        local menuTimer
        menuTimer = timer.doAfter(minFloat, function()
            menuTimer = nil -- make upvalue so not collected prematurely
            for _, menuitem in ipairs(separator[1]) do
                if menuitem.AXTitle:match("^Turn Hiding O") then
                    menuitem:doAXPress()
                    return
                end
            end
            -- if we're still here, then didn't find menu item
            separator:doAXShowMenu() -- closes menu
        end)
    end
end
