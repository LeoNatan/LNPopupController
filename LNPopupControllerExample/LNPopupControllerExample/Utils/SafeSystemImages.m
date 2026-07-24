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
#import "LNPopupDemoContextMenuInteraction.h"
@import AVKit;

extern BOOL LNPopupSettingsIsCatalyst(void);

BOOL LNBarIsClassicCompact(LNPopupBar* bar)
{
	return bar.effectiveBarStyle == LNPopupBarStyleCompact;
}

BOOL LNBarIsFloatingCompact(LNPopupBar* bar)
{
	return bar.effectiveBarStyle == LNPopupBarStyleFloatingCompact && !LNPopupSettingsIsCatalyst();
}

void LNPopupItemSetStandardMusicControls(LNPopupItem* popupItem, LNPopupBar* popupBar, BOOL isPlay, BOOL animated, UITraitCollection* traitCollection, UIAction* prevAction, UIAction* playPauseAction, UIAction* nextAction)
{
	LNSystemImageScale playPauseScale;
	LNSystemImageScale otherScale;
	
	BOOL isClassicCompact = LNBarIsClassicCompact(popupBar);
	BOOL isFloatingCompact = LNBarIsFloatingCompact(popupBar);
	BOOL isLargeEnvironment = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && !isFloatingCompact) || LNPopupSettingsIsCatalyst();
	
	if(isLargeEnvironment)
	{
		playPauseScale = LNSystemImageScaleLarger;
		otherScale = LNSystemImageScaleNormal;
	}
	else if(isClassicCompact)
	{
		playPauseScale = LNSystemImageScaleCompact;
		otherScale = LNSystemImageScaleCompact;
	}
	else if(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular || isFloatingCompact == NO)
	{
		playPauseScale = traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact || isFloatingCompact ? LNSystemImageScaleLarge : LNSystemImageScaleLarger;
		otherScale = LNSystemImageScaleNormal;
	}
	else
	{
		playPauseScale = LNSystemImageScaleNormal;
		otherScale = LNSystemImageScaleNormal;
	}
	
	UIBarButtonItem* shuffle = LNSystemBarButtonItemAction(@"shuffle", LNSystemImageScaleExtraCompact, nil);
#if TARGET_OS_MACCATALYST
	shuffle.tintColor = UIColor.tertiaryLabelColor;
#endif
	shuffle.accessibilityLabel = NSLocalizedString(@"Shuffle", @"");
	shuffle.accessibilityIdentifier = @"Shuffle";
	shuffle.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* repeat = LNSystemBarButtonItemAction(@"repeat", LNSystemImageScaleExtraCompact, nil);
#if TARGET_OS_MACCATALYST
	repeat.tintColor = UIColor.tertiaryLabelColor;
#endif
	repeat.accessibilityLabel = NSLocalizedString(@"Repeat", @"");
	repeat.accessibilityIdentifier = @"Repeat";
	repeat.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* playPause = LNSystemBarButtonItemAction(isPlay ? @"play.fill" : @"pause.fill", playPauseScale, playPauseAction);
	playPause.accessibilityLabel = NSLocalizedString(isPlay ? @"Play" : @"Pause", @"");
	playPause.accessibilityIdentifier = @"PlayPauseButton";
	playPause.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = LNSystemBarButtonItemAction(@"forward.fill", otherScale, nextAction);
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = LNSystemBarButtonItemAction(@"backward.fill", otherScale, prevAction);
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = LNSystemBarButtonItemAction(@"ellipsis", otherScale, nil);
	more.menu = [LNPopupDemoContextMenuInteraction menuWithTitle:NO sourceItemForShare:more];
	more.accessibilityLabel = NSLocalizedString(@"More", @"");
	more.accessibilityIdentifier = @"More";
	more.accessibilityTraits = UIAccessibilityTraitButton;
	
	AVRoutePickerView* routePickerView = [AVRoutePickerView new];
	UIBarButtonItem* airplay = [[UIBarButtonItem alloc] initWithCustomView:routePickerView];
	airplay.accessibilityLabel = NSLocalizedString(@"Airplay", @"");
	airplay.accessibilityIdentifier = @"Airplay";
	airplay.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* volume = LNSystemBarButtonItemAction(@"speaker.wave.2.fill", otherScale, nil);
	volume.accessibilityLabel = NSLocalizedString(@"Volume", @"");
	volume.accessibilityIdentifier = @"Volume";
	volume.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(traitCollection.popupBarEnvironment == LNPopupBarEnvironmentInline)
	{
		[popupItem setTrailingBarButtonItems:@[ playPause ] animated:animated];
	}
	else if(isClassicCompact)
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
			[popupItem setLeadingBarButtonItems:@[] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ playPause, next ] animated:animated];
		}
		else if(isLargeEnvironment)
		{
			[popupItem setLeadingBarButtonItems:@[ shuffle, prev, playPause, next, repeat ] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ more, airplay, volume ] animated:animated];
		}
		else
		{
			[popupItem setLeadingBarButtonItems:@[] animated:animated];
			[popupItem setTrailingBarButtonItems:@[ prev, playPause, next ] animated:animated];
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
			@(LNSystemImageScaleExtraCompact): [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall],
			@(LNSystemImageScaleCompact): [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium],
			@(LNSystemImageScaleNormal): [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleHeadline scale:UIImageSymbolScaleLarge],
			@(LNSystemImageScaleLarge): [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle2 scale:UIImageSymbolScaleLarge],
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
			@(LNSystemImageScaleLarge): @(28),
			@(LNSystemImageScaleLarger): @(30),
		};
	});
	
	return [widthMap[@(scale)] doubleValue];
}

@interface LNLargeButtonItem: UIBarButtonItem @end
@implementation LNLargeButtonItem
{
	UIButton* _button;
	LNSystemImageScale _scale;
}

- (instancetype)initWithButton:(UIButton*)button scale:(LNSystemImageScale)scale
{
	self = [super initWithCustomView:button];
	
	if(self)
	{
		_button = button;
		_scale = scale;
		
		_button.preferredBehavioralStyle = UIBehavioralStylePad;
	}
	
	return self;
}

- (void)setImage:(UIImage *)image
{
	if(image.isSymbolImage)
	{
		NSString* name = [image valueForKeyPath:@"imageAsset.assetName"];
		
		[_button setImage:LNSystemImage(name, _scale) forState:UIControlStateNormal];
	}
	else
	{
		[_button setImage:image forState:UIControlStateNormal];
	}
}

- (void)setSymbolImage:(UIImage *)symbolImage withContentTransition:(NSSymbolContentTransition *)transition options:(nonnull NSSymbolEffectOptions *)options
{
	if(symbolImage.isSymbolImage)
	{
		NSString* name = [symbolImage valueForKeyPath:@"imageAsset.assetName"];
		symbolImage = LNSystemImage(name, _scale);
		
		[_button.imageView setSymbolImage:symbolImage withContentTransition:transition options:options];
	}
	
	[_button setImage:symbolImage forState:UIControlStateNormal];
}

@end

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
		
		rv = [[LNLargeButtonItem alloc] initWithButton:button scale:scale];
	}
	else{
		rv = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(name, scale) style:UIBarButtonItemStylePlain target:target action:action];
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
			[button.widthAnchor constraintEqualToConstant:_LNWidthForScale(scale)],
		]];
		
		rv = [[LNLargeButtonItem alloc] initWithButton:button scale:scale];
	}
	else{
		rv = [[UIBarButtonItem alloc] initWithPrimaryAction:primaryAction];
		rv.image = LNSystemImage(name, scale);
	}
	return rv;
}
