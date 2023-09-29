//
//  DemoViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#if LNPOPUP
@import LNPopupController;
#endif
#import "DemoViewController.h"
#import "DemoPopupContentViewController.h"
#import "RandomColors.h"
#import "SettingsTableViewController.h"
#import "SplitViewController.h"
#import "LNPopupControllerExample-Swift.h"
#import "LNPopupDemoContextMenuInteraction.h"
@import UIKit;

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
< UIContextMenuInteractionDelegate, LNPopupPresentationDelegate >
#endif

@property (nonatomic, strong) NSString* colorSeedString;
@property (nonatomic) NSInteger colorSeedCount;

@end

@implementation DemoViewController
{
	__weak IBOutlet UIButton *_galleryButton;
	__weak IBOutlet UIButton *_nextButton;
	
	__weak IBOutlet UIBarButtonItem *_barStyleButton;
	BOOL _alreadyPresentedAutomatically;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(self.colorSeedString == nil)
	{
		if(self.splitViewController != nil)
		{
			self.colorSeedString = [NSString stringWithFormat:@"%@", @(arc4random())];
		}
		else if(self.tabBarController != nil)
		{
			NSUInteger tabIdx = [self.tabBarController.viewControllers indexOfObject:self.navigationController ?: self];
			self.colorSeedString = [NSString stringWithFormat:@"tab_%@", @(tabIdx)];
		}
		else
		{
			self.colorSeedString = @"nil";
		}
		self.colorSeedCount = 0;
	}
	
	NSString* seed = [NSString stringWithFormat:@"%@%@", self.colorSeedString, self.colorSeedCount == 0 ? @"" : [NSString stringWithFormat:@"%@", @(self.colorSeedCount)]];
	self.view.backgroundColor = LNSeedAdaptiveColor(seed);
//	self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self updateBottomDockingViewEffectForBarPresentation];
	
	//Ugly hack to fix tab bar tint color.
	self.tabBarController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix split view controller tint color.
	self.splitViewController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix navigation view controller tint color.
	self.navigationController.view.tintColor = self.view.tintColor;
	
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
#if LNPOPUP
	LNPopupBarStyle popupBarStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue];
	if(popupBarStyle == LNPopupBarStyleFloating || (popupBarStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
	{
#endif
		UITabBarAppearance* tba = [UITabBarAppearance new];
		[tba configureWithDefaultBackground];
		tba.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		self.tabBarController.tabBar.standardAppearance = tba;
		
		UIToolbarAppearance* ta = [UIToolbarAppearance new];
		[ta configureWithDefaultBackground];
		ta.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		self.navigationController.toolbar.standardAppearance = ta;
	}
#if LNPOPUP
}
#endif

- (UIViewController*)_targetVCForPopup
{
	if([self.splitViewController isKindOfClass:SplitViewControllerPrimaryPopup.class] && self.navigationController != [self.ln_splitViewController viewControllerForColumn:LNSplitViewControllerColumnPrimary])
	{
		return nil;
	}
	
	NSMutableArray* vcs = @[self].mutableCopy;
	if(self.navigationController)
	{
		[vcs addObject:self.navigationController];
	}
	if([self.splitViewController isKindOfClass:SplitViewControllerSecondaryPopup.class] && [vcs containsObject:[self.ln_splitViewController viewControllerForColumn:LNSplitViewControllerColumnPrimary]])
	{
		return nil;
	}
	
	if([self.splitViewController isKindOfClass:SplitViewControllerSecondaryPopup.class] && [vcs containsObject:[self.ln_splitViewController viewControllerForColumn:LNSplitViewControllerColumnSupplementary]])
	{
		return nil;
	}
	
	if([self.splitViewController isKindOfClass:SplitViewControllerGlobalPopup.class])
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
	
//	UIViewController* demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
	UIViewController* demoVC = [DemoPopupContentViewController new];
	
	LNPopupCloseButtonStyle closeButtonStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsCloseButtonStyle] unsignedIntegerValue];
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
	targetVC.popupBar.progressViewStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsProgressViewStyle] unsignedIntegerValue];
	targetVC.popupBar.barStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue];
	
	targetVC.popupInteractionStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsInteractionStyle] unsignedIntegerValue];
	targetVC.popupContentView.popupCloseButtonStyle = closeButtonStyle;
	
	NSNumber* marqueeEnabledSetting = [[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsMarqueeStyle];
	NSNumber* marqueeEnabledCalculated = nil;
	if(marqueeEnabledSetting && [marqueeEnabledSetting isEqualToNumber:@0] == NO)
	{
		marqueeEnabledCalculated = @((BOOL)([marqueeEnabledSetting unsignedIntegerValue] - 1));
		targetVC.popupBar.standardAppearance.marqueeScrollEnabled = marqueeEnabledCalculated.boolValue;
	}
	
	NSNumber* effectOverride = [NSUserDefaults.standardUserDefaults objectForKey:PopupSettingsVisualEffectViewBlurEffect];
	if(effectOverride != nil)
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
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:PopupSettingsEnableCustomizations])
	{
		LNPopupBarAppearance* appearance = [LNPopupBarAppearance new];
		appearance.marqueeScrollEnabled = marqueeEnabledCalculated.boolValue;
		
		NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		paragraphStyle.alignment = NSTextAlignmentRight;
		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
	
		appearance.titleTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:14], NSForegroundColorAttributeName: [UIColor yellowColor]};
		appearance.subtitleTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:12], NSForegroundColorAttributeName: [UIColor greenColor]};
		
		if(targetVC.popupBar.barStyle == LNPopupBarStyleFloating || (targetVC.popupBar.barStyle == LNPopupBarStyleDefault && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17))
		{
			appearance.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		}
		else
		{
			targetVC.popupBar.inheritsAppearanceFromDockingView = NO;
			appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		}
		
		[targetVC.popupBar setTintColor:[UIColor systemYellowColor]];
		targetVC.popupBar.standardAppearance = appearance;
	}
	
	targetVC.shouldExtendPopupBarUnderSafeArea = [NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsExtendBar];
	
	if([NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsContextMenuEnabled])
	{
		[targetVC.popupBar addInteraction:[[LNPopupDemoContextMenuInteraction alloc] initWithTitle:YES]];
	}
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:PopupSettingsCustomBarEverywhereEnabled])
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
	segue.destinationViewController.hidesBottomBarWhenPushed = [NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsHidesBottomBarWhenPushed];
	if([segue.destinationViewController isKindOfClass:DemoViewController.class])
	{
		[(DemoViewController*)segue.destinationViewController setColorSeedString:self.colorSeedString];
		[(DemoViewController*)segue.destinationViewController setColorSeedCount:self.colorSeedCount + 1];
	}
}

#pragma mark UIContextMenuInteractionDelegate

#if LNPOPUP
- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:nil];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willEndForConfiguration:(UIContextMenuConfiguration *)configuration animator:(nullable id<UIContextMenuInteractionAnimating>)animator
{
	[animator addAnimations:^{
		UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]] applicationActivities:nil];
		avc.modalPresentationStyle = UIModalPresentationFormSheet;
		avc.popoverPresentationController.sourceView = [self _targetVCForPopup].popupBar;
		[self presentViewController:avc animated:YES completion:nil];
	}];
	
	[animator addCompletion:^{
		
	}];
}
#endif

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
