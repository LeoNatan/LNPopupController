//
//  RandomColors.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import UIKit;
#import "RandomColors.h"

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
	CGFloat hue = ( arc4random() % 256 / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 0.1 + ( arc4random() % 64 / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

UIColor* LNRandomLightColor(void)
{
	CGFloat hue = ( arc4random() % 256 / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 1.0 - ( arc4random() % 64 / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
