//
//  LNPopupControllerExampleSupport.m
//  LNPopupControllerExampleSupport
//
//  Created by Leo Natan on 8/20/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "LNPopupControllerExampleSupport.h"
#import "DemoPresentationController.h"

@interface DemoGalleryControllerTableView : UITableView @end
@implementation DemoGalleryControllerTableView

- (BOOL)canBecomeFocused
{
	return NO;
}

@end

@interface DemoTabBarController : UITabBarController <UIViewControllerTransitioningDelegate> @end

@implementation DemoTabBarController

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

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.modalPresentationStyle = UIModalPresentationCustom;
	self.transitioningDelegate = self;
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle
{
	super.modalPresentationStyle = UIModalPresentationCustom;
	self.transitioningDelegate = self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
	return [[DemoPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

@interface DemoTabBar : UITabBar @end
@implementation DemoTabBar

- (void)setFrame:(CGRect)frame
{
	//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);
	
	[super setFrame:frame];
}

@end

@interface DemoToolbar : UIToolbar @end
@implementation DemoToolbar

- (void)setFrame:(CGRect)frame
{
	//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);
	
	[super setFrame:frame];
}

@end

@interface PassthroughNavigationController : UINavigationController <UIViewControllerTransitioningDelegate> @end
@implementation PassthroughNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
}

- (UITabBarItem *)tabBarItem
{
	return self.viewControllers.firstObject.tabBarItem;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.modalPresentationStyle = UIModalPresentationCustom;
	self.transitioningDelegate = self;
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle
{
	super.modalPresentationStyle = UIModalPresentationCustom;
	self.transitioningDelegate = self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
	return [[DemoPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
