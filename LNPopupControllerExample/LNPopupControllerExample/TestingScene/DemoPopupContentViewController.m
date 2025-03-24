//
//  DemoPopupContentViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2016-08-06.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#if LNPOPUP
#import "DemoPopupContentViewController.h"
#import "SettingKeys.h"
#import "RandomColors.h"
#import "LoremIpsum.h"
#import "SafeSystemImages.h"

@import LNPopupController;

void LNApplyTitleWithSettings(UIViewController* self)
{
	uint32_t titleLowerLimit = 2;
	uint32_t titleUpperLimit = 5;
	
	uint32_t subtitleLowerLimit = 4;
	uint32_t subtitleUpperLimit = 16;
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingMarqueeEnabled] == YES)
	{
		subtitleLowerLimit = 10;
	}
	
	self.popupItem.title = [[LoremIpsum wordsWithNumber:arc4random_uniform(titleUpperLimit - titleLowerLimit) + titleLowerLimit] capitalizedString];
	self.popupItem.subtitle = [[LoremIpsum wordsWithNumber:arc4random_uniform(subtitleUpperLimit - subtitleLowerLimit) + subtitleLowerLimit] valueForKey:@"li_stringByCapitalizingFirstLetter"];
	
	if([NSUserDefaults.standardUserDefaults boolForKey:PopupSettingForceRTL])
	{
		self.popupItem.title = [self.popupItem.title stringByApplyingTransform:NSStringTransformLatinToHebrew reverse:NO];
		self.popupItem.subtitle = [self.popupItem.subtitle stringByApplyingTransform:NSStringTransformLatinToHebrew reverse:NO];
	}
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableDemoSceneColors] == NO)
	{
		self.popupItem.image = [UIImage imageNamed:@"genre7"];
	}
	else
	{
		self.popupItem.image = [UIImage imageNamed:@"genre_white"];
	}
	//	self.popupItem.progress = (float) arc4random() / UINT32_MAX;
	self.popupItem.progress = 1.0;
}

@interface DemoPopupContentView : UIView @end
@implementation DemoPopupContentView

- (void)setFrame:(CGRect)frame
{
//	NSLog(@"Frame: %@", @(frame));
	[super setFrame:frame];
}

@end

@interface DemoPopupContentViewController () @end
@implementation DemoPopupContentViewController
{
	NSInteger _lastStyle;
	LNPopupShadowedImageView* _preferredTransitionView;
	UIView* _genericTransitionView;
}

- (void)loadView
{
	self.view = [DemoPopupContentView new];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPopupItemButtonsWithTraitCollection:newCollection animated:context.animated];
		[self updateTransitionViewShadowColor];
	} completion:nil];
	
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)_updateBackgroundColor
{
	if(self.view.traitCollection.userInterfaceStyle != _lastStyle)
	{
		_lastStyle = self.view.traitCollection.userInterfaceStyle;
		
		if([NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableDemoSceneColors] == NO)
		{
			self.view.backgroundColor = LNSeedAdaptiveInvertedColor(@"Popup");
		}
		else
		{
			self.view.backgroundColor = UIColor.labelColor;
		}
	}
	
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)button:(UIBarButtonItem*)button
{
	NSLog(@"✓");
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection animated:(BOOL)animated
{
	LNSystemImageScale scale;
	LNSystemImageScale backForwardScale;
	if([[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue] == LNPopupBarStyleCompact)
	{
		scale = LNSystemImageScaleCompact;
		backForwardScale = LNSystemImageScaleCompact;
	}
	else if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		scale = LNSystemImageScaleLarger;
		backForwardScale = LNSystemImageScaleLarge;
	}
	else
	{
		scale = LNSystemImageScaleNormal;
		backForwardScale = LNSystemImageScaleNormal;
	}
	
	UIBarButtonItem* play = LNSystemBarButtonItem(@"pause.fill", scale != LNSystemImageScaleLarger ? scale + 1 : scale, self, @selector(button:));
	play.accessibilityLabel = NSLocalizedString(@"Pause", @"");
	play.accessibilityIdentifier = @"PauseButton";
	play.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* stop = LNSystemBarButtonItem(@"stop.fill", scale, self, @selector(button:));
	stop.accessibilityLabel = NSLocalizedString(@"Stop", @"");
	stop.accessibilityIdentifier = @"StopButton";
	stop.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = LNSystemBarButtonItem(@"forward.fill", backForwardScale, self, @selector(button:));
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = LNSystemBarButtonItem(@"backward.fill", backForwardScale, self, @selector(button:));
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = LNSystemBarButtonItem(@"ellipsis", scale, self, @selector(button:));
	prev.accessibilityLabel = NSLocalizedString(@"More", @"");
	prev.accessibilityIdentifier = @"MoreButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(scale == LNSystemImageScaleCompact)
	{
		if(collection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[self.popupItem setLeadingBarButtonItems:@[ play ] animated:animated];
			[self.popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
		else
		{
			[self.popupItem setLeadingBarButtonItems:@[ prev, play, next ] animated:animated];
			[self.popupItem setTrailingBarButtonItems:@[ more ] animated:animated];
		}
	}
	else
	{
		if(collection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			[self.popupItem setBarButtonItems:@[ play, next ] animated:NO];
		}
		else
		{		
			[self.popupItem setBarButtonItems:@[ prev, play, next ] animated:NO];
		}
	}
}

- (BOOL)prefersStatusBarHidden
{
	return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (void)updateTransitionViewShadowColor
{
	if(_preferredTransitionView != nil)
	{
		NSShadow* shadow = _preferredTransitionView.shadow.copy;
		
		if([NSUserDefaults.settingDefaults boolForKey:PopupSettingEnableCustomizations])
		{
			shadow.shadowColor = UIColor.yellowColor;
		}
		else
		{
			shadow.shadowColor = [UIColor.blackColor colorWithAlphaComponent:(_preferredTransitionView.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? 0.333333 : 0.666667)];
		}
		
		_preferredTransitionView.shadow = shadow;
	}
	else if(_genericTransitionView != nil)
	{
		_genericTransitionView.layer.shadowOffset = CGSizeZero;
		if([NSUserDefaults.settingDefaults boolForKey:PopupSettingEnableCustomizations])
		{
			_genericTransitionView.layer.shadowColor = UIColor.yellowColor.CGColor;
			_genericTransitionView.layer.shadowOpacity = 1.0;
		}
		else
		{
			_genericTransitionView.layer.shadowColor = UIColor.blackColor.CGColor;
			if(_genericTransitionView.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
			{
				_genericTransitionView.layer.shadowOpacity = 0.333333;
			}
			else
			{
				_genericTransitionView.layer.shadowOpacity = 0.666667;
			}
		}
	}
}

- (void)viewDidMoveToPopupContainerContentView:(LNPopupContentView *)popupContentView
{
	[super viewDidMoveToPopupContainerContentView:popupContentView];
	
	if(popupContentView == nil)
	{
		return;
	}
	
	LNApplyTitleWithSettings(self);
	
	if([NSUserDefaults.settingDefaults integerForKey:PopupSettingTransitionType] == 0)
	{
		NSShadow* shadow = [NSShadow new];
		shadow.shadowBlurRadius = 15.0;
		
		_preferredTransitionView = [[LNPopupShadowedImageView alloc] initWithImage:self.popupItem.image];
		_preferredTransitionView.shadow = shadow;
		_preferredTransitionView.cornerRadius = 30.0;
		_preferredTransitionView.translatesAutoresizingMaskIntoConstraints = NO;
		[self updateTransitionViewShadowColor];
		
		NSLayoutConstraint* leading = [_preferredTransitionView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor];
		leading.priority = UILayoutPriorityDefaultHigh;
		NSLayoutConstraint* trailing = [_preferredTransitionView.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor];
		trailing.priority = UILayoutPriorityDefaultHigh;
		
		[self.view addSubview:_preferredTransitionView];
		[NSLayoutConstraint activateConstraints:@[
			leading,
			trailing,
			[_preferredTransitionView.widthAnchor constraintLessThanOrEqualToConstant:400],
			[_preferredTransitionView.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
			[_preferredTransitionView.topAnchor constraintGreaterThanOrEqualToAnchor:popupContentView.popupCloseButton.bottomAnchor constant:20],
			[_preferredTransitionView.widthAnchor constraintEqualToAnchor:_preferredTransitionView.heightAnchor],
		]];
	}
	else if([NSUserDefaults.settingDefaults integerForKey:PopupSettingTransitionType] == 1)
	{
		UIImageView* transitionImageView = [UIImageView new];
		transitionImageView.layer.cornerRadius = 30.0;
		transitionImageView.layer.cornerCurve = kCACornerCurveContinuous;
		transitionImageView.layer.masksToBounds = YES;
		transitionImageView.translatesAutoresizingMaskIntoConstraints = NO;
		
		_genericTransitionView = [UIView new];
		_genericTransitionView.layer.shadowRadius = 15.0;
		_genericTransitionView.translatesAutoresizingMaskIntoConstraints = NO;
		[self updateTransitionViewShadowColor];
		
		[_genericTransitionView addSubview:transitionImageView];
		[NSLayoutConstraint activateConstraints:@[
			[_genericTransitionView.leadingAnchor constraintEqualToAnchor:transitionImageView.leadingAnchor],
			[_genericTransitionView.trailingAnchor constraintEqualToAnchor:transitionImageView.trailingAnchor],
			[_genericTransitionView.topAnchor constraintEqualToAnchor:transitionImageView.topAnchor],
			[_genericTransitionView.bottomAnchor constraintEqualToAnchor:transitionImageView.bottomAnchor],
		]];
		
		
		NSLayoutConstraint* leading = [_genericTransitionView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor];
		leading.priority = UILayoutPriorityDefaultHigh;
		NSLayoutConstraint* trailing = [_genericTransitionView.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor];
		trailing.priority = UILayoutPriorityDefaultHigh;
		
		[self.view addSubview:_genericTransitionView];
		[NSLayoutConstraint activateConstraints:@[
			leading,
			trailing,
			[_genericTransitionView.widthAnchor constraintLessThanOrEqualToConstant:400],
			[_genericTransitionView.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
			[_genericTransitionView.topAnchor constraintGreaterThanOrEqualToAnchor:popupContentView.popupCloseButton.bottomAnchor constant:20],
			[_genericTransitionView.widthAnchor constraintEqualToAnchor:_genericTransitionView.heightAnchor],
		]];
		
		transitionImageView.image = self.popupItem.image;
	}
	else
	{
		UILabel* topLabel = [UILabel new];
		topLabel.text = NSLocalizedString(@"Top", @"");
		topLabel.textColor = [UIColor systemBackgroundColor];
		topLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		topLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:topLabel];
		
		NSLayoutConstraint* center = [topLabel.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor];
		center.priority = 500;
		[NSLayoutConstraint activateConstraints:@[
			[topLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
			center,
			[topLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:popupContentView.popupCloseButton.trailingAnchor constant:8],
		]];
		
		UILabel* bottomLabel = [UILabel new];
		bottomLabel.text = NSLocalizedString(@"Bottom", @"");
		bottomLabel.textColor = [UIColor systemBackgroundColor];
		bottomLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:bottomLabel];
		[NSLayoutConstraint activateConstraints:@[
			[bottomLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
			[bottomLabel.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor]
		]];
		
		UILabel* leadingMarginLabel = [UILabel new];
		leadingMarginLabel.text = NSLocalizedString(@"|-Leading (Margin)", @"");
		leadingMarginLabel.textAlignment = NSTextAlignmentLeft;
		leadingMarginLabel.textColor = [UIColor systemBackgroundColor];
		leadingMarginLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		leadingMarginLabel.adjustsFontForContentSizeCategory = YES;
		//	leadingMarginLabel.adjustsFontSizeToFitWidth = YES;
		leadingMarginLabel.numberOfLines = 0;
		leadingMarginLabel.lineBreakMode = NSLineBreakByWordWrapping;
		leadingMarginLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:leadingMarginLabel];
		[NSLayoutConstraint activateConstraints:@[
			[leadingMarginLabel.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
			[leadingMarginLabel.topAnchor constraintEqualToAnchor:topLabel.bottomAnchor constant:60]
		]];
		
		UILabel* trailingMarginLabel = [UILabel new];
		trailingMarginLabel.text = NSLocalizedString(@"Trailing (Margin)-|", @"");
		trailingMarginLabel.textAlignment = NSTextAlignmentRight;
		trailingMarginLabel.textColor = [UIColor systemBackgroundColor];
		trailingMarginLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		trailingMarginLabel.adjustsFontForContentSizeCategory = YES;
		//	trailingMarginLabel.adjustsFontSizeToFitWidth = YES;
		trailingMarginLabel.numberOfLines = 0;
		trailingMarginLabel.lineBreakMode = NSLineBreakByWordWrapping;
		trailingMarginLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:trailingMarginLabel];
		[NSLayoutConstraint activateConstraints:@[
			[trailingMarginLabel.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
			[trailingMarginLabel.topAnchor constraintEqualToAnchor:topLabel.bottomAnchor constant:60],
			[trailingMarginLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:leadingMarginLabel.trailingAnchor constant:8],
			[trailingMarginLabel.widthAnchor constraintEqualToAnchor:leadingMarginLabel.widthAnchor]
		]];
		
		UILabel* leadingSafeAreaLabel = [UILabel new];
		leadingSafeAreaLabel.text = NSLocalizedString(@"|-Leading (Safe Area)", @"");
		leadingSafeAreaLabel.textAlignment = NSTextAlignmentLeft;
		leadingSafeAreaLabel.textColor = [UIColor systemBackgroundColor];
		leadingSafeAreaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		leadingSafeAreaLabel.adjustsFontForContentSizeCategory = YES;
		//	leadingSafeAreaLabel.adjustsFontSizeToFitWidth = YES;
		leadingSafeAreaLabel.numberOfLines = 0;
		leadingSafeAreaLabel.lineBreakMode = NSLineBreakByWordWrapping;
		leadingSafeAreaLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:leadingSafeAreaLabel];
		[NSLayoutConstraint activateConstraints:@[
			[leadingSafeAreaLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[leadingSafeAreaLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:0]
		]];
		
		UILabel* trailingSafeAreaLabel = [UILabel new];
		trailingSafeAreaLabel.text = NSLocalizedString(@"Trailing (Safe Area)-|", @"");
		trailingSafeAreaLabel.textAlignment = NSTextAlignmentRight;
		trailingSafeAreaLabel.textColor = [UIColor systemBackgroundColor];
		trailingSafeAreaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		trailingSafeAreaLabel.adjustsFontForContentSizeCategory = YES;
		//	trailingSafeAreaLabel.adjustsFontSizeToFitWidth = YES;
		trailingSafeAreaLabel.numberOfLines = 0;
		trailingSafeAreaLabel.lineBreakMode = NSLineBreakByWordWrapping;
		trailingSafeAreaLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:trailingSafeAreaLabel];
		[NSLayoutConstraint activateConstraints:@[
			[trailingSafeAreaLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[trailingSafeAreaLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:0],
			[trailingSafeAreaLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:leadingSafeAreaLabel.trailingAnchor constant:8],
			[trailingSafeAreaLabel.widthAnchor constraintEqualToAnchor:leadingSafeAreaLabel.widthAnchor]
		]];
		
		self.popupItem.accessibilityLabel = NSLocalizedString(@"Custom popup bar accessibility label", @"");
		self.popupItem.accessibilityHint = NSLocalizedString(@"Custom popup bar accessibility hint", @"");
		
	}
		
	[self _updateBackgroundColor];
		
//	UIButton* customCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
//	[customCloseButton setTitle:NSLocalizedString(@"Custom Close Button", @"") forState:UIControlStateNormal];
//	customCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
//	[customCloseButton setTitleColor:UIColor.systemBackgroundColor forState:UIControlStateNormal];
//	customCloseButton.pointerInteractionEnabled = YES;
//	[customCloseButton addTarget:self action:@selector(_closePopup) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:customCloseButton];
//	[NSLayoutConstraint activateConstraints:@[
//		[self.view.safeAreaLayoutGuide.centerXAnchor constraintEqualToAnchor:customCloseButton.centerXAnchor],
//		[self.view.safeAreaLayoutGuide.centerYAnchor constraintEqualToAnchor:customCloseButton.centerYAnchor],
//	]];
}

- (nullable UIView*)viewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState
{
	switch([NSUserDefaults.settingDefaults integerForKey:PopupSettingTransitionType])
	{
		case 0:
			return _preferredTransitionView;
		case 1:
			return _genericTransitionView;
		default:
			return nil;
	}
}

- (void)_closePopup
{
	[self.popupPresentationContainerViewController closePopupAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingEnableTransition] == NO)
//	{
//		return;
//	}
//	
//	[UIView performWithoutAnimation:^{
//		self.view.alpha = 0.0;
//	}];
//	
//	self.view.alpha = 1.0;
}

- (void)viewIsAppearing:(BOOL)animated
{
	[super viewIsAppearing:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
//	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingEnableTransition] == NO)
//	{
//		return;
//	}
//	
//	[UIView performWithoutAnimation:^{
//		self.view.alpha = 1.0;
//	}];
//	
//	self.view.alpha = 0.0;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
}

- (void)viewLayoutMarginsDidChange
{
	[super viewLayoutMarginsDidChange];
}

- (void)dealloc
{
	
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;//Slide;
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
	return YES;
}

@end

#endif
