//
//  _LNPopupBarAppearanceLegacySupport.m
//  LNPopupController
//
//  Created by Leo Natan on 09/01/2024.
//  Copyright © 2024 Leo Natan. All rights reserved.
//

#import "_LNPopupBarAppearanceLegacySupport.h"

@implementation _LNPopupBarAppearanceLegacySupport
{
	BOOL _wantsDynamicFloatingBackgroundEffect;
}

@synthesize floatingBackgroundEffect=_floatingBackgroundEffect;

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		self.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
		self.backgroundColor = nil;
		self.backgroundImage = nil;
		self.shadowColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
		self.shadowImage = nil;
		
		[self configureWithDefaultImageShadow];
		[self configureWithDefaultHighlightColor];
		[self configureWithDefaultMarqueeScroll];
		[self configureWithDisabledMarqueeScroll];
		
		[self configureWithDefaultFloatingBackground];
	}
	
	return self;
}

- (UIBlurEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection
{
	if(_wantsDynamicFloatingBackgroundEffect == NO)
	{
		return _floatingBackgroundEffect;
	}
	
	if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
	{
		return [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
	}
	
	
	return [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
}

- (void)setFloatingBackgroundEffect:(UIBlurEffect *)floatingBackgroundEffect
{
	_wantsDynamicFloatingBackgroundEffect = NO;
	[self willChangeValueForKey:@"floatingBackgroundEffect"];
	_floatingBackgroundEffect = floatingBackgroundEffect;
	[self didChangeValueForKey:@"floatingBackgroundEffect"];
}

- (void)configureWithDefaultHighlightColor
{
	_highlightColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.2];
}

- (void)configureWithDefaultMarqueeScroll
{
	_marqueeScrollEnabled = YES;
	_marqueeScrollRate = 30;
	_marqueeScrollDelay = 2.0;
	_coordinateMarqueeScroll = YES;
}

- (void)configureWithDisabledMarqueeScroll
{
	_marqueeScrollEnabled = NO;
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
	shadow.shadowColor = _LNPopupBarAppearanceLegacySupport._defaultSecondaryShadowColor;
	shadow.shadowOffset = CGSizeMake(0.0, 0.0);
	shadow.shadowBlurRadius = 3.0;
	return shadow;
}

- (void)configureWithDefaultImageShadow
{
	_imageShadow = [self _defaultImageShadow];
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
	NSShadow* shadow = [NSShadow new];
	shadow.shadowColor = _LNPopupBarAppearanceLegacySupport._defaultProminentShadowColor;
	shadow.shadowOffset = CGSizeMake(0.0, 0.0);
	shadow.shadowBlurRadius = 8.0;
	return shadow;
}

- (void)configureWithDefaultFloatingBackground
{
	self.floatingBackgroundColor = UIColor.clearColor;
	self.floatingBackgroundImage = nil;
	self.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
	_wantsDynamicFloatingBackgroundEffect = YES;
	self.floatingBackgroundImageContentMode = UIViewContentModeScaleToFill;
	self.floatingBarBackgroundShadow = self._defaultFloatingBarBackgroundShadow;
}

@end
