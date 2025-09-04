//
//  LNPopupBarAppearance.m
//  LNPopupController
//
//  Created by Léo Natan on 2021-06-20.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupBarAppearance+Private.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "_LNPopupGlassUtils.h"

static void* _LNPopupItemObservationContext = &_LNPopupItemObservationContext;

@implementation LNPopupBarAppearance
{
	BOOL _wantsDynamicFloatingBackgroundEffect;
}

@synthesize floatingBackgroundEffect=_floatingBackgroundEffect;

static NSArray* __notifiedProperties = nil;

+ (void)initialize
{
	@autoreleasepool
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			__notifiedProperties = LNPopupGetPropertyNames(self, nil);
			
#ifndef LNPopupControllerEnforceStrictClean
			Method m1 = class_getInstanceMethod(self, @selector(a:cC:));
			class_addMethod(self, NSSelectorFromString(LNPopupHiddenString("appearance:categoriesChanged:")), method_getImplementation(m1), method_getTypeEncoding(m1));
#endif
		});
	}
}

- (void)_notify
{
	[self.delegate popupBarAppearanceDidChange:self];
}

#ifndef LNPopupControllerEnforceStrictClean
//appearance:categoriesChanged:
- (void)a:(UIBarAppearance *)arg1 cC:(NSUInteger)arg2
{
	[self _notify];
}
#endif

- (void)_commonInit
{
	static NSString* changeObserver = LNPopupHiddenString("changeObserver");
	
#ifndef LNPopupControllerEnforceStrictClean
	[self setValue:self forKey:changeObserver];
#endif
	
	for(NSString* key in __notifiedProperties)
	{
		[self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:_LNPopupItemObservationContext];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	id oldValue = change[NSKeyValueChangeOldKey];
	id newValue = change[NSKeyValueChangeNewKey];
	
	if([oldValue isEqual:newValue])
	{
		return;
	}
	
	if(context == _LNPopupItemObservationContext)
	{
		[self _notify];
	}
}

- (void)dealloc
{
	for(NSString* key in __notifiedProperties)
	{
		[self removeObserver:self forKeyPath:key context:_LNPopupItemObservationContext];
	}
}

- (instancetype)initWithIdiom:(UIUserInterfaceIdiom)idiom
{
	self = [super initWithIdiom:UIUserInterfaceIdiomUnspecified];
	
	if(self)
	{
		[self configureWithDefaultBackground];
		
		[self configureWithDefaultImageShadow];
		[self configureWithDefaultHighlightColor];
		[self configureWithDefaultMarqueeScroll];
		[self configureWithDisabledMarqueeScroll];
		
		[self configureWithDefaultFloatingBackground];

		[self _commonInit];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if(coder.allowsKeyedCoding == NO)
	{
		[NSException raise:NSInvalidArgumentException format:@"Only coders with allowsKeyedCoding=true supported."];
	}
	
	[super encodeWithCoder:coder];
	
	for(NSString* key in __notifiedProperties)
	{
		[coder encodeObject:[self valueForKey:key] forKey:key];
	}
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if(coder.allowsKeyedCoding == NO)
	{
		[NSException raise:NSInvalidArgumentException format:@"Only coders with allowsKeyedCoding=true supported."];
		return nil;
	}
	
	self = [super initWithCoder:coder];
	
	if(self)
	{
		for(NSString* key in __notifiedProperties)
		{
			[self setValue:[coder decodeObjectForKey:key] forKey:key];
		}
		
		[self _commonInit];
	}
	
	return self;
}

- (instancetype)initWithBarAppearance:(UIBarAppearance *)barAppearance
{
	self = [super initWithBarAppearance:barAppearance];
	
	if(self && [barAppearance isKindOfClass:LNPopupBarAppearance.class])
	{
		LNPopupBarAppearance* other = (LNPopupBarAppearance*)barAppearance;
		
		for(NSString* key in __notifiedProperties) 
		{
			[self setValue:[other valueForKey:key] forKey:key];
		}
		
		[self _commonInit];
	}
	
	return self;
}

- (BOOL)isEqual:(LNPopupBarAppearance*)other
{
	if([other isKindOfClass:LNPopupBarAppearance.class] == NO)
	{
		return NO;
	}
	
	BOOL rv = [super isEqual:other];
	
	for(NSString* key in __notifiedProperties) 
	{
		id myVal = [self valueForKey:key];
		id otherVal = [other valueForKey:key];
		rv = rv && (myVal == otherVal || [myVal isEqual:otherVal]);
	}
	
	return rv;
}

- (UIVisualEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection
{
	if(_wantsDynamicFloatingBackgroundEffect == NO)
	{
		return _floatingBackgroundEffect;
	}
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26, *))
	{
		if(LNPopupEnvironmentHasGlass())
		{
			UIGlassEffect* effect = [LNPopupGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
			effect.interactive = YES;
			return effect;
		}
	}
#endif
	
	if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
	{
		return [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
	}
	
	
	return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
- (UICornerConfiguration*)floatingBackgroundCornerConfigurationForCustomBar:(BOOL)isCustomBar API_AVAILABLE(ios(26.0))
{
	if(!LNPopupEnvironmentHasGlass())
	{
		return [UICornerConfiguration configurationWithRadius:[UICornerRadius fixedRadius:0]];
	}
	
	if(self.floatingBackgroundCornerConfiguration != nil)
	{
		return self.floatingBackgroundCornerConfiguration;
	}
	
	if(isCustomBar)
	{
		return [UICornerConfiguration configurationWithUniformTopRadius:[UICornerRadius fixedRadius:12] uniformBottomRadius:[UICornerRadius containerConcentricRadiusWithMinimum:12]];
	}
	
	return [UICornerConfiguration capsuleConfiguration];
}
#endif

- (void)setFloatingBackgroundEffect:(UIBlurEffect *)floatingBackgroundEffect
{
	_wantsDynamicFloatingBackgroundEffect = NO;
	[self willChangeValueForKey:@"floatingBackgroundEffect"];
	_floatingBackgroundEffect = floatingBackgroundEffect;
	[self didChangeValueForKey:@"floatingBackgroundEffect"];
}

- (void)configureWithDefaultHighlightColor
{
	_highlightColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
		if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
		{
			return [UIColor.whiteColor colorWithAlphaComponent:0.1];
		}
		else
		{
			return [UIColor.systemGray2Color colorWithAlphaComponent:LNPopupEnvironmentHasGlass() ? 0.3 : 0.2];
		}
	}];
	
	[self _notify];
}

- (void)configureWithDefaultMarqueeScroll
{
	_marqueeScrollEnabled = YES;
	_marqueeScrollRate = 30;
	_marqueeScrollDelay = 2.0;
	_coordinateMarqueeScroll = YES;
	
	[self _notify];
}

- (void)configureWithDisabledMarqueeScroll
{
	_marqueeScrollEnabled = NO;
	
	[self _notify];
}

+ (UIColor*)_defaultProminentShadowColor
{
	return [UIColor.blackColor colorWithAlphaComponent:0.22];
}

+ (UIColor*)_defaultSecondaryShadowColor
{
	return [UIColor.blackColor colorWithAlphaComponent:0.12];
}

- (NSShadow*)_defaultImageShadow
{
	NSShadow* shadow = [NSShadow new];
	shadow.shadowColor = LNPopupBarAppearance._defaultSecondaryShadowColor;
	shadow.shadowOffset = CGSizeMake(0.0, 0.0);
	shadow.shadowBlurRadius = 3.0;
	return shadow;
}

- (void)configureWithDefaultImageShadow
{
	_imageShadow = [self _defaultImageShadow];

//	if(@available(iOS 17.0, *))
//	{
//		_imageShadow.shadowColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
//			UIColor* rv = [traitCollection objectForTrait:_LNPopupDominantColorTrait.class];
//			if(rv == nil)
//			{
//				rv = LNPopupBarAppearance._defaultSecondaryShadowColor;
//			}
//			else
//			{
//				rv = [rv colorWithAlphaComponent:0.15];
//			}
//			return rv;
//		}];
//	}
}

- (void)configureWithStaticImageShadow
{
	_imageShadow = [self _defaultImageShadow];
}

- (void)configureWithNoImageShadow
{
	_imageShadow = nil;
}

- (NSShadow*)_defaultFloatingBarBackgroundShadow
{
	if(LNPopupEnvironmentHasGlass())
	{
		NSShadow* shadow = [NSShadow new];
		shadow.shadowColor = [LNPopupBarAppearance._defaultProminentShadowColor colorWithAlphaComponent:0.17];
		shadow.shadowOffset = CGSizeMake(0.0, 8.0);
		shadow.shadowBlurRadius = 12.0;
		return shadow;
	}
	else
	{
		NSShadow* shadow = [NSShadow new];
		shadow.shadowColor = LNPopupBarAppearance._defaultProminentShadowColor;
		shadow.shadowOffset = CGSizeMake(0.0, 0.0);
		shadow.shadowBlurRadius = 8.0;
		return shadow;
	}
}

- (void)configureWithDefaultFloatingBackground
{
	if(LNPopupEnvironmentHasGlass())
	{
		self.floatingBackgroundColor = nil;
	}
	else
	{
		self.floatingBackgroundColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
			if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
			{
				return [UIColor.whiteColor colorWithAlphaComponent:0.1];
			}
			else
			{
				return UIColor.clearColor;
			}
		}];
	}
	self.floatingBackgroundImage = nil;
	
	UIVisualEffect* effect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26.0, *))
	{
		if(LNPopupEnvironmentHasGlass())
		{
			effect = [LNPopupGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
		}
		else
		{
			effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
		}
	}
	else
	{
#endif
		effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	}
#endif
	
	self.floatingBackgroundEffect = effect;
	_wantsDynamicFloatingBackgroundEffect = YES;
	self.floatingBackgroundImageContentMode = UIViewContentModeScaleToFill;
	self.floatingBarBackgroundShadow = self._defaultFloatingBarBackgroundShadow;
	
	[self _notify];
}

- (void)configureWithOpaqueFloatingBackground
{
	UIBarAppearance* temp = [UIBarAppearance new];
	[temp configureWithOpaqueBackground];
	
	self.floatingBackgroundColor = temp.backgroundColor;
	self.floatingBackgroundImage = temp.backgroundImage;
	self.floatingBackgroundEffect = temp.backgroundEffect;
	_wantsDynamicFloatingBackgroundEffect = NO;
	self.floatingBackgroundImageContentMode = temp.backgroundImageContentMode;
	self.floatingBarBackgroundShadow = self._defaultFloatingBarBackgroundShadow;
	
	[self _notify];
}

- (void)configureWithTransparentFloatingBackground;
{
	UIBarAppearance* temp = [UIBarAppearance new];
	[temp configureWithTransparentBackground];
	
	self.floatingBackgroundColor = temp.backgroundColor;
	self.floatingBackgroundImage = temp.backgroundImage;
	self.floatingBackgroundEffect = temp.backgroundEffect;
	_wantsDynamicFloatingBackgroundEffect = NO;
	self.floatingBackgroundImageContentMode = temp.backgroundImageContentMode;
	self.floatingBarBackgroundShadow = self._defaultFloatingBarBackgroundShadow;
	
	[self _notify];
}

@end

@implementation _LNPopupDominantColorTrait

+ (__kindof id<NSObject>)defaultValue
{
	return nil;
}

+ (NSString *)name
{
	return @"PopupImageDominantColor";
}

+ (BOOL)affectsColorAppearance
{
	return YES;
}

@end
