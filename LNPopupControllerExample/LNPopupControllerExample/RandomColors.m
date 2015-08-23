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
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.7;
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.2;
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

UIColor* LNRandomLightColor()
{
	CGFloat hue = ( arc4random() % 256 / 256.0 );
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.1;
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.7;
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}