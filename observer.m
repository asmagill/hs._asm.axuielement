#import "common.h"

static int refTable = LUA_NOREF ;

static NSMutableDictionary *observerDetails = nil ;

#pragma mark - Support Functions

int pushAXObserver(lua_State *L, AXObserverRef observer) {
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    if (!details) {
        details = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"selfRefCount" : @(0),
            @"callbackRef"  : @(LUA_NOREF),
            @"isRunning"    : @(NO),
            @"watching"     : [[NSMutableDictionary alloc] init] ;
        }] ;

#pragma message "pushAXObserver whatever else needs to be initialized"

        observerDetails[(__bridge id)observer] = details ;
    }
    details[@"selfRefCount"] = @([(NSNumber *)details[@"selfRefCount"] intValue] + 1) ;

    AXObserverRef* thePtr = lua_newuserdata(L, sizeof(AXObserverRef)) ;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
// Apple is #^#$@#%^$ inconsistent with Core Foundation types as other CF type refs don't trigger a warning.
    *thePtr = CFRetain(observer) ;
#pragma clang diagnostic pop
    luaL_getmetatable(L, OBSERVER_TAG) ;
    lua_setmetatable(L, -2) ;
    return 1 ;
}

// reduce duplication in meta_gc and userdata_gc
static void cleanupAXObserver(AXObserverRef observer, NSMutableDictionary *details) {
    LuaSkin *skin = [LuaSkin shared] ;
    details[@"callbackRef"] = @([skin luaUnref:refTable ref:[(NSNumber *)details[@"callbackRef"] intValue]]) ;
    if ([(NSNumber *)details[@"isRunning"] boolValue]) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), kCFRunLoopCommonModes) ;
        details[@"isRunning"] = @(NO) ;
    }

#pragma message "cleanupAXObserver whatever else needs to cleared"

}

static void observerCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, CFDictionaryRef info, __unused void *refcon) {
    LuaSkin   *skin = [LuaSkin shared] ;
    lua_State *L    = skin.L ;

    NSDictionary *details = observerDetails[(__bridge id)observer] ;
    if (!details) {
        [skin logWarn:[NSString stringWithFormat:@"%s:callback triggered for unregistered observer", OBSERVER_TAG]] ;
    } else {
        int callbackRef = [(NSNumber *)details[@"callbackRef"] intValue] ;
        if (callbackRef != LUA_NOREF) {
            [skin pushLuaRef:refTable ref:callbackRef] ;
            pushAXObserver(L, observer) ;
            pushAXUIElement(L, element) ;
            [skin pushNSObject:(__bridge NSString *)notification] ;
            [skin pushNSObject:(__bridge NSDictionary *)info withOptions:LS_NSDescribeUnknownTypes] ;
            if (![skin protectedCallAndTraceback:4 nresults:0]) {
                [skin logError:[NSString stringWithFormat:@"%s:callback error:%s", OBSERVER_TAG, lua_tostring(L, -1)]] ;
                lua_pop(L, 1) ;
            }
        }
    }
}

#pragma mark - Module Functions

static int observer_new(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TNUMBER | LS_TINTEGER, LS_TBREAK] ;
    pid_t         appPid   = (pid_t)lua_tointeger(L, 1) ;
    AXObserverRef observer = NULL ;
    AXError       err      = AXObserverCreateWithInfoCallback(appPid, observerCallback, &observer) ;

    if (err != kAXErrorSuccess) return luaL_error(L, AXErrorAsString(err)) ;

    pushAXObserver(L, observer) ;
    return 1 ;
}

#pragma mark - Module Methods

static int observer_start(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG, LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    if (![(NSNumber *)details[@"isRunning"] boolValue]) {
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), kCFRunLoopCommonModes) ;
        details[@"isRunning"] = @(YES) ;
    }
    lua_pushvalue(L, 1) ;
    return 1 ;
}

static int observer_stop(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG, LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    if ([(NSNumber *)details[@"isRunning"] boolValue]) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), kCFRunLoopCommonModes) ;
        details[@"isRunning"] = @(NO) ;
    }
    lua_pushvalue(L, 1) ;
    return 1 ;
}

static int observer_isRunning(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG, LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    lua_pushboolean(L, [(NSNumber *)details[@"isRunning"] boolValue]) ;
    return 1 ;
}

static int observer_callback(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG, LS_TFUNCTION | LS_TNIL | LS_TOPTIONAL, LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;

    if (lua_gettop(L) == 2) {
        details[@"callbackRef"] = @([skin luaUnref:refTable ref:[(NSNumber *)details[@"callbackRef"] intValue]]) ;
        if (lua_type(L, 2) != LUA_TNIL) {
            lua_pushvalue(L, 2) ;
            details[@"callbackRef"] = @([skin luaRef:refTable]) ;
            lua_pushvalue(L, 1) ;
        }
    } else {
        int callbackRef = [(NSNumber *)details[@"callbackRef"] intValue] ;
        if (callbackRef != LUA_NOREF) {
            [skin pushLuaRef:refTable ref:callbackRef] ;
        } else {
            lua_pushnil(L) ;
        }
    }
    return 1 ;
}

static int observer_addWatchedElement(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG,
                    LS_TUSERDATA, USERDATA_TAG,
                    LS_TSTRING,
                    LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    AXUIElementRef      element  = get_axuielementref(L, 2, USERDATA_TAG) ;
    NSString            *notification = [skin toNSObjectAtIndex:3] ;

// AXError AXObserverAddNotification(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon);

    return 1 ;
}

static int observer_removeWatchedElement(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG,
                    LS_TUSERDATA, USERDATA_TAG,
                    LS_TSTRING,
                    LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    AXUIElementRef      element  = get_axuielementref(L, 2, USERDATA_TAG) ;
    NSString            *notification = [skin toNSObjectAtIndex:3] ;

// AXError AXObserverRemoveNotification(AXObserverRef observer, AXUIElementRef element, CFStringRef notification);

    return 1 ;
}

static int observer_watchedElements(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    [skin checkArgs:LS_TUSERDATA, OBSERVER_TAG, LS_TBREAK] ;
    AXObserverRef       observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;

    return 1 ;
}


#pragma mark - Module Constants

/// hs._asm.axuielement.observer.notifications[]
/// Constant
/// A table of accessibility object notification names, provided for reference.
///
/// Notes:
///  * Notification support is currently not provided by this module, so this table is in anticipation of future additions.
static int pushNotificationsTable(lua_State *L) {
    LuaSkin *skin = [LuaSkin shared] ;
    lua_newtable(L) ;
// Focus notifications
    [skin pushNSObject:(__bridge NSString *)kAXMainWindowChangedNotification] ;       lua_setfield(L, -2, "mainWindowChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXFocusedWindowChangedNotification] ;    lua_setfield(L, -2, "focusedWindowChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXFocusedUIElementChangedNotification] ; lua_setfield(L, -2, "focusedUIElementChanged") ;
// Application notifications
    [skin pushNSObject:(__bridge NSString *)kAXApplicationActivatedNotification] ;    lua_setfield(L, -2, "applicationActivated") ;
    [skin pushNSObject:(__bridge NSString *)kAXApplicationDeactivatedNotification] ;  lua_setfield(L, -2, "applicationDeactivated") ;
    [skin pushNSObject:(__bridge NSString *)kAXApplicationHiddenNotification] ;       lua_setfield(L, -2, "applicationHidden") ;
    [skin pushNSObject:(__bridge NSString *)kAXApplicationShownNotification] ;        lua_setfield(L, -2, "applicationShown") ;
// Window notifications
    [skin pushNSObject:(__bridge NSString *)kAXWindowCreatedNotification] ;           lua_setfield(L, -2, "windowCreated") ;
    [skin pushNSObject:(__bridge NSString *)kAXWindowMovedNotification] ;             lua_setfield(L, -2, "windowMoved") ;
    [skin pushNSObject:(__bridge NSString *)kAXWindowResizedNotification] ;           lua_setfield(L, -2, "windowResized") ;
    [skin pushNSObject:(__bridge NSString *)kAXWindowMiniaturizedNotification] ;      lua_setfield(L, -2, "windowMiniaturized") ;
    [skin pushNSObject:(__bridge NSString *)kAXWindowDeminiaturizedNotification] ;    lua_setfield(L, -2, "windowDeminiaturized") ;
// New drawer, sheet, and help tag notifications
    [skin pushNSObject:(__bridge NSString *)kAXDrawerCreatedNotification] ;           lua_setfield(L, -2, "drawerCreated") ;
    [skin pushNSObject:(__bridge NSString *)kAXSheetCreatedNotification] ;            lua_setfield(L, -2, "sheetCreated") ;
    [skin pushNSObject:(__bridge NSString *)kAXHelpTagCreatedNotification] ;          lua_setfield(L, -2, "helpTagCreated") ;
// Element notifications
    [skin pushNSObject:(__bridge NSString *)kAXValueChangedNotification] ;            lua_setfield(L, -2, "valueChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXUIElementDestroyedNotification] ;      lua_setfield(L, -2, "UIElementDestroyed") ;
    [skin pushNSObject:(__bridge NSString *)kAXElementBusyChangedNotification] ;      lua_setfield(L, -2, "elementBusyChanged") ;
// Menu notifications
    [skin pushNSObject:(__bridge NSString *)kAXMenuOpenedNotification] ;              lua_setfield(L, -2, "menuOpened") ;
    [skin pushNSObject:(__bridge NSString *)kAXMenuClosedNotification] ;              lua_setfield(L, -2, "menuClosed") ;
    [skin pushNSObject:(__bridge NSString *)kAXMenuItemSelectedNotification] ;        lua_setfield(L, -2, "menuItemSelected") ;
// Table and outline view notifications
    [skin pushNSObject:(__bridge NSString *)kAXRowCountChangedNotification] ;         lua_setfield(L, -2, "rowCountChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXRowCollapsedNotification] ;            lua_setfield(L, -2, "rowCollapsed") ;
    [skin pushNSObject:(__bridge NSString *)kAXRowExpandedNotification] ;             lua_setfield(L, -2, "rowExpanded") ;
// Miscellaneous notifications
    [skin pushNSObject:(__bridge NSString *)kAXSelectedChildrenChangedNotification] ; lua_setfield(L, -2, "selectedChildrenChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXResizedNotification] ;                 lua_setfield(L, -2, "resized") ;
    [skin pushNSObject:(__bridge NSString *)kAXMovedNotification] ;                   lua_setfield(L, -2, "moved") ;
    [skin pushNSObject:(__bridge NSString *)kAXCreatedNotification] ;                 lua_setfield(L, -2, "created") ;
    [skin pushNSObject:(__bridge NSString *)kAXAnnouncementRequestedNotification] ;   lua_setfield(L, -2, "announcementRequested") ;
    [skin pushNSObject:(__bridge NSString *)kAXLayoutChangedNotification] ;           lua_setfield(L, -2, "layoutChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXSelectedCellsChangedNotification] ;    lua_setfield(L, -2, "selectedCellsChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXSelectedChildrenMovedNotification] ;   lua_setfield(L, -2, "selectedChildrenMoved") ;
    [skin pushNSObject:(__bridge NSString *)kAXSelectedColumnsChangedNotification] ;  lua_setfield(L, -2, "selectedColumnsChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXSelectedRowsChangedNotification] ;     lua_setfield(L, -2, "selectedRowsChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXSelectedTextChangedNotification] ;     lua_setfield(L, -2, "selectedTextChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXTitleChangedNotification] ;            lua_setfield(L, -2, "titleChanged") ;
    [skin pushNSObject:(__bridge NSString *)kAXUnitsChangedNotification] ;            lua_setfield(L, -2, "unitsChanged") ;

    return 1 ;
}

#pragma mark - Hammerspoon/Lua Infrastructure

static int userdata_tostring(lua_State* L) {
    LuaSkin *skin = [LuaSkin shared] ;
//     AXObserverRef observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    [skin pushNSObject:[NSString stringWithFormat:@"%s: (%p)", OBSERVER_TAG, lua_topointer(L, 1)]] ;
    return 1 ;
}

static int userdata_gc(lua_State* L) {
    LuaSkin *skin = [LuaSkin shared] ;
    AXObserverRef observer = get_axobserverref(L, 1, OBSERVER_TAG) ;
    NSMutableDictionary *details = observerDetails[(__bridge id)observer] ;
    if (!details) {
        [skin logWarn:[NSString stringWithFormat:@"%s:__gc triggered for unregistered observer", OBSERVER_TAG]] ;
    } else {
        details[@"selfRefCount"] = @([(NSNumber *)details[@"selfRefCount"] intValue] - 1) ;
        if ([(NSNumber *)details[@"selfRefCount"] intValue] == 0) {
            cleanupAXObserver(observer, details) ;
            observerDetails[(__bridge id)observer] = nil ;
            CFRelease(observer) ;
        }
    }
    lua_pushnil(L) ;
    lua_setmetatable(L, 1) ;
    return 0 ;
}

static int userdata_eq(lua_State* L) {
    AXObserverRef observer1 = get_axobserverref(L, 1, OBSERVER_TAG) ;
    AXObserverRef observer2 = get_axobserverref(L, 2, OBSERVER_TAG) ;
    lua_pushboolean(L, CFEqual(observer1, observer2)) ;
    return 1 ;
}

static int meta_gc(lua_State* __unused L) {
    [observerDetails enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *details, __unused BOOL *stop) {
        cleanupAXObserver((__bridge AXObserverRef)key, details) ;
    }] ;
    [observerDetails removeAllObjects] ;
    observerDetails = nil ;
    return 0 ;
}

// Metatable for userdata objects
static const luaL_Reg userdata_metaLib[] = {
    {"start",           observer_start},
    {"stop",            observer_stop},
    {"isRunning",       observer_isRunning},
    {"callback",        observer_callback},
    {"addWatcher",      observer_addWatchedElement},
    {"removeWatcher",   observer_removeWatchedElement},
    {"watchedElements", observer_watchedElements},

    {"__tostring",      userdata_tostring},
    {"__eq",            userdata_eq},
    {"__gc",            userdata_gc},
    {NULL,              NULL}
} ;

// Functions for returned object when module loads
static luaL_Reg moduleLib[] = {
    {"new", observer_new},
    {NULL,  NULL}
} ;

// Metatable for module, if needed
static const luaL_Reg module_metaLib[] = {
    {"__gc", meta_gc},
    {NULL,   NULL}
} ;

int luaopen_hs__asm_axuielement_observer(lua_State* L) {
    LuaSkin *skin = [LuaSkin shared] ;
    refTable = [skin registerLibraryWithObject:OBSERVER_TAG
                                     functions:moduleLib
                                 metaFunctions:module_metaLib
                               objectFunctions:userdata_metaLib] ;

    observerDetails = [[NSMutableDictionary alloc] init] ;

    pushNotificationsTable(L) ; lua_setfield(L, -2, "notifications") ;

    return 1 ;
}
