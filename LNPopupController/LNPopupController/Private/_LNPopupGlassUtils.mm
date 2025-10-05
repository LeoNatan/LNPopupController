//
//  _LNPopupGlassUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 13/8/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupGlassUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "_LNPopupSwizzlingUtils.h"

BOOL LNPopupEnvironmentHasGlass(void)
{
	static BOOL rv;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		{
			rv = ![[NSBundle.mainBundle objectForInfoDictionaryKey:@"UIDesignRequiresCompatibility"] boolValue];
		}
		else
		{
			rv = NO;
		}
#else
		rv = NO;
#endif
	});
	
	return rv;
}

@implementation UIVisualEffect (LNPopupSupport)

- (BOOL)ln_isGlass
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26.0, *))
	if([self isKindOfClass:UIGlassEffect.class])
	{
		return YES;
	}
#endif
	
	return NO;
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5

@implementation _LNPopupGlassEffect

+ (instancetype)effectWithStyle:(UIGlassEffectStyle)style
{
	_LNPopupGlassEffect* effect = (id)[super effectWithStyle:style];
	effect.style = style;
	return effect;
}

@end

@implementation _LNPopupBorrowedGlassEffect
{
	NSString* _configName;
}

+ (void)load
{
	Method from = __LNSwizzleClassGetInstanceMethod(self, @selector(shineSause));
	SEL to = NSSelectorFromString(LNPopupHiddenString("glass"));
	class_addMethod(self, to, method_getImplementation(from), method_getTypeEncoding(from));
}

+ (instancetype)shineEffect
{
	static NSString* const shinyGlassConfig = LNPopupHiddenString("_posterSwitcherGlassButtonConfiguration");
	
	_LNPopupBorrowedGlassEffect* borrowed = (id)[super effectWithStyle:UIGlassEffectStyleRegular];
	borrowed->_configName = shinyGlassConfig;
	return borrowed;
}

- (id)shineSause
{
	static NSString* const material = LNPopupHiddenString("_material");
	
	UIButtonConfiguration* config = [UIButtonConfiguration valueForKey:_configName];
	UIButton* button = [UIButton buttonWithConfiguration:config primaryAction:nil];
	button.frame = CGRectMake(0, 0, 440, 440);
	[button layoutIfNeeded];
	
	id rv = [button.configuration.background valueForKey:material];
	
	[rv setValue:@(self.isInteractive) forKey:LNPopupHiddenString("flexible")];
	[rv setValue:self.tintColor forKey:LNPopupHiddenString("tintColor")];
	
	return rv;
}

@end

@implementation _LNPopupGlassWrapperEffect
{
	UIGlassEffect* _proxied;
}

+ (void)load
{
	Method from = __LNSwizzleClassGetInstanceMethod(self, @selector(proxiedValue));
	SEL to = NSSelectorFromString(LNPopupHiddenString("glass"));
	class_addMethod(self, to, method_getImplementation(from), method_getTypeEncoding(from));
}

+ (instancetype)wrapperWithEffect:(UIVisualEffect *)effect
{
	_LNPopupGlassWrapperEffect* rv = (id)[super effectWithStyle:UIGlassEffectStyleClear];
	rv->_proxied = (id)effect;
	return rv;
}

- (id)proxiedValue
{
	id rv = [_proxied valueForKey:NSStringFromSelector(_cmd)];
	
	if(self.disableForeground)
	{
		[rv setValue:@YES forKey:@"excludingForeground"];
	}
	
	if(self.disableInteractive)
	{
		[rv setValue:@NO forKey:@"flexible"];
	}
	
	if(self.disableShadow)
	{
		[rv setValue:@YES forKey:@"excludingShadow"];
	}
	
	return rv;
}

@end

@interface UIGlassEffect (LNPopupEqualityCheck) @end
@implementation UIGlassEffect (LNPopupEqualityCheck)

- (BOOL)isEqual:(UIGlassEffect*)object
{
	if([object isKindOfClass:UIGlassEffect.class] == NO)
	{
		return NO;
	}
	
	static NSString* const key = LNPopupHiddenString("glass");
	return [[self valueForKey:key] isEqual:[object valueForKey:key]];
}

@end

#endif
