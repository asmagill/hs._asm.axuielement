#pragma once

@import Cocoa ;
@import LuaSkin ;

// AXTextMarker and AXTextMarkerRange support gleaned from HIServices framework disassembly and
// https://chromium.googlesource.com/chromium/src/+/ee5dac5d4335b5f4fc6bd99136d38e7a070a4559/content/browser/accessibility/browser_accessibility_cocoa.mm
typedef CFTypeRef AXTextMarkerRangeRef ;
typedef CFTypeRef AXTextMarkerRef ;

extern CFTypeID        AXTextMarkerGetTypeID(void) __attribute__((weak_import)) ;
extern AXTextMarkerRef AXTextMarkerCreate(CFAllocatorRef allocator, const char* bytes, CFIndex length) __attribute__((weak_import)) ;
extern CFIndex         AXTextMarkerGetLength(AXTextMarkerRef text_marker) __attribute__((weak_import)) ;
extern const char*     AXTextMarkerGetBytePtr(AXTextMarkerRef text_marker) __attribute__((weak_import)) ;

extern CFTypeID             AXTextMarkerRangeGetTypeID(void) __attribute__((weak_import)) ;
extern AXTextMarkerRangeRef AXTextMarkerRangeCreate(CFAllocatorRef allocator, AXTextMarkerRef start_marker, AXTextMarkerRef end_marker) __attribute__((weak_import)) ;
extern AXTextMarkerRef      AXTextMarkerRangeCopyStartMarker(AXTextMarkerRangeRef text_marker_range) __attribute__((weak_import)) ;
extern AXTextMarkerRef      AXTextMarkerRangeCopyEndMarker(AXTextMarkerRangeRef text_marker_range) __attribute__((weak_import)) ;


// In AppKit disassembly but not in header files
extern NSString *NSAccessibilityAttributedValueForStringAttributeParameterizedAttribute ;
extern NSString *NSAccessibilityScrollToShowDescendantParameterizedAttributeAction ;
extern NSString *NSAccessibilityIndexForChildUIElementParameterizedAttribute ;
extern NSString *NSAccessibilityResultsForSearchPredicateParameterizedAttribute ;
extern NSString *NSAccessibilityLoadSearchResultParameterizedAttribute ;
extern NSString *NSAccessibilityFocusRingManipulationParameterizedAttribute ;
extern NSString *NSAccessibilityReplaceRangeWithTextParameterizedAttribute ;


#define USERDATA_TAG     "hs.axuielement"
#define OBSERVER_TAG     "hs.axuielement.observer"
#define AXTEXTMARKER_TAG "hs.axuielement.axtextmarker"
#define AXTEXTMRKRNG_TAG "hs.axuielement.axtextmarkerrange"

#define get_axuielementref(L, idx, tag) *((AXUIElementRef*)luaL_checkudata(L, idx, tag))
#define get_axobserverref(L, idx, tag) *((AXObserverRef*)luaL_checkudata(L, idx, tag))
#define get_axtextmarkerref(L, idx, tag) *((AXTextMarkerRef*)luaL_checkudata(L, idx, tag))
#define get_axtextmarkerrangeref(L, idx, tag) *((AXTextMarkerRangeRef*)luaL_checkudata(L, idx, tag))

extern AXUIElementRef getElementRefPropertyFromClassObject(NSObject *object) ;

extern BOOL new_application(lua_State* L, pid_t pid) ;
extern BOOL new_window(lua_State* L, AXUIElementRef win) ;

extern int pushAXUIElement(lua_State *L, AXUIElementRef theElement) ;
extern int pushAXObserver(lua_State *L, AXObserverRef theObserver) ;
extern int pushAXTextMarker(lua_State *L, AXTextMarkerRef theElement) ;
extern int pushAXTextMarkerRange(lua_State *L, AXTextMarkerRangeRef theElement) ;

extern const char *AXErrorAsString(AXError theError) ;

extern int pushCFTypeToLua(lua_State *L, CFTypeRef theItem, int refTable) ;
extern CFTypeRef lua_toCFType(lua_State *L, int idx) ;

int luaopen_hs_axuielement_observer(lua_State* L) ;
int luaopen_hs_axuielement_axtextmarker(lua_State* L) ;
