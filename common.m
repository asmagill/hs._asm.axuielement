#import "common.h"

// keep this current with Hammerspoon's method for creating new hs.application and hs.window objects

// I *think* these will work with @cmsj's WIP updates to window/application/uielement

@protocol PlaceHoldersForInterim
- (id)initWithPid:(pid_t)pid ;
- (id)initWithAXUIElementRef:(AXUIElementRef)winRef ;
@end

extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out) ;

BOOL new_application(lua_State* L, pid_t pid) {
    Class HSA = NSClassFromString(@"HSapplication") ;
    if (HSA) {
        id obj = [[HSA alloc] initWithPid:pid] ;
        if (obj) {
            [[LuaSkin shared] pushNSObject:obj] ;
            return true ;
        } else {
            return false ;
        }
    } else {
        AXUIElementRef* appptr = lua_newuserdata(L, sizeof(AXUIElementRef));
        AXUIElementRef app = AXUIElementCreateApplication(pid);
        *appptr = app;

        if (!app) return false;

        luaL_getmetatable(L, "hs.application");
        lua_setmetatable(L, -2);

        lua_newtable(L);
        lua_pushinteger(L, pid);
        lua_setfield(L, -2, "pid");
        lua_setuservalue(L, -2);
        return true;
    }
}

void new_window(lua_State* L, AXUIElementRef win) {
    Class HSW = NSClassFromString(@"HSwindow") ;
    if (HSW) {
        id obj = [[HSW alloc] initWithAXUIElementRef:win] ;
        [[LuaSkin shared] pushNSObject:obj] ;
    } else {
        AXUIElementRef* winptr = lua_newuserdata(L, sizeof(AXUIElementRef));
        *winptr = win;

        luaL_getmetatable(L, "hs.window");
        lua_setmetatable(L, -2);

        lua_newtable(L);

        pid_t pid;
        if (AXUIElementGetPid(win, &pid) == kAXErrorSuccess) {
            lua_pushinteger(L, pid);
            lua_setfield(L, -2, "pid");
        }

        CGWindowID winid;
        AXError err = _AXUIElementGetWindow(win, &winid);
        if (!err) {
            lua_pushinteger(L, winid);
            lua_setfield(L, -2, "id");
        }

        lua_setuservalue(L, -2);
    }
}
