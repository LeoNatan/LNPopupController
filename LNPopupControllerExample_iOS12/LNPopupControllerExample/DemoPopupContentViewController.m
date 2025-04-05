//
//  DemoPopupContentViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 6/8/16.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#if LNPOPUP
#import "DemoPopupContentViewController.h"
#import "SettingsTableViewController.h"
#import "RandomColors.h"

@import LNPopupController;

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
}

- (void)loadView
{
	self.view = [DemoPopupContentView new];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPopupItemButtonsWithTraitCollection:newCollection animated:context.animated];
	} completion:nil];
	
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)_updateBackgroundColor
{
	if(@available(iOS 13.0, *)) {
		if(self.view.traitCollection.userInterfaceStyle != _lastStyle)
		{
			_lastStyle = self.view.traitCollection.userInterfaceStyle;
			self.view.backgroundColor = LNSeedAdaptiveInvertedColor(@"Popup");
		}
	}
	else
	{
		if(_lastStyle == 0)
		{
			_lastStyle++;
			self.view.backgroundColor = LNSeedDarkColor(@"Popup");
		}
	}
	
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)button:(UIBarButtonItem*)button
{
	NSLog(@"✓");
}

UIImage* LNSystemImage(NSString* named)
{
	if (@available(iOS 13.0, *))
	{
		static UIImageSymbolConfiguration* largeConfig = nil;
		static UIImageSymbolConfiguration* compactConfig = nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			largeConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleUnspecified];
			compactConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium];
		});
		
		UIImageSymbolConfiguration* config;
		if([[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue] == LNPopupBarStyleCompact)
		{
			config = compactConfig;
		}
		else
		{
			config = largeConfig;
		}
		
		return [UIImage systemImageNamed:named withConfiguration:config];
	}
	else
	{
		UIImage* rv = [UIImage imageNamed:named];
		
		if(rv != nil)
		{
			return rv;
		}
		
		return [UIImage imageNamed:@"gears"];
	}
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection animated:(BOOL)animated
{
	BOOL useCompact = [[NSUserDefaults.standardUserDefaults objectForKey:PopupSettingsBarStyle] unsignedIntegerValue] == LNPopupBarStyleCompact;
	
	UIBarButtonItem* play = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"play.fill") style:UIBarButtonItemStylePlain target:self action:@selector(button:)];
	play.accessibilityLabel = NSLocalizedString(@"Play", @"");
	play.accessibilityIdentifier = @"PlayButton";
	play.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* stop = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"stop.fill") style:UIBarButtonItemStylePlain target:self action:@selector(button:)];
	stop.accessibilityLabel = NSLocalizedString(@"Stop", @"");
	stop.accessibilityIdentifier = @"StopButton";
	stop.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* next = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"forward.fill") style:UIBarButtonItemStylePlain target:self action:@selector(button:)];
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* prev = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"backward.fill") style:UIBarButtonItemStylePlain target:self action:@selector(button:)];
	prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
	prev.accessibilityIdentifier = @"PrevButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	UIBarButtonItem* more = [[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"ellipsis") style:UIBarButtonItemStylePlain target:self action:@selector(button:)];
	prev.accessibilityLabel = NSLocalizedString(@"More", @"");
	prev.accessibilityIdentifier = @"MoreButton";
	prev.accessibilityTraits = UIAccessibilityTraitButton;
	
	if(useCompact)
	{
		play.width = 44;
		prev.width = 44;
		next.width = 44;
		stop.width = 44;
		more.width = 44;
		
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
		prev.width = 50;
		play.width = 50;
		next.width = 50;
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

- (void)viewDidMoveToPopupContainerContentView:(LNPopupContentView *)popupContentView
{
	[super viewDidMoveToPopupContainerContentView:popupContentView];
	
	if(popupContentView == nil)
	{
		return;
	}
	
	UIButton* customCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[customCloseButton setTitle:NSLocalizedString(@"Custom Close Button", @"") forState:UIControlStateNormal];
	customCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
	
	UILabel* topLabel = [UILabel new];
	topLabel.text = NSLocalizedString(@"Top", @"");
	topLabel.textColor = [UIColor whiteColor];
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
	bottomLabel.textColor = [UIColor whiteColor];
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
	leadingMarginLabel.textColor = [UIColor whiteColor];
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
	trailingMarginLabel.textColor = [UIColor whiteColor];
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
	leadingSafeAreaLabel.textColor = [UIColor whiteColor];
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
	trailingSafeAreaLabel.textColor = [UIColor whiteColor];
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
	
//	UIView* safeAreaMask = [UIView new];
//	safeAreaMask.translatesAutoresizingMaskIntoConstraints = NO;
//	safeAreaMask.layer.borderColor = [UIColor.greenColor colorWithAlphaComponent:0.5].CGColor;
//	safeAreaMask.layer.borderWidth = 2.0;
//	[self.view addSubview:safeAreaMask];
//	[NSLayoutConstraint activateConstraints:@[
//		[self.view.safeAreaLayoutGuide.leadingAnchor constraintEqualToAnchor:safeAreaMask.leadingAnchor],
//		[self.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:safeAreaMask.trailingAnchor],
//		[self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:safeAreaMask.topAnchor],
//		[self.view.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:safeAreaMask.bottomAnchor],
//	]];
//
//	UIView* layoutMarginsMask = [UIView new];
//	layoutMarginsMask.translatesAutoresizingMaskIntoConstraints = NO;
//	layoutMarginsMask.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.5].CGColor;
//	layoutMarginsMask.layer.borderWidth = 2.0;
//	[self.view addSubview:layoutMarginsMask];
//	[NSLayoutConstraint activateConstraints:@[
//		[self.view.layoutMarginsGuide.leadingAnchor constraintEqualToAnchor:layoutMarginsMask.leadingAnchor],
//		[self.view.layoutMarginsGuide.trailingAnchor constraintEqualToAnchor:layoutMarginsMask.trailingAnchor],
//		[self.view.layoutMarginsGuide.topAnchor constraintEqualToAnchor:layoutMarginsMask.topAnchor],
//		[self.view.layoutMarginsGuide.bottomAnchor constraintEqualToAnchor:layoutMarginsMask.bottomAnchor],
//	]];
	
	[self _updateBackgroundColor];
	
//	UIButton* customCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
//	[customCloseButton setTitle:NSLocalizedString(@"Custom Close Button", @"") forState:UIControlStateNormal];
//	customCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
//	[customCloseButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//	customCloseButton.pointerInteractionEnabled = YES;
//	[customCloseButton addTarget:self action:@selector(_closePopup) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:customCloseButton];
//	[NSLayoutConstraint activateConstraints:@[
//		[self.view.safeAreaLayoutGuide.centerXAnchor constraintEqualToAnchor:customCloseButton.centerXAnchor],
//		[self.view.safeAreaLayoutGuide.centerYAnchor constraintEqualToAnchor:customCloseButton.centerYAnchor],
//	]];
}

- (void)_closePopup
{
	[self.popupPresentationContainerViewController closePopupAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
}

- (void)dealloc
{
	
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	if (@available(iOS 13.0, *)) {
		return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
	} else {
		return UIStatusBarStyleLightContent;
	}
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;//Slide;
}

@end

#endif
