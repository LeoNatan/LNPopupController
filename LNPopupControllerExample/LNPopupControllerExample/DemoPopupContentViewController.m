//
//  DemoPopupContentViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 6/8/16.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import "DemoPopupContentViewController.h"

@import LNPopupController;

@interface DemoPopupContentViewController ()

@end

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
	UIBarButtonItem* play = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] style:UIBarButtonItemStylePlain target:nil action:NULL];
	play.accessibilityLabel = NSLocalizedString(@"Play", @"");
	UIBarButtonItem* more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action"] style:UIBarButtonItemStylePlain target:nil action:NULL];
	more.accessibilityLabel = NSLocalizedString(@"More", @"");
	
	if(collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		UIBarButtonItem* prev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"prev"] style:UIBarButtonItemStylePlain target:nil action:NULL];
		prev.accessibilityLabel = NSLocalizedString(@"Previous Track", @"");
		UIBarButtonItem* next = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nextFwd"] style:UIBarButtonItemStylePlain target:nil action:NULL];
		next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
		
		self.popupItem.leftBarButtonItems = @[ prev, play, next ];
		
		UIBarButtonItem* upnext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:nil action:NULL];
		upnext.accessibilityLabel = NSLocalizedString(@"Up Next", @"");
		upnext.accessibilityHint = NSLocalizedString(@"Double Tap to Show Up Next List", @"");
		
		self.popupItem.rightBarButtonItems = @[ upnext, more ];
	}
	else
	{
		self.popupItem.leftBarButtonItems = @[ play ];
		self.popupItem.rightBarButtonItems = @[ more ];
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
