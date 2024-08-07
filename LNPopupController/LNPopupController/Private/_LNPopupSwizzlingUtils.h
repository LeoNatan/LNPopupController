//
//  _LNPopupSwizzlingUtils.h
//  LNPopupController
//
//  Created by Léo Natan on 2020-07-31.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ObjectiveC;
#import <objc/runtime.h>

#define unavailable(...) @available(__VA_ARGS__)) { } else if(YES

#define LNSwizzleComplain(FORMAT, ...) \
if(shouldTrapAndPrint) { \
NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,__func__,##__VA_ARGS__]; \
NSLog(@"LNPopupController: %@", errStr); \
raise(SIGTRAP); \
}

#ifndef LNAlwaysInline
#define LNAlwaysInline inline __attribute__((__always_inline__))
#endif /* LNAlwaysInline */

LNAlwaysInline
static BOOL LNSwizzleMethod(Class cls, SEL orig, SEL alt)
{
	static BOOL shouldTrapAndPrint = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shouldTrapAndPrint = [NSProcessInfo.processInfo.environment[@"LNPOPUP_DEBUG_SWIZZLES"] boolValue] == YES;
	});
	
	Method origMethod = class_getInstanceMethod(cls, orig);
	if (!origMethod) {
		LNSwizzleComplain(@"original method %@ not found for class %@", NSStringFromSelector(orig), cls);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(cls, alt);
	if (!altMethod) {
		LNSwizzleComplain(@"alternate method %@ not found for class %@", NSStringFromSelector(alt), cls);
		return NO;
	}
	
	class_addMethod(cls, orig, class_getMethodImplementation(cls, orig), method_getTypeEncoding(origMethod));
	class_addMethod(cls, alt, class_getMethodImplementation(cls, alt), method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(cls, orig), class_getInstanceMethod(cls, alt));
	return YES;
}

LNAlwaysInline
static BOOL LNSwizzleClassMethod(Class cls, SEL orig, SEL alt)
{
	return LNSwizzleMethod(object_getClass((id)cls), orig, alt);
}

LNAlwaysInline
static void __LNCopyMethods(Class orig, Class target)
{
	//Copy class methods
	Class targetMetaclass = object_getClass(target);
	
	unsigned int methodCount = 0;
	Method *methods = class_copyMethodList(object_getClass(orig), &methodCount);
	
	for (unsigned int i = 0; i < methodCount; i++)
	{
		Method method = methods[i];
		if(strcmp(sel_getName(method_getName(method)), "load") == 0 || strcmp(sel_getName(method_getName(method)), "initialize") == 0)
		{
			continue;
		}
		class_addMethod(targetMetaclass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
	}
	
	free(methods);
	
	//Copy instance methods
	methods = class_copyMethodList(orig, &methodCount);
	
	for (unsigned int i = 0; i < methodCount; i++)
	{
		Method method = methods[i];
		class_addMethod(target, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
	}
	
	free(methods);
}

LNAlwaysInline
static BOOL LNDynamicallySubclass(id obj, Class target)
{
	if(obj == nil)
	{
		return NO;
	}
	
	SEL canarySEL = NSSelectorFromString([NSString stringWithFormat:@"__LN_canaryInTheCoalMine_%@", NSStringFromClass(target)]);
	if([object_getClass(obj) instancesRespondToSelector:canarySEL])
	{
		//Already there.
		return YES;
	}
	
	NSString* clsName = [NSString stringWithFormat:@"%@(%@)", NSStringFromClass(object_getClass(obj)), NSStringFromClass(target)];
	Class cls = objc_getClass(clsName.UTF8String);
	
	if(cls == nil)
	{
		cls = objc_allocateClassPair(object_getClass(obj), clsName.UTF8String, 0);
		__LNCopyMethods(target, cls);
		class_addMethod(cls, canarySEL, imp_implementationWithBlock(^ (id _self) {}), "v16@0:8");
		objc_registerClassPair(cls);
	}
	
	NSMutableDictionary* superRegistrar = objc_getAssociatedObject(obj, (void*)&objc_setAssociatedObject);
	if(superRegistrar == nil)
	{
		superRegistrar = [NSMutableDictionary new];
	}
	
	superRegistrar[NSStringFromClass(target)] = object_getClass(obj);
	
	object_setClass(obj, cls);
	objc_setAssociatedObject(obj, (void*)&objc_setAssociatedObject, superRegistrar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	return YES;
}

LNAlwaysInline
static Class LNDynamicSubclassSuper(id obj, Class dynamic)
{
	NSMutableDictionary* superRegistrar = objc_getAssociatedObject(obj, (void*)&objc_setAssociatedObject);
	Class cls = superRegistrar[NSStringFromClass(dynamic)];
	if(cls == nil)
	{
		cls = class_getSuperclass(object_getClass(obj));
	}
	
	return cls;
}


NSString* _LNPopupDecodeBase64String(NSString* base64String);
NSArray<NSString*>* _LNPopupGetPropertyNames(Class cls, NSArray<NSString*>* excludedProperties);
