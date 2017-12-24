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
@import Darwin;

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;
static const void* LNToolbarBuggy = &LNToolbarBuggy;
static const void* LNPopupAdjustingInsets = &LNPopupAdjustingInsets;

#ifndef LNPopupControllerEnforceStrictClean
//_setContentOverlayInsets:
static NSString* const sCoOvBase64 = @"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOg==";
//_updateContentOverlayInsetsForSelfAndChildren
static NSString* const upCoOvBase64 = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRm9yU2VsZkFuZENoaWxkcmVu";
//_edgeInsetsForChildViewController:insetsAreAbsolute:
static NSString* const edInsBase64 = @"X2VkZ2VJbnNldHNGb3JDaGlsZFZpZXdDb250cm9sbGVyOmluc2V0c0FyZUFic29sdXRlOg==";
//_hideBarWithTransition:isExplicit:
static NSString* const hBWTiEBase64 = @"X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og==";
//_showBarWithTransition:isExplicit:
static NSString* const sBWTiEBase64 = @"X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og==";
//_setToolbarHidden:edge:duration:
static NSString* const sTHedBase64 = @"X3NldFRvb2xiYXJIaWRkZW46ZWRnZTpkdXJhdGlvbjo=";
//_viewControllerUnderlapsStatusBar
static NSString* const vCUSBBase64 = @"X3ZpZXdDb250cm9sbGVyVW5kZXJsYXBzU3RhdHVzQmFy";
//_hideShowNavigationBarDidStop:finished:context:
static NSString* const hSNBDSfcBase64 = @"X2hpZGVTaG93TmF2aWdhdGlvbkJhckRpZFN0b3A6ZmluaXNoZWQ6Y29udGV4dDo=";
//_viewSafeAreaInsetsFromScene
static NSString* const vSAIFSBase64 = @"X3ZpZXdTYWZlQXJlYUluc2V0c0Zyb21TY2VuZQ==";
//_updateContentOverlayInsetsFromParentIfNecessary
static NSString* const uCOIFPINBase64 = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRnJvbVBhcmVudElmTmVjZXNzYXJ5";
//_setContentOverlayInsets:andLeftMargin:rightMargin:
static NSString* const sCOIaLMrMBase64 = @"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOmFuZExlZnRNYXJnaW46cmlnaHRNYXJnaW46";
//_updateLayoutForStatusBarAndInterfaceOrientation
static NSString* const uLFSBAIO = @"X3VwZGF0ZUxheW91dEZvclN0YXR1c0JhckFuZEludGVyZmFjZU9yaWVudGF0aW9u";
//_accessibilitySpeakThisViewController
static NSString* const aSTVC = @"X2FjY2Vzc2liaWxpdHlTcGVha1RoaXNWaWV3Q29udHJvbGxlcg==";
//UIViewControllerAccessibility
static NSString* const uiVCA = @"VUlWaWV3Q29udHJvbGxlckFjY2Vzc2liaWxpdHk=";
//UINavigationControllerAccessibility
static NSString* const uiNVCA = @"VUlOYXZpZ2F0aW9uQ29udHJvbGxlckFjY2Vzc2liaWxpdHk=";
//UITabBarControllerAccessibility
static NSString* const uiTBCA = @"VUlUYWJCYXJDb250cm9sbGVyQWNjZXNzaWJpbGl0eQ==";

static UIViewController* (*__orig_uiVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiNVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiTBCA_aSTVC)(id, SEL);

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

#ifndef LNPopupControllerEnforceStrictClean
static id __accessibilityBundleLoadObserver;
__attribute__((constructor))
static void __accessibilityBundleLoadHandler()
{
	__accessibilityBundleLoadObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSBundleDidLoadNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
		NSBundle* bundle = note.object;
		if([bundle.bundleURL.lastPathComponent isEqualToString:@"UIKit.axbundle"] == NO)
		{
			return;
		}
		
		NSString* selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:aSTVC options:0] encoding:NSUTF8StringEncoding];
		
		NSString* clsName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uiVCA options:0] encoding:NSUTF8StringEncoding];
		Method m1 = class_getInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiVCA_aSTVC = (void*)method_getImplementation(m1);
		Method m2 = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uiNVCA options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiNVCA_aSTVC = (void*)method_getImplementation(m1);
		m2 = class_getInstanceMethod([UINavigationController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uiTBCA options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiTBCA_aSTVC = (void*)method_getImplementation(m1);
		m2 = class_getInstanceMethod([UITabBarController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		[[NSNotificationCenter defaultCenter] removeObserver:__accessibilityBundleLoadObserver];
		__accessibilityBundleLoadObserver = nil;
	}];
}
#endif

@interface UIViewController ()
//_edgeInsetsForChildViewController:insetsAreAbsolute:
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
		
		m1 = class_getInstanceMethod([self class], @selector(setNeedsStatusBarAppearanceUpdate));
		m2 = class_getInstanceMethod([self class], @selector(_ln_setNeedsStatusBarAppearanceUpdate));
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
		
		m1 = class_getInstanceMethod([self class], @selector(presentViewController:animated:completion:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_presentViewController:animated:completion:));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		//_viewControllerUnderlapsStatusBar
		NSString* selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:vCUSBBase64 options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_vCUSB));
		method_exchangeImplementations(m1, m2);
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uLFSBAIO options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
		method_exchangeImplementations(m1, m2);
		
		if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11)
		{
			//_setContentOverlayInsets:
			selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sCoOvBase64 options:0] encoding:NSUTF8StringEncoding];
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			m2 = class_getInstanceMethod([self class], @selector(_sCoOvIns:));
			method_exchangeImplementations(m1, m2);
		}
		else
		{
			//_viewSafeAreaInsetsFromScene
			selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:vSAIFSBase64 options:0] encoding:NSUTF8StringEncoding];
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			if(m1 != nil)
			{
				m2 = class_getInstanceMethod([self class], @selector(_vSAIFS));
				method_exchangeImplementations(m1, m2);
			}
			
			//_updateContentOverlayInsetsFromParentIfNecessary
			selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uCOIFPINBase64 options:0] encoding:NSUTF8StringEncoding];
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			if(m1 != nil)
			{
				m2 = class_getInstanceMethod([self class], @selector(_uCOIFPIN));
				method_exchangeImplementations(m1, m2);
			}
			
			//_setContentOverlayInsets:andLeftMargin:rightMargin:
			selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sCOIaLMrMBase64 options:0] encoding:NSUTF8StringEncoding];
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			if(m1 != nil)
			{
				m2 = class_getInstanceMethod([self class], @selector(_sCOI:aLM:rM:));
				method_exchangeImplementations(m1, m2);
			}
		}
#endif
	});
}

- (void)_ln_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
	if(self.popupPresentationContainerViewController)
	{
		[self.popupPresentationContainerViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
	}
	else
	{
		[self _ln_presentViewController:viewControllerToPresent animated:flag completion:completion];
	}
}

- (void)_ln_setNeedsStatusBarAppearanceUpdate
{
	if(self.popupPresentationContainerViewController)
	{
		[self.popupPresentationContainerViewController setNeedsStatusBarAppearanceUpdate];
	}
	else
	{
		[self _ln_setNeedsStatusBarAppearanceUpdate];
	}
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

- (UIViewController*)_findAncestorParentPopupContainerController
{
	if(self._ln_popupController_nocreate)
	{
		return self;
	}
	
	if(self.parentViewController == nil)
	{
		return nil;
	}
	
	return [self.parentViewController _findAncestorParentPopupContainerController];
}

- (UIViewController*)_findChildInPopupPresentation
{
	if(self._ln_popupController_nocreate)
	{
		return self;
	}
	
	__block UIViewController* vc = nil;
	
	[self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		vc = [obj _findChildInPopupPresentation];
		if(vc != nil)
		{
			*stop = YES;
		}
	}];
	
	return vc;
}

- (nullable UIViewController *)_common_childviewControllersForStatusBarLogic
{
	UIViewController* vcToCheckForPopupPresentation = self;
	if([self isKindOfClass:[UISplitViewController class]])
	{
		vcToCheckForPopupPresentation = [self _findChildInPopupPresentation];
	}
	
	CGFloat statusBarHeightThreshold = UIApplication.sharedApplication.statusBarFrame.size.height / 2;
	
	if((vcToCheckForPopupPresentation._ln_popupController_nocreate.popupControllerTargetState == LNPopupPresentationStateOpen) ||
	   (vcToCheckForPopupPresentation._ln_popupController_nocreate.popupControllerTargetState > LNPopupPresentationStateClosed && vcToCheckForPopupPresentation._ln_popupController_nocreate.popupContentView.frame.origin.y <= statusBarHeightThreshold))
	{
		return vcToCheckForPopupPresentation.popupContentViewController;
	}
	
	return nil;
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarHidden
{
	UIViewController* vc = [self _common_childviewControllersForStatusBarLogic];
	
	return vc ?: [self _ln_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarStyle
{
	UIViewController* vc = [self _common_childviewControllersForStatusBarLogic];
	
	return vc ?: [self _ln_childViewControllerForStatusBarStyle];
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

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	return __orig_uiVCA_aSTVC(self, _cmd);
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_common_uLFSBAIO
{
	if(self.popupContentViewController)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:UIApplication.sharedApplication.statusBarOrientationAnimationDuration delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
				[self.popupContentViewController _uLFSBAIO];
				[self._ln_popupController_nocreate _repositionPopupCloseButton];
			} completion:nil];
		});
	}
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

//_updateContentOverlayInsetsFromParentIfNecessary
- (void)_uCOIFPIN
{
	[self _uCOIFPIN];
}

//_setContentOverlayInsets:andLeftMargin:rightMargin:
- (void)_sCOI:(UIEdgeInsets)insets aLM:(CGFloat)l rM:(CGFloat)r
{
	if([self _isContainedInPopupController])
	{
		if (@available(iOS 11.0, *))
		{
			insets = self.popupPresentationContainerViewController.view.superview.safeAreaInsets;
			insets.top = MAX(self.view.window.safeAreaInsets.top, self.prefersStatusBarHidden == NO ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0);
			insets.bottom = self.view.window.safeAreaInsets.bottom;
			
			UINavigationController* nvc = self.navigationController;
			if(nvc != nil)
			{
				if((self.edgesForExtendedLayout & UIRectEdgeTop) == UIRectEdgeTop)
				{
					insets.top += !nvc.isNavigationBarHidden * nvc.navigationBar.bounds.size.height;
				}
				else
				{
					insets.top = nvc.isNavigationBarHidden ? insets.top : 0;
				}
				
				if((self.edgesForExtendedLayout & UIRectEdgeBottom) == UIRectEdgeBottom)
				{
					insets.bottom += !nvc.isToolbarHidden * nvc.toolbar.bounds.size.height;
				}
				else
				{
					insets.bottom = nvc.isToolbarHidden ? insets.bottom : 0;
				}
			}
			
			UITabBarController* tvc = self.tabBarController;
			if(tvc != nil && tvc.tabBar.window != nil)
			{
				if((self.edgesForExtendedLayout & UIRectEdgeBottom) == UIRectEdgeBottom)
				{
					insets.bottom = tvc.tabBar.bounds.size.height;
				}
				else
				{
					insets.bottom = 0;
				}
			}
		}
	}
	
	[self _sCOI:insets aLM:l rM:r];
}

//_setContentOverlayInsets:
- (void)_sCoOvIns:(UIEdgeInsets)insets
{
	if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11)
	{
		if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && ![self isKindOfClass:[UITabBarController class]] && ![self isKindOfClass:[UINavigationController class]])
		{
			insets.bottom += self.defaultFrameForBottomDockingView_internalOrDeveloper.size.height + self._ln_popupController_nocreate.popupBar.frame.size.height;
		}
		
		if([self _isContainedInPopupController])
		{
			insets.top = self.prefersStatusBarHidden == NO ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0;
			insets.bottom = 0;
		}
	}
	
	[self _sCoOvIns:insets];
}

//_viewSafeAreaInsetsFromScene
- (UIEdgeInsets)_vSAIFS
{
	if([self _isContainedInPopupController])
	{
		if (@available(iOS 11.0, *)) {
			return self.popupPresentationContainerViewController.view.superview.safeAreaInsets;
		}
	}
	
	UIEdgeInsets insets = [self _vSAIFS];
	
	return insets;
}

//_edgeInsetsForChildViewController:insetsAreAbsolute:
- (UIEdgeInsets)_ln_common_eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets insets = [self eIFCVC:controller iAA:absolute];
	
	if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11)
	{
		if([controller _isContainedInPopupController])
		{
			insets.top += controller.prefersStatusBarHidden == NO ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0;
			insets.bottom = 0;
			*absolute = YES;
			
			return insets;
		}
		
		if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden)
		{
			insets.bottom += self._ln_popupController_nocreate.popupBar.bounds.size.height;
		}
	}
	
	return insets;
}

//_viewControllerUnderlapsStatusBar
- (BOOL)_vCUSB
{
	if ([self _isContainedInPopupController])
	{
		UIViewController* statusBarVC = [self childViewControllerForStatusBarHidden] ?: self;
		
		return [statusBarVC prefersStatusBarHidden] == NO;
	}
	
	return [self _vCUSB];
}
#endif

- (void)_layoutPopupBarOrderForTransition
{
	[self.bottomDockingViewForPopup_internalOrDeveloper.superview bringSubviewToFront:self.bottomDockingViewForPopup_internalOrDeveloper];
	[self._ln_popupController_nocreate.popupContentView.superview bringSubviewToFront:self._ln_popupController_nocreate.popupContentView];
	[self._ln_popupController_nocreate.popupBar.superview bringSubviewToFront:self._ln_popupController_nocreate.popupBar];
}

- (void)_layoutPopupBarOrderForUse
{
	[self._ln_popupController_nocreate.popupBar.superview bringSubviewToFront:self._ln_popupController_nocreate.popupBar];
	[self.bottomDockingViewForPopup_internalOrDeveloper.superview bringSubviewToFront:self.bottomDockingViewForPopup_internalOrDeveloper];
	[self._ln_popupController_nocreate.popupContentView.superview bringSubviewToFront:self._ln_popupController_nocreate.popupContentView];
}

- (void)_ln_popup_viewDidLayoutSubviews
{
	[self _ln_popup_viewDidLayoutSubviews];
	
	if(self.bottomDockingViewForPopup_nocreateOrDeveloper != nil)
	{
		if(self.bottomDockingViewForPopup_nocreateOrDeveloper == self._ln_bottomBarSupport_nocreate)
		{
			self._ln_bottomBarSupport.frame = self.defaultFrameForBottomDockingView_internalOrDeveloper;
			[self.view bringSubviewToFront:self._ln_bottomBarSupport];
		}
		else
		{
			self._ln_bottomBarSupport.hidden = YES;
		}
		
		if(self._ignoringLayoutDuringTransition == NO && self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden)
		{
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
		}
		
		if(self._ignoringLayoutDuringTransition == NO)
		{
			[self _layoutPopupBarOrderForUse];
		}
	}
}

- (BOOL)_ignoringLayoutDuringTransition
{
	return [objc_getAssociatedObject(self, LNPopupAdjustingInsets) boolValue];
}

- (void)_setIgnoringLayoutDuringTransition:(BOOL)ignoringLayoutDuringTransition
{
	objc_setAssociatedObject(self, LNPopupAdjustingInsets, @(ignoringLayoutDuringTransition), OBJC_ASSOCIATION_RETAIN);
}

@end

void _LNPopupSupportFixInsetsForViewController(UIViewController* controller, BOOL layout, CGFloat additionalSafeAreaInsetsBottom)
{
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* selName;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//_updateContentOverlayInsetsForSelfAndChildren
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:upCoOvBase64 options:0] encoding:NSUTF8StringEncoding];
	});
	
	void (*dispatchMethod)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
	dispatchMethod(controller, NSSelectorFromString(selName));
	
	[controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
		_LNPopupSupportFixInsetsForViewController(obj, NO, 0);
	}];
	
	if (@available(iOS 11.0, *)) {
		if(controller._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden)
		{
			UIEdgeInsets insets = controller.additionalSafeAreaInsets;
			insets.bottom += additionalSafeAreaInsetsBottom;
			controller.additionalSafeAreaInsets = insets;
		}
	}
	
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

- (BOOL)_isTabBarHiddenDuringTransition
{
	NSNumber* isHidden = objc_getAssociatedObject(self, LNToolbarHiddenBeforeTransition);
	return isHidden.boolValue;
}

- (void)_setTabBarHiddenDuringTransition:(BOOL)toolbarHidden
{
	objc_setAssociatedObject(self, LNToolbarHiddenBeforeTransition, @(toolbarHidden), OBJC_ASSOCIATION_RETAIN);
}

- (nullable UIView *)bottomDockingViewForPopup_nocreate
{
	return self.tabBar;
}

- (nullable UIView *)bottomDockingViewForPopupBar
{
	return self.tabBar;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	if (@available(iOS 11.0, *)) {
		return self.tabBar.hidden == NO && self._isTabBarHiddenDuringTransition == NO ? UIEdgeInsetsZero : self.view.superview.safeAreaInsets;
	} else {
		return UIEdgeInsetsZero;
	}
}

- (CGRect)defaultFrameForBottomDockingView
{
	CGRect bottomBarFrame = self.tabBar.frame;
	CGSize bottomBarSizeThatFits = [self.tabBar sizeThatFits:CGSizeZero];
	bottomBarFrame.size.height = MAX(bottomBarFrame.size.height, bottomBarSizeThatFits.height);
	
	bottomBarFrame.origin = CGPointMake(0, self.view.bounds.size.height - (self._isTabBarHiddenDuringTransition ? 0.0 : bottomBarFrame.size.height));
	
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
		NSString* selName;
		
		//_edgeInsetsForChildViewController:insetsAreAbsolute:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:edInsBase64 options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		//_hideBarWithTransition:isExplicit:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:hBWTiEBase64 options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(hBWT:iE:));
		method_exchangeImplementations(m1, m2);
		
		//_showBarWithTransition:isExplicit:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sBWTiEBase64 options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(sBWT:iE:));
		method_exchangeImplementations(m1, m2);
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uLFSBAIO options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
		method_exchangeImplementations(m1, m2);
#endif
	});
}

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	return __orig_uiTBCA_aSTVC(self, _cmd);
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

//_edgeInsetsForChildViewController:insetsAreAbsolute:
- (UIEdgeInsets)eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets rv = [self _ln_common_eIFCVC:controller iAA:absolute];
	
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && [[self valueForKey:@"isBarHidden"] isEqualToNumber:@YES])
	{
		rv.bottom -= self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	return rv;
}

- (void)__repositionPopupBarToClosed_hack
{
	CGRect defaultFrame = [self defaultFrameForBottomDockingView];
	CGRect frame = self._ln_popupController_nocreate.popupBar.frame;
	frame.origin.y = defaultFrame.origin.y - frame.size.height - self.insetsForBottomDockingView.bottom;
	self._ln_popupController_nocreate.popupBar.frame = frame;
}

//_hideBarWithTransition:isExplicit:
- (void)hBWT:(NSInteger)t iE:(BOOL)e
{
	[self _setTabBarHiddenDuringTransition:YES];
	[self _setIgnoringLayoutDuringTransition:YES];
	
	[self hBWT:t iE:e];
	
	if(t > 0)
	{
		[self _setIgnoringLayoutDuringTransition:YES];
		
		[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:0 animations:^{
			[self __repositionPopupBarToClosed_hack];
		} completion:nil];
		
		[self.selectedViewController.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[self _setIgnoringLayoutDuringTransition:NO];
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
		}];
	}
}

//_showBarWithTransition:isExplicit:
- (void)sBWT:(NSInteger)t iE:(BOOL)e
{
	[self _setTabBarHiddenDuringTransition:NO];
	
	[self sBWT:t iE:e];
	
	if(t > 0)
	{
		[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:0 animations:^{
			[self __repositionPopupBarToClosed_hack];
		} completion:nil];
		
		[self.selectedViewController.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			if(context.isCancelled)
			{
				[self _setTabBarHiddenDuringTransition:YES];
			}
			[UIView animateWithDuration:0.15 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:0 animations:^{
				[self __repositionPopupBarToClosed_hack];
			} completion:^(BOOL finished) {
				[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
			}];
		}];
	}
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

- (nullable UIView *)bottomDockingViewForPopup_nocreate
{
	return self.toolbar;
}

- (nullable UIView *)bottomDockingViewForPopupBar
{
	return self.toolbar;
}

- (CGRect)defaultFrameForBottomDockingView
{
	CGRect toolbarBarFrame = self.toolbar.frame;
	
	toolbarBarFrame.origin = CGPointMake(toolbarBarFrame.origin.x, self.view.bounds.size.height - (self.isToolbarHidden ? 0.0 : toolbarBarFrame.size.height));
	
	return toolbarBarFrame;
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
		
		m1 = class_getInstanceMethod([self class], @selector(setNavigationBarHidden:animated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_setNavigationBarHidden:animated:));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		//_edgeInsetsForChildViewController:insetsAreAbsolute:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:edInsBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		//_setToolbarHidden:edge:duration:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:sTHedBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_sTH:e:d:));
		method_exchangeImplementations(m1, m2);
		
		//_hideShowNavigationBarDidStop:finished:context:
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:hSNBDSfcBase64 options:0] encoding:NSUTF8StringEncoding];
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(hSNBDS:f:c:));
		method_exchangeImplementations(m1, m2);
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:uLFSBAIO options:0] encoding:NSUTF8StringEncoding];
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
		method_exchangeImplementations(m1, m2);
#endif
	});
}

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	return __orig_uiNVCA_aSTVC(self, _cmd);
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

//Support for `hidesBottomBarWhenPushed`.
//_setToolbarHidden:edge:duration:
- (void)_sTH:(BOOL)arg1 e:(unsigned int)arg2 d:(CGFloat)arg3;
{
	//Move popup bar and content according to current state of the toolbar.
	[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
	
	//Trigger the toolbar hide or show transition.
	[self _sTH:arg1 e:arg2 d:arg3];
	
	void (^animations)(void) = ^ {
		//During the transition, animate the popup bar and content together with the toolbar transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
		[self _layoutPopupBarOrderForTransition];
	};
	
	void (^completion)(BOOL finished) = ^ (BOOL finished) {
		//Position the popup bar and content to the superview of the toolbar for the transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerState];
		[self _layoutPopupBarOrderForUse];
	};
	
	if(self.transitionCoordinator)
	{
		[self _setIgnoringLayoutDuringTransition:YES];
		
		[self.transitionCoordinator animateAlongsideTransitionInView:self._ln_popupController_nocreate.popupBar.superview animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			animations();
		} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			completion(context.isCancelled == NO);
			
			[self _setIgnoringLayoutDuringTransition:NO];
		}];
	}
	else
	{
		[UIView animateWithDuration:arg3 animations:animations completion:completion];
	}
}

//_edgeInsetsForChildViewController:insetsAreAbsolute:
- (UIEdgeInsets)eIFCVC:(UIViewController*)controller iAA:(BOOL*)absolute
{
	UIEdgeInsets rv = [self _ln_common_eIFCVC:controller iAA:absolute];
	
	if(self._ln_popupController_nocreate.popupControllerState != LNPopupPresentationStateHidden && self.isToolbarHidden)
	{
		rv.bottom -= self._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	return rv;
}

//_hideShowNavigationBarDidStop:finished:context:
- (void)hSNBDS:(id)arg1 f:(id)arg2 c:(id)arg3;
{
	[self hSNBDS:arg1 f:arg2 c:arg3];
	
	[self _layoutPopupBarOrderForUse];
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

- (void)_ln_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self _ln_setNavigationBarHidden:hidden animated:animated];
	
	[self _layoutPopupBarOrderForUse];
}

@end

@interface UISplitViewController (LNPopupSupportPrivate) @end
@implementation UISplitViewController (LNPopupSupportPrivate)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9)
		{
			Method m1 = class_getInstanceMethod([self class], @selector(viewDidLayoutSubviews));
			Method m2 = class_getInstanceMethod([self class], @selector(_ln_popup_viewDidLayoutSubviews_SplitViewNastyApple));
			method_exchangeImplementations(m1, m2);
		}
	});
}

- (void)_ln_popup_viewDidLayoutSubviews_SplitViewNastyApple
{
	[self _ln_popup_viewDidLayoutSubviews_SplitViewNastyApple];
	
	if(self.bottomDockingViewForPopup_nocreateOrDeveloper != nil)
	{
		//Apple forgot to call the super implementation of viewDidLayoutSubviews, but we need that to layout the popup bar correctly.
		struct objc_super superInfo = {
			self,
			[UIViewController class]
		};
		void (*super_call)(struct objc_super*, SEL) = (void (*)(struct objc_super*, SEL))objc_msgSendSuper;
		super_call(&superInfo, @selector(viewDidLayoutSubviews));
	}
}

@end
