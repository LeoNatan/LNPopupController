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

void LNPopupItemSetStandardMusicControls(LNPopupItem* popupItem, BOOL isPlay, BOOL animated, UITraitCollection* traitCollection, UIAction* prevAction, UIAction* playPauseAction, UIAction* nextAction)
{
	LNSystemImageScale scale;
	LNSystemImageScale backForwardScale;
	
	BOOL isCompact = LNBarIsCompact();
	BOOL isFloatingCompact = LNBarIsFloatingCompact();
	
	if(isCompact && !isFloatingCompact)
	{
		scale = LNSystemImageScaleCompact;
		backForwardScale = LNSystemImageScaleCompact;
	}
	else if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		scale = isFloatingCompact ? LNSystemImageScaleLarge : LNSystemImageScaleLarger;
		backForwardScale = LNSystemImageScaleNormal;
	}
	else
	{
		scale = LNSystemImageScaleNormal;
		backForwardScale = LNSystemImageScaleNormal;
	}
	
	UIBarButtonItem* pause = LNSystemBarButtonItemAction(@"pause.fill", scale, playPauseAction);
	pause.accessibilityLabel = NSLocalizedString(@"Pause", @"");
	pause.accessibilityIdentifier = @"PauseButton";
	pause.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* play = LNSystemBarButtonItemAction(@"play.fill", scale, playPauseAction);
	pause.accessibilityLabel = NSLocalizedString(@"Play", @"");
	pause.accessibilityIdentifier = @"PlayButton";
	pause.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = LNSystemBarButtonItemAction(@"forward.fill", backForwardScale, nextAction);
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = LNSystemBarButtonItemAction(@"backward.fill", backForwardScale, prevAction);
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = LNSystemBarButtonItemAction(@"ellipsis", LNSystemImageScaleNormal, nil);
	prev.accessibilityLabel = NSLocalizedString(@"More", @"");
	prev.accessibilityIdentifier = @"MoreButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(isCompact && !isFloatingCompact)
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setLeadingBarButtonItems:@[ isPlay ? play : pause ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
		else
		{
			[popupItem setLeadingBarButtonItems:@[ prev, isPlay ? play : pause, next ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
	}
	else
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setBarButtonItems:@[ isPlay ? play : pause, next ] animated:animated];
		}
		else
		{
			[popupItem setBarButtonItems:@[ prev, isPlay ? play : pause, next ] animated:animated];
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
			@(LNSystemImageScaleNormal): @(44),
			@(LNSystemImageScaleLarge): @(44),
			@(LNSystemImageScaleLarger): @(44),
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
//		rv.width = _LNWidthForScale(scale);
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
//		rv.width = _LNWidthForScale(scale);
	}
	return rv;
}
