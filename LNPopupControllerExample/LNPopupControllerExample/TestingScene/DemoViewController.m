//
//  DemoViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
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
#endif
#import "LNPopupDemoContextMenuInteraction.h"
#import "LNPopupControllerExample-Bridging-Header.h"
@import UIKit;

@interface UIImage ()

+ (instancetype)_systemImageNamed:(NSString*)arg1;

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
	__weak IBOutlet UIButton *_galleryButton;
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
		
		//This is safe even with the UITab API, because this will be accessed very early on, when loaded from storyboard.
		super.tabBarItem.image = [UIImage systemImageNamed:[NSString stringWithFormat:@"%lu.square.fill", [self.tabBarController.viewControllers indexOfObject:target] + 1]];
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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
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
		else
		{
			self.colorSeedString = @"nil";
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
	
	if(@available(iOS 18.0, *))
	{
		_hideTabBarButton.hidden = (self.tabBarController == nil && self.navigationController == nil) || self.navigationController.viewControllers.count > 1;
	}
	else
	{
		if (@available(iOS 16.0, *))
		{
			_hideTabBarButton.hidden = self.navigationController == nil || self.tabBarController != nil;
		}
		else
		{
			_hideTabBarButton.enabled = self.navigationController == nil || self.tabBarController != nil;
		}
	}
	
//	UIViewController* settings = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
//	[self addChildViewController:settings];
//	[self.view insertSubview:settings.view atIndex:0];
//	settings.view.frame = self.view.bounds;
//	[settings didMoveToParentViewController:self];
}

- (void)updateNavigationBarTitlePositionForTraitCollection:(UITraitCollection*)traitCollection
{
	if (@available(iOS 18.0, *))
	{
		if(self.tabBarController == nil || UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad || traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
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

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	[self updateBottomDockingViewEffectForBarPresentation];
}

- (void)viewIsAppearing:(BOOL)animated
{
	[super viewIsAppearing:animated];
	
	[self updateBottomDockingViewEffectForBarPresentation];
	
	//Ugly hack to fix tab bar tint color.
	self.tabBarController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix split view controller tint color.
	self.splitViewController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix navigation view controller tint color.
	self.navigationController.view.tintColor = self.view.tintColor;
	
	_galleryButton.titleLabel.adjustsFontForContentSizeCategory = YES;
	_nextButton.titleLabel.adjustsFontForContentSizeCategory = YES;
	
	_galleryButton.hidden = [self.parentViewController isKindOfClass:[UINavigationController class]];
	_nextButton.hidden = self.navigationController == nil || self.splitViewController != nil;
	
	if(self.tabBarController == nil || self.navigationController.topViewController == self.navigationController.viewControllers.firstObject)
	{
		[self _presentBar:nil animated:NO];
	}
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

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[self updateNavigationBarTitlePositionForTraitCollection:newCollection];
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
	UINavigationBarAppearance* nba = nil;
	
	BOOL disableScrollEdgeAppearance = [NSUserDefaults.settingDefaults boolForKey:PopupSettingDisableScrollEdgeAppearance];
	if(disableScrollEdgeAppearance)
	{
		nba = [UINavigationBarAppearance new];
		[nba configureWithDefaultBackground];
	}
	
#if LNPOPUP
	LNPopupBarStyle popupBarStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue];
	if(popupBarStyle == LNPopupBarStyleFloating || (popupBarStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
#endif
	{
		UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
		
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

- (UIViewController*)_targetVCForPopup
{
	void (^block)(NSString*) = ^ (NSString* title) {
		self->_hideTabBarButton.enabled = NO;
		if (@available(iOS 16.0, *))
		{
			self->_hideTabBarButton.hidden = YES;
		}
		self->_showPopupBarButton.hidden = YES;
		self->_hidePopupBarButton.hidden = YES;
		[self.navigationController setToolbarHidden:YES animated:NO];
		
		if (@available(iOS 17.0, *))
		{
			UIContentUnavailableConfiguration* config = [UIContentUnavailableConfiguration emptyConfiguration];
			config.text = title;
			[self setContentUnavailableConfiguration:config];
		}
	};
	
	if([self.splitViewController isKindOfClass:LNSplitViewControllerPrimaryPopup.class] && self.navigationController != [self.splitViewController viewControllerForColumn:UISplitViewControllerColumnPrimary])
	{
		self.view.backgroundColor = UIColor.systemBackgroundColor;
		block(NSLocalizedString(@"Primary", @""));
		return nil;
	}
	
	NSMutableArray* vcs = @[self].mutableCopy;
	if(self.navigationController)
	{
		[vcs addObject:self.navigationController];
	}
	if([self.splitViewController isKindOfClass:LNSplitViewControllerSecondaryPopup.class] && [vcs containsObject:[self.splitViewController viewControllerForColumn:UISplitViewControllerColumnPrimary]])
	{
		self.view.backgroundColor = UIColor.clearColor;
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
			demoVC = [DemoPopupContentViewController new];
			break;
	}
	
	LNPopupCloseButtonStyle closeButtonStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingCloseButtonStyle] unsignedIntegerValue];
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
	targetVC.popupBar.progressViewStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingProgressViewStyle] unsignedIntegerValue];
	targetVC.popupBar.barStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingBarStyle] unsignedIntegerValue];
	
	targetVC.popupInteractionStyle = [[NSUserDefaults.settingDefaults objectForKey:PopupSettingInteractionStyle] unsignedIntegerValue];
	targetVC.popupContentView.popupCloseButtonStyle = closeButtonStyle;
	
	targetVC.allowPopupHapticFeedbackGeneration = [NSUserDefaults.settingDefaults boolForKey:PopupSettingHapticFeedbackEnabled];
	
	targetVC.popupBar.limitFloatingContentWidth = [NSUserDefaults.settingDefaults boolForKey:PopupSettingLimitFloatingWidth];
	
	NSNumber* effectOverride = [NSUserDefaults.settingDefaults objectForKey:PopupSettingVisualEffectViewBlurEffect];
	if(effectOverride != nil && effectOverride.unsignedIntValue != 0xffff)
	{
		if(targetVC.popupBar.effectiveBarStyle == LNPopupBarStyleFloating)
		{
			targetVC.popupBar.standardAppearance.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:effectOverride.unsignedIntegerValue];
		}
		else
		{
			targetVC.popupBar.inheritsAppearanceFromDockingView = NO;
			targetVC.popupBar.standardAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:effectOverride.unsignedIntegerValue];
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
		appearance.imageShadow.shadowColor = UIColor.yellowColor;
		
		if(targetVC.popupBar.barStyle == LNPopupBarStyleFloating || (targetVC.popupBar.barStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
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
		targetVC.popupBar.customBarViewController = [ManualLayoutCustomBarViewController new];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	segue.destinationViewController.hidesBottomBarWhenPushed =
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 180000
			[self.tabBarController setTabBarHidden:!self.tabBarController.isTabBarHidden animated:YES];
#endif
		}
	}
	else if(self.navigationController != nil)
	{
		[self.navigationController setToolbarHidden:!self.navigationController.isToolbarHidden animated:YES];
	}
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

@interface PassthroughNavigationController : UINavigationController @end
@implementation PassthroughNavigationController

- (UITabBarItem *)tabBarItem
{
	return self.viewControllers.firstObject.tabBarItem;
}

@end
