//
//  LNPopupContentViewController.m
//  LNPopupController
//
//  Created by Leo Natan on 06/01/2024.
//  Copyright © 2024 Leo Natan. All rights reserved.
//

#import "LNPopupContentViewController.h"

@interface LNPopupContentPresentationController: UISheetPresentationController

@property (nonatomic, setter=_setWantsFullScreen:) BOOL _wantsFullScreen;
@property (nonatomic, setter=_setAllowsInteractiveDismissWhenFullScreen:) BOOL _allowsInteractiveDismissWhenFullScreen;

@end

@implementation LNPopupContentPresentationController

@dynamic _wantsFullScreen, _allowsInteractiveDismissWhenFullScreen;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
	self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
	
	if(self)
	{
		self._wantsFullScreen = YES;
		self._allowsInteractiveDismissWhenFullScreen = YES;
		self.prefersGrabberVisible = YES;
	}
	
	return self;
}

@end

@interface LNPopupContentViewController () <UIViewControllerTransitioningDelegate> @end

@implementation LNPopupContentViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if(self)
	{
		self.modalPresentationStyle = UIModalPresentationCustom;
		self.transitioningDelegate = self;
	}
	
	return self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
	return [[LNPopupContentPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
	return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
	return self.childViewControllers.firstObject;
}

@end
