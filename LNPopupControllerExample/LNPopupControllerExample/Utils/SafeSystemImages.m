//
//  SafeSystemImages.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-09-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#include "SafeSystemImages.h"

#if LNPOPUP
#import "SettingKeys.h"
#import <LNPopupController/LNPopupController.h>

BOOL LNBarIsCompact(void)
{
	BOOL isCompact = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleCompact ||
	[[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleFloatingCompact ||
	([[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleDefault &&
	 LNPopupSettingsHasOS26Glass() &&
	 UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad);
	
	return isCompact;
}

BOOL LNBarIsFloatingCompact(void)
{
	BOOL isFloatingCompact = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleFloatingCompact ||
	([[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleDefault &&
	 LNPopupSettingsHasOS26Glass() &&
	 UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad);
	
	return isFloatingCompact;
}

void LNPopupItemSetStandardMusicControls(LNPopupItem* popupItem, BOOL animated, UITraitCollection* traitCollection, id target, SEL action)
{
	LNSystemImageScale scale;
	LNSystemImageScale backForwardScale;
	
	BOOL isCompact = LNBarIsCompact();
	BOOL isFloatingCompact = LNBarIsFloatingCompact();
	
	if(isCompact)
	{
		scale = LNSystemImageScaleCompact;
		backForwardScale = LNSystemImageScaleCompact;
	}
	else if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		scale = LNSystemImageScaleLarger;
		backForwardScale = LNSystemImageScaleLarge;
	}
	else
	{
		scale = LNSystemImageScaleNormal;
		backForwardScale = LNSystemImageScaleNormal;
	}
	
	UIBarButtonItem* play = LNSystemBarButtonItem(@"pause.fill", scale != LNSystemImageScaleLarger ? scale + 1 : scale, target, action);
	play.accessibilityLabel = NSLocalizedString(@"Pause", @"");
	play.accessibilityIdentifier = @"PauseButton";
	play.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* stop = LNSystemBarButtonItem(@"stop.fill", scale, target, action);
	stop.accessibilityLabel = NSLocalizedString(@"Stop", @"");
	stop.accessibilityIdentifier = @"StopButton";
	stop.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = LNSystemBarButtonItem(@"forward.fill", backForwardScale, target, action);
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = LNSystemBarButtonItem(@"backward.fill", backForwardScale, target, action);
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = LNSystemBarButtonItem(@"ellipsis", scale, target, action);
	prev.accessibilityLabel = NSLocalizedString(@"More", @"");
	prev.accessibilityIdentifier = @"MoreButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(isCompact && !isFloatingCompact)
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setLeadingBarButtonItems:@[ play ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
		else
		{
			[popupItem setLeadingBarButtonItems:@[ prev, play, next ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
	}
	else
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setBarButtonItems:@[ play, next ] animated:NO];
		}
		else
		{
			[popupItem setBarButtonItems:@[ prev, play, next ] animated:NO];
		}
	}
}

#endif

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
		UIButton* button = [UIButton systemButtonWithImage:LNSystemImage(name, scale) target:target action:action];
		
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
		UIButton* button = [UIButton systemButtonWithPrimaryAction:primaryAction];
		[button setImage:LNSystemImage(name, scale) forState:UIControlStateNormal];
		
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
