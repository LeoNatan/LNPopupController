//
//  UIViewController+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "UIView+LNPopupSupportPrivate.h"
#import "UITabBar+LNPopupMinimizationSupport.h"

CF_EXTERN_C_BEGIN
extern void __ln_doNotCall__fixUIHostingViewHitTest(void) noexcept;
CF_EXTERN_C_END

#import <objc/runtime.h>
#import <os/log.h>

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;
static const void* LNPopupAdjustingInsets = &LNPopupAdjustingInsets;
static const void* LNPopupAdditionalSafeAreaInsets = &LNPopupAdditionalSafeAreaInsets;
static const void* LNUserAdditionalSafeAreaInsets = &LNUserAdditionalSafeAreaInsets;
static const void* LNPopupChildAdditiveSafeAreaInsets = &LNPopupChildAdditiveSafeAreaInsets;
static const void* LNPopupIgnorePrepareTabBar = &LNPopupIgnorePrepareTabBar;
static const void* LNPopupBarExtensionView = &LNPopupBarExtensionView;

static void __LNPopupUpdateChildInsets(UIViewController* controller);

BOOL __ln_popup_suppressViewControllerLifecycle = NO;

@interface __LNFakeContext: NSObject

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@end
@implementation __LNFakeContext @end

@interface _LNPopupBarExtensionView : _LNPopupBarBackgroundView @end
@implementation _LNPopupBarExtensionView

#if DEBUG

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

#endif

@end

@interface NSObject ()

@property (nonatomic, readonly) BOOL _ln_popupUIRequiresZeroInsets;

@end

#ifndef LNPopupControllerEnforceStrictClean

//_accessibilitySpeakThisViewController
static UIViewController* (*__orig_uiVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiNVCA_aSTVC)(id, SEL);
static UIViewController* (*__orig_uiTBCA_aSTVC)(id, SEL);

#endif

static NSTimeInterval __ln_tabBarTransitionDuration(UIViewController* vc, NSUInteger transition)
{
	if(LNPopupEnvironmentHasGlass())
	{
		return 0.1;
	}
	
#ifndef LNPopupControllerEnforceStrictClean
	//durationForTransition:
	static SEL dFT = NSSelectorFromString(LNPopupHiddenString("durationForTransition:"));
	static NSTimeInterval (*specialized_objc_msgSend)(id, SEL, NSUInteger) = reinterpret_cast<decltype(specialized_objc_msgSend)>(objc_msgSend);
	
	return specialized_objc_msgSend(vc, dFT, transition);
#else
	return 0.5;
#endif
}

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
		
		NSString* selName = LNPopupHiddenString("_accessibilitySpeakThisViewController");
		
		//UIViewControllerAccessibility
		//_accessibilitySpeakThisViewController
		NSString* clsName = LNPopupHiddenString("UIViewControllerAccessibility");
		Method m1 = LNSwizzleClassGetInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiVCA_aSTVC = reinterpret_cast<decltype(__orig_uiVCA_aSTVC)>(method_getImplementation(m1));
		Method m2 = LNSwizzleClassGetInstanceMethod([UIViewController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = LNPopupHiddenString("UINavigationControllerAccessibility");
		m1 = LNSwizzleClassGetInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiNVCA_aSTVC = reinterpret_cast<decltype(__orig_uiNVCA_aSTVC)>(method_getImplementation(m1));
		m2 = LNSwizzleClassGetInstanceMethod([UINavigationController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		clsName = LNPopupHiddenString("UITabBarControllerAccessibility");
		m1 = LNSwizzleClassGetInstanceMethod(NSClassFromString(clsName), NSSelectorFromString(selName));
		__orig_uiTBCA_aSTVC = reinterpret_cast<decltype(__orig_uiTBCA_aSTVC)>(method_getImplementation(m1));
		m2 = LNSwizzleClassGetInstanceMethod([UITabBarController class], NSSelectorFromString(@"_aSTVC"));
		method_exchangeImplementations(m1, m2);
		
		[[NSNotificationCenter defaultCenter] removeObserver:__accessibilityBundleLoadObserver];
		__accessibilityBundleLoadObserver = nil;
	}];
}
#endif

#pragma mark - UIViewController

BOOL __ln_alreadyInHideShowBar = NO;
UIRectEdge __ln_hideBarEdge = UIRectEdgeNone;

@implementation UIViewController (LNPopupLayout)

+ (void)load
{
	@autoreleasepool
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			__ln_doNotCall__fixUIHostingViewHitTest();
			
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
							@selector(viewWillTransitionToSize:withTransitionCoordinator:),
							@selector(_ln_viewWillTransitionToSize:withTransitionCoordinator:));
			
			LNSwizzleMethod(self,
							@selector(willTransitionToTraitCollection:withTransitionCoordinator:),
							@selector(_ln_willTransitionToTraitCollection:withTransitionCoordinator:));
			
			LNSwizzleMethod(self,
							@selector(presentViewController:animated:completion:),
							@selector(_ln_presentViewController:animated:completion:));
			
#ifndef LNPopupControllerEnforceStrictClean
			NSString* selName = LNPopupHiddenString("_viewControllerUnderlapsStatusBar");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_vCUSB));
			
			selName = LNPopupHiddenString("_updateLayoutForStatusBarAndInterfaceOrientation");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_uLFSBAIO));
			
			if(@available(iOS 15.0, *))
			{
				selName = LNPopupHiddenString("_updateContentOverlayInsetsFromParentIfNecessary");
				LNSwizzleMethod(self,
								NSSelectorFromString(selName),
								@selector(_uCOIFPIN));
				
				
			}
			else
			{
				selName = LNPopupHiddenString("_viewSafeAreaInsetsFromScene");
				LNSwizzleMethod(self,
								NSSelectorFromString(selName),
								@selector(_vSAIFS));
			}
			
			selName = LNPopupHiddenString("setParentViewController:");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_ln_sPVC:));
#endif
		});
	}
}

- (void)_ln_updateSafeAreaInsets
{
#ifndef LNPopupControllerEnforceStrictClean
	static SEL sel = NSSelectorFromString(LNPopupHiddenString("_updateContentOverlayInsetsForSelfAndChildren"));
	static void(*objc_msgSend_uCOIFSAC)(id, SEL) = reinterpret_cast<decltype(objc_msgSend_uCOIFSAC)>(objc_msgSend);
	
	objc_msgSend_uCOIFSAC(self, sel);
#endif
}

- (BOOL)_ln_isModalInPresentation
{
	if(self._ln_popupController_nocreate.popupControllerInternalState >= _LNPopupPresentationStateTransitioning)
	{
		return YES;
	}
	
	return [self _ln_isModalInPresentation];
}

- (BOOL)_ln_isObjectFromSwiftUI
{
	static NSString* key = LNPopupHiddenString("_isFromSwiftUI");
	return [self.class respondsToSelector:NSSelectorFromString(key)] && [[self.class valueForKey:key] boolValue];
}

- (BOOL)_ln_shouldPopupContentAnyFadeForTransition
{
	BOOL bottomBarIsVisible = [self.bottomDockingViewForPopup_internalOrDeveloper isKindOfClass:_LNPopupBottomBarSupport.class] == NO && self.ln_popupController.bottomBar.hidden == NO && self.ln_popupController.bottomBar.window != nil;
	
	return self.popupBar.window.safeAreaInsets.bottom != 0 || bottomBarIsVisible;
}

- (BOOL)_ln_shouldPopupContentViewFadeForTransition
{
	BOOL bottomBarExtensionIsVisible = self._ln_bottomBarExtension_nocreate != nil && self._ln_bottomBarExtension_nocreate.isHidden == NO && self._ln_bottomBarExtension_nocreate.alpha > 0 && self._ln_bottomBarExtension_nocreate.frame.size.height > 0;
	
	BOOL bottomBarIsVisible = [self.bottomDockingViewForPopup_internalOrDeveloper isKindOfClass:_LNPopupBottomBarSupport.class] == NO && self.ln_popupController.bottomBar.hidden == NO && self.ln_popupController.bottomBar.window != nil;
	
	return bottomBarExtensionIsVisible == NO && (bottomBarIsVisible == NO || LNPopupEnvironmentHasGlass());
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
	if(LNPopupEnvironmentHasGlass())
	{
		return NO;
	}
	
	return !self._ln_popupController_nocreate.popupBar.resolvedIsFloating && self.shouldExtendPopupBarUnderSafeArea;
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
	
	UIEdgeInsets user = _LNUserSafeAreaInsets(self);
	
	_LNUpdateUserSafeAreaInsets(self, user, additionalSafeAreaInsets);
}

- (void)_ln_setAdditionalSafeAreaInsets:(UIEdgeInsets)additionalSafeAreaInsets
{
	objc_setAssociatedObject(self, LNUserAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIEdgeInsets popup = _LNPopupSafeAreaInsets(self);
	
	_LNUpdateUserSafeAreaInsets(self, additionalSafeAreaInsets, popup);
}

- (void)_ln_setChildAdditiveSafeAreaInsets:(UIEdgeInsets)childAdditiveSafeAreaInsets
{
	objc_setAssociatedObject(self, LNPopupChildAdditiveSafeAreaInsets, [NSValue valueWithUIEdgeInsets:childAdditiveSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

UIEdgeInsets _LNPopupSafeAreaInsets(id self)
{
	return [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

static inline __attribute__((always_inline)) UIEdgeInsets _LNUserSafeAreaInsets(id self)
{
	return [objc_getAssociatedObject(self, LNUserAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

UIEdgeInsets _LNPopupChildAdditiveSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNPopupChildAdditiveSafeAreaInsets) UIEdgeInsetsValue];
}

- (UIEdgeInsets)_ln_additionalSafeAreaInsets
{
	UIEdgeInsets user = _LNPopupSafeAreaInsets(self);
	UIEdgeInsets popup = _LNUserSafeAreaInsets(self);
	
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
	
	if(@available(iOS 18.0, *))
	{
		if([self isKindOfClass:UITabBarController.class])
		{
			[coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
				static SEL sel = NSSelectorFromString(LNPopupHiddenString("_forceUpdateScrollViewIfNecessary"));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[self performSelector:sel];
#pragma clang diagnostic pop
			}];
		}
	}
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

- (nullable UIViewController *)_ln_childViewControllerForStatusBarLogic
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
	static SEL contentMarginSEL = NSSelectorFromString(LNPopupHiddenString("_contentMargin"));
	static SEL setContentMarginSEL = NSSelectorFromString(LNPopupHiddenString("_setContentMargin:"));
	static SEL _setContentOverlayInsets_andLeftMargin_rightMarginSEL = NSSelectorFromString(LNPopupHiddenString("_setContentOverlayInsets:andLeftMargin:rightMargin:"));
	
	static CGFloat (*contentMarginFunc)(id, SEL) = reinterpret_cast<decltype(contentMarginFunc)>(objc_msgSend);
	static void (*setContentMarginFunc)(id, SEL, CGFloat) = reinterpret_cast<decltype(setContentMarginFunc)>(objc_msgSend);
	static void (*_setContentOverlayInsets_andLeftMargin_rightMarginFunc)(id, SEL, UIEdgeInsets, CGFloat, CGFloat) = reinterpret_cast<decltype(_setContentOverlayInsets_andLeftMargin_rightMarginFunc)>(objc_msgSend);
	
	if([self respondsToSelector:@selector(_ln_popupUIRequiresZeroInsets)] && self._ln_popupUIRequiresZeroInsets == YES)
	{
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc(self, _setContentOverlayInsets_andLeftMargin_rightMarginSEL, UIEdgeInsetsZero, 0, 0);
		setContentMarginFunc(self, setContentMarginSEL, 0);
		
		return;
	}
	
	[self _uCOIFPIN];
	
	if(@available(iOS 17.0, *))
	{
		if(__ln_alreadyInHideShowBar && __ln_hideBarEdge == UIRectEdgeBottom)
		{
			[self.view layoutIfNeeded];
		}
	}
		
	if(self.popupPresentationContainerViewController != nil)
	{
		CGFloat contentMargin = contentMarginFunc(self.popupPresentationContainerViewController, contentMarginSEL);
		
		UIEdgeInsets insets = __LNEdgeInsetsSum(self.popupPresentationContainerViewController.view.safeAreaInsets, UIEdgeInsetsMake(0, 0, - _LNPopupSafeAreaInsets(self.popupPresentationContainerViewController).bottom, 0));
		
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc(self, _setContentOverlayInsets_andLeftMargin_rightMarginSEL, insets, contentMargin, contentMargin);
		setContentMarginFunc(self, setContentMarginSEL, contentMargin);
		
		self.view.insetsLayoutMarginsFromSafeArea = YES;
		self.viewRespectsSystemMinimumLayoutMargins = NO;
		self.view.layoutMargins = UIEdgeInsetsMake(0, contentMargin, 0, contentMargin);
	}
	
	if([self.parentViewController isKindOfClass:UIPageViewController.class] && self.parentViewController._isContainedInPopupController)
	{
		//Work around Apple bugs
		
		CGFloat contentMargin = contentMarginFunc(self.parentViewController, contentMarginSEL);
		UIEdgeInsets insets = self.parentViewController.view.safeAreaInsets;
		
		_setContentOverlayInsets_andLeftMargin_rightMarginFunc(self, _setContentOverlayInsets_andLeftMargin_rightMarginSEL, insets, contentMargin, contentMargin);
		setContentMarginFunc(self, setContentMarginSEL, contentMargin);
	}
	
	if(LNPopupBar.isCatalystApp && self.popupContentViewController)
	{
		[self.popupContentViewController _uLFSBAIO];
		[self._ln_popupController_nocreate.popupContentView _repositionPopupCloseButton];
	}
}


//_viewSafeAreaInsetsFromScene (iOS 14)
- (UIEdgeInsets)_vSAIFS
{
	if([self respondsToSelector:@selector(_ln_popupUIRequiresZeroInsets)] && self._ln_popupUIRequiresZeroInsets == YES)
	{
		return UIEdgeInsetsZero;
	}
	
	if([self _isContainedInPopupController])
	{
		return __LNEdgeInsetsSum(self.popupPresentationContainerViewController.view.safeAreaInsets, UIEdgeInsetsMake(0, 0, - _LNPopupSafeAreaInsets(self.popupPresentationContainerViewController).bottom, 0));
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
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_bottomBarExtension_nocreate belowSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
	[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupContentView belowSubview:self._ln_popupController_nocreate.popupBar];
}

- (void)_layoutPopupBarOrderForUse
{
	UIView* bottomBar = self.bottomDockingViewForPopup_internalOrDeveloper;
	LNPopupBar* popupBar = self._ln_popupController_nocreate.popupBar;
	UIView* parentForPopupBar = bottomBar.superview != nil ? bottomBar.superview : popupBar.superview;
	
	[bottomBar.superview bringSubviewToFront:bottomBar];
	if(popupBar.resolvedIsFloating)
	{
		[parentForPopupBar insertSubview:popupBar aboveSubview:bottomBar];
	}
	else
	{
		[parentForPopupBar insertSubview:popupBar belowSubview:bottomBar];
	}
	[parentForPopupBar insertSubview:self._ln_bottomBarExtension_nocreate belowSubview:popupBar];
	[parentForPopupBar insertSubview:self._ln_popupController_nocreate.popupContentView aboveSubview:popupBar];
	if(popupBar.os26TransitionView != nil)
	{
		[parentForPopupBar insertSubview:popupBar.os26TransitionView aboveSubview:popupBar];
	}
}

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension_nocreate
{
	return objc_getAssociatedObject(self, LNPopupBarExtensionView);
}

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension
{
	if(LNPopupEnvironmentHasGlass())
	{
		return nil;
	}
	
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

- (void)_ln_layoutPopupBarAndContent
{
	if(self._ln_popupController_nocreate.popupControllerInternalState > LNPopupPresentationStateBarHidden)
	{
		if(self.bottomDockingViewForPopup_nocreateOrDeveloper == self._ln_bottomBarSupport_nocreate)
		{
			self._ln_bottomBarSupport_nocreate.frame = [self _defaultFrameForBottomDockingViewForPopupBar:self._ln_popupController_nocreate.popupBar];
			[self.view bringSubviewToFront:self._ln_bottomBarSupport_nocreate];
			
			self._ln_bottomBarExtension.frame = self._ln_bottomBarSupport_nocreate.frame;
		}
		else
		{
			self._ln_bottomBarSupport_nocreate.hidden = YES;
		}
		
		if([self isKindOfClass:UINavigationController.class] == NO && [self isKindOfClass:UITabBarController.class] == NO)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = self._ln_popupController_nocreate.popupBar.resolvedIsFloating ? 0.0 : 1.0;
		}
		
		if(self._ignoringLayoutDuringTransition == NO && self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
		{
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		}
		
		if(self._ignoringLayoutDuringTransition == NO)
		{
			[self _layoutPopupBarOrderForUse];
		}
		
		if(self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
		{
			CGFloat offset = [self _ln_popupOffsetForPopupBar:self.popupBar];
			CGFloat realHeight = _LNPopupBarHeightForPopupBar(self.popupBar);
			CGFloat barHeightToUse;
			
			if((self._ln_popupController_nocreate.popupControllerPublicState == LNPopupPresentationStateBarPresented && self._ln_popupController_nocreate.popupControllerTargetState >= self._ln_popupController_nocreate.popupControllerPublicState) || self._ln_popupController_nocreate.popupControllerPublicState == LNPopupPresentationStateOpen)
			{
				//Use real bar height and offset
				barHeightToUse = realHeight - offset;
			}
			else
			{
				//Use frame size and relative offset for animating popup bar presentation/dismiss.
				barHeightToUse = self.popupBar.frame.size.height - (self.popupBar.frame.size.height / realHeight) * offset;
			}
			
			UIEdgeInsets neededInsets = UIEdgeInsetsMake(0, 0, MAX(0, barHeightToUse), 0);
			
			UIEdgeInsets safe = _LNPopupSafeAreaInsets(self);
			UIEdgeInsets childAdditive = _LNPopupChildAdditiveSafeAreas(self);
			
			if(neededInsets.bottom != MAX(safe.bottom, childAdditive.bottom))
			{
				_LNPopupSupportSetPopupInsetsForViewController(self, YES, neededInsets);
			}
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

- (void)_ln_popup_viewDidLayoutSubviews
{
	[self _ln_popup_viewDidLayoutSubviews];
	
	[self _ln_layoutPopupBarAndContent];
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
	void (*super_class)(struct objc_super*, SEL, BOOL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
	super_class(&super, @selector(viewWillAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewIsAppearing:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
	super_class(&super, @selector(viewIsAppearing:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidAppear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
	super_class(&super, @selector(viewDidAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewWillDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
	super_class(&super, @selector(viewWillDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
	super_class(&super, @selector(viewDidDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

@end

static void __LNPopupUpdateChildInsets(UIViewController* controller)
{
	if(controller.requiresIndirectSafeAreaManagement == YES)
	{
		for (__kindof UIViewController* obj in controller.childViewControllers)
		{
			__LNPopupUpdateChildInsets(obj);
		}
		
		return;
	}
	
	UIEdgeInsets popupSafeAreaInsets = UIEdgeInsetsZero;
	
	UIViewController* parentViewController = controller.parentViewController;
	
	while(parentViewController != nil && parentViewController.requiresIndirectSafeAreaManagement == YES)
	{
		popupSafeAreaInsets = __LNEdgeInsetsSum(popupSafeAreaInsets, _LNPopupChildAdditiveSafeAreas(parentViewController));
		parentViewController = parentViewController.parentViewController;
	}
	
	_LNSetPopupSafeAreaInsets(controller, popupSafeAreaInsets);
}

void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL wantsLayout, UIEdgeInsets popupEdgeInsets)
{
	BOOL shouldLayout = NO;
	
	//Container classes with bottom bars have bugs if additional safe areas are applied directly to them.
	//Instead, set a custom property and update their children recursively to take care of the additional safe area.
	if(controller.requiresIndirectSafeAreaManagement == YES)
	{
		UIEdgeInsets current = _LNPopupChildAdditiveSafeAreas(controller);
		if(UIEdgeInsetsEqualToEdgeInsets(current, popupEdgeInsets) == NO)
		{
			shouldLayout = YES;
			[controller _ln_setChildAdditiveSafeAreaInsets:popupEdgeInsets];
			__LNPopupUpdateChildInsets(controller);
		}
	}
	else
	{
		UIEdgeInsets current = _LNPopupSafeAreaInsets(controller);
		if(UIEdgeInsetsEqualToEdgeInsets(current, popupEdgeInsets) == NO)
		{
			shouldLayout = YES;
			_LNSetPopupSafeAreaInsets(controller, popupEdgeInsets);
		}
	}
	
	if(wantsLayout && shouldLayout)
	{
		[controller.view setNeedsUpdateConstraints];
		[controller.view setNeedsLayout];
		[controller.view layoutIfNeeded];
	}
}

#pragma mark - UITabBarController

@implementation UITabBarController (LNPopupSupportPrivate)

- (void)_layoutModernTabBarControllerFloatingPopupWithSuperFallback:(void(^)(void))superFallback API_AVAILABLE(ios(26.0))
{
	LNPopupBar* popupBar = self._ln_popupController_nocreate.popupBar;

	static NSString* className = LNPopupHiddenString("Container");
	NSUInteger idx = [self.view.subviews indexOfObjectPassingTest:^BOOL(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		return [NSStringFromClass(obj.class) containsString:className];
	}];
	
	if(idx == NSNotFound)
	{
		superFallback();
	}
	else
	{
		UIView* tabBarContainer = [self.view.subviews objectAtIndex:idx];
		
		[self.view insertSubview:self._ln_popupController_nocreate.popupBar belowSubview:tabBarContainer];
		[self.view insertSubview:self._ln_popupController_nocreate.popupContentView aboveSubview:tabBarContainer];
		if(self._ln_popupController_nocreate.popupBar.os26TransitionView != nil)
		{
			[self.view insertSubview:self._ln_popupController_nocreate.popupBar.os26TransitionView aboveSubview:self._ln_popupController_nocreate.popupBar];
		}
	}
	
	popupBar._hackyMargins = [self _ln_popupBarMarginsForPopupBar:popupBar];
	
	[popupBar layoutIfNeeded];
}

- (void)_layoutPopupBarOrderForTransition
{
	if(!LNPopupEnvironmentHasGlass())
	{
		[super _layoutPopupBarOrderForTransition];
		return;
	}
	
	if(@available(iOS 26.0, *))
	[self _layoutModernTabBarControllerFloatingPopupWithSuperFallback:^{
		[super _layoutPopupBarOrderForTransition];
	}];
}

- (void)_layoutPopupBarOrderForUse
{
	void (^legacy)(void) = ^
	{
		if(@available(iOS 18.0, *))
		{
			LNPopupBar* popupBar = self._ln_popupController_nocreate.popupBar;
			popupBar._hackyMargins = NSDirectionalEdgeInsetsZero;
			
			static NSString* outlineViewKey = LNPopupHiddenString("_outlineView");
			UIView* outlineView = [self.sidebar valueForKey:outlineViewKey];
			
			if(self.tabBar.superview != nil || outlineView == nil)
			{
				[super _layoutPopupBarOrderForUse];
				[popupBar layoutIfNeeded];
				return;
			}
			
			popupBar._hackyMargins = [self _ln_popupBarMarginsForPopupBar:popupBar];
			if(popupBar._hackyMargins.leading > 0)
			{
				[super _layoutPopupBarOrderForUse];
				[popupBar layoutIfNeeded];
				return;
			}
			
			static NSString* tabContainerViewKey = LNPopupHiddenString("visualStyle.tabContainerView");
			UIView* parentForPopupBar = [self valueForKeyPath:tabContainerViewKey];
			[parentForPopupBar insertSubview:popupBar atIndex:0];
			[parentForPopupBar insertSubview:self._ln_bottomBarExtension_nocreate belowSubview:popupBar];
			[parentForPopupBar insertSubview:self._ln_popupController_nocreate.popupContentView atIndex:parentForPopupBar.subviews.count];
			
			[popupBar layoutIfNeeded];
			
			return;
		}
		
		[super _layoutPopupBarOrderForUse];
	};
	
	if(@available(iOS 26.0, *))
	if(LNPopupEnvironmentHasGlass())
	{
		[self _layoutModernTabBarControllerFloatingPopupWithSuperFallback:legacy];
		return;
	}
	
	legacy();
}

- (BOOL)_isTabBarHiddenDuringTransition
{
	NSNumber* isHidden = objc_getAssociatedObject(self, LNToolbarHiddenBeforeTransition);
	return isHidden.boolValue || self.tabBar.superview == nil;
}

- (void)_setTabBarHiddenDuringTransition:(BOOL)tabBarHidden
{
	objc_setAssociatedObject(self, LNToolbarHiddenBeforeTransition, @(tabBarHidden), OBJC_ASSOCIATION_RETAIN);
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
	if(LNPopupEnvironmentHasGlass())
	{
		return UIEdgeInsetsZero;
	}
	
	return self.tabBar.hidden == NO && self._isTabBarHiddenDuringTransition == NO ? UIEdgeInsetsZero : self.view.superview.safeAreaInsets;
}

- (CGFloat)_ln_popupOffsetForPopupBar:(LNPopupBar *)popupBar
{
	if(self._isTabBarHiddenDuringTransition)
	{
		return [super _ln_popupOffsetForPopupBar:popupBar];
	}
	
	if(LNPopupEnvironmentTabBarSupportsMinimizationAPI() && popupBar.supportsMinimization && self._ln_isFloatingTabBar == NO && (popupBar.resolvedIsCustom == NO || popupBar.customBarWantsFullBarWidth == NO))
	{
		CGRect proposedFrame = self.tabBar._ln_proposedFrameForPopupBar;
		return proposedFrame.origin.y + proposedFrame.size.height;
	}
	
	if(LNPopupEnvironmentHasGlass())
	{
		return -8.0;
	}
	
	return 0.0;
}

- (BOOL)requiresIndirectSafeAreaManagement
{
	return YES;
}

- (CGRect)defaultFrameForBottomDockingView
{
	if(LNPopupEnvironmentHasGlass() && self._isTabBarHiddenDuringTransition)
	{
		return super.defaultFrameForBottomDockingView_internal;
	}
	
	CGRect bottomBarFrame = self.tabBar.frame;
	bottomBarFrame.origin = CGPointMake(0, self.view.bounds.size.height - (self._isTabBarHiddenDuringTransition ? 0.0 : bottomBarFrame.size.height));
	return bottomBarFrame;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNSwizzleMethod(self,
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_tvc));
		
		LNSwizzleMethod(self,
						@selector(setSelectedViewController:),
						@selector(_ln_setSelectedViewController:));
		
		LNSwizzleMethod(self,
						@selector(setViewControllers:animated:),
						@selector(_ln_setViewControllers:animated:));
		
		if(LNPopupEnvironmentHasGlass())
		{
			LNSwizzleMethod(self,
							@selector(setTabBarHidden:animated:),
							@selector(_ln_setTabBarHidden:animated:));
		}
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		
		selName = LNPopupHiddenString("_hideBarWithTransition:isExplicit:duration:reason:");
		if([self instancesRespondToSelector:NSSelectorFromString(selName)])
		{
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(hBWT:iE:d:r:));
		}
		else
		{
			selName = LNPopupHiddenString("_hideBarWithTransition:isExplicit:duration:");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(hBWT:iE:d:));
		}
		
		selName = LNPopupHiddenString("_showBarWithTransition:isExplicit:duration:reason:");
		if([self instancesRespondToSelector:NSSelectorFromString(selName)])
		{
			//_showBarWithTransition:isExplicit:duration:reason:
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(sBWT:iE:d:r:));
		}
		else
		{
			selName = LNPopupHiddenString("_showBarWithTransition:isExplicit:duration:");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(sBWT:iE:d:));
		}
		
		selName = LNPopupHiddenString("_updateLayoutForStatusBarAndInterfaceOrientation");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_uLFSBAIO));
		
		selName = LNPopupHiddenString("_prepareTabBar");
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
		if(self.tabBar.isHidden == NO && self._isTabBarHiddenDuringTransition == NO && self._ignoringLayoutDuringTransition == NO && self._ln_isFloatingTabBar == NO)
		{
			self._ln_bottomBarExtension_nocreate.hidden = YES;
			[self._ln_bottomBarExtension_nocreate removeFromSuperview];
			
			if(self._ln_popupController_nocreate.popupBar.resolvedIsFloating)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			}
			
		}
		else
		{
			self._ln_bottomBarExtension.hidden = NO;
			
			if(self._ln_isFloatingTabBar == YES)
			{
				self._ln_bottomBarExtension_nocreate.alpha = 1.0;
			}
			
			if(self._ln_popupController_nocreate.popupBar.resolvedIsFloating && self._ignoringLayoutDuringTransition == NO)
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
	super_call(&superInfo, _cmd);
	
	if(self._ignoringLayoutDuringTransition == NO)
	{
		CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
		CGRect frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
		UIEdgeInsets hackyInsets = _LNEdgeInsetsFromDirectionalEdgeInsets(self._ln_popupController_nocreate.popupBar, self._ln_popupController_nocreate.popupBar._hackyMargins);
		self._ln_bottomBarExtension_nocreate.frame = UIEdgeInsetsInsetRect(frame, hackyInsets);
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
	CGFloat offset = [self _ln_popupOffsetForPopupBar:self._ln_popupController_nocreate.popupBar];
	frame.origin.y = defaultFrame.origin.y - frame.size.height - self.insetsForBottomDockingView.bottom + offset;
	self._ln_popupController_nocreate.popupBar.frame = frame;
}

- (void)_ln_animateAlongsideTransition:(NSUInteger)transition withDuration:(NSTimeInterval)duration animations:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animations completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
	id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.selectedViewController.transitionCoordinator;
	
	__weak __typeof(self) weakSelf = self;
	
	if(transitionCoordinator != nil)
	{
		[transitionCoordinator animateAlongsideTransition:animations completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			if(completion != nil)
			{
				completion(context);
			}
		}];
	}
	else
	{
		__LNFakeContext* ctx = [__LNFakeContext new];
		ctx.cancelled = NO;
		if(duration != 0)
		{
			if(duration == -1)
			{
				duration = __ln_tabBarTransitionDuration(self, transition);
			}
			
			[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^{
				if(animations != nil)
				{
					animations((id)ctx);
				}
			} completion:^(BOOL finished) {
				if(completion != nil)
				{
					completion((id)ctx);
				}
			}];
		}
		else
		{
			[UIView performWithoutAnimation:^{
				if(animations != nil)
				{
					animations((id)ctx);
				}
				if(completion != nil)
				{
					completion((id)ctx);
				}
			}];
		}
	}
}

- (BOOL)_ln_isFloatingTabBar
{
	if(ln_unavailable(iOS 18.0, *))
	{
		return NO;
	}
	
	if(self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		return YES;
	}
	
	return NO;
}

- (void)_ln_hideLogicWithTransition:(NSInteger)transition isExplicit:(BOOL)isExplicit duration:(NSTimeInterval)duration superCall:(void(^)(void))superCall
{
	if(self._ln_popupController_nocreate.popupControllerInternalState == LNPopupPresentationStateBarHidden || self._ln_isFloatingTabBar == YES)
	{
		[self _setTabBarHiddenDuringTransition:YES];
		
		superCall();
		
		[self _ln_animateAlongsideTransition:transition withDuration:duration animations:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			if(transition != 1)
			{
				[self _ln_updateSafeAreaInsets];
				[self.view layoutIfNeeded];
			}
		} completion:nil];
		
		return;
	}
	
	if(__ln_alreadyInHideShowBar == YES)
	{
		//Ignore nested calls to _hideBarWithTransition:isExplicit:duration:reason:
		superCall();
		return;
	}
	
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedIsFloating;
	if(!isFloating)
	{
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	}
	
	BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.tabBar.superview.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
	
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	CGRect frame = self.tabBar.frame;
	if(transition == 1)
	{
		frame.origin.x = (isRTL ? -1 : 1) * self.view.bounds.size.width;
	}
	self._ln_bottomBarExtension.frame = frame;
	self._ln_bottomBarExtension_nocreate.hidden = NO;
	self._ln_bottomBarExtension_nocreate.alpha = 1.0;
	
	[self._ln_bottomBarExtension layoutIfNeeded];
	
	__ln_alreadyInHideShowBar = YES;
	superCall();
	__ln_alreadyInHideShowBar = NO;
	
	if(transition != 1 && isExplicit == NO)
	{
		return;
	}
	
	NSString* effectGroupingIdentifier = self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier;
	NSString* traitOverride = nil;
	
	if(@available(iOS 17.0, *))
	{
		traitOverride = [self._ln_popupController_nocreate.bottomBar.traitCollection objectForTrait:_LNPopupBarBackgroundGroupNameOverride.class];
	}
	
	if(transition == 1)
	{
		if(@available(iOS 17.0, *))
		{
			[self._ln_popupController_nocreate.bottomBar.traitOverrides setObject:nil forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
		}
		else
		{
			self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = nil;
		}
	}
	else
	{
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
	}
	
	self._ln_popupController_nocreate.popupBar.wantsBackgroundCutout = NO;
	if(transition == 1 && isFloating)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = NO;
	}
	
	[self.tabBar _setIgnoringLayoutDuringTransition:YES];
	[self _setIgnoringLayoutDuringTransition:YES];
	
	CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
	
	[self _layoutPopupBarOrderForTransition];
	
	CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
	
	self._ln_bottomBarExtension_nocreate.alpha = 1.0;
	
	void (^animations)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self._ln_popupController_nocreate _popupBarMetricsDidChange:self._ln_popupController_nocreate.popupBar shouldLayout:NO];
		//During the transition, animate the popup bar and content together with the tab bar transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		[self _setTabBarHiddenDuringTransition:YES];
		
		CGFloat barOffset = [self _ln_popupOffsetForPopupBar:self._ln_popupController_nocreate.popupBar];
		
		if(transition != 1)
		{
			[self _ln_updateSafeAreaInsets];
			[self.view layoutIfNeeded];
		}
		
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, self._ln_bottomBarExtension_nocreate.frame.size.height);
		
		if(transition == 1)
		{
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
		}
		
		[self __repositionPopupBarToClosed_hack];
		
		if(isFloating)
		{
			[self._ln_popupController_nocreate.popupBar layoutIfNeeded];
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			
			if(transition == 1)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.frame = CGRectOffset(backgroundViewFrame, (isRTL ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + bottomSafeArea - barOffset);
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 1.0;
			}
			else
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.frame = CGRectOffset(backgroundViewFrame, 0, bottomSafeArea - barOffset);
				self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 0.0;
			}
		}
	};
	
	void (^completion)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self.tabBar _setIgnoringLayoutDuringTransition:NO];
		
		if(isFloating)
		{
			if(transition == 1)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = YES;
			}
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 0.0;
		}
		[self._ln_popupController_nocreate.popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
		
		self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
		
		[self _setIgnoringLayoutDuringTransition:NO];
		[self._ln_popupController_nocreate _popupBarMetricsDidChange:self._ln_popupController_nocreate.popupBar shouldLayout:NO];
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		
		if(@available(iOS 17.0, *))
		{
			[self._ln_popupController_nocreate.bottomBar.traitOverrides setObject:traitOverride forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
		}
		else
		{
			self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = effectGroupingIdentifier;
		}
		
		self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
		
		[self _layoutPopupBarOrderForUse];
	};
	
	[self _ln_animateAlongsideTransition:transition withDuration:duration animations:animations completion:completion];
}

- (void)_ln_showLogicWithTransition:(NSInteger)transition isExplicit:(BOOL)isExplicit duration:(NSTimeInterval)duration superCall:(void(^)(void))superCall
{
	if(__ln_alreadyInHideShowBar == YES)
	{
		//Ignore nested calls to _showBarWithTransition:isExplicit:duration:
		superCall();
		return;
	}
	
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedIsFloating;
	
	BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.tabBar.superview.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
	
	[self._ln_popupController_nocreate.popupBar _cancelGestureRecognizers];
	
	BOOL wasHidden = self.tabBar.isHidden || self._isTabBarHiddenDuringTransition;

	__ln_alreadyInHideShowBar = YES;
	superCall();
	__ln_alreadyInHideShowBar = NO;
	
	if(LNPopupEnvironmentHasGlass())
	{
		BOOL isUserHidden = NO;
		if(@available(iOS 26.0, *))
		{
			isUserHidden = self.isTabBarHidden;
		}
		
		if(isUserHidden == YES)
		{
			return;
		}
	}
	
	CGFloat laterBarOffset = [self _ln_popupOffsetForPopupBar:self._ln_popupController_nocreate.popupBar];
	
	if(isExplicit == NO)
	{
		return;
	}
	
	if(wasHidden == NO)
	{
		return;
	}
	
	if(self._ln_isFloatingTabBar == YES)
	{
		[self.view setNeedsLayout];
		[self _setTabBarHiddenDuringTransition:NO];
		
		return;
	}
	
	if(!isFloating)
	{
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	}
	
	[self _setPrepareTabBarIgnored:YES];
	
	self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
	
	self._ln_popupController_nocreate.popupBar.wantsBackgroundCutout = NO;
	
	__block CGRect frame = self.tabBar.frame;
	
	__block CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
	CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
	if(transition == 2 && isFloating)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 1.0;
		self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.hidden = NO;
		
		CGRect initial = CGRectOffset(backgroundViewFrame, (isRTL ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + bottomSafeArea - laterBarOffset);
		
		self._ln_popupController_nocreate.popupBar.backgroundView.frame = initial;
	}
	else if(isFloating)
	{
		self._ln_popupController_nocreate.popupBar.backgroundView.frame = CGRectOffset(backgroundViewFrame, 0, bottomSafeArea - laterBarOffset);
	}
	
	[self _setIgnoringLayoutDuringTransition:YES];
	
	NSString* effectGroupingIdentifier = self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier;
	NSString* traitOverride = nil;
	
	if(@available(iOS 17.0, *))
	{
		traitOverride = [self._ln_popupController_nocreate.bottomBar.traitCollection objectForTrait:_LNPopupBarBackgroundGroupNameOverride.class];
	}
	
	if(transition == 2)
	{
		if(@available(iOS 17.0, *))
		{
			[self._ln_popupController_nocreate.bottomBar.traitOverrides setObject:nil forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
		}
		else
		{
			self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = nil;
		}
	}
	
	void (^animations)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setTabBarHiddenDuringTransition:NO];
		
		if(transition != 2)
		{
			[self _ln_updateSafeAreaInsets];
			[self.view setNeedsLayout];
			[self.view layoutIfNeeded];
		}
		
		[UIView performWithoutAnimation:^{
			self.tabBar.frame = frame;
		}];
		
		if(transition == 2)
		{
			frame.origin.x += (isRTL ? -1 : 1) * self.view.bounds.size.width;
		}
		self._ln_bottomBarExtension.frame = frame;
		
		if(transition == 2)
		{
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		}
		if(isFloating)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = backgroundViewFrame;
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = 1.0;
			if(transition == 2)
			{
				self._ln_popupController_nocreate.popupBar.backgroundView.transitionShadingView.alpha = 0.0;
			}
		}
		
		[self _layoutPopupBarOrderForTransition];
		[self __repositionPopupBarToClosed_hack];
		
		[self._ln_popupController_nocreate _popupBarMetricsDidChange:self._ln_popupController_nocreate.popupBar shouldLayout:NO];
		//During the transition, animate the popup bar and content together with the tab bar transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
	};
	
	void (^completion)(id<UIViewControllerTransitionCoordinatorContext>) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPrepareTabBarIgnored:NO];
		[self._ln_popupController_nocreate.popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
		
		if(transition == 2 && isFloating)
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
		[self._ln_popupController_nocreate _popupBarMetricsDidChange:self._ln_popupController_nocreate.popupBar shouldLayout:NO];
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		
		[self _layoutPopupBarOrderForUse];
		
		[self _setIgnoringLayoutDuringTransition:NO];
		
		if(@available(iOS 17.0, *))
		{
			[self._ln_popupController_nocreate.bottomBar.traitOverrides setObject:traitOverride forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
		}
		else
		{
			self._ln_popupController_nocreate.popupBar.effectGroupingIdentifier = effectGroupingIdentifier;
		}
		
		if(context.isCancelled == NO)
		{
			self._ln_bottomBarExtension_nocreate.alpha = 0.0;
		}
	};
	
	[self _ln_animateAlongsideTransition:transition withDuration:duration animations:animations completion:completion];
}

//_hideBarWithTransition:isExplicit:duration:
- (void)hBWT:(NSInteger)t iE:(BOOL)e d:(NSTimeInterval)duration
{
	[self _ln_hideLogicWithTransition:t isExplicit:e duration:duration superCall:^{
		[self hBWT:t iE:e d:duration];
	}];
}

//_hideBarWithTransition:isExplicit:duration:reason:
- (void)hBWT:(NSInteger)transition iE:(BOOL)isExplicit d:(NSTimeInterval)duration r:(NSUInteger)reason
{
	[self _ln_hideLogicWithTransition:transition isExplicit:isExplicit duration:duration superCall:^{
		[self hBWT:transition iE:isExplicit d:duration r:reason];
	}];
}

//_showBarWithTransition:isExplicit:duration:
- (void)sBWT:(NSInteger)t iE:(BOOL)e d:(NSTimeInterval)duration
{
	[self _ln_showLogicWithTransition:t isExplicit:e duration:duration superCall:^{
		[self sBWT:t iE:e d:duration];
	}];
}

//_showBarWithTransition:isExplicit:duration:reason:
- (void)sBWT:(NSInteger)transition iE:(BOOL)isExplicit d:(NSTimeInterval)duration r:(NSUInteger)reason
{
	[self _ln_showLogicWithTransition:transition isExplicit:isExplicit duration:duration superCall:^{
		[self sBWT:transition iE:isExplicit d:duration r:reason];
	}];
}

- (void)_ln_setTabBarHidden:(BOOL)hidden animated:(BOOL)animated API_AVAILABLE(ios(18.0))
{
	if(self.isTabBarHidden == hidden)
	{
		return;
	}
	
	void(^superCall)(void) = ^
	{
		[self _ln_setTabBarHidden:hidden animated:animated];
	};
	
	if(hidden)
	{
		[self _ln_hideLogicWithTransition: animated ? 7 : 0 isExplicit:YES duration:-1 superCall:superCall];
	}
	else
	{
		[self _ln_showLogicWithTransition: animated ? 3 : 0 isExplicit:YES duration:-1 superCall:superCall];
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

//updateTabBarLayout
- (void)_ln_uTBL
{
	if(self._ignoringLayoutDuringTransition == NO)
	{
		[self _ln_uTBL];
	}
}

#endif

@end

#pragma mark - UINavigationController

@interface UINavigationController (LNPopupSupportPrivate) @end
@implementation UINavigationController (LNPopupSupportPrivate)

- (void)_layoutModernNavigationControllerFloatingPopupWithSuperFallback:(void(^)(void))superFallback
{
	static NSString* floatingBarContainerKey = LNPopupHiddenString("floatingBarContainerView");
	UIView* floatingBarContainer = [self valueForKey:floatingBarContainerKey];
	
	if(floatingBarContainer == nil)
	{
		superFallback();
		return;
	}
	
	[self.view insertSubview:self._ln_popupController_nocreate.popupBar belowSubview:floatingBarContainer];
	[self.view insertSubview:self._ln_popupController_nocreate.popupContentView aboveSubview:floatingBarContainer];
	[self.view insertSubview:self._ln_popupController_nocreate.popupBar.os26TransitionView aboveSubview:self._ln_popupController_nocreate.popupBar];
}

- (void)_layoutPopupBarOrderForTransition
{
	if(!LNPopupEnvironmentHasGlass())
	{
		[super _layoutPopupBarOrderForTransition];
		return;
	}
	
	[self _layoutModernNavigationControllerFloatingPopupWithSuperFallback:^{
		[super _layoutPopupBarOrderForTransition];
	}];
}

- (void)_layoutPopupBarOrderForUse
{
	if(!LNPopupEnvironmentHasGlass())
	{
		[super _layoutPopupBarOrderForUse];
		return;
	}
	
	[self _layoutModernNavigationControllerFloatingPopupWithSuperFallback:^{
		[super _layoutPopupBarOrderForUse];
	}];
}

- (nullable UIView *)bottomDockingViewForPopup_nocreate
{
	return self.toolbar;
}

- (nullable UIView *)bottomDockingViewForPopupBar
{
	return self.toolbar;
}

- (CGFloat)_ln_popupOffsetForPopupBar:(LNPopupBar *)popupBar
{
	return self.isToolbarHidden ? [super _ln_popupOffsetForPopupBar:popupBar] : LNPopupEnvironmentHasGlass() ? -8.0 : 0.0;
}

- (CGRect)defaultFrameForBottomDockingView
{
	if(LNPopupEnvironmentHasGlass())
	{
		static auto key = LNPopupHiddenString("_floatingBarContainerView.toolbarOverlayInset");
		CGFloat inset;
		if(self.isToolbarHidden)
		{
			inset = self.view.safeAreaInsets.bottom;
		}
		else
		{
			inset = [[self valueForKeyPath:key] doubleValue];
		}
		return CGRectMake(0, self.view.bounds.size.height - inset, self.view.bounds.size.width, inset);
	}
	
	CGRect toolbarBarFrame = self.toolbar.frame;

	CGFloat bottomSafeAreaHeight = 0.0;
	if(ln_unavailable(iOS 18.0, *))
	{
		bottomSafeAreaHeight = self.view.safeAreaInsets.bottom;
		if([NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"] == NO)
		{
			bottomSafeAreaHeight -= self.view.window.safeAreaInsets.bottom;
		}
	}
	toolbarBarFrame.origin = CGPointMake(toolbarBarFrame.origin.x, self.view.bounds.size.height - (self.isToolbarHidden ? 0.0 : toolbarBarFrame.size.height) - bottomSafeAreaHeight);
	
	if(@available(iOS 18.0, *))
	{
		CGFloat offset = 0;
		
		if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			static auto key = LNPopupHiddenString("_backgroundView.bounds");
			if([[self.toolbar valueForKeyPath:key] CGRectValue].size.height < (self.toolbar.bounds.size.height + self.view.safeAreaInsets.bottom))
			{
				//Something in UIKit reports safe area insets incorrectly on iPadOS. This is a workaround for this issue.
				offset = 5.0;
			}
		}
		
		toolbarBarFrame.origin.y += offset;
	}
	
	return toolbarBarFrame;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	if(LNPopupEnvironmentHasGlass())
	{
		return UIEdgeInsetsZero;
	}
	
	BOOL isPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
	
	if(self.presentingViewController != nil && [NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"])
	{
		return UIEdgeInsetsZero;
	}

	return UIEdgeInsetsMake(0, 0, MAX(self.view.superview.safeAreaInsets.bottom, self.view.window.safeAreaInsets.bottom), 0);
}

- (BOOL)requiresIndirectSafeAreaManagement
{
	return YES;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
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
		
		selName = LNPopupHiddenString("_setToolbarHidden:edge:duration:");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_sTH:e:d:));
		
		selName = LNPopupHiddenString("_hideShowNavigationBarDidStop:finished:context:");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(hSNBDS:f:c:));
		
		selName = LNPopupHiddenString("_updateLayoutForStatusBarAndInterfaceOrientation");
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
			BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedIsFloating;
			
			if(self.isToolbarHidden == NO)
			{
				self._ln_bottomBarExtension_nocreate.hidden = YES;
				[self._ln_bottomBarExtension_nocreate removeFromSuperview];
				
				if(isFloating)
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
	BOOL isFloating = self._ln_popupController_nocreate.popupBar.resolvedIsFloating;
	
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
	
	if(edge == UIRectEdgeBottom && wasToolbarHidden != hidden)
	{
		[self _setIgnoringLayoutDuringTransition:YES];
	}
	
	CGFloat earlyBarOffset = [self _ln_popupOffsetForPopupBar:self._ln_popupController_nocreate.popupBar];
	
	__ln_hideBarEdge = edge;
	__ln_alreadyInHideShowBar = YES;
	//Trigger the toolbar hide or show transition.
	[self _sTH:hidden e:edge d:duration];
	__ln_alreadyInHideShowBar = NO;
	__ln_hideBarEdge = UIRectEdgeNone;
	
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
		
		CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
		CGRect backgroundViewFrame = self._ln_popupController_nocreate.popupBar.backgroundView.frame;
		CGRect initialBackgroundViewFrame;
		CGRect targetBackgroundViewFrame;
		
		CGFloat laterBarOffset = [self _ln_popupOffsetForPopupBar:self._ln_popupController_nocreate.popupBar];
		
		if(edge == UIRectEdgeBottom)
		{
			if(hidden == YES)
			{
				initialBackgroundViewFrame = backgroundViewFrame;
				targetBackgroundViewFrame = CGRectOffset(backgroundViewFrame, 0, bottomSafeArea - laterBarOffset);
			}
			else
			{
				initialBackgroundViewFrame = CGRectOffset(backgroundViewFrame, 0, bottomSafeArea - earlyBarOffset);
				targetBackgroundViewFrame = backgroundViewFrame;
			}
		}
		else if(hidden == YES)
		{
			initialBackgroundViewFrame = backgroundViewFrame;
			targetBackgroundViewFrame = CGRectOffset(backgroundViewFrame, (edge == UIRectEdgeRight ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + bottomSafeArea - laterBarOffset);
		}
		else
		{
			initialBackgroundViewFrame = CGRectOffset(backgroundViewFrame, (edge == UIRectEdgeRight ? 1 : -1) * CGRectGetWidth(backgroundViewFrame), -CGRectGetHeight(frame) + bottomSafeArea - earlyBarOffset);
			targetBackgroundViewFrame = backgroundViewFrame;
		}
		
		if(isFloating)
		{
			self._ln_popupController_nocreate.popupBar.backgroundView.alpha = (hidden == YES || edge != UIRectEdgeBottom) ? 1.0 : 0.0;
			self._ln_popupController_nocreate.popupBar.backgroundView.frame = initialBackgroundViewFrame;
		}
		
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = hidden == NO ? 0.0 : 1.0;
		
		CGFloat safeArea = self.view.superview.safeAreaInsets.bottom;
		
		[self _layoutPopupBarOrderForTransition];
		
		void (^animations)(void) = ^ {
			[self._ln_popupController_nocreate _popupBarMetricsDidChange:self._ln_popupController_nocreate.popupBar shouldLayout:NO];
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
					self._ln_popupController_nocreate.popupBar.backgroundView.alpha = edge == UIRectEdgeBottom ? 0.0 : 1.0;
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
		
		if(edge != UIRectEdgeBottom)
		{
			[self _setIgnoringLayoutDuringTransition:YES];
		}
		
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

- (BOOL)requiresIndirectSafeAreaManagement
{
	if(LNPopupEnvironmentHasGlass())
	{
		return YES;
	}
	
	return super.requiresIndirectSafeAreaManagement;
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
