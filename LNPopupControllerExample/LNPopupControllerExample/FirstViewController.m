//
//  FirstViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import LNPopupController;
#import "FirstViewController.h"
#import "LoremIpsum.h"
#import "RandomColors.h"

@interface DemoGalleryController : UITableViewController @end
@implementation DemoGalleryController

- (IBAction)unwindToGallery:(UIStoryboardSegue *)unwindSegue
{
	//No-op
}

@end

@interface DemoPopupContentViewController : UIViewController @end
@implementation DemoPopupContentViewController

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPopupItemButtonsWithTraitCollection:newCollection];
	} completion:nil];
	
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection
{
	if(collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		self.popupItem.leftBarButtonItems = @[ [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"prev"] style:UIBarButtonItemStylePlain target:nil action:NULL],
											   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] style:UIBarButtonItemStylePlain target:nil action:NULL],
											   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nextFwd"] style:UIBarButtonItemStylePlain target:nil action:NULL]];
		
		self.popupItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:nil action:NULL],
												[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action"] style:UIBarButtonItemStylePlain target:nil action:NULL]];
	}
	else
	{
		self.popupItem.leftBarButtonItems = @[ [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] style:UIBarButtonItemStylePlain target:nil action:NULL] ];
		self.popupItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action"] style:UIBarButtonItemStylePlain target:nil action:NULL] ];
	}
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)prefersStatusBarHidden
{
//	return YES;
	return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;
}

@end

@implementation FirstViewController
{
	__weak IBOutlet UIButton *_galleryButton;
	
}

#warning Enable this code to demonstrate popup bar customization
//+ (void)load
//{
//	[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:14], NSForegroundColorAttributeName: [UIColor yellowColor]}];
//	[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setSubtitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:12], NSForegroundColorAttributeName: [UIColor greenColor]}];
//	[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setBarStyle:UIBarStyleBlack];
//	[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setTintColor:[UIColor yellowColor]];
//}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = LNRandomLightColor();

#warning Enable this code to demonstrate disabling the popup close button.
//	self.navigationController.popupContentView.popupCloseButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//Ugly hack to fix tab bar tint color.
	self.tabBarController.view.tintColor = [UIColor redColor];
	_galleryButton.hidden = self.parentViewController != nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _presentBar:nil];
}

- (IBAction)_changeBarStyle:(id)sender
{
	self.navigationController.toolbar.barStyle = 1 - self.navigationController.toolbar.barStyle;
	self.navigationController.toolbar.tintColor = self.navigationController.toolbar.barStyle ? LNRandomLightColor() : LNRandomDarkColor();
	[self.navigationController.toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.tintColor = self.navigationController.toolbar.tintColor;
	}];
	self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle;
	self.navigationController.navigationBar.tintColor = self.navigationController.toolbar.tintColor;
	
	[self.navigationController updatePopupBarAppearance];
}

- (IBAction)_presentBar:(id)sender
{
	UIViewController* targetVC = self.tabBarController;
	if(targetVC == nil)
	{
		targetVC = self.navigationController;
		
		if(targetVC == nil)
		{
			targetVC = self;
		}
	}
	
	if(targetVC.popupContentViewController != nil)
	{
		return;
	}
	
	DemoPopupContentViewController* demoVC = [DemoPopupContentViewController new];
	demoVC.view.backgroundColor = LNRandomDarkColor();
	demoVC.popupItem.title = [LoremIpsum sentence];
	demoVC.popupItem.subtitle = [LoremIpsum sentence];
	demoVC.popupItem.progress = (float) arc4random() / UINT32_MAX;
	
	[targetVC presentPopupBarWithContentViewController:demoVC animated:YES completion:nil];
}

- (IBAction)_dismissBar:(id)sender
{
	UIViewController* targetVC = self.tabBarController;
	if(targetVC == nil)
	{
		targetVC = self.navigationController;
		
		if(targetVC == nil)
		{
			targetVC = self;
		}
	}
	
	[targetVC dismissPopupBarAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

@end
