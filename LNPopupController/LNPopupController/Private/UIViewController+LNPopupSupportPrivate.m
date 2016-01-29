//
//  UIViewController+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 1015 Leo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"

@import ObjectiveC;

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;

#ifndef LNPopupControllerEnforceStrictClean
static NSString* const sCoOvBase64 = @"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOg==";
static NSString* const upCoOvBase64 = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRm9yU2VsZkFuZENoaWxkcmVu";
static NSString* const edInsBase64 = @"X2VkZ2VJbnNldHNGb3JDaGlsZFZpZXdDb250cm9sbGVyOmluc2V0c0FyZUFic29sdXRlOg==";
static NSString* const hBWTiEBase64 = @"X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og==";
static NSString* const sBWTiEBase64 = @"X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og==";
static NSString* const sTHedBase64 = @"X3NldFRvb2xiYXJIaWRkZW46ZWRnZTpkdXJhdGlvbjo=";
static NSString* const vCUSBBase64 = @"X3ZpZXdDb250cm9sbGVyVW5kZXJsYXBzU3RhdHVzQmFy";
#endif

/**
 A helper view for view controllers without real bottom bars.
 */
@implementation _LNPopupBottomBarSupport

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self) { self.userInteractionEnabled = NO; self.hidden = YES; }
	return self;
}

@end

@interface UIViewController ()
- (UIEdgeInsets)eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute;
@end
@interface UIViewController (LNPopupLayout) @end
@implementation UIViewController (LNPopupLayout)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Method m1 = class_getInstanceMethod([self class], @selector(viewDidLayoutSubviews));
		Method m2 = class_getInstanceMethod([self class], @selector(_ln_popup_viewDidLayoutSubviews));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarStyle));
		m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarStyle));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarHidden));
		m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarHidden));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(viewWillTransitionToSize:withTransitionCoordinator:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_viewWillTransitionToSize:withTransitionCoordinator:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(willTransitionToTraitCollection:withTransitionCoordinator:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_willTransitionToTraitCollection:withTransitionCoordinator:));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:vCUSBBase64 options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_vCUSB));
		method_exchangeImplementations(m1, m2);
		
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sCoOvBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_sCoOvIns:));
		method_exchangeImplementations(m1, m2);
#endif
	});
}

- (void)_ln_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	if(self._ln_popupController_nocreate)
	{
		[self.popupContentViewController viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	}
	
	[self _ln_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)_ln_willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	if(self._ln_popupController_nocreate)
	{
		[self.popupContentViewController willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	}
	
	[self _ln_willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarHidden
{
	if(self._ln_popupController_nocreate.popupControllerTargetState > LNPopupPresentationStateClosed && self._ln_popupController_nocreate.popupBar.center.y < -10)
	{
		return self.popupContentViewController;
	}
	
	return [self _ln_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarStyle
{
	if(self._ln_popupController_nocreate.popupControllerTargetState > LNPopupPresentationStateClosed && self._ln_popupController_nocreate.popupBar.center.y < -10)
	{
		return self.popupContentViewController;
	}	
	
	return [self _ln_childViewControllerForStatusBarStyle];
}


- (nullable UIViewController *)_ln_childViewControllerForStatusBarHidden
{
	return [self _ln_common_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_childViewControllerForStatusBarStyle
{
	return [self _ln_common_childViewControllerForStatusBarStyle];
}

#ifndef LNPopupControllerEnforceStrictClean
- (void)_sCoOvIns:(UIEdgeInsets)insets
{
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && ![self isKindOfClass:[UITabBarController class]] && ![self isKindOfClass:[UINavigationController class]])
	{
		insets.bottom += self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	[self _sCoOvIns:insets];
}

- (UIEdgeInsets)_ln_common_eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets insets = [self eIFCVC:controller iAA:absolute];
	
	if(controller == self.popupContentViewController)
	{
		insets.top = controller.prefersStatusBarHidden == NO ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0;
		insets.bottom = 0;
		*absolute = YES;
		
		return insets;
	}
	
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden)
	{
		insets.bottom += self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	return insets;
}

- (BOOL)_vCUSB
{
	if(self.popupPresentationContainerViewController != nil)
	{
		UIViewController* statusBarVC = [self childViewControllerForStatusBarHidden] ?: self;
		
		return [statusBarVC prefersStatusBarHidden] == NO;
	}
	
	return [self _vCUSB];
}
#endif

- (void)_ln_popup_viewDidLayoutSubviews
{
	[self _ln_popup_viewDidLayoutSubviews];
	
	if(self.bottomDockingViewForPopup_nocreate != nil)
	{
		if(self.bottomDockingViewForPopup == self._ln_bottomBarSupport)
		{
			self._ln_bottomBarSupport.frame = self.defaultFrameForBottomDockingView;
			[self.view bringSubviewToFront:self._ln_bottomBarSupport];
		}
		else
		{
			self._ln_bottomBarSupport.hidden = YES;
		}
		
		if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden)
		{
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
		}
	}
}

@end

void _LNPopupSupportFixInsetsForViewController(UIViewController* controller, BOOL layout)
{
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* selName;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:upCoOvBase64 options:0] encoding:NSUTF8StringEncoding];
	});
	
	void (*dispatchMethod)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
	
	dispatchMethod(controller, NSSelectorFromString(selName));
	
	[controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
		_LNPopupSupportFixInsetsForViewController(obj, NO);
	}];
	
	if(layout)
	{
		[controller.view setNeedsUpdateConstraints];
		[controller.view setNeedsLayout];
		[controller.view layoutIfNeeded];
	}
#endif
}

@interface UITabBarController (LNPopupSupportPrivate) @end
@implementation UITabBarController (LNPopupSupportPrivate)

- (nullable UIView *)bottomDockingViewForPopup_nocreate
{
	return self.tabBar;
}

- (nonnull UIView *)bottomDockingViewForPopup
{
	return self.tabBar;
}

- (CGRect)defaultFrameForBottomDockingView
{
	CGRect bottomBarFrame = self.tabBar.frame;
	
	bottomBarFrame.origin = CGPointMake(0, self.view.bounds.size.height - bottomBarFrame.size.height);

	return bottomBarFrame;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Method m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarStyle));
		Method m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarStyle));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarHidden));
		m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarHidden));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:edInsBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:hBWTiEBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(hBWT:iE:));
		method_exchangeImplementations(m1, m2);
		
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sBWTiEBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(sBWT:iE:));
		method_exchangeImplementations(m1, m2);
#endif
	});
}

#ifndef LNPopupControllerEnforceStrictClean

- (UIEdgeInsets)eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets rv = [self _ln_common_eIFCVC:controller iAA:absolute];
	
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && [[self valueForKey:@"isBarHidden"] isEqualToNumber:@YES])
	{
		rv.bottom -= self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	return rv;
}

- (void)hBWT:(NSInteger)t iE:(BOOL)e
{
	[self hBWT:t iE:e];
	[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];
	[self._ln_popupController_nocreate.popupBar setHidden:self.tabBar.hidden];
	[self._ln_popupController_nocreate.popupContentView setHidden:self.tabBar.hidden];
	
	[self.selectedViewController.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context)
	{
		[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];
		[self._ln_popupController_nocreate.popupBar setHidden:self.tabBar.hidden];
		[self._ln_popupController_nocreate.popupContentView setHidden:self.tabBar.hidden];
	}];
}

- (void)sBWT:(NSInteger)t iE:(BOOL)e
{
	[self sBWT:t iE:e];
	[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];
	[self._ln_popupController_nocreate.popupBar setHidden:self.tabBar.hidden];
	[self._ln_popupController_nocreate.popupContentView setHidden:self.tabBar.hidden];
	
	[self.selectedViewController.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context)
	{
		[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];
		[self._ln_popupController_nocreate.popupBar setHidden:self.tabBar.hidden];
		[self._ln_popupController_nocreate.popupContentView setHidden:self.tabBar.hidden];
	}];
}
#endif

- (nullable UIViewController *)_ln_childViewControllerForStatusBarHidden
{
	return [self _ln_common_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_childViewControllerForStatusBarStyle
{
	return [self _ln_common_childViewControllerForStatusBarStyle];
}

@end

@interface UINavigationController (LNPopupSupportPrivate) @end
@implementation UINavigationController (LNPopupSupportPrivate)

- (BOOL)isToolbarHiddenDuringTransition
{
	NSNumber* isHidden = objc_getAssociatedObject(self, LNToolbarHiddenBeforeTransition);
	
	if(isHidden == nil)
	{
		return self.isToolbarHidden;
	}
	
	return isHidden.boolValue;
}

- (void)setToolbarHiddenDuringTransition:(BOOL)toolbarHidden
{
	objc_setAssociatedObject(self, LNToolbarHiddenBeforeTransition, @(toolbarHidden), OBJC_ASSOCIATION_RETAIN);
}

- (nullable UIView *)bottomDockingViewForPopup_nocreate
{
	return self.toolbar;
}

- (nonnull UIView *)bottomDockingViewForPopup
{
	return self.toolbar;
}

- (CGRect)defaultFrameForBottomDockingView
{
	CGRect bottomBarFrame = self.toolbar.frame;
	
	if(self.isToolbarHiddenDuringTransition)
	{
		bottomBarFrame.origin = CGPointMake(bottomBarFrame.origin.x, self.view.bounds.size.height);
	}
	else
	{
		bottomBarFrame.origin = CGPointMake(bottomBarFrame.origin.x, self.view.bounds.size.height - bottomBarFrame.size.height);
	}
	
	return bottomBarFrame;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Method m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarStyle));
		Method m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarStyle));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarHidden));
		m2 = class_getInstanceMethod([self class], @selector(_ln_childViewControllerForStatusBarHidden));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:edInsBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sTHedBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_sTH:e:d:));
		method_exchangeImplementations(m1, m2);
#endif

	});
}

//Support for `hidesBottomBarWhenPushed`.
- (void)_sTH:(BOOL)arg1 e:(unsigned int)arg2 d:(double)arg3;
{
	//During transition, the toolbar is displayed throught the entire animation, despite what `isToolbarHidden` may indicate.
	[self setToolbarHiddenDuringTransition:(self.isToolbarHidden == arg1 && arg1 == YES)];
	
	//Move popup bar and content according to current state of the toolbar.
	[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
	
	//Trigger the toolbar hide or show transition.
	[self _sTH:arg1 e:arg2 d:arg3];
	
	//Display or hide the popup bar and content as needed.
	[self._ln_popupController_nocreate.popupBar setHidden:self.isToolbarHiddenDuringTransition];
	[self._ln_popupController_nocreate.popupContentView setHidden:self.isToolbarHiddenDuringTransition];
	//Position the popup bar and content to the superview of the toolbar for the transition.
	[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];
	
	[[self transitionCoordinator] animateAlongsideTransitionInView:self._ln_popupController_nocreate.popupBar.superview animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		//During the transition, animate the popup bar and content together with the toolbar transition.
		
		
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

		[self setToolbarHiddenDuringTransition:arg1];
		//Position the popup bar and content to the superview of the toolbar for the transition.
		
		[self._ln_popupController_nocreate _movePopupBarAndContentToBottomBarSuperview];

		//Display or hide the popup bar and content as needed.
		[self._ln_popupController_nocreate.popupBar setHidden:self.isToolbarHiddenDuringTransition];
		[self._ln_popupController_nocreate.popupContentView setHidden:self.isToolbarHiddenDuringTransition];
	}];
}

#ifndef LNPopupControllerEnforceStrictClean
- (UIEdgeInsets)eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets rv = [self _ln_common_eIFCVC:controller iAA:absolute];
	
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && self.isToolbarHidden)
	{
		rv.bottom -= self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	return rv;
}
#endif

- (nullable UIViewController *)_ln_childViewControllerForStatusBarHidden
{
	return [self _ln_common_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_childViewControllerForStatusBarStyle
{
	return [self _ln_common_childViewControllerForStatusBarStyle];
}

@end
