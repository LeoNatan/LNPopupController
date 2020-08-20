//
//  RandomColors.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import UIKit;
#import "RandomColors.h"

static UIColor* demoLightColor;
static UIColor* demoDarkColor;
static NSMutableArray<UIColor*>* namedSystemColors;
static NSUInteger lastNamedSystemColorIdx = 0;

__attribute__((constructor))
static void LNInitializeDemoColors(void)
{
	demoLightColor = [UIColor colorWithRed:0.631372549 green:0.8666666667 blue:0.4470588235 alpha:1.0];
	demoDarkColor = [UIColor colorWithRed:0.1215686275 green:0.0862745098 blue:0.168627451 alpha:1.0];
	
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

API_AVAILABLE(ios(13.0))
UIColor* LNRandomAdaptiveColor(void)
{
	UIColor* light = LNRandomLightColor();
	UIColor* dark = LNRandomDarkColor();
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
UIColor* LNRandomAdaptiveInvertedColor(void)
{
	UIColor* light = LNRandomLightColor();
	UIColor* dark = LNRandomDarkColor();
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

UIColor* LNRandomDarkColor(void)
{
	static BOOL shouldProvideDemoColor = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shouldProvideDemoColor = [NSUserDefaults.standardUserDefaults boolForKey:@"LNUseDemoRandomColors"];
	});
	
	if(shouldProvideDemoColor)
	{
		return demoDarkColor;
	}
	
	CGFloat hue = ( arc4random_uniform(256) / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 0.1 + ( arc4random_uniform(64) / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

UIColor* LNRandomLightColor(void)
{
	static BOOL shouldProvideDemoColor = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shouldProvideDemoColor = [NSUserDefaults.standardUserDefaults boolForKey:@"LNUseDemoRandomColors"];
	});
	
	if(shouldProvideDemoColor)
	{
		return demoLightColor;
	}
	
	CGFloat hue = ( arc4random_uniform(256) / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 1.0 - ( arc4random_uniform(64) / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
