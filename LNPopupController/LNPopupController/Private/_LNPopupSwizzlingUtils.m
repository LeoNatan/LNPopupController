//
//  _LNPopupSwizzlingUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 2018-01-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupSwizzlingUtils.h"

BOOL __LNSwizzleShouldTrapAndPrint(void)
{
	static BOOL shouldTrapAndPrint = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shouldTrapAndPrint = [NSProcessInfo.processInfo.environment[@"LNPOPUP_DEBUG_SWIZZLES"] boolValue] == YES;
	});
	return shouldTrapAndPrint;
}

BOOL __LNSwizzleMethod(Class cls, SEL orig, SEL alt)
{
	Method origMethod = LNSwizzleClassGetInstanceMethod(cls, orig);
	if(!origMethod)
	{
		return NO;
	}
	
	Method altMethod = LNSwizzleClassGetInstanceMethod(cls, alt);
	if(!altMethod)
	{
		return NO;
	}
	
	class_addMethod(cls, orig, class_getMethodImplementation(cls, orig), method_getTypeEncoding(origMethod));
	class_addMethod(cls, alt, class_getMethodImplementation(cls, alt), method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(LNSwizzleClassGetInstanceMethod(cls, orig), LNSwizzleClassGetInstanceMethod(cls, alt));
	return YES;
}

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

Method __LNSwizzleClassGetInstanceMethod(Class cls, SEL sel)
{
	Method m = class_getInstanceMethod(cls, sel);
	if(m == nil)
	{
		LNSwizzleComplain(@"original method %@ not found for class %@", NSStringFromSelector(sel), cls);
	}
	return m;
}

Method __LNSwizzleClassGetClassMethod(Class cls, SEL sel)
{
	Method m = class_getClassMethod(cls, sel);
	if(m == nil)
	{
		LNSwizzleComplain(@"original method %@ not found for class %@", NSStringFromSelector(sel), cls);
	}
	return m;
}

BOOL __LNDynamicSubclass(id obj, Class target)
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
		Class orig = object_getClass(obj);
		cls = objc_allocateClassPair(orig, clsName.UTF8String, 0);
		__LNCopyMethods(target, cls);
		class_addMethod(cls, canarySEL, imp_implementationWithBlock(^ (id _self) {}), "v16@0:8");
		objc_registerClassPair(cls);
		class_addMethod(cls, @selector(class), imp_implementationWithBlock(^(id _) {
			return orig;
		}), "@@:");
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

Class __LNDynamicSubclassSuper(id obj, Class dynamic)
{
	NSMutableDictionary* superRegistrar = objc_getAssociatedObject(obj, (void*)&objc_setAssociatedObject);
	Class cls = superRegistrar[NSStringFromClass(dynamic)];
	if(cls == nil)
	{
		cls = class_getSuperclass(object_getClass(obj));
	}
	
	return cls;
}

NSArray<NSString*>* __LNPopupGetPropertyNames(Class cls, NSArray<NSString*>* excludedProperties, BOOL ignoreAttribs)
{
	unsigned int propertyCount = 0;
	objc_property_t* properties = class_copyPropertyList(cls, &propertyCount);
	
	NSMutableArray* rv = [NSMutableArray new];
	for(unsigned int idx = 0; idx < propertyCount; idx++)
	{
		NSString* propertyName = @(property_getName(properties[idx]));
		if([excludedProperties containsObject:propertyName])
		{
			continue;
		}
		
		BOOL hasVar = NO;
		BOOL isWeak = NO;
		if(ignoreAttribs == NO)
		{
			unsigned int attribCount = 0;
			objc_property_attribute_t* attribs = property_copyAttributeList(properties[idx], &attribCount);
			
			for(unsigned int idx2 = 0; idx2 < attribCount; idx2++)
			{
				if(strncmp(attribs[idx2].name, "V", 1) == 0 && strlen(attribs[idx2].value) > 0)
				{
					hasVar = YES;
				}
				
				if(strncmp(attribs[idx2].name, "W", 1) == 0)
				{
					isWeak = YES;
				}
			}
			
			free(attribs);
		}
		
		if(ignoreAttribs || (hasVar && !isWeak))
		{
			[rv addObject:propertyName];
		}
	}
	
	free(properties);
	
	return rv;
}
