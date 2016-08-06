//
//  RandomColors.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import UIKit;

UIColor* LNRandomDarkColor()
{
	CGFloat hue = ( arc4random() % 256 / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 0.1 + ( arc4random() % 64 / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

UIColor* LNRandomLightColor()
{
	CGFloat hue = ( arc4random() % 256 / 256.0 );
	CGFloat saturation = 0.5;
	CGFloat brightness = 1.0 - ( arc4random() % 64 / 256.0 );
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
