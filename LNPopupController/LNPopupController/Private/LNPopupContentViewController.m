//
//  LNPopupContentViewController.m
//  LNPopupController
//
//  Created by Leo Natan on 9/12/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "LNPopupContentViewController.h"
#import "_LNPopupPresentationController.h"
#import "_LNPopupSheetPresentationController_.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"

@interface LNPopupContentViewController () <UIViewControllerTransitioningDelegate, LNPopupPresentationControllerDelegate> @end

@implementation LNPopupContentViewController
{
	__weak LNPopupController* _popupController;
	UIPresentationController<_LNPopupPresentationController>* _currentPresentationController;
}

- (instancetype)initWithPopupController:(LNPopupController*)popupController
{
	self = [super init];
	
	if(self)
	{
		_popupController = popupController;
		self.transitioningDelegate = self;
		self.modalPresentationStyle = UIModalPresentationCustom;
		
		self.popupContentView.layer.masksToBounds = YES;
	}
	
	return self;
}

- (LNPopupContentView *)popupContentView
{
	return (id)self.view;
}

- (void)loadView
{
	self.view = [LNPopupContentView new];
	self.view.backgroundColor = UIColor.systemGreenColor;
}

#pragma mark Presentation, animation and interaction

- (void)currentPresentationDidEnd
{
	_currentPresentationController = nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
	if(_currentPresentationController != nil)
	{
		return _currentPresentationController;
	}
	
	Class targetClass;
	
	switch (self.popupPresentationStyle) {
//		case LNPopupPresentationStyleFullScreen:
//			targetClass = _LNFullScreenPopupPresentationController.class;
//			break;
//		case LNPopupPresentationStyleFullHeight:
//			targetClass = _LNFullHeightPopupPresentationController.class;
//			break;
//		case LNPopupPresentationStyleOverCurrentContext:
//			targetClass = _LNOverCurrentContextPopupPresentationController.class;
//			break;
		case LNPopupPresentationStyleSheet:
#if ! LNPopupControllerEnforceStrictClean
			if(@available(iOS 13.0, *))
			{
				UIPresentationController* pc = [presenting ?: source nonMemoryLeakingPresentationController];
				if([NSStringFromClass(pc.class) containsString:@"Form"])
				{
					targetClass = _LNPopupFormSheetPresentationController;
				}
				else
				{
					targetClass = _LNPopupPageSheetPresentationController;
				}
			}
			else
			{
#endif
				[NSException raise:NSInternalInconsistencyException format:@"Sheet presentation style is not supported on iOS versions below 13."];
//				targetClass = _LNLegacyOSSheetPopupPresentationController.class;
#if ! LNPopupControllerEnforceStrictClean
			}
#endif
			
			break;
		default:
			NSAssert(NO, @"Should not be here!");
//			targetClass = _LNFullHeightPopupPresentationController.class;
			break;
	}
	
	_currentPresentationController = [[targetClass alloc] initWithPresentedViewController:presented presentingViewController:presenting];
	_currentPresentationController.popupPresentationControllerDelegate = self;
	
	return _currentPresentationController;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
{
	if([_currentPresentationController conformsToProtocol:@protocol(_LNPopupPresentationController)] == NO)
	{
		return nil;
	}
	
	return (id)_currentPresentationController;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;
{
	if([_currentPresentationController conformsToProtocol:@protocol(_LNPopupPresentationController)] == NO)
	{
		return nil;
	}
	
	return (id)_currentPresentationController;
}

#pragma mark View Controller Forwarding

- (BOOL)modalPresentationCapturesStatusBarAppearance
{
	return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
	return YES;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
	return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
	return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
	return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
	return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForUserInterfaceStyle
{
	return self.childViewControllers.firstObject;
}

- (BOOL)isModalInPresentation
{
	return self.childViewControllers.firstObject.isModalInPresentation;
}

@end
