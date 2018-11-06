//
//  UIViewController+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 1015 Leo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupBase64Utils.h"

@import ObjectiveC;
@import Darwin;

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;
static const void* LNToolbarBuggy = &LNToolbarBuggy;
static const void* LNPopupAdjustingInsets = &LNPopupAdjustingInsets;
static const void* LNPopupAdditionalSafeAreaInsets = &LNPopupAdditionalSafeAreaInsets;
static const void* LNUserAdditionalSafeAreaInsets = &LNUserAdditionalSafeAreaInsets;

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
		
		NSString* selName = _LNPopupDecodeBase64String(aSTVC);
		
		NSString* clsName = _LNPopupDecodeBase64String(uiVCA);
		Method m1 = class_getInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiVCA_aSTVC = (void*)method_getImplementation(m1);
		Method m2 = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = _LNPopupDecodeBase64String(uiNVCA);
		m1 = class_getInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiNVCA_aSTVC = (void*)method_getImplementation(m1);
		m2 = class_getInstanceMethod([UINavigationController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = _LNPopupDecodeBase64String(uiTBCA);
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
		
		m1 = class_getInstanceMethod([self class], @selector(additionalSafeAreaInsets));
		m2 = class_getInstanceMethod([self class], @selector(_ln_additionalSafeAreaInsets));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(setAdditionalSafeAreaInsets:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_setAdditionalSafeAreaInsets:));
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
		NSString* selName = _LNPopupDecodeBase64String(vCUSBBase64);
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_vCUSB));
		method_exchangeImplementations(m1, m2);
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = _LNPopupDecodeBase64String(uLFSBAIO);
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
		method_exchangeImplementations(m1, m2);
		
		if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11)
		{
			//_setContentOverlayInsets:
			selName = _LNPopupDecodeBase64String(sCoOvBase64);
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			m2 = class_getInstanceMethod([self class], @selector(_sCoOvIns:));
			method_exchangeImplementations(m1, m2);
		}
		else
		{
			//_viewSafeAreaInsetsFromScene
			selName = _LNPopupDecodeBase64String(vSAIFSBase64);
			m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
			if(m1 != nil)
			{
				m2 = class_getInstanceMethod([self class], @selector(_vSAIFS));
				method_exchangeImplementations(m1, m2);
			}
		}
#endif
	});
}

static UIEdgeInsets __LNEdgeInsetsSum(UIEdgeInsets userEdgeInsets, UIEdgeInsets popupUserEdgeInsets)
{
	UIEdgeInsets final = userEdgeInsets;
	final.bottom += popupUserEdgeInsets.bottom;
	final.top += popupUserEdgeInsets.top;
	final.left += popupUserEdgeInsets.left;
	final.right += popupUserEdgeInsets.right;
	
	return final;
}

- (void)_ln_updateUserSafeAreaInsets:(UIEdgeInsets)userEdgeInsets popupSafeAreaInsets:(UIEdgeInsets)popupUserEdgeInsets
{
	UIEdgeInsets final = __LNEdgeInsetsSum(userEdgeInsets, popupUserEdgeInsets);
	
	[self _ln_setAdditionalSafeAreaInsets:final];
}

- (void)_ln_setPopupSafeAreaInsets:(UIEdgeInsets)additionalSafeAreaInsets
{
	objc_setAssociatedObject(self, LNPopupAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIEdgeInsets user = [objc_getAssociatedObject(self, LNUserAdditionalSafeAreaInsets) UIEdgeInsetsValue];
	
	[self _ln_updateUserSafeAreaInsets:user popupSafeAreaInsets:additionalSafeAreaInsets];
}

- (void)_ln_setAdditionalSafeAreaInsets:(UIEdgeInsets)additionalSafeAreaInsets
{
	objc_setAssociatedObject(self, LNUserAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIEdgeInsets popup = [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
	
	[self _ln_updateUserSafeAreaInsets:additionalSafeAreaInsets popupSafeAreaInsets:popup];
}

- (UIEdgeInsets)_ln_popupSafeAreaInsets
{
	return [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

- (UIEdgeInsets)_ln_additionalSafeAreaInsets
{
	UIEdgeInsets user = [objc_getAssociatedObject(self, LNUserAdditionalSafeAreaInsets) UIEdgeInsetsValue];
	UIEdgeInsets popup = [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
	
	return __LNEdgeInsetsSum(user, popup);
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

static inline __attribute__((always_inline)) void _LNPopupSupportSetPopupInsetsForViewController_modern(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets)
{
	if([controller isKindOfClass:UITabBarController.class] || [controller isKindOfClass:UINavigationController.class] || [controller isKindOfClass:UISplitViewController.class])
	{
		[((UINavigationController*)controller).viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
			_LNPopupSupportSetPopupInsetsForViewController_modern(obj, NO, popupEdgeInsets);
		}];
	}
	else
	{
		[controller _ln_setPopupSafeAreaInsets:popupEdgeInsets];
	}
	
	if(layout)
	{
		[controller.view setNeedsUpdateConstraints];
		[controller.view setNeedsLayout];
		[controller.view layoutIfNeeded];
	}
}

static inline __attribute__((always_inline)) void _LNPopupSupportFixInsetsForViewController_legacy(UIViewController* controller, BOOL layout)
{
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* selName;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//_updateContentOverlayInsetsForSelfAndChildren
		selName = _LNPopupDecodeBase64String(upCoOvBase64);
	});
	
	void (*dispatchMethod)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
	dispatchMethod(controller, NSSelectorFromString(selName));
	
	[controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
		_LNPopupSupportFixInsetsForViewController_legacy(obj, NO);
	}];
	
	if(layout)
	{
		[controller.view setNeedsUpdateConstraints];
		[controller.view setNeedsLayout];
		[controller.view layoutIfNeeded];
	}
#endif
}

void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets)
{
	
	if (@available(iOS 11.0, *))
	{
		_LNPopupSupportSetPopupInsetsForViewController_modern(controller, layout, popupEdgeInsets);
	}
	else
	{
		_LNPopupSupportFixInsetsForViewController_legacy(controller, layout);
	}
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
		
		m1 = class_getInstanceMethod([self class], @selector(setViewControllers:animated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_setViewControllers:animated:));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		
		//_edgeInsetsForChildViewController:insetsAreAbsolute:
		selName = _LNPopupDecodeBase64String(edInsBase64);
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		//_hideBarWithTransition:isExplicit:
		selName = _LNPopupDecodeBase64String(hBWTiEBase64);
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(hBWT:iE:));
		method_exchangeImplementations(m1, m2);
		
		//_showBarWithTransition:isExplicit:
		selName = _LNPopupDecodeBase64String(sBWTiEBase64);
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(sBWT:iE:));
		method_exchangeImplementations(m1, m2);
		
//		//_updateLayoutForStatusBarAndInterfaceOrientation
//		selName = _LNPopupDecodeBase64String(uLFSBAIO);
//		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
//		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
//		method_exchangeImplementations(m1, m2);
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
	return [self _ln_common_eIFCVC:controller iAA:absolute];
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

- (void)_ln_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
	[viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		_LNPopupSupportSetPopupInsetsForViewController(obj, NO, self.viewControllers.firstObject._ln_popupSafeAreaInsets);
	}];
	
	[self _ln_setViewControllers:viewControllers animated:animated];
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
		
		m1 = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_pushViewController:animated:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_popViewControllerAnimated:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(popToRootViewControllerAnimated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_popToRootViewControllerAnimated:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod([self class], @selector(setViewControllers:animated:));
		m2 = class_getInstanceMethod([self class], @selector(_ln_setViewControllers:animated:));
		method_exchangeImplementations(m1, m2);
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		//_edgeInsetsForChildViewController:insetsAreAbsolute:
		selName = _LNPopupDecodeBase64String(edInsBase64);
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(eIFCVC:iAA:));
		method_exchangeImplementations(m1, m2);
		
		//_setToolbarHidden:edge:duration:
		selName = _LNPopupDecodeBase64String(sTHedBase64);
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(_sTH:e:d:));
		method_exchangeImplementations(m1, m2);
		
		//_hideShowNavigationBarDidStop:finished:context:
		selName = _LNPopupDecodeBase64String(hSNBDSfcBase64);
		
		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
		m2 = class_getInstanceMethod([self class], @selector(hSNBDS:f:c:));
		method_exchangeImplementations(m1, m2);
		
//		//_updateLayoutForStatusBarAndInterfaceOrientation
//		selName = _LNPopupDecodeBase64String(uLFSBAIO);
//		m1 = class_getInstanceMethod([self class], NSSelectorFromString(selName));
//		m2 = class_getInstanceMethod([self class], @selector(_uLFSBAIO));
//		method_exchangeImplementations(m1, m2);
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
	return [self _ln_common_eIFCVC:controller iAA:absolute];
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

- (void)_ln_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	_LNPopupSupportSetPopupInsetsForViewController(viewController, NO, self.topViewController._ln_popupSafeAreaInsets);
	
	[self _ln_pushViewController:viewController animated:animated];
}

- (NSArray<__kindof UIViewController*>*)_ln_popToRootViewControllerAnimated:(BOOL)animated
{
	NSArray<__kindof UIViewController*>* rv = [self _ln_popToRootViewControllerAnimated:animated];
	
	void (^block)(void) = ^ {
		[rv enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			_LNPopupSupportSetPopupInsetsForViewController(obj, NO, UIEdgeInsetsZero);
		}];
	};
	
	if(self.transitionCoordinator == nil)
	{
		block();
	}
	else
	{
		[self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			if(context.isCancelled == NO)
			{
				block();
			}
		}];
	}
	
	return rv;
}

- (UIViewController*)_ln_popViewControllerAnimated:(BOOL)animated
{
	UIViewController* vc = [self _ln_popViewControllerAnimated:animated];
	
	void (^block)(void) = ^ {
		_LNPopupSupportSetPopupInsetsForViewController(vc, NO, UIEdgeInsetsZero);
	};
	
	if(self.transitionCoordinator == nil)
	{
		block();
	}
	else
	{
		[self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			if(context.isCancelled == NO)
			{
				block();
			}
		}];
	}
	
	return vc;
}

- (void)_ln_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
	[viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		_LNPopupSupportSetPopupInsetsForViewController(obj, NO, self.topViewController._ln_popupSafeAreaInsets);
	}];
	
	[self _ln_setViewControllers:viewControllers animated:animated];
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
			
			m1 = class_getInstanceMethod([self class], @selector(setViewControllers:animated:));
			m2 = class_getInstanceMethod([self class], @selector(_ln_setViewControllers:animated:));
			method_exchangeImplementations(m1, m2);
			
			m1 = class_getInstanceMethod([self class], @selector(addChildViewController:));
			m2 = class_getInstanceMethod([self class], @selector(_ln_addChildViewController:));
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

- (void)_ln_addChildViewController:(UIViewController *)childController
{
	_LNPopupSupportSetPopupInsetsForViewController(childController, NO, self.viewControllers.firstObject._ln_popupSafeAreaInsets);
	
	[self _ln_addChildViewController:childController];
	
}

- (void)_ln_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
	[viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		_LNPopupSupportSetPopupInsetsForViewController(obj, NO, self.viewControllers.firstObject._ln_popupSafeAreaInsets);
	}];
	
	[self _ln_setViewControllers:viewControllers animated:animated];
}

@end
