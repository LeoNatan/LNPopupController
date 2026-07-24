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
	
	UIBarButtonItem* playPause = LNSystemBarButtonItemAction(isPlay ? @"play.fill" : @"pause.fill", scale, playPauseAction);
	playPause.accessibilityLabel = NSLocalizedString(isPlay ? @"Play" : @"Pause", @"");
	playPause.accessibilityIdentifier = @"PlayPauseButton";
	playPause.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = LNSystemBarButtonItemAction(@"forward.fill", backForwardScale, nextAction);
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = LNSystemBarButtonItemAction(@"backward.fill", backForwardScale, prevAction);
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = LNSystemBarButtonItemAction(@"ellipsis", LNSystemImageScaleNormal, nil);
	more.accessibilityLabel = NSLocalizedString(@"More", @"");
	more.accessibilityIdentifier = @"MoreButton";
	more.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(isCompact && !isFloatingCompact)
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setLeadingBarButtonItems:@[ playPause ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
		else
		{
			[popupItem setLeadingBarButtonItems:@[ prev, playPause, next ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
	}
	else
	{
		if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[popupItem setBarButtonItems:@[ playPause, next ] animated:animated];
		}
		else
		{
			[popupItem setBarButtonItems:@[ prev, playPause, next ] animated:animated];
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

@interface LNLargeButtonItem: UIBarButtonItem @end
@implementation LNLargeButtonItem
{
	UIButton* _button;
	LNSystemImageScale _scale;
}

+ (UIButtonConfiguration*)buttonConfiguration
{
	UIButtonConfiguration* config = [UIButtonConfiguration tintedButtonConfiguration];
	UIBackgroundConfiguration* background = [UIBackgroundConfiguration clearConfiguration];
	background.backgroundColor = UIColor.clearColor;
	config.background = background;
	return config;
}

- (instancetype)initWithButton:(UIButton*)button scale:(LNSystemImageScale)scale
{
	self = [super initWithCustomView:button];
	
	if(self)
	{
		_button = button;
		_scale = scale;
	}
	
	return self;
}

- (void)_updateConfig:(UIButtonConfiguration*)config fromImage:(UIImage*)image
{
	if(image.isSymbolImage)
	{
		NSString* name = [image valueForKeyPath:@"imageAsset.assetName"];
		config.image = LNSystemImage(name, _scale);
	}
	else
	{
		config.image = image;
	}
}

- (void)setImage:(UIImage *)image
{
	UIButtonConfiguration* config = [LNLargeButtonItem buttonConfiguration];
	[self _updateConfig:config fromImage:image];
	_button.configuration = config;
}

- (void)setSymbolImage:(UIImage *)symbolImage withContentTransition:(NSSymbolContentTransition *)transition options:(nonnull NSSymbolEffectOptions *)options
{
	UIButtonConfiguration* config = [LNLargeButtonItem buttonConfiguration];
	[self _updateConfig:config fromImage:symbolImage];
	if(@available(iOS 26.0, *))
	{
		config.symbolContentTransition = [UISymbolContentTransition transitionWithContentTransition:transition options:options];
	}
	_button.configuration = config;
}

@end

UIBarButtonItem* LNSystemBarButtonItemAction(NSString* name, LNSystemImageScale scale, UIAction* primaryAction)
{
	UIBarButtonItem* rv;
	if(scale > LNSystemImageScaleNormal)
	{
		UIButton* button = [UIButton systemButtonWithPrimaryAction:primaryAction];
		UIButtonConfiguration* config = [LNLargeButtonItem buttonConfiguration];
		config.image = LNSystemImage(name, scale);
		button.configuration = config;
		
		button.translatesAutoresizingMaskIntoConstraints = NO;
		[NSLayoutConstraint activateConstraints:@[
			[button.widthAnchor constraintEqualToConstant:_LNWidthForScale(scale)]
		]];
		
		rv = [[LNLargeButtonItem alloc] initWithButton:button scale:scale];
	}
	else{
		rv = [[UIBarButtonItem alloc] initWithPrimaryAction:primaryAction];
		rv.image = LNSystemImage(name, scale);
//		rv.width = _LNWidthForScale(scale);
	}
	return rv;
}
