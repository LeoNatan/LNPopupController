//
//  RandomColors.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import UIKit;
#import "RandomColors.h"

static NSMutableArray<UIColor*>* namedSystemColors;
static NSUInteger lastNamedSystemColorIdx = 0;

__attribute__((constructor))
static void LNInitializeDemoColors(void)
{
	namedSystemColors = @[
		UIColor.systemRedColor,
		UIColor.systemGreenColor,
		UIColor.systemBlueColor,
		UIColor.systemOrangeColor,
		UIColor.systemYellowColor,
		UIColor.systemPinkColor,
		UIColor.systemPurpleColor,
		UIColor.systemTealColor,
	].mutableCopy;
	if (@available(iOS 13.0, *))
	{
		[namedSystemColors addObject:UIColor.systemIndigoColor];
	}
}

UIColor* LNRandomSystemColor(void)
{
//	return namedSystemColors[arc4random_uniform((uint32_t)namedSystemColors.count)];
	
	NSUInteger rv = lastNamedSystemColorIdx;
	lastNamedSystemColorIdx = (lastNamedSystemColorIdx + 1) % namedSystemColors.count;
	return namedSystemColors[rv];
}

UIColor* _LNSeedDarkColor(long seed)
{
	srand48(seed);
	CGFloat hue = drand48();
	CGFloat saturation = 0.5;
	CGFloat brightness = 0.3 + 0.1 * drand48();
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

UIColor* _LNSeedLightColor(long seed)
{
	srand48(seed);
	CGFloat hue = drand48();
	CGFloat saturation = 0.5;
	CGFloat brightness = 1.0 - 0.1 * drand48();
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

API_AVAILABLE(ios(13.0))
UIColor* _LNSeedAdaptiveColor(long seed)
{
	UIColor* light = _LNSeedLightColor(seed);
	UIColor* dark = _LNSeedDarkColor(seed);
	return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull collection) {
		if(collection.userInterfaceStyle == UIUserInterfaceStyleDark)
		{
			return dark;
		}
		else
		{
			return light;
		}
	}];
}

API_AVAILABLE(ios(13.0))
UIColor* _LNSeedAdaptiveInvertedColor(long seed)
{
	UIColor* light = _LNSeedLightColor(seed);
	UIColor* dark = _LNSeedDarkColor(seed);
	return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull collection) {
		if(collection.userInterfaceStyle == UIUserInterfaceStyleDark)
		{
			return light;
		}
		else
		{
			return dark;
		}
	}];
}


API_AVAILABLE(ios(13.0))
UIColor* LNRandomAdaptiveColor(void)
{
	return _LNSeedAdaptiveColor(arc4random());
}

API_AVAILABLE(ios(13.0))
UIColor* LNRandomAdaptiveInvertedColor(void)
{
	return _LNSeedAdaptiveInvertedColor(arc4random());
}

API_AVAILABLE(ios(13.0))
UIColor* LNSeedAdaptiveColor(NSString* seed)
{
	return _LNSeedAdaptiveColor(seed.hash);
}

API_AVAILABLE(ios(13.0))
UIColor* LNSeedAdaptiveInvertedColor(NSString* seed)
{
	return _LNSeedAdaptiveInvertedColor(seed.hash);
}

UIColor* LNRandomDarkColor(void)
{
	return _LNSeedDarkColor(arc4random());
}

UIColor* LNRandomLightColor(void)
{
	return _LNSeedLightColor(arc4random());
}

UIColor* LNSeedDarkColor(NSString* seed)
{
	return _LNSeedDarkColor(seed.hash);
}

UIColor* LNSeedLightColor(NSString* seed)
{
	return _LNSeedLightColor(seed.hash);
}
