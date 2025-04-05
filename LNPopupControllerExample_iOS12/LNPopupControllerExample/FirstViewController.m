//
//  FirstViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#if LNPOPUP
@import LNPopupController;
#endif
#import "FirstViewController.h"
#import "DemoPopupContentViewController.h"
#import "LoremIpsum.h"
#import "RandomColors.h"
#import "SettingsTableViewController.h"
#import "SplitViewController.h"
@import UIKit;

extern UIImage* LNSystemImage(NSString* named);

@interface TabBar : UITabBar @end
@implementation TabBar

- (void)setFrame:(CGRect)frame
{
//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);

	[super setFrame:frame];
}

@end

@interface Toolbar : UIToolbar @end
@implementation Toolbar

- (void)setFrame:(CGRect)frame
{
//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);
	
	[super setFrame:frame];
}

@end

@interface FirstView : UIView @end

@implementation FirstView

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	[super willMoveToWindow:newWindow];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
}

@end

@interface FirstViewController () <UINavigationControllerDelegate
#if LNPOPUP
, UIContextMenuInteractionDelegate, LNPopupPresentationDelegate
#endif
>

@property (nonatomic, strong) NSString* colorSeedString;
@property (nonatomic) NSInteger colorSeedCount;

@end

@implementation FirstViewController
{
	__weak IBOutlet UIButton *_galleryButton;
	__weak IBOutlet UIButton *_nextButton;
	
	__weak IBOutlet UIBarButtonItem *_barStyleButton;
	BOOL _alreadyPresentedAutomatically;
}

- (UITabBarItem *)tabBarItem
{
	if(self.tabBarController != nil)
	{
		UIViewController* target = self;
		if(self.navigationController != nil)
		{
			target = self.navigationController;
		}
		
		super.tabBarItem.image = LNSystemImage([NSString stringWithFormat:@"%lu.square.fill", [self.tabBarController.viewControllers indexOfObject:target] + 1]);
	}
	
	return super.tabBarItem;
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
		else if(self.navigationController != nil)
		{
			self.colorSeedString = [NSString stringWithFormat:@"tab_109"];
		}
		else
		{
			self.colorSeedString = @"nil";
		}
		self.colorSeedCount = 0;
	}
	
	NSString* seed = [NSString stringWithFormat:@"%@%@", self.colorSeedString, self.colorSeedCount == 0 ? @"" : [NSString stringWithFormat:@"%@", @(self.colorSeedCount)]];
	if (@available(iOS 13.0, *))
	{
		self.view.backgroundColor = LNSeedAdaptiveColor(seed);
	} else {
		self.view.backgroundColor = LNSeedLightColor(seed);
	}
	
	self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
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

- (void)dealloc
{
	
}

- (IBAction)_changeBarStyle:(id)sender
{
	if (@available(iOS 13.0, *))
	{
		UIUserInterfaceStyle currentStyle = self.navigationController.traitCollection.userInterfaceStyle;
		
		self.navigationController.overrideUserInterfaceStyle = currentStyle == UIUserInterfaceStyleLight ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
	}
	else
	{
		self.navigationController.toolbar.barStyle = 1 - self.navigationController.toolbar.barStyle;
	}
	
	self.navigationController.toolbar.tintColor = LNRandomSystemColor();
	
	[self.navigationController.toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.tintColor = self.navigationController.toolbar.tintColor;
	}];
	self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle;
	self.navigationController.navigationBar.tintColor = self.navigationController.toolbar.tintColor;
	
	[self.navigationController setNeedsPopupBarAppearanceUpdate];
}

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
	
	uint32_t titleLowerLimit = 2;
	uint32_t titleUpperLimit = 5;
	
	uint32_t subtitleLowerLimit = 4;
	uint32_t subtitleUpperLimit = 16;
	
	demoVC.popupItem.title = [[LoremIpsum wordsWithNumber:arc4random_uniform(titleUpperLimit - titleLowerLimit) + titleLowerLimit] capitalizedString];
	demoVC.popupItem.subtitle = [[LoremIpsum wordsWithNumber:arc4random_uniform(subtitleUpperLimit - subtitleLowerLimit) + subtitleLowerLimit] valueForKey:@"li_stringByCapitalizingFirstLetter"];
	
	if([NSUserDefaults.standardUserDefaults boolForKey:@"NSForceRightToLeftWritingDirection"])
	{
		demoVC.popupItem.title = [demoVC.popupItem.title stringByApplyingTransform:NSStringTransformLatinToHebrew reverse:NO];
		demoVC.popupItem.subtitle = [demoVC.popupItem.subtitle stringByApplyingTransform:NSStringTransformLatinToHebrew reverse:NO];
	}
	
	demoVC.popupItem.image = [UIImage imageNamed:@"genre7"];
	demoVC.popupItem.progress = (float) arc4random() / UINT32_MAX;
	
	LNPopupCloseButtonStyle closeButtonStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsCloseButtonStyle] unsignedIntegerValue];
	
	UILabel* topLabel = [UILabel new];
	topLabel.text = NSLocalizedString(@"Top", @"");
	if (@available(iOS 13.0, *)) {
		topLabel.textColor = [UIColor systemBackgroundColor];
	} else {
		topLabel.textColor = [UIColor lightTextColor];
	}
	topLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	topLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[demoVC.view addSubview:topLabel];
	
	CGFloat offset =
#if ! TARGET_OS_MACCATALYST
	closeButtonStyle == LNPopupCloseButtonStyleDefault ||
#endif
	closeButtonStyle == LNPopupCloseButtonStyleChevron || closeButtonStyle == LNPopupCloseButtonStyleGrabber ? 40 : 0;
	
	[NSLayoutConstraint activateConstraints:@[
		[topLabel.topAnchor constraintEqualToAnchor:demoVC.view.safeAreaLayoutGuide.topAnchor],
		[topLabel.centerXAnchor constraintEqualToAnchor:demoVC.view.safeAreaLayoutGuide.centerXAnchor constant:offset]
	]];
	
	UILabel* bottomLabel = [UILabel new];
	bottomLabel.text = NSLocalizedString(@"Bottom", @"");
	if (@available(iOS 13.0, *)) {
		bottomLabel.textColor = [UIColor systemBackgroundColor];
	} else {
		bottomLabel.textColor = [UIColor lightTextColor];
	}
	bottomLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[demoVC.view addSubview:bottomLabel];
	[NSLayoutConstraint activateConstraints:@[
		[bottomLabel.bottomAnchor constraintEqualToAnchor:demoVC.view.safeAreaLayoutGuide.bottomAnchor],
		[bottomLabel.centerXAnchor constraintEqualToAnchor:demoVC.view.safeAreaLayoutGuide.centerXAnchor]
	]];
	
	demoVC.popupItem.accessibilityLabel = NSLocalizedString(@"Custom popup bar accessibility label", @"");
	demoVC.popupItem.accessibilityHint = NSLocalizedString(@"Custom popup bar accessibility hint", @"");
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
	targetVC.popupBar.progressViewStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsProgressViewStyle] unsignedIntegerValue];
	targetVC.popupBar.barStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue];
	targetVC.popupInteractionStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsInteractionStyle] unsignedIntegerValue];
	targetVC.popupContentView.popupCloseButtonStyle = closeButtonStyle;
	
	targetVC.shouldExtendPopupBarUnderSafeArea = [NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsExtendBar];
	
//	if (@available(iOS 13.0, *))
//	{
//		UIContextMenuInteraction* i = [[UIContextMenuInteraction alloc] initWithDelegate:self];
//		[targetVC.popupBar addInteraction:i];
//	}
	
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
	if([segue.destinationViewController isKindOfClass:FirstViewController.class])
	{
		[(FirstViewController*)segue.destinationViewController setColorSeedString:self.colorSeedString];
		[(FirstViewController*)segue.destinationViewController setColorSeedCount:self.colorSeedCount + 1];
	}
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	//Mask Apple's push bug. This uses private API, so don't copy it as is in your app!
	
	if(@available(iOS 14.0, *))
	{
		UIViewController* disappearing = [navigationController valueForKey:@"disappearingViewController"];
		UIViewController* target = viewController;
		BOOL isPushing = [[navigationController valueForKey:@"isPushing"] boolValue];
		
		self.tabBarController.view.backgroundColor = (isPushing ? target : disappearing).view.backgroundColor;
	}
}

#pragma mark UIContextMenuInteractionDelegate

#if LNPOPUP
- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location API_AVAILABLE(ios(13.0))
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:nil];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willEndForConfiguration:(UIContextMenuConfiguration *)configuration animator:(nullable id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(13.0))
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

@interface PassthroughNavigationController : UINavigationController @end
@implementation PassthroughNavigationController

- (UITabBarItem *)tabBarItem
{
	return self.viewControllers.firstObject.tabBarItem;
}

@end
