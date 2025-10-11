//
//  DemoViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
@import LNPopupController;
#import <LNPopupController/LNPopupController-Swift.h>
#endif
#import "DemoViewController.h"
#import "DemoPopupContentViewController.h"
#import "RandomColors.h"
#import "SettingKeys.h"
#import "LNSplitViewController.h"
#if LNPOPUP
#import "LNPopupControllerExample-Swift.h"
#else
#import "LNPopupControllerExampleNoPopup-Swift.h"
#endif
#import "LNPopupDemoContextMenuInteraction.h"
#import "LNPopupControllerExample-Bridging-Header.h"
@import UIKit;

@interface UIImage ()

+ (instancetype)_systemImageNamed:(NSString*)name;
+ (instancetype)_systemImageNamed:(NSString*)name withConfiguration:(nullable UIImageConfiguration *)configuration allowPrivate:(BOOL)allowPrivate;

@end

@interface DemoView : UIView @end

@implementation DemoView

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	[super willMoveToWindow:newWindow];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
}

@end

@interface DemoViewController ()
#if LNPOPUP
< LNPopupPresentationDelegate >
#endif

@property (nonatomic, strong) NSString* colorSeedString;
@property (nonatomic) NSInteger colorSeedCount;

@end

@implementation DemoViewController
{
	__weak IBOutlet UIBarButtonItem *_galleryBarButton;
	UIButton* _galleryButton;
	__weak IBOutlet UIButton *_nextButton;
	
	__weak IBOutlet UIBarButtonItem *_barStyleButton;
	__weak IBOutlet UIBarButtonItem *_hideTabBarButton;
	
	__weak IBOutlet UIButton* _showPopupBarButton;
	__weak IBOutlet UIButton* _hidePopupBarButton;
	
	BOOL _alreadyPresentedAutomatically;
}

- (UITabBarItem *)tabBarItem
{
	if(@available(iOS 18.0, *))
	{
		if(self.tab != nil)
		{
			return super.tabBarItem;
		}
	}
	
	if(self.tabBarController != nil)
	{
		UIViewController* target = self;
		if(self.navigationController != nil)
		{
			target = self.navigationController;
		}
		
		NSInteger idx = [self.tabBarController.viewControllers indexOfObject:target] + 1;
		
		BOOL isCustomContainer = NO;
		if(@available(iOS 18.0, *))
		{
			isCustomContainer = [self.tabBarController isKindOfClass:LNCustomContainerController.class];
		}
		if(idx != 4 || self.navigationController == nil || NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26 || isCustomContainer)
		{
			//This is safe even with the UITab API, because this will be accessed very early on, when loaded from storyboard.
			super.tabBarItem.image = [UIImage systemImageNamed:[NSString stringWithFormat:@"%lu.square.fill", idx]];
		}
		else
		{
			if(super.tabBarItem.tag != 1)
			{
				self.navigationItem.searchController = [UISearchController new];
				
				super.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1];
				super.tabBarItem.image = [UIImage systemImageNamed:@"magnifyingglass"];
				super.tabBarItem.title = NSLocalizedString(@"Search", @"");
			}
		}
	}
	
	return super.tabBarItem;
}

- (UITab *)tab API_AVAILABLE(ios(18.0))
{
	if([self.parentViewController isKindOfClass:UINavigationController.class])
	{
		return self.parentViewController.tab;
	}
	
	return super.tab;
}

- (NSUInteger)tabIndexInAncestorTabBarController
{
	if(@available(iOS 18, *))
	{
		return [self.tabBarController.tabs indexOfObject:self.tab];
	}
	else
	{
		return [self.tabBarController.viewControllers indexOfObject:self.navigationController ?: self];
	}
}

- (void)updatePopupContentViewAppearanceOverrideWithTraitCollection:(UITraitCollection*)traitCollection
{
#if LNPOPUP
	_barStyleButton.image = [UIImage _systemImageNamed:@"appearance"];
	if(_barStyleButton.image != nil)
	{
		_barStyleButton.title = nil;
	}
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingInvertDemoSceneColors])
	{
		self._targetVCForPopup.popupContentView.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
	}
	else
	{
		self._targetVCForPopup.popupContentView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
	}
#endif
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (@available(iOS 17.0, *)) {
		[self registerForTraitChanges:@[UITraitUserInterfaceStyle.class] withHandler:^(__kindof id<UITraitEnvironment>  _Nonnull traitEnvironment, UITraitCollection * _Nonnull previousCollection) {
			[traitEnvironment updatePopupContentViewAppearanceOverrideWithTraitCollection:traitEnvironment.traitCollection];
		}];
	}
	[self updatePopupContentViewAppearanceOverrideWithTraitCollection:self.traitCollection];
	
	if(LNPopupSettingsHasOS26Glass())
	{
		_galleryBarButton.title = nil;
	}
	else
	{
		_galleryBarButton.image = nil;
	}
	
	[self updateNavigationBarTitlePositionForTraitCollection:self.traitCollection];
	
	if(self.colorSeedString == nil)
	{
		if(self.splitViewController != nil)
		{
			UIViewController* indexTarget = self.tabBarController ?: self.navigationController ?: self;
			NSInteger idx = 1 - [self.splitViewController.viewControllers indexOfObject:indexTarget];
			
			self.colorSeedString = [NSString stringWithFormat:@"split_%@_%@%@ccolors", NSStringFromClass(self.splitViewController.class), @(idx), @(idx)];
		}
		else if(self.tabBarController != nil)
		{
			NSUInteger tabIdx = self.tabIndexInAncestorTabBarController;
			self.colorSeedString = [NSString stringWithFormat:@"tab_%@", @(tabIdx)];
		}
		else if(self.navigationController != nil)
		{
			self.colorSeedString = [NSString stringWithFormat:@"nil"];
		}
		else
		{
			self.colorSeedString = @"ZviewZz";
		}
		self.colorSeedCount = 0;
	}
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableDemoSceneColors] == NO)
	{
		NSString* seed = [NSString stringWithFormat:@"%@%@", self.colorSeedString, self.colorSeedCount == 0 ? @"" : [NSString stringWithFormat:@"%@", @(self.colorSeedCount)]];
		self.view.backgroundColor = LNSeedAdaptiveColor(seed);
	}
	else
	{
		self.view.backgroundColor = UIColor.systemBackgroundColor;
	}
	
	[self updateHideTabBarButtonHiddenStateForTraitCollection:self.traitCollection];
	
	UIButtonConfiguration* config;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26.0, *))
	{
		if(LNPopupSettingsHasOS26Glass())
		{
			config = [UIButtonConfiguration prominentGlassButtonConfiguration];
		}
		else
		{
			config = [UIButtonConfiguration borderlessButtonConfiguration];
			config.baseForegroundColor = self.view.tintColor;
		}
	}
	else
	{
#endif
		config = [UIButtonConfiguration borderlessButtonConfiguration];
		config.baseForegroundColor = self.view.tintColor;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	}
#endif
	
	if(LNPopupSettingsHasOS26Glass())
	{
		config.image = [UIImage systemImageNamed:@"xmark"];
	}
	else
	{
		config.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Gallery", @"") attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
	}
	config.preferredSymbolConfigurationForImage = [UIImageSymbolConfiguration configurationWithPointSize:17];
	
	_galleryButton = [UIButton buttonWithConfiguration:config primaryAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
		[self performSegueWithIdentifier:@"UnwindSegue" sender:nil];
	}]];
	_galleryButton.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint* x = [self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:_galleryButton.topAnchor constant:LNPopupSettingsHasOS26Glass() ? 6 : -1];
	x.priority = UILayoutPriorityRequired - 10;
	
	[self.view addSubview:_galleryButton];
	[NSLayoutConstraint activateConstraints:@[
		[self.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:_galleryButton.trailingAnchor constant:LNPopupSettingsHasOS26Glass() ? 20 : 8],
		x
	]];
	
	if(LNPopupSettingsHasOS26Glass())
	{
		NSLayoutConstraint* y = [self.view.topAnchor constraintLessThanOrEqualToAnchor:_galleryButton.topAnchor constant:-10];
		y.priority = UILayoutPriorityRequired;
		y.active = YES;
		
		[NSLayoutConstraint activateConstraints:@[
			[_galleryButton.widthAnchor constraintEqualToConstant:44],
			[_galleryButton.heightAnchor constraintEqualToConstant:44],
		]];
	}
	
//	UIViewController* settings = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
//	[self addChildViewController:settings];
//	[self.view insertSubview:settings.view atIndex:0];
//	settings.view.frame = self.view.bounds;
//	[settings didMoveToParentViewController:self];
}

- (void)updateNavigationBarTitlePositionForTraitCollection:(UITraitCollection*)traitCollection
{
	if(@available(iOS 18.0, *))
	{
		if([self.tabBarController isKindOfClass:LNCustomContainerController.class] == YES || self.tabBarController == nil || UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad || traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
		{
			_hideTabBarButton.image = [UIImage systemImageNamed:@"dock.rectangle"];
			self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
			self.navigationItem.style = UINavigationItemStyleNavigator;
		}
		else
		{
			_hideTabBarButton.image = [UIImage _systemImageNamed:@"rectangle.line.horizontal.inset.top"];
			self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
			self.navigationItem.style = UINavigationItemStyleEditor;
		}
	}
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
}

- (void)viewIsAppearing:(BOOL)animated
{
	[super viewIsAppearing:animated];
	
	if(self.isInSearchTab)
	{
		self.navigationItem.title = self.navigationItem.searchController != nil ? NSLocalizedString(@"Search", @"") : NSLocalizedString(@"Search Result", @"");
	
		if([NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableDemoSceneColors] == NO)
		{
			NSString* seed = [NSString stringWithFormat:@"%@%@", self.colorSeedString, self.colorSeedCount == 0 ? @"" : [NSString stringWithFormat:@"%@", @(self.colorSeedCount)]];
			self.view.backgroundColor = LNSeedAdaptiveSubduedColor(seed);
		}
		else
		{
			self.view.backgroundColor = UIColor.systemBackgroundColor;
		}
	}
	
	[self updateBottomDockingViewEffectForBarPresentation];
	
	//Ugly hack to fix tab bar tint color.
	self.tabBarController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix split view controller tint color.
	self.splitViewController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix navigation view controller tint color.
	self.navigationController.view.tintColor = self.view.tintColor;
	
	_nextButton.titleLabel.adjustsFontForContentSizeCategory = YES;
	
	_galleryButton.hidden = [self.parentViewController isKindOfClass:[UINavigationController class]];
	_nextButton.hidden = self.navigationController == nil || self.splitViewController != nil;
	
	if(self.tabBarController == nil || self.navigationController.topViewController == self.navigationController.viewControllers.firstObject)
	{
		[self _presentBar:nil animated:NO];
	}
}

- (void)updatePopupCloseButtonTintColor
{
#if LNPOPUP
	if(self._targetVCForPopup.popupContentView.popupCloseButton.effectiveStyle == LNPopupCloseButtonStyleProminentGlass)
	{
		self._targetVCForPopup.popupContentView.popupCloseButton.tintColor = self.view.backgroundColor;
	}
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self updatePopupCloseButtonTintColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)updateHideTabBarButtonHiddenStateForTraitCollection:(UITraitCollection*)traitCollection;
{
	if(@available(iOS 18.0, *))
	{
		if(traitCollection == nil)
		{
			traitCollection = self.traitCollection;
		}
		
		BOOL isCustomContainer = [self.tabBarController isKindOfClass:LNCustomContainerController.class];
		BOOL canHaveSidebar = isCustomContainer == NO && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
		
		if(self.tabBarController != nil)
		{
			[self.navigationItem setHidesBackButton:canHaveSidebar && self.tabBarController.sidebar.isHidden == NO];
		}
		
		BOOL isFirst = [self.navigationController.viewControllers indexOfObject:self] == 0;
		BOOL isTNil = self.tabBarController == nil;
		BOOL isNNil = self.navigationController == nil;
		BOOL isSNil = self.splitViewController == nil;
		BOOL isSidebarHidden = self.tabBarController.sidebar.isHidden;
		
		_hideTabBarButton.hidden = isCustomContainer == YES || isSNil == NO || isFirst == NO || isNNil || (!isTNil && canHaveSidebar && isSidebarHidden == NO);
	}
	else
	{
		if(@available(iOS 16.0, *))
		{
			_hideTabBarButton.hidden = self.navigationController == nil || self.tabBarController != nil;
		}
		else
		{
			_hideTabBarButton.enabled = self.navigationController == nil || self.tabBarController != nil;
		}
	}
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self updateHideTabBarButtonHiddenStateForTraitCollection:self.traitCollection];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self updateNavigationBarTitlePositionForTraitCollection:newCollection];
		[self updatePopupContentViewAppearanceOverrideWithTraitCollection:newCollection];
	} completion:nil];
}

- (void)dealloc
{
	
}

- (IBAction)_changeBarStyle:(id)sender
{
	UIUserInterfaceStyle currentStyle = self.navigationController.traitCollection.userInterfaceStyle;
	self.navigationController.overrideUserInterfaceStyle = currentStyle == UIUserInterfaceStyleLight ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
	self.navigationController.toolbar.tintColor = LNRandomSystemColor();
	[self.navigationController.toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.tintColor = self.navigationController.toolbar.tintColor;
	}];
	self.navigationController.navigationBar.tintColor = self.navigationController.toolbar.tintColor;
#if LNPOPUP
	[self.navigationController setNeedsPopupBarAppearanceUpdate];
#endif
}

- (void)updateBottomDockingViewEffectForBarPresentation
{
	if(LNPopupSettingsHasOS26Glass())
	{
		return;
	}
	
	if(LNPopupSettingsHasOS26Glass() == NO)
	{
		UINavigationBarAppearance* nba = nil;
		
		BOOL disableScrollEdgeAppearance = [NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableScrollEdgeAppearance];
		if(disableScrollEdgeAppearance)
		{
			nba = [UINavigationBarAppearance new];
			[nba configureWithDefaultBackground];
		}
		
#if LNPOPUP
		LNPopupBarStyle popupBarStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue];
		if(popupBarStyle == LNPopupBarStyleFloating || popupBarStyle == LNPopupBarStyleFloatingCompact || (popupBarStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
#endif
		{
			UIBlurEffectStyle style;
			if(NSProcessInfo.processInfo.isMacCatalystApp || NSProcessInfo.processInfo.isiOSAppOnMac)
			{
				style = UIBlurEffectStyleSystemThickMaterial;
			}
			else
			{
				style = UIBlurEffectStyleSystemThinMaterial;
			}
			
			UIBlurEffect* effect = [UIBlurEffect effectWithStyle:style];
			
#if LNPOPUP
			nba.backgroundEffect = effect;
#endif
			
			UITabBarAppearance* tba = [UITabBarAppearance new];
			[tba configureWithDefaultBackground];
			tba.backgroundEffect = effect;
			self.tabBarController.tabBar.standardAppearance = tba;
			
			UIToolbarAppearance* ta = [UIToolbarAppearance new];
			[ta configureWithDefaultBackground];
			ta.backgroundEffect = effect;
			self.navigationController.toolbar.standardAppearance = ta;
		}
		
		self.navigationController.navigationBar.scrollEdgeAppearance = nba;
		self.navigationController.navigationBar.compactScrollEdgeAppearance = nba;
		
		UITabBarAppearance* tba = nil;
		if(disableScrollEdgeAppearance)
		{
			tba = [[UITabBarAppearance alloc] initWithBarAppearance:nba];
		}
		self.tabBarController.tabBar.scrollEdgeAppearance = tba;
		
		UIToolbarAppearance* ta = nil;
		if(disableScrollEdgeAppearance)
		{
			ta = [[UIToolbarAppearance alloc] initWithBarAppearance:nba];
		}
		self.navigationController.toolbar.scrollEdgeAppearance = ta;
		self.navigationController.toolbar.compactScrollEdgeAppearance = ta;
	}
}

- (UIViewController*)_targetVCForPopup
{
	void (^block)(NSString*) = ^ (NSString* title) {
		self->_hideTabBarButton.enabled = NO;
		if(@available(iOS 16.0, *))
		{
			self->_hideTabBarButton.hidden = YES;
		}
		self->_showPopupBarButton.hidden = YES;
		self->_hidePopupBarButton.hidden = YES;
		[self.navigationController setToolbarHidden:YES animated:NO];
		
		if(@available(iOS 17.0, *))
		{
			UIContentUnavailableConfiguration* config = [UIContentUnavailableConfiguration emptyConfiguration];
			config.text = title;
			[self setContentUnavailableConfiguration:config];
		}
	};
	
	if([self.splitViewController isKindOfClass:LNSplitViewControllerPrimaryPopup.class] && self.navigationController != [self.splitViewController viewControllerForColumn:UISplitViewControllerColumnPrimary])
	{
		self.view.backgroundColor = UIColor.systemBackgroundColor;
		block(NSLocalizedString(@"Secondary", @""));
		return nil;
	}
	
	NSMutableArray* vcs = @[self].mutableCopy;
	if(self.navigationController)
	{
		[vcs addObject:self.navigationController];
	}
	if([self.splitViewController isKindOfClass:LNSplitViewControllerSecondaryPopup.class] && [vcs containsObject:[self.splitViewController viewControllerForColumn:UISplitViewControllerColumnPrimary]])
	{
		self.view.backgroundColor = UIColor.secondarySystemBackgroundColor;
		block(NSLocalizedString(@"Sidebar", @""));
		
		return nil;
	}
	
	if([self.splitViewController isKindOfClass:LNSplitViewControllerGlobalPopup.class])
	{
		return self.splitViewController;
	}
	
	UIViewController* targetVC = self.tabBarController;
	
	if(targetVC == nil)
	{
		targetVC = self.navigationController;
		
		if(targetVC == nil)
		{
			targetVC = self;
		}
	}
	
	return targetVC;
}

- (IBAction)_presentBar:(id)sender
{
	[self _presentBar:sender animated:YES];
}

- (void)_presentBar:(id)sender animated:(BOOL)animated;
{
#if LNPOPUP
	if(_alreadyPresentedAutomatically == YES && sender == nil)
	{
		return;
	}
	
	if(sender == nil)
	{
		_alreadyPresentedAutomatically = YES;
	}
	
	UIViewController* targetVC = [self _targetVCForPopup];
	
	if(targetVC == nil)
	{
		return;
	}
	
	if(targetVC.popupContentViewController != nil)
	{
		return;
	}
	
	if(targetVC == self.navigationController && self.navigationController.viewControllers.count > 1 && self.splitViewController == nil && sender == nil)
	{
		return;
	}
	
	UIViewController* demoVC;
	BOOL wantsGlassBackground = YES;
	switch([NSUserDefaults.settingDefaults integerForKey:PopupSettingUseScrollingPopupContent])
	{
		case 10:
		case 11:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScrollingColors"];
			break;
		
		case 20:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VerticalPagedScrollingColors"];
			break;
		case 21:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HorizontalPagedScrollingColors"];
			break;
		case 22:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VerticalGroupedPagedScrollingColors"];
			break;
		case 23:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HorizontalGroupedPagedScrollingColors"];
			break;
			
		case 100:
			demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScrollingMap"];
			break;
		default:
			wantsGlassBackground = NO;
			demoVC = [DemoPopupContentViewController new];
			break;
	}
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26.0, *))
	{
		if(wantsGlassBackground)
		{
			targetVC.popupContentView.backgroundEffect = [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
		}
	}
#endif
	
	LNPopupCloseButtonStyle closeButtonStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingCloseButtonStyle] unsignedIntegerValue];
	if(LNPopupSettingsHasOS26Glass() && closeButtonStyle == LNPopupCloseButtonStyleDefault)
	{
		closeButtonStyle = LNPopupCloseButtonStyleShinyGlass;
	}
	
	LNPopupCloseButtonPositioning closeButtonPositioning = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingCloseButtonPositioning] unsignedIntegerValue];
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
	targetVC.popupBar.progressViewStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingProgressViewStyle] unsignedIntegerValue];
	targetVC.popupBar.barStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue];
	
	targetVC.popupInteractionStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingInteractionStyle] unsignedIntegerValue];

	if(targetVC.effectivePopupInteractionStyle == LNPopupInteractionStyleScroll && [NSUserDefaults.settingDefaults integerForKey:PopupSettingUseScrollingPopupContent] == 0)
	{
		targetVC.popupInteractionStyle = LNPopupInteractionStyleSnap;
	}

	targetVC.popupContentView.popupCloseButtonStyle = closeButtonStyle;
	targetVC.popupContentView.popupCloseButtonPositioning = closeButtonPositioning;
	[self updatePopupCloseButtonTintColor];
	
	targetVC.allowPopupHapticFeedbackGeneration = [NSUserDefaults.settingDefaults boolForKey:PopupSettingHapticFeedbackEnabled];
	
	targetVC.popupBar.limitFloatingContentWidth = [NSUserDefaults.settingDefaults boolForKey:PopupSettingLimitFloatingWidth];

	NSNumber* effectOverride = [NSUserDefaults.settingDefaults objectForKey:PopupSettingVisualEffectViewBlurEffect];
	if(effectOverride != nil && effectOverride.integerValue != 0xffff && (effectOverride.integerValue >= 0 || LNPopupSettingsHasOS26Glass()))
	{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		if(effectOverride.integerValue < 0 && LNPopupSettingsHasOS26Glass())
		{
			NSInteger glassStyle = labs(effectOverride.integerValue) - 1;
			UIGlassEffect* glassEffect = [UIGlassEffect effectWithStyle:glassStyle];
			glassEffect.interactive = YES;
			//Always floating
			targetVC.popupBar.standardAppearance.floatingBackgroundEffect = glassEffect;
		}
#endif
		
		if(effectOverride.integerValue >= 0)
		{
			if(targetVC.popupBar.effectiveBarStyle == LNPopupBarStyleFloating || targetVC.popupBar.effectiveBarStyle == LNPopupBarStyleFloatingCompact)
			{
				targetVC.popupBar.standardAppearance.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:effectOverride.integerValue];
			}
			else
			{
				targetVC.popupBar.inheritsAppearanceFromDockingView = NO;
				targetVC.popupBar.standardAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:effectOverride.integerValue];
			}
		}
	}
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingEnableCustomizations])
	{
		LNPopupBarAppearance* appearance = [LNPopupBarAppearance new];
		
		NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		paragraphStyle.alignment = NSTextAlignmentRight;
		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
		
		appearance.titleTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont fontWithName:@"Chalkduster" size:14]], NSForegroundColorAttributeName: UIColor.yellowColor};
		appearance.subtitleTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [[UIFontMetrics metricsForTextStyle:UIFontTextStyleSubheadline] scaledFontForFont:[UIFont fontWithName:@"Chalkduster" size:12]], NSForegroundColorAttributeName: UIColor.greenColor};
		
		appearance.floatingBarBackgroundShadow.shadowColor = UIColor.redColor;
		appearance.floatingBarBackgroundShadow.shadowOffset = CGSizeZero;
		
		appearance.imageShadow.shadowColor = UIColor.yellowColor;
		
		if(targetVC.popupBar.barStyle == LNPopupBarStyleFloating || targetVC.popupBar.barStyle == LNPopupBarStyleFloatingCompact || (targetVC.popupBar.barStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
		{
			appearance.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		}
		else
		{
			
			appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			targetVC.popupBar.inheritsAppearanceFromDockingView = NO;
		}
		
		targetVC.popupBar.tintColor = UIColor.yellowColor;
		targetVC.popupBar.standardAppearance = appearance;
	}
	
	targetVC.popupBar.standardAppearance.floatingBarShineEnabled = [NSUserDefaults.settingDefaults boolForKey:PopupSettingShineEnabled];
	
	targetVC.popupBar.standardAppearance.marqueeScrollEnabled = [NSUserDefaults.settingDefaults boolForKey:PopupSettingMarqueeEnabled];
	targetVC.popupBar.standardAppearance.coordinateMarqueeScroll = [NSUserDefaults.settingDefaults boolForKey:PopupSettingMarqueeCoordinationEnabled];
	
	targetVC.shouldExtendPopupBarUnderSafeArea = [NSUserDefaults.settingDefaults boolForKey:PopupSettingExtendBar];
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingContextMenuEnabled])
	{
		[targetVC.popupBar addInteraction:[[LNPopupDemoContextMenuInteraction alloc] initWithTitle:YES]];
	}
	
	if([NSUserDefaults.settingDefaults boolForKey:PopupSettingCustomBarEverywhereEnabled])
	{
		targetVC.shouldExtendPopupBarUnderSafeArea = NO;
		targetVC.popupBar.inheritsAppearanceFromDockingView = NO;
		targetVC.popupBar.customBarViewController = [[ManualLayoutCustomBarViewController alloc] initWithCustomCornerConfiguration:NO];
		[targetVC.popupBar.standardAppearance configureWithTransparentBackground];
	}
	
	targetVC.popupPresentationDelegate = self;
	[targetVC presentPopupBarWithContentViewController:demoVC animated:animated completion:nil];
#endif
}

- (IBAction)_dismissBar:(id)sender
{
#if LNPOPUP
	__kindof UIViewController* targetVC = [self _targetVCForPopup];
	[targetVC dismissPopupBarAnimated:YES completion:nil];
#endif
}

- (BOOL)isInSearchTab
{
	BOOL rv = NO;
	
	if(@available(iOS 18.0, *))
	{
		if([self.tab isKindOfClass:UISearchTab.class])
		{
			rv = YES;
		}
	}
	
	return rv;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	segue.destinationViewController.hidesBottomBarWhenPushed = self.isInSearchTab == NO &&
#if LNPOPUP
	[NSUserDefaults.settingDefaults boolForKey:PopupSettingHidesBottomBarWhenPushed];
#else
	YES;
#endif
	if([segue.destinationViewController isKindOfClass:DemoViewController.class])
	{
		[(DemoViewController*)segue.destinationViewController setColorSeedString:self.colorSeedString];
		[(DemoViewController*)segue.destinationViewController setColorSeedCount:self.colorSeedCount + 1];
	}
}

- (IBAction)_hideBottomBar:(id)sender
{
	if(self.tabBarController != nil)
	{
		if(@available(iOS 18.0, *))
		{
			[self.tabBarController setTabBarHidden:!self.tabBarController.isTabBarHidden animated:YES];
		}
	}
	else if(self.navigationController != nil)
	{
		[self.navigationController setToolbarHidden:!self.navigationController.isToolbarHidden animated:YES];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ? UIStatusBarStyleDarkContent : UIStatusBarStyleLightContent;
}

#pragma mark LNPopupPresentationDelegate

- (void)popupPresentationControllerWillPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated
{
	
}

- (void)popupPresentationControllerDidPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated
{

}

- (void)popupPresentationControllerWillDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated
{

}

- (void)popupPresentationControllerDidDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated
{
	
}

- (void)popupPresentationController:(UIViewController *)popupPresentationController willOpenPopupWithContentController:(UIViewController *)popupContentController animated:(BOOL)animated
{
	
}

- (void)popupPresentationController:(UIViewController *)popupPresentationController didOpenPopupWithContentController:(UIViewController *)popupContentController animated:(BOOL)animated
{
	
}

- (void)popupPresentationController:(UIViewController *)popupPresentationController willClosePopupWithContentController:(UIViewController *)popupContentController animated:(BOOL)animated
{
	
}

- (void)popupPresentationController:(UIViewController *)popupPresentationController didClosePopupWithContentController:(UIViewController *)popupContentController animated:(BOOL)animated
{
	
}

@end
