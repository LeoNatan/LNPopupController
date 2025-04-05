//
//  SafeSystemImages.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-09-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#include "SafeSystemImages.h"

UIImage* LNSystemImage(NSString* named, LNSystemImageScale scale)
{
	static NSDictionary<NSNumber*, UIImageSymbolConfiguration*>* configMap;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		configMap = @{
			@(LNSystemImageScaleCompact): [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium],
			@(LNSystemImageScaleNormal): [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleHeadline scale:UIImageSymbolScaleLarge],
			@(LNSystemImageScaleLarge): [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle3 scale:UIImageSymbolScaleLarge],
			@(LNSystemImageScaleLarger): [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle1 scale:UIImageSymbolScaleLarge],
		};
	});
	
	UIImageSymbolConfiguration* config = configMap[@(scale)];
	return [UIImage systemImageNamed:named withConfiguration:config];
}

CGFloat _LNWidthForScale(LNSystemImageScale scale)
{
	static NSDictionary<NSNumber*, NSNumber*>* widthMap;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		widthMap = @{
			@(LNSystemImageScaleCompact): @(44),
			@(LNSystemImageScaleNormal): @(60),
			@(LNSystemImageScaleLarge): @(60),
			@(LNSystemImageScaleLarger): @(62),
		};
	});
	
	return [widthMap[@(scale)] doubleValue];
}

UIBarButtonItem* LNSystemBarButtonItem(NSString* name, LNSystemImageScale scale, id target, SEL action)
{
	UIBarButtonItem* rv;
	if(scale > LNSystemImageScaleNormal)
	{
		UIButtonConfiguration* config = [UIButtonConfiguration plainButtonConfiguration];
		config.image = LNSystemImage(name, scale);
		
		UIButton* button = [UIButton buttonWithConfiguration:config primaryAction:nil];
		[button addTarget:target action:action forControlEvents:UIControlEventPrimaryActionTriggered];
		
		button.translatesAutoresizingMaskIntoConstraints = NO;
		[NSLayoutConstraint activateConstraints:@[
			[button.widthAnchor constraintEqualToConstant:_LNWidthForScale(scale)]
		]];
		
		rv = [[UIBarButtonItem alloc] initWithCustomView:button];
	}
	else{
		rv = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(name, scale) style:UIBarButtonItemStylePlain target:target action:action];
		rv.width = _LNWidthForScale(scale);
	}
	return rv;
}

UIBarButtonItem* LNSystemBarButtonItemAction(NSString* name, LNSystemImageScale scale, UIAction* primaryAction)
{
	UIBarButtonItem* rv;
	if(scale > LNSystemImageScaleNormal)
	{
		UIButtonConfiguration* config = [UIButtonConfiguration plainButtonConfiguration];
		config.image = LNSystemImage(name, scale);
		
		UIButton* button = [UIButton buttonWithConfiguration:config primaryAction:primaryAction];
		
		button.translatesAutoresizingMaskIntoConstraints = NO;
		[NSLayoutConstraint activateConstraints:@[
			[button.widthAnchor constraintEqualToConstant:_LNWidthForScale(scale)]
		]];
		
		rv = [[UIBarButtonItem alloc] initWithCustomView:button];
	}
	else{
		rv = [[UIBarButtonItem alloc] initWithPrimaryAction:primaryAction];
		rv.image = LNSystemImage(name, scale);
		rv.width = _LNWidthForScale(scale);
	}
	return rv;
}
