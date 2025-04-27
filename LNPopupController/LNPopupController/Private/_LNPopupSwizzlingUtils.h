//
//  _LNPopupSwizzlingUtils.h
//  LNPopupController
//
//  Created by Léo Natan on 2020-07-31.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

CF_EXTERN_C_BEGIN

#define unavailable(...) @available(__VA_ARGS__)) { } else if(YES

#define LNSwizzleComplain(FORMAT, ...) \
if(shouldTrapAndPrint) { \
NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,__func__,##__VA_ARGS__]; \
NSLog(@"LNPopupController: %@", errStr); \
raise(SIGTRAP); \
}

#ifndef LNAlwaysInline
#define LNAlwaysInline CF_INLINE
#endif /* LNAlwaysInline */

extern BOOL __LNSwizzleMethod(Class cls, SEL orig, SEL alt);

#define LNSwizzleMethod __LNSwizzleMethod

LNAlwaysInline
BOOL __LNSwizzleClassMethod(Class cls, SEL orig, SEL alt)
{
	return LNSwizzleMethod(object_getClass((id)cls), orig, alt);
}

extern BOOL __LNDynamicSubclass(id obj, Class target);
#define LNDynamicSubclass __LNDynamicSubclass
extern Class __LNDynamicSubclassSuper(id obj, Class dynamic);
#define LNDynamicSubclassSuper __LNDynamicSubclassSuper

NSArray<NSString*>* __LNPopupGetPropertyNames(Class cls, NSArray<NSString*>* excludedProperties);
#define LNPopupGetPropertyNames __LNPopupGetPropertyNames

CF_EXTERN_C_END
