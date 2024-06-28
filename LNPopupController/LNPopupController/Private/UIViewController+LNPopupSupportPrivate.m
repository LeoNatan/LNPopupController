//
//  UIViewController+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupSwizzlingUtils.h"
#import "UIView+LNPopupSupportPrivate.h"

@import ObjectiveC;
@import Darwin;

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;
static const void* LNPopupAdjustingInsets = &LNPopupAdjustingInsets;
static const void* LNPopupAdditionalSafeAreaInsets = &LNPopupAdditionalSafeAreaInsets;
static const void* LNUserAdditionalSafeAreaInsets = &LNUserAdditionalSafeAreaInsets;
static const void* LNPopupChildAdditiveSafeAreaInsets = &LNPopupChildAdditiveSafeAreaInsets;
static const void* LNPopupIgnorePrepareTabBar = &LNPopupIgnorePrepareTabBar;
static const void* LNPopupBarExtensionView = &LNPopupBarExtensionView;

static NSSet<Class>* __LNPopupBuggyAdditionalSafeAreaClasses;
static void __LNPopupUpdateChildInsets(UIViewController* controller);
static BOOL __LNPopupIsClassBuggyForAdditionalSafeArea(UIViewController* controller);

BOOL __ln_popup_suppressViewControllerLifecycle = NO;

@interface __LNFakeContext: NSObject

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@end
@implementation __LNFakeContext @end

@interface _LNPopupBarExtensionView : _LNPopupBarBackgroundView @end
@implementation _LNPopupBarExtensionView

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

@end

@interface NSObject ()

@property (nonatomic, readonly) BOOL _ln_popupUIRequiresZeroInsets;

@end

#ifndef LNPopupControllerEnforceStrictClean
//_hideBarWithTransition:isExplicit:duration:
static NSString* const hBWTiEDBase64 = @"X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0OmR1cmF0aW9uOg==";
//_showBarWithTransition:isExplicit:duration:
static NSString* const sBWTiEDBase64 = @"X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0OmR1cmF0aW9uOg==";
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
//_updateContentOverlayInsetsFromParentIfNecessary
static NSString* const uCOIFPIN = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRnJvbVBhcmVudElmTmVjZXNzYXJ5";
//_accessibilitySpeakThisViewController
static NSString* const aSTVC = @"X2FjY2Vzc2liaWxpdHlTcGVha1RoaXNWaWV3Q29udHJvbGxlcg==";
//setParentViewController:
static NSString* const sPVC = @"c2V0UGFyZW50Vmlld0NvbnRyb2xsZXI6";
//UIViewControllerAccessibility
static NSString* const uiVCA = @"VUlWaWV3Q29udHJvbGxlckFjY2Vzc2liaWxpdHk=";
//UINavigationControllerAccessibility
static NSString* const uiNVCA = @"VUlOYXZpZ2F0aW9uQ29udHJvbGxlckFjY2Vzc2liaWxpdHk=";
//UITabBarControllerAccessibility
static NSString* const uiTBCA = @"VUlUYWJCYXJDb250cm9sbGVyQWNjZXNzaWJpbGl0eQ==";
//_prepareTabBar
static NSString* const pTBBase64 = @"X3ByZXBhcmVUYWJCYXI=";

//_setContentOverlayInsets:andLeftMargin:rightMargin:
static NSString* const sCOIaLMrM = @"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOmFuZExlZnRNYXJnaW46cmlnaHRNYXJnaW46";
//_contentMargin
static NSString* const cM = @"X2NvbnRlbnRNYXJnaW4=";
//_setContentMargin:
static NSString* const sCM = @"X3NldENvbnRlbnRNYXJnaW46";

//_accessibilitySpeakThisViewController
static UIViewController* (*__orig_uiVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiNVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiTBCA_aSTVC)(id, SEL);

#endif

/**
 A helper view for view controllers without real bottom bars.
 */
@implementation _LNPopupBottomBarSupport
{
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.userInteractionEnabled = NO;
//		self.hidden = YES;
	}
	return self;
}

@end

#ifndef LNPopupControllerEnforceStrictClean
static id __accessibilityBundleLoadObserver;
__attribute__((constructor))
static void __accessibilityBundleLoadHandler(void)
{
	__accessibilityBundleLoadObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSBundleDidLoadNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
		NSBundle* bundle = note.object;
		if([bundle.bundleURL.lastPathComponent isEqualToString:@"UIKit.axbundle"] == NO)
		{
			return;
		}
		
		NSString* selName = _LNPopupDecodeBase64String(aSTVC);
		
		//UIViewControllerAccessibility
		//_accessibilitySpeakThisViewController
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

#pragma mark - UIViewController

@interface UIViewController (LNPopupLayout) @end
@implementation UIViewController (LNPopupLayout)

+ (void)load
{
	@autoreleasepool
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			__LNPopupBuggyAdditionalSafeAreaClasses = [NSSet setWithObjects:UINavigationController.class, UITabBarController.class, nil];
			
			LNSwizzleMethod(self,
							@selector(isModalInPresentation),
							@selector(_ln_isModalInPresentation));
			
			LNSwizzleMethod(self,
							@selector(setOverrideUserInterfaceStyle:),
							@selector(_ln_popup_setOverrideUserInterfaceStyle:));
			
			LNSwizzleMethod(self,
							@selector(viewWillAppear:),
							@selector(_ln_popup_viewWillAppear:));
			
			LNSwizzleMethod(self,
							@selector(viewDidAppear:),
							@selector(_ln_popup_viewDidAppear:));
			
			LNSwizzleMethod(self,
							@selector(viewWillDisappear:),
							@selector(_ln_popup_viewWillDisappear:));
			
			LNSwizzleMethod(self,
							@selector(viewDidDisappear:),
							@selector(_ln_popup_viewDidDisappear:));
			
			LNSwizzleMethod(self,
							@selector(viewDidLayoutSubviews),
							@selector(_ln_popup_viewDidLayoutSubviews));
			
			LNSwizzleMethod(self,
							@selector(additionalSafeAreaInsets),
							@selector(_ln_additionalSafeAreaInsets));
			
			LNSwizzleMethod(self,
							@selector(setAdditionalSafeAreaInsets:),
							@selector(_ln_setAdditionalSafeAreaInsets:));
			
			LNSwizzleMethod(self,
							@selector(setNeedsStatusBarAppearanceUpdate),
							@selector(_ln_setNeedsStatusBarAppearanceUpdate));
			
			LNSwizzleMethod(self,
							@selector(setNeedsUpdateOfHomeIndicatorAutoHidden),
							@selector(_ln_setNeedsUpdateOfHomeIndicatorAutoHidden));
			
			LNSwizzleMethod(self,
							@selector(childViewControllerForStatusBarStyle),
							@selector(_ln_childViewControllerForStatusBarStyle));
			
			LNSwizzleMethod(self,
							@selector(childViewControllerForStatusBarHidden),
							@selector(_ln_childViewControllerForStatusBarHidden));
			
			LNSwizzleMethod(self,
							@selector(childViewControllerForHomeIndicatorAutoHidden),
							@selector(_ln_childViewControllerForHomeIndicatorAutoHidden));
			
			LNSwizzleMethod(self,
							@selector(viewWillTransitionToSize:withTransitionCoordinator:),
							@selector(_ln_viewWillTransitionToSize:withTransitionCoordinator:));
			
			LNSwizzleMethod(self,
							@selector(willTransitionToTraitCollection:withTransitionCoordinator:),
							@selector(_ln_willTransitionToTraitCollection:withTransitionCoordinator:));
			
			LNSwizzleMethod(self,
							@selector(presentViewController:animated:completion:),
							@selector(_ln_presentViewController:animated:completion:));
			
#ifndef LNPopupControllerEnforceStrictClean
			//_viewControllerUnderlapsStatusBar
			NSString* selName = _LNPopupDecodeBase64String(vCUSBBase64);
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_vCUSB));
			
			//_updateLayoutForStatusBarAndInterfaceOrientation
			selName = _LNPopupDecodeBase64String(uLFSBAIO);
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_uLFSBAIO));
			
			if(@available(iOS 15.0, *))
			{
				//_updateContentOverlayInsetsFromParentIfNecessary
				selName = _LNPopupDecodeBase64String(uCOIFPIN);
				LNSwizzleMethod(self,
								NSSelectorFromString(selName),
								@selector(_uCOIFPIN));
				
				
			}
			else
			{
				//_viewSafeAreaInsetsFromScene
				selName = _LNPopupDecodeBase64String(vSAIFSBase64);
				LNSwizzleMethod(self,
								NSSelectorFromString(selName),
								@selector(_vSAIFS));
			}
			
			//setParentViewController:
			selName = _LNPopupDecodeBase64String(sPVC);
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_ln_sPVC:));
#endif
		});
	}
}

- (BOOL)_ln_isModalInPresentation
{
	if(self._ln_popupController_nocreate.popupControllerInternalState >= _LNPopupPresentationStateTransitioning)
	{
		return YES;
	}
	
	return [self _ln_isModalInPresentation];
}

- (void)_ln_popup_setOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle
{
	[self _ln_popup_setOverrideUserInterfaceStyle:overrideUserInterfaceStyle];
	
	if(self._isContainedInPopupController)
	{
		[self.popupPresentationContainerViewController.popupContentView setControllerOverrideUserInterfaceStyle:overrideUserInterfaceStyle];
	}
}

- (BOOL)_ln_reallyShouldExtendPopupBarUnderSafeArea
{
	return self._ln_popupController_nocreate.popupBar.resolvedStyle != LNPopupBarStyleFloating && self.shouldExtendPopupBarUnderSafeArea;
}

- (BOOL)_ln_shouldDisplayBottomShadowViewDuringTransition
{
	BOOL bottomBarExtensionIsVisible = self._ln_bottomBarExtension_nocreate.isHidden == NO && self._ln_bottomBarExtension_nocreate.alpha > 0 && self._ln_bottomBarExtension_nocreate.frame.size.height > 0;
	BOOL backgroundVisible = self.ln_popupController.popupBar.backgroundView.isHidden == NO && self.ln_popupController.popupBar.backgroundView.alpha > 0;
	BOOL bottomBarVisible = self.ln_popupController.bottomBar.hidden == NO;
	
	return bottomBarExtensionIsVisible == NO && backgroundVisible == YES && bottomBarVisible == YES;
}

static inline __attribute__((always_inline)) void _LNUpdateUserSafeAreaInsets(id self, UIEdgeInsets userEdgeInsets, UIEdgeInsets popupUserEdgeInsets)
{
	UIEdgeInsets final = __LNEdgeInsetsSum(userEdgeInsets, popupUserEdgeInsets);
	
	[self _ln_setAdditionalSafeAreaInsets:final];
}

static inline __attribute__((always_inline)) void _LNSetPopupSafeAreaInsets(id self, UIEdgeInsets additionalSafeAreaInsets)
{
	objc_setAssociatedObject(self, LNPopupAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIEdgeInsets user = _LNUserSafeAreas(self);
	
	_LNUpdateUserSafeAreaInsets(self, user, additionalSafeAreaInsets);
}

- (void)_ln_setAdditionalSafeAreaInsets:(UIEdgeInsets)additionalSafeAreaInsets
{
	objc_setAssociatedObject(self, LNUserAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIEdgeInsets popup = _LNPopupSafeAreas(self);
	
	_LNUpdateUserSafeAreaInsets(self, additionalSafeAreaInsets, popup);
}

- (void)_ln_setChildAdditiveSafeAreaInsets:(UIEdgeInsets)childAdditiveSafeAreaInsets
{
	objc_setAssociatedObject(self, LNPopupChildAdditiveSafeAreaInsets, [NSValue valueWithUIEdgeInsets:childAdditiveSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

UIEdgeInsets _LNPopupSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

static inline __attribute__((always_inline)) UIEdgeInsets _LNUserSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNUserAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

UIEdgeInsets _LNPopupChildAdditiveSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNPopupChildAdditiveSafeAreaInsets) UIEdgeInsetsValue];
}

- (UIEdgeInsets)_ln_additionalSafeAreaInsets
{
	UIEdgeInsets user = _LNPopupSafeAreas(self);
	UIEdgeInsets popup = _LNUserSafeAreas(self);
	
	return __LNEdgeInsetsSum(user, popup);
}

- (UIEdgeInsets)_ln_popupSafeAreaInsetsForChildController
{
	UIViewController* vc = self;
	while(vc != nil && vc._ln_popupController_nocreate == nil)
	{
		vc = vc.parentViewController;
	}
	
	CGRect barFrame = vc._ln_popupController_nocreate.popupBar.frame;
	return UIEdgeInsetsMake(0, 0, barFrame.size.height, 0);
}

//setParentViewController:
- (void)_ln_sPVC:(UIViewController*)parentViewController
{
	[self _ln_sPVC:parentViewController];
	
	__LNPopupUpdateChildInsets(self);
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

- (void)_ln_setNeedsUpdateOfHomeIndicatorAutoHidden
{
	if(self.popupPresentationContainerViewController)
	{
		[self.popupPresentationContainerViewController setNeedsUpdateOfHomeIndicatorAutoHidden];
	}
	else
	{
		[self _ln_setNeedsUpdateOfHomeIndicatorAutoHidden];
	}
}

- (void)_ln_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	if(self._ln_popupController_nocreate)
	{
		[self.popupContentViewController viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	}
	
	if(self._ln_popupController_nocreate.popupBar.customBarViewController != nil)
	{
		[self._ln_popupController_nocreate.popupBar _transitionCustomBarViewControllerWithPopupContainerSize:size withCoordinator:coordinator];
	}
	
	[self _ln_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)_ln_willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	if(self._ln_popupController_nocreate)
	{
		[self.popupContentViewController willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	}
	
	if(self._ln_popupController_nocreate.popupBar.customBarViewController != nil)
	{
		[self._ln_popupController_nocreate.popupBar _transitionCustomBarViewControllerWithPopupContainerTraitCollection:newCollection withCoordinator:coordinator];
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

- (nullable UIViewController *)_common_childViewControllersForStatusBarLogic
{
	UIViewController* vcToCheckForPopupPresentation = self;
	if([self isKindOfClass:[UISplitViewController class]])
	{
		vcToCheckForPopupPresentation = [self _findChildInPopupPresentation];
	}
	
	if(vcToCheckForPopupPresentation._ln_popupController_nocreate == nil)
	{
		return nil;
	}
	
	CGFloat statusBarHeight = [LNPopupController _statusBarHeightForView:self.isViewLoaded ? self.view : nil];
	
	if((vcToCheckForPopupPresentation._ln_popupController_nocreate.popupControllerTargetState == LNPopupPresentationStateOpen) ||
	   (vcToCheckForPopupPresentation._ln_popupController_nocreate.popupControllerTargetState > LNPopupPresentationStateBarPresented && vcToCheckForPopupPresentation._ln_popupController_nocreate.popupContentView.frame.origin.y <= (statusBarHeight / 2)))
	{
		return vcToCheckForPopupPresentation.popupContentViewController;
	}
	
	return nil;
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarHidden
{
	UIViewController* vc = [self _common_childViewControllersForStatusBarLogic];
	
	return vc ?: [self _ln_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_common_childViewControllerForStatusBarStyle
{
	UIViewController* vc = [self _common_childViewControllersForStatusBarLogic];
	
	return vc ?: [self _ln_childViewControllerForStatusBarStyle];
}

- (nullable UIViewController *)_ln_common_childViewControllerForHomeIndicatorAutoHidden
{
	UIViewController* vc = [self _common_childViewControllersForStatusBarLogic];
	
	return vc ?: [self _ln_childViewControllerForHomeIndicatorAutoHidden];
}

- (nullable UIViewController *)_ln_childViewControllerForStatusBarHidden
{
	return [self _ln_common_childViewControllerForStatusBarHidden];
}

- (nullable UIViewController *)_ln_childViewControllerForStatusBarStyle
{
	return [self _ln_common_childViewControllerForStatusBarStyle];
}

- (nullable UIViewController *)_ln_childViewControllerForHomeIndicatorAutoHidden
{
	return [self _ln_common_childViewControllerForHomeIndicatorAutoHidden];
}

- (void)_ln_setPopupPresentationState:(LNPopupPresentationState)newState
{
	[self willChangeValueForKey:@"popupPresentationState"];
	self._ln_popupController.popupControllerPublicState = newState;
	[self didChangeValueForKey:@"popupPresentationState"];
}

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	//_accessibilitySpeakThisViewController
	return __orig_uiVCA_aSTVC(self, _cmd);
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_common_uLFSBAIO
{
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

//_updateContentOverlayInsetsFromParentIfNecessary (iOS 15 and above)
- (void)_uCOIFPIN
{
	static SEL contentMarginSEL;
	static SEL setContentMarginSEL;
	static SEL _setContentOverlayInsets_andLeftMargin_rightMarginSEL;
	
	static CGFloat (*contentMarginFunc)(id, SEL);
	static void (*setContentMarginFunc)(id, SEL, CGFloat);
	static void (*_setContentOverlayInsets_andLeftMargin_rightMarginFunc)(id, SEL, UIEdgeInsets, CGFloat, CGFloat);
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		contentMarginSEL = NSSelectorFromString(_LNPopupDecodeBase64String(cM));
		setContentMarginSEL = NSSelectorFromString(_LNPopupDecodeBase64String(sCM));
		_setContentOverlayInsets_andLeftMargin_rightMarginSEL = NSSelectorFromString(_LNPopupDecodeBase64String(sCOIaLMrM));
		
		contentMarginFunc = (void*)objc_msgSend;
		setContentMarginFunc = (void*)objc_msgSend;
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc = (void*)objc_msgSend;
	});
	
	if([self respondsToSelector:@selector(_ln_popupUIRequiresZeroInsets)] && self._ln_popupUIRequiresZeroInsets == YES)
	{
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc(self, _setContentOverlayInsets_andLeftMargin_rightMarginSEL, UIEdgeInsetsZero, 0, 0);
		setContentMarginFunc(self, setContentMarginSEL, 0);
		
		return;
	}
	
	[self _uCOIFPIN];
	
	if(self.popupPresentationContainerViewController != nil)
	{
		CGFloat contentMargin = contentMarginFunc(self.popupPresentationContainerViewController, contentMarginSEL);
		
		UIEdgeInsets insets = __LNEdgeInsetsSum(self.popupPresentationContainerViewController.view.safeAreaInsets, UIEdgeInsetsMake(0, 0, - _LNPopupSafeAreas(self.popupPresentationContainerViewController).bottom, 0));
		
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc(self, _setContentOverlayInsets_andLeftMargin_rightMarginSEL, insets, contentMargin, contentMargin);
		setContentMarginFunc(self, setContentMarginSEL, contentMargin);
		
		self.view.insetsLayoutMarginsFromSafeArea = YES;
		self.viewRespectsSystemMinimumLayoutMargins = NO;
		self.view.layoutMargins = UIEdgeInsetsMake(0, contentMargin, 0, contentMargin);
	}
	
#if ! TARGET_OS_MACCATALYST
	if(self.popupContentViewController)
	{
		[self.popupContentViewController _uLFSBAIO];
		[self._ln_popupController_nocreate.popupContentView _repositionPopupCloseButton];
	}
#endif
}


//_viewSafeAreaInsetsFromScene (iOS 14)
- (UIEdgeInsets)_vSAIFS
{
	if([self _isContainedInPopupController])
	{
		return __LNEdgeInsetsSum(self.popupPresentationContainerViewController.view.safeAreaInsets, UIEdgeInsetsMake(0, 0, - _LNPopupSafeAreas(self.popupPresentationContainerViewController).bottom, 0));
	}
	
	UIEdgeInsets insets = [self _vSAIFS];
	
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
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupBar aboveSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_bottomBarExtension_nocreate belowSubview:self._ln_popupController_nocreate.popupBar];
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupContentView belowSubview:self._ln_popupController_nocreate.popupBar];
}

- (void)_layoutPopupBarOrderForUse
{
	[self.bottomDockingViewForPopup_internalOrDeveloper.superview bringSubviewToFront:self.bottomDockingViewForPopup_internalOrDeveloper];
	if(self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating)
	{
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupBar aboveSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
	}
	else
	{
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupBar belowSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
	}
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_bottomBarExtension_nocreate belowSubview:self._ln_popupController_nocreate.popupBar];
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupContentView belowSubview:self._ln_popupController_nocreate.popupBar];
}

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension_nocreate
{
	return objc_getAssociatedObject(self, LNPopupBarExtensionView);
}

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension
{
	if(self._ln_reallyShouldExtendPopupBarUnderSafeArea == NO || self._ln_popupController_nocreate.popupControllerInternalState == LNPopupPresentationStateBarHidden)
	{
		[self._ln_bottomBarExtension_nocreate removeFromSuperview];
		objc_setAssociatedObject(self, LNPopupBarExtensionView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		return nil;
	}
	
	_LNPopupBarBackgroundView* rv = objc_getAssociatedObject(self, LNPopupBarExtensionView);
	if(rv == nil)
	{
		rv = [[_LNPopupBarExtensionView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]];
		rv.alpha = 0.0;
		objc_setAssociatedObject(self, LNPopupBarExtensionView, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self._ln_popupController _updateBarExtensionStyleFromPopupBar];
	}
	
	return rv;
}

- (void)_ln_popup_viewWillAppear:(BOOL)animated
{
	if(__ln_popup_suppressViewControllerLifecycle == YES)
	{
		return;
	}
	
	[self _ln_popup_viewWillAppear:animated];
}

- (void)_ln_popup_viewDidAppear:(BOOL)animated
{
	if(__ln_popup_suppressViewControllerLifecycle == YES)
	{
		return;
	}
	
	[self _ln_popup_viewDidAppear:animated];
}

- (void)_ln_popup_viewWillDisappear:(BOOL)animated
{
	if(__ln_popup_suppressViewControllerLifecycle == YES)
	{
		return;
	}
	
	[self _ln_popup_viewWillDisappear:animated];
}

- (void)_ln_popup_viewDidDisappear:(BOOL)animated
{
	if(__ln_popup_suppressViewControllerLifecycle == YES)
	{
		return;
	}
	
	[self _ln_popup_viewDidDisappear:animated];
}

- (void)_ln_popup_viewDidLayoutSubviews
{
	[self _ln_popup_viewDidLayoutSubviews];
	
	if(self._ln_popupController_nocreate.popupControllerInternalState > LNPopupPresentationStateBarHidden)
	{
		if(self.bottomDockingViewForPopup_nocreateOrDeveloper == self._ln_bottomBarSupport_nocreate)
		{
			self._ln_bottomBarSupport_nocreate.frame = self.defaultFrameForBottomDockingView_internalOrDeveloper;
			[self.view bringSubviewToFront:self._ln_bottomBarSupport_nocreate];
			
			self._ln_bottomBarExtension.frame = self._ln_bottomBarSupport_nocreate.frame;
		}
		else
		{
			self._ln_bottomBarSupport_nocreate.hidden = YES;
		}
		
		if([self isKindOfClass:UINavigationController.class] == NO && [self isKindOfClass:UITabBarController.class] == NO)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating ? 0.0 : 1.0;
		}
		
		if(self._ignoringLayoutDuringTransition == NO && self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
		{
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		}
		
		if(self._ignoringLayoutDuringTransition == NO)
		{
			[self _layoutPopupBarOrderForUse];
		}
	}
	
	UIView* extensionView = self._ln_bottomBarExtension_nocreate;
	dispatch_block_t removeFromSuperview = ^ {
		[extensionView removeFromSuperview];
		extensionView.alpha = 0.0;
	};
	
	if(self._ln_reallyShouldExtendPopupBarUnderSafeArea == NO || (self._ln_popupController_nocreate.popupControllerInternalState == LNPopupPresentationStateBarHidden && extensionView.superview != nil))
	{
		removeFromSuperview();
	}
	else if([self isKindOfClass:UINavigationController.class] == NO && [self isKindOfClass:UITabBarController.class] == NO)
	{
		if([extensionView.layer.animationKeys containsObject:@"opacity"] == NO)
		{
			extensionView.alpha = 1.0;
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

- (void)_userFacing_viewWillAppear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewIsAppearing:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewIsAppearing:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidAppear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewWillDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

@end

static BOOL __LNPopupIsClassBuggyForAdditionalSafeArea(UIViewController* controller)
{
	for (Class cls in __LNPopupBuggyAdditionalSafeAreaClasses)
	{
		if([controller isKindOfClass:cls])
		{
			return YES;
		}
	}
	
	return NO;
}

static void __LNPopupUpdateChildInsets(UIViewController* controller)
{
	if(__LNPopupIsClassBuggyForAdditionalSafeArea(controller) == YES)
	{
		for (__kindof UIViewController* obj in controller.childViewControllers)
		{
			__LNPopupUpdateChildInsets(obj);
		}
		
		return;
	}
	
	UIEdgeInsets popupSafeAreaInsets = UIEdgeInsetsZero;
	
	UIViewController* parentViewController = controller.parentViewController;
	
	while(parentViewController != nil && __LNPopupIsClassBuggyForAdditionalSafeArea(parentViewController) == YES)
	{
		popupSafeAreaInsets = __LNEdgeInsetsSum(popupSafeAreaInsets, _LNPopupChildAdditiveSafeAreas(parentViewController));
		parentViewController = parentViewController.parentViewController;
	}
	
	_LNSetPopupSafeAreaInsets(controller, popupSafeAreaInsets);
}

void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets)
{
	//Container classes with bottom bars have bugs if additional safe areas are applied directly to them.
	//Instead, set a custom property and update their children recursively to take care of the additional safe area.
	if(__LNPopupIsClassBuggyForAdditionalSafeArea(controller) == YES)
	{
		[controller _ln_setChildAdditiveSafeAreaInsets:popupEdgeInsets];
		__LNPopupUpdateChildInsets(controller);
	}
	else
	{
		_LNSetPopupSafeAreaInsets(controller, popupEdgeInsets);
	}
	
	if(layout)
	{
		[controller.view setNeedsUpdateConstraints];
		[controller.view setNeedsLayout];
		[controller.view layoutIfNeeded];
	}
}

#pragma mark - UITabBarController

@interface UITabBarController (LNPopupSupportPrivate) @end
@implementation UITabBarController (LNPopupSupportPrivate)

- (BOOL)_isTabBarHiddenDuringTransition
{
	NSNumber* isHidden = objc_getAssociatedObject(self, LNToolbarHiddenBeforeTransition);
	return isHidden.boolValue || self.tabBar.superview == nil;
}

- (void)_setTabBarHiddenDuringTransition:(BOOL)toolbarHidden
{
	objc_setAssociatedObject(self, LNToolbarHiddenBeforeTransition, @(toolbarHidden), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)_isPrepareTabBarIgnored
{
	NSNumber* isHidden = objc_getAssociatedObject(self, LNPopupIgnorePrepareTabBar);
	return isHidden.boolValue;
}

- (void)_setPrepareTabBarIgnored:(BOOL)isPrepareTabBarIgnored
{
	objc_setAssociatedObject(self, LNPopupIgnorePrepareTabBar, @(isPrepareTabBarIgnored), OBJC_ASSOCIATION_RETAIN);
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
	return self.tabBar.hidden == NO && self._isTabBarHiddenDuringTransition == NO ? UIEdgeInsetsZero : self.view.superview.safeAreaInsets;
}

- (CGRect)defaultFrameForBottomDockingView
{
	CGRect bottomBarFrame = self.tabBar.frame;
	bottomBarFrame.origin = CGPointMake(0, self.view.bounds.size.height - (self._isTabBarHiddenDuringTransition ? 0.0 : bottomBarFrame.size.height));
	return bottomBarFrame;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNSwizzleMethod(self,
						@selector(childViewControllerForStatusBarStyle),
						@selector(_ln_childViewControllerForStatusBarStyle));
		
		LNSwizzleMethod(self,
						@selector(childViewControllerForStatusBarHidden),
						@selector(_ln_childViewControllerForStatusBarHidden));
		
		LNSwizzleMethod(self,
						@selector(childViewControllerForHomeIndicatorAutoHidden),
						@selector(_ln_childViewControllerForHomeIndicatorAutoHidden));
		
		LNSwizzleMethod(self,
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_tvc));
		
		LNSwizzleMethod(self,
						@selector(setSelectedViewController:),
						@selector(_ln_setSelectedViewController:));
		
		LNSwizzleMethod(self,
						@selector(setViewControllers:animated:),
						@selector(_ln_setViewControllers:animated:));
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		
		//_hideBarWithTransition:isExplicit:duration:
		selName = _LNPopupDecodeBase64String(hBWTiEDBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(hBWT:iE:d:));
		
		//_showBarWithTransition:isExplicit:duration:
		selName = _LNPopupDecodeBase64String(sBWTiEDBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(sBWT:iE:d:));
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = _LNPopupDecodeBase64String(uLFSBAIO);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_uLFSBAIO));
		
		selName = _LNPopupDecodeBase64String(pTBBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_pTB));
#endif
	});
}

- (void)_ln_popup_viewDidLayoutSubviews_tvc
{
	if(self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
	{
		if(self.tabBar.isHidden == NO && self._isTabBarHiddenDuringTransition == NO && self._ignoringLayoutDuringTransition == NO)
		{
			self._ln_bottomBarExtension_nocreate.hidden = YES;
			[self._ln_bottomBarExtension_nocreate removeFromSuperview];
			
			if(self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			}
		}
		else
		{
			self._ln_bottomBarExtension.hidden = NO;
			
			if(self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating && self._ignoringLayoutDuringTransition == NO)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 0.0;
			}
		}
	}
	
	struct objc_super superInfo = {
		self,
		[UIViewController class]
	};
	void (*super_call)(struct objc_super*, SEL) = (void (*)(struct objc_super*, SEL))objc_msgSendSuper;
	super_call(&superInfo, @selector(viewDidLayoutSubviews));
	
	if(self._ignoringLayoutDuringTransition == NO)
	{
		CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
	}
}

- (void)_ln_setSelectedViewController:(__kindof UIViewController *)selectedViewController
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	[self _ln_setSelectedViewController:selectedViewController];
}

- (void)_ln_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	[self _ln_setViewControllers:viewControllers animated:animated];
}

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	//_accessibilitySpeakThisViewController
	return __orig_uiTBCA_aSTVC(self, _cmd);
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

- (void)__repositionPopupBarToClosed_hack
{
	CGRect defaultFrame = [self defaultFrameForBottomDockingView];
	CGRect frame = self._ln_popupController_nocreate.popupBar.frame;
	frame.origin.y = defaultFrame.origin.y - frame.size.height - self.insetsForBottomDockingView.bottom;
	self._ln_popupController_nocreate.popupBar.frame = frame;
}

static BOOL _alreadyInHideShowBar = NO;

//_hideBarWithTransition:isExplicit:duration:
- (void)hBWT:(NSInteger)t iE:(BOOL)e d:(NSTimeInterval)duration
{
	if(_alreadyInHideShowBar == YES)
	{
		//Ignore nested calls to _hideBarWithTransition:isExplicit:duration:
		[self hBWT:t iE:e d:duration];
		return;
	}
	
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating;
	if(!isFloating)
	{
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	}
	
	BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.tabBar.superview.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
	
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	[self _setTabBarHiddenDuringTransition:YES];
	
	CGRect frame = self.tabBar.frame;
	if(t != 0)
	{
		frame.origin.x = (isRTL ? -1 : 1) * self.view.bounds.size.width;
	}
	self._ln_bottomBarExtension.frame = frame;
	self._ln_bottomBarExtension_nocreate.hidden = NO;
	self._ln_bottomBarExtension_nocreate.alpha = 1.0;
	
	_alreadyInHideShowBar = YES;
	[self hBWT:t iE:e d:duration];
	_alreadyInHideShowBar = NO;
	
	NSString* effectGroupingIdentifier = self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier;
	self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = nil;
	
	self._ln_popupController_nocreate.popupBar.wantsBackgroundCutout = NO;
	if(t == 1 && isFloating)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = NO;
	}
	
	[self _setIgnoringLayoutDuringTransition:YES];
	
	CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
	
	[self _layoutPopupBarOrderForTransition];
	
	CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
	
	self._ln_bottomBarExtension_nocreate.alpha = 1.0;
	
	void (^animations)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, self._ln_bottomBarExtension_nocreate.frame.size.height);
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
		
		[self __repositionPopupBarToClosed_hack];
		if(isFloating)
		{
			[self._ln_popupController_nocreate.popupBar layoutIfNeeded];
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = CGRectOffset(backgroundViewFrame, (isRTL ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + bottomSafeArea);
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			if(t == 1)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 1.0;
			}
		}
	};
	
	void (^completion)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		if(isFloating)
		{
			if(t == 1)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = YES;
			}
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 0.0;
		}
		[self._ln_popupController_nocreate.popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
		
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
		
		[self _setIgnoringLayoutDuringTransition:NO];
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		
		self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = effectGroupingIdentifier;
		
		self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
		
		[self _layoutPopupBarOrderForUse];
	};
	
	id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.selectedViewController.transitionCoordinator;
	
	if(transitionCoordinator != nil)
	{
		[transitionCoordinator animateAlongsideTransition:animations completion:completion];
	}
	else
	{
		[UIView performWithoutAnimation:^{
			animations(nil);
			completion(nil);
		}];
	}
}

//_showBarWithTransition:isExplicit:duration:
- (void)sBWT:(NSInteger)t iE:(BOOL)e d:(NSTimeInterval)duration
{
	if(_alreadyInHideShowBar == YES)
	{
		//Ignore nested calls to _showBarWithTransition:isExplicit:duration:
		[self sBWT:t iE:e d:duration];
		return;
	}
	
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating;
	
	BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.tabBar.superview.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
	
	if(e == YES)
	{
		if(!isFloating)
		{
			self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
		}
		
		[self _setPrepareTabBarIgnored:YES];
	}
	
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	BOOL wasHidden = self.tabBar.isHidden;
	
	_alreadyInHideShowBar = YES;
	[self sBWT:t iE:e d:duration];
	_alreadyInHideShowBar = NO;
	
	if(e == NO)
	{
		return;
	}
	
	if(wasHidden == NO)
	{
		return;
	}
	
	self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
	self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
	
	if(wasHidden == YES)
	{
		self._ln_popupController_nocreate.popupBar.wantsBackgroundCutout = NO;
	}
	
	if(t == 2 && isFloating)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 1.0;
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = NO;
	}
	
	CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
	if(isFloating && wasHidden == YES)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.frame = CGRectOffset(backgroundViewFrame, (isRTL ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(self.tabBar.frame) + self.view.superview.safeAreaInsets.bottom);
	}
	__block CGRect frame = self.tabBar.frame;
	
	[self _setIgnoringLayoutDuringTransition:YES];
	
	NSString* effectGroupingIdentifier = self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier;
	self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = nil;
	
	void (^animations)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[UIView performWithoutAnimation:^{
			self.tabBar.frame = frame;
		}];
		
		frame.origin.x += (isRTL ? -1 : 1) * self.view.bounds.size.width;
		self._ln_bottomBarExtension.frame = frame;
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		if(isFloating && wasHidden == YES)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			if(t == 2)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
			}
		}
		
		[self _setTabBarHiddenDuringTransition:NO];
		[self _layoutPopupBarOrderForTransition];
		[self __repositionPopupBarToClosed_hack];
	};
	
	void (^completion)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPrepareTabBarIgnored:NO];
		
		if(wasHidden == YES)
		{
			[self._ln_popupController_nocreate.popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
		}
		
		if(t == 2 && isFloating)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
			self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = YES;
		}
		
		if(context.isCancelled)
		{
			[self _setTabBarHiddenDuringTransition:YES];
		}
		
		if(isFloating)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = context.isCancelled ? 0.0 : 1.0;
		}
		
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		
		[self _layoutPopupBarOrderForUse];
		
		[self _setIgnoringLayoutDuringTransition:NO];
		
		self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = effectGroupingIdentifier;
		
		if(context.isCancelled == NO)
		{
			self._ln_bottomBarExtension_nocreate.alpha = 0.0;
		}
	};
	
	id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.selectedViewController.transitionCoordinator;
	
	if(transitionCoordinator != nil)
	{
		[transitionCoordinator animateAlongsideTransition:animations completion:completion];
	}
	else
	{
		[UIView performWithoutAnimation:^{
			__LNFakeContext* ctx = [__LNFakeContext new];
			ctx.cancelled = NO;
			animations((id)ctx);
			completion((id)ctx);
		}];
	}
}

//_prepareTabBar
- (void)_ln_pTB
{
	CGRect oldBarFrame = self.tabBar.frame;

	if(self._ignoringLayoutDuringTransition == NO)
	{
		[self _ln_pTB];
	}
	
	if(self._isPrepareTabBarIgnored == YES)
	{
		self.tabBar.frame = oldBarFrame;
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

- (nullable UIViewController *)_ln_childViewControllerForHomeIndicatorAutoHidden
{
	return [self _ln_common_childViewControllerForHomeIndicatorAutoHidden];
}

@end

#pragma mark - UINavigationController

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
	
	CGFloat bottomSafeAreaHeight = self.view.safeAreaInsets.bottom;
	if([NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"] == NO)
	{
		bottomSafeAreaHeight -= self.view.window.safeAreaInsets.bottom;
	}
	
	toolbarBarFrame.origin = CGPointMake(toolbarBarFrame.origin.x, self.view.bounds.size.height - (self.isToolbarHidden ? 0.0 : toolbarBarFrame.size.height) - bottomSafeAreaHeight);
	
	return toolbarBarFrame;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	if(self.presentingViewController != nil && [NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"])
	{
		return UIEdgeInsetsZero;
	}
	
	return UIEdgeInsetsMake(0, 0, MAX(self.view.superview.safeAreaInsets.bottom, self.view.window.safeAreaInsets.bottom), 0);
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNSwizzleMethod(self,
						@selector(childViewControllerForStatusBarStyle),
						@selector(_ln_childViewControllerForStatusBarStyle));
		
		LNSwizzleMethod(self,
						@selector(childViewControllerForStatusBarHidden),
						@selector(_ln_childViewControllerForStatusBarHidden));
		
		LNSwizzleMethod(self,
						@selector(childViewControllerForHomeIndicatorAutoHidden),
						@selector(_ln_childViewControllerForHomeIndicatorAutoHidden));
		
		LNSwizzleMethod(self,
						@selector(setNavigationBarHidden:animated:),
						@selector(_ln_setNavigationBarHidden:animated:));
		
		LNSwizzleMethod(self,
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_nvc));
		
		LNSwizzleMethod(self,
						@selector(pushViewController:animated:),
						@selector(_ln_pushViewController:animated:));
		
		LNSwizzleMethod(self,
						@selector(popViewControllerAnimated:),
						@selector(_ln_popViewControllerAnimated:));
		
		LNSwizzleMethod(self,
						@selector(popToViewController:animated:),
						@selector(_ln_popToViewController:animated:));
		
		LNSwizzleMethod(self,
						@selector(popToRootViewControllerAnimated:),
						@selector(_ln_popToRootViewControllerAnimated:));
		
		LNSwizzleMethod(self,
						@selector(setViewControllers:animated:),
						@selector(_ln_setViewControllers:animated:));
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		
		//_setToolbarHidden:edge:duration:
		selName = _LNPopupDecodeBase64String(sTHedBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_sTH:e:d:));
		
		//_hideShowNavigationBarDidStop:finished:context:
		selName = _LNPopupDecodeBase64String(hSNBDSfcBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(hSNBDS:f:c:));
		
		//_updateLayoutForStatusBarAndInterfaceOrientation
		selName = _LNPopupDecodeBase64String(uLFSBAIO);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_uLFSBAIO));
#endif
	});
}

- (void)_ln_popup_viewDidLayoutSubviews_nvc
{
	if(self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
	{
		if(self._ignoringLayoutDuringTransition == NO)
		{
			BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating;
			
			if(self.isToolbarHidden == NO)
			{
				self._ln_bottomBarExtension_nocreate.hidden = YES;
				[self._ln_bottomBarExtension_nocreate removeFromSuperview];
				
				if(self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating)
				{
					self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
				}
			}
			else
			{
				self._ln_bottomBarExtension.hidden = NO;
				self._ln_bottomBarExtension_nocreate.alpha = 1.0;
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = isFloating ? 0.0 : 1.0;
			}
		}
	}
	
	if(@available(iOS 16.0, *))
	{
		//This will call this class' actual implementation of `viewDidLayoutSubviews` (which doesn't call `super.viewDidLayoutSubviews`).
		[self _ln_popup_viewDidLayoutSubviews_nvc];
	}
	
	//This will call `UIViewController.viewDidLayoutSubviews`.
	struct objc_super superInfo = {
		self,
		[UIViewController class]
	};
	void (*super_call)(struct objc_super*, SEL) = (void (*)(struct objc_super*, SEL))objc_msgSendSuper;
	super_call(&superInfo, @selector(viewDidLayoutSubviews));
	
	if(self._ignoringLayoutDuringTransition == NO)
	{
		CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
	}
}

- (void)_ln_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	[self _ln_pushViewController:viewController animated:animated];
}

- (UIViewController *)_ln_popViewControllerAnimated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	return [self _ln_popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)_ln_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	return [self _ln_popToViewController:viewController animated:animated];
}

- (NSArray<__kindof UIViewController *> *)_ln_popToRootViewControllerAnimated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	return [self _ln_popToRootViewControllerAnimated:animated];
}

- (void)_ln_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated
{
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	return [self _ln_setViewControllers:viewControllers animated:animated];
}

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
- (UIViewController*)_aSTVC
{
	if(self.popupContentViewController && self.popupPresentationState == LNPopupPresentationStateOpen)
	{
		return self.popupContentViewController;
	}
	
	//_accessibilitySpeakThisViewController
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
- (void)_sTH:(BOOL)hidden e:(UIRectEdge)edge d:(NSTimeInterval)duration;
{
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedStyle == LNPopupBarStyleFloating;
	
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	//Move popup bar and content according to current state of the toolbar.
	[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
	
	__block CGRect frame = self.toolbar.frame;
	frame.size.height += self.view.superview.safeAreaInsets.bottom;
	if(edge != UIRectEdgeBottom)
	{
		frame.origin.x = (edge == UIRectEdgeRight ? -1 : 1) * self.view.bounds.size.width;
	}
	
	BOOL wasToolbarHidden = self.isToolbarHidden;
	
	//Trigger the toolbar hide or show transition.
	[self _sTH:hidden e:edge d:duration];
	
	if(wasToolbarHidden != hidden)
	{
		if(isFloating == NO)
		{
			self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
		}
		
		self._ln_popupController_nocreate.popupBar.wantsBackgroundCutout = NO;
		
		if(hidden == YES)
		{
			self._ln_bottomBarExtension.frame = frame;
			self._ln_bottomBarExtension_nocreate.hidden = NO;
			self._ln_bottomBarExtension_nocreate.alpha = 1.0;
		}
		
		CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
		CGRect initialBackgroundViewFrame;
		CGRect targetBackgroundViewFrame;
		
		if(edge == UIRectEdgeBottom)
		{
			if(hidden == YES)
			{
				initialBackgroundViewFrame = backgroundViewFrame;
				targetBackgroundViewFrame = CGRectOffset(backgroundViewFrame, 0, CGRectGetHeight(frame));
			}
			else
			{
				initialBackgroundViewFrame = CGRectOffset(backgroundViewFrame, 0, CGRectGetHeight(frame));
				targetBackgroundViewFrame = backgroundViewFrame;
			}
		}
		else if(hidden == YES)
		{
			initialBackgroundViewFrame = backgroundViewFrame;
			targetBackgroundViewFrame = CGRectOffset(backgroundViewFrame, (edge == UIRectEdgeRight ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + self.view.superview.safeAreaInsets.bottom);
		}
		else
		{
			initialBackgroundViewFrame = CGRectOffset(backgroundViewFrame, (edge == UIRectEdgeRight ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + self.view.superview.safeAreaInsets.bottom);
			targetBackgroundViewFrame = backgroundViewFrame;
		}
		
		if(isFloating)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = initialBackgroundViewFrame;
		}
		
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = hidden == NO ? 0.0 : 1.0;
		
		CGFloat safeArea = self.view.superview.safeAreaInsets.bottom;
		
		[self _layoutPopupBarOrderForTransition];
		
		void (^animations)(void) = ^ {
			//During the transition, animate the popup bar and content together with the toolbar transition.
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
			
			if(isFloating)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.frame = targetBackgroundViewFrame;
			}
			
			CGRect frame;
			if(hidden)
			{
				self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - safeArea, self.view.bounds.size.width, self._ln_bottomBarExtension_nocreate.frame.size.height);
				
				self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
				
				if(isFloating)
				{
					self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
				}
			}
			else
			{
				frame = self.toolbar.frame;
				frame.size.height += self.view.superview.safeAreaInsets.bottom;
				if(edge != UIRectEdgeBottom)
				{
					frame.origin.x = (edge == UIRectEdgeRight ? -1 : 1) * self.view.bounds.size.width;
				}
				self._ln_bottomBarExtension_nocreate.frame = frame;
				
				self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
				
				if(isFloating)
				{
					self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
				}
			}
		};
		
		void (^completion)(BOOL finished) = ^ (BOOL finished) {
			if(isFloating)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = hidden ? 0.0 : 1.0;
			}
			
			[self._ln_popupController_nocreate.popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
			
			if(hidden)
			{
				self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - safeArea, (edge == UIRectEdgeRight ? -1 : 1) * self.view.bounds.size.width, safeArea);
			}
			else if(finished)
			{
				self._ln_bottomBarExtension_nocreate.alpha = 0.0;
			}
			
			//Position the popup bar and content to the superview of the toolbar for the transition.
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
//			[self _layoutPopupBarOrderForUse];
			
			self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
			
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
			
			[self _setIgnoringLayoutDuringTransition:NO];
		};
		
		[self _setIgnoringLayoutDuringTransition:YES];
		
		if(duration == 0)
		{
			animations();
			completion(YES);
			
			return;
		}
		
		if(self.transitionCoordinator)
		{
			[self.transitionCoordinator animateAlongsideTransitionInView:self._ln_popupController_nocreate.popupBar.superview animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
				animations();
			} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
				completion(context.isCancelled == NO);
			}];
		}
		else
		{
			[UIView animateWithDuration:duration animations:animations completion:completion];
		}
	}
}

//_hideShowNavigationBarDidStop:finished:context:
- (void)hSNBDS:(id)arg1 f:(id)arg2 c:(id)arg3;
{
	[self hSNBDS:arg1 f:arg2 c:arg3];
	
	self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
	self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
	
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

- (nullable UIViewController *)_ln_childViewControllerForHomeIndicatorAutoHidden
{
	return [self _ln_common_childViewControllerForHomeIndicatorAutoHidden];
}

- (void)_ln_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self _ln_setNavigationBarHidden:hidden animated:animated];
	
	if([self _ignoringLayoutDuringTransition] == NO)
	{
		[self _layoutPopupBarOrderForUse];
	}
}

@end

#pragma mark - UISplitViewController

@interface UISplitViewController (LNPopupSupportPrivate) @end
@implementation UISplitViewController (LNPopupSupportPrivate)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNSwizzleMethod(self,
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_SplitViewNastyApple));
	});
}

- (void)_ln_popup_viewDidLayoutSubviews_SplitViewNastyApple
{
	[self _ln_popup_viewDidLayoutSubviews_SplitViewNastyApple];
	
	if(self._ln_popupController_nocreate.popupControllerInternalState > LNPopupPresentationStateBarHidden)
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

#pragma mark - View controller appearance control

@implementation _LN_UIViewController_AppearanceControl

- (void)viewWillAppear:(BOOL)animated
{
	//Ignore
}

- (void)viewDidAppear:(BOOL)animated
{
	//Ignore
}

- (void)viewIsAppearing:(BOOL)animated
{
	//Ignore
}

- (void)viewWillDisappear:(BOOL)animated
{
	//Ignore
}

- (void)viewDidDisappear:(BOOL)animated
{
	//Ignore
}

- (Class)class
{
	return LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
}

@end
