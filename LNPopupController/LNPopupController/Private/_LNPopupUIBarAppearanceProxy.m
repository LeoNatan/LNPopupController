//
//  _LNPopupUIBarAppearanceProxy.m
//  LNPopupController
//
//  Created by Léo Natan on 2023-08-30.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#if ! LNPopupControllerEnforceStrictClean

#import "_LNPopupUIBarAppearanceProxy.h"
#import "_LNPopupSwizzlingUtils.h"

@import UIKit;
@import ObjectiveC;

//_backgroundData
static NSString* const _bD = @"X2JhY2tncm91bmREYXRh";
//shadowViewBackgroundColor
static NSString* const _sVBC = @"c2hhZG93Vmlld0JhY2tncm91bmRDb2xvcg==";
//shadowViewTintColor
static NSString* const _sVTC = @"c2hhZG93Vmlld1RpbnRDb2xvcg==";

static const void* _LNPopupBarBackgroundDataSubclassShadowHandlerKey = &_LNPopupBarBackgroundDataSubclassShadowHandlerKey;

#define LN_ADD_PROPERTY_GETTER(cls, base64Name, impBlock) SEL sel##base64Name = NSSelectorFromString(_LNPopupDecodeBase64String(base64Name)); \
class_addMethod(cls, sel##base64Name, imp_implementationWithBlock(^id(id _self){ \
return ((id(^)(id, SEL))impBlock)(_self, sel##base64Name); \
}), method_getTypeEncoding(class_getInstanceMethod(NSObject.class, @selector(description))));

#define LN_SHADOW_CLEAR_COLOR_OR_SUPER if(self._ln_shouldHideShadow) { \
return UIColor.clearColor; \
} else { \
Class superclass = LNDynamicSubclassSuper(self, _LNPopupBarBackgroundDataSubclass.class); \
struct objc_super super = {.receiver = self, .super_class = superclass}; \
id (*super_class)(struct objc_super*, SEL) = (void*)objc_msgSendSuper; \
return super_class(&super, _cmd); \
}

#define LN_SHADOW_NIL_IMAGE_OR_SUPER if(self._ln_shouldHideShadow) { \
return nil; \
} else { \
Class superclass = LNDynamicSubclassSuper(self, _LNPopupBarBackgroundDataSubclass.class); \
struct objc_super super = {.receiver = self, .super_class = superclass}; \
id (*super_class)(struct objc_super*, SEL) = (void*)objc_msgSendSuper; \
return super_class(&super, _cmd); \
}

@interface NSObject ()

- (id)replicate;

@end

@interface _LNPopupBarBackgroundDataSubclass: NSObject

@property (nonatomic, copy) BOOL (^_ln_shadowColorHandler)(void);

@end
@implementation _LNPopupBarBackgroundDataSubclass

- (Class)class
{
	return LNDynamicSubclassSuper(self, _LNPopupBarBackgroundDataSubclass.class);
}

+ (void)load
{
	@autoreleasepool {
		id imp = ^id(_LNPopupBarBackgroundDataSubclass* self, SEL _cmd){
			LN_SHADOW_CLEAR_COLOR_OR_SUPER
		};
		
		//shadowViewBackgroundColor
		LN_ADD_PROPERTY_GETTER(self, _sVBC, imp);
		//shadowViewTintColor
		LN_ADD_PROPERTY_GETTER(self, _sVTC, imp);
	}
}

- (BOOL(^)(void))_ln_shadowColorHandler
{
	return objc_getAssociatedObject(self, _LNPopupBarBackgroundDataSubclassShadowHandlerKey);
}

- (void)set_ln_shadowColorHandler:(BOOL(^)(void))handler
{
	objc_setAssociatedObject(self, _LNPopupBarBackgroundDataSubclassShadowHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)_ln_shouldHideShadow
{
	BOOL (^handler)(void) = self._ln_shadowColorHandler;
	return handler != nil && handler();
}

- (UIColor*)shadowColor
{
	LN_SHADOW_CLEAR_COLOR_OR_SUPER
}

- (UIImage*)shadowImage
{
	LN_SHADOW_NIL_IMAGE_OR_SUPER
}

@end

@implementation _LNPopupUIBarAppearanceProxy
{
	id _proxiedObject;
	BOOL (^_shadowColorHandler)(void);
}

- (Class)class
{
	return [_proxiedObject class];
}

+ (void)load
{
	@autoreleasepool 
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		//_backgroundData
		id block = ^id(_LNPopupUIBarAppearanceProxy* _self, SEL _cmd) {
			id rv = [_self->_proxiedObject performSelector:_cmd];
			if(rv == nil)
			{
				return rv;
			}
			
			rv = [rv replicate];
			LNDynamicallySubclass(rv, _LNPopupBarBackgroundDataSubclass.class);
			[rv setValue:_self->_shadowColorHandler forKey:@"_ln_shadowColorHandler"];
			
			return rv;
		};
		LN_ADD_PROPERTY_GETTER(_LNPopupUIBarAppearanceProxy.class, _bD, block);
#pragma clang diagnostic pop
	}
}

- (instancetype)initWithProxiedObject:(id)obj shadowColorHandler:(BOOL(^)(void))shadowColorHandler
{
	if(obj == nil)
	{
		return nil;
	}
	
	self = [super init];
	if(self)
	{
		_proxiedObject = obj;
		_shadowColorHandler = shadowColorHandler;
	}
	return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return _proxiedObject;
}

@end

#endif
