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

- (void)loadView
{
	self.view = [DemoPopupContentView new];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPopupItemButtonsWithTraitCollection:newCollection];
		[self _updateBackgroundColor];
	} completion:nil];
	
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)_updateBackgroundColor
{
	if (@available(iOS 13.0, *)) {
		self.view.backgroundColor = LNRandomAdaptiveInvertedColor();
	} else {
		self.view.backgroundColor = LNRandomDarkColor();
	}
	
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)button:(UIBarButtonItem*)button
{
	NSLog(@"✓");
}

static UIImage* LNSystemImage(NSString* named)
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
		return [UIImage imageNamed:@"gears"];
	}
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection
{
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
	
	if([[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue] == LNPopupBarStyleCompact)
	{
		self.popupItem.leadingBarButtonItems = @[ play ];
		self.popupItem.trailingBarButtonItems = @[ next, stop ];
	}
	else
	{
		play.width = 50;
		next.width = 50;
		self.popupItem.barButtonItems = @[ play, next ];
		self.popupItem.leadingBarButtonItems = nil;
	}
}

- (BOOL)prefersStatusBarHidden
{
	return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIButton* customCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[customCloseButton setTitle:NSLocalizedString(@"Custom Close Button", @"") forState:UIControlStateNormal];
	customCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
	if (@available(iOS 13.0, *)) {
		[customCloseButton setTitleColor:UIColor.systemBackgroundColor forState:UIControlStateNormal];
	} else {
		[customCloseButton setTitleColor:UIColor.lightTextColor forState:UIControlStateNormal];
	}
	[customCloseButton addTarget:self action:@selector(_closePopup) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:customCloseButton];
	[NSLayoutConstraint activateConstraints:@[
											  [self.view.safeAreaLayoutGuide.centerXAnchor constraintEqualToAnchor:customCloseButton.centerXAnchor],
											  [self.view.safeAreaLayoutGuide.centerYAnchor constraintEqualToAnchor:customCloseButton.centerYAnchor],
											  ]];
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
