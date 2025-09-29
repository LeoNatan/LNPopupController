//
//  _LNPopupGlassUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 13/8/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupGlassUtils.h"
#import "_LNPopupBase64Utils.hh"

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

@implementation LNPopupGlassEffect

+ (instancetype)effectWithStyle:(UIGlassEffectStyle)style
{
	LNPopupGlassEffect* effect = (id)[super effectWithStyle:style];
	effect.style = style;
	return effect;
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
