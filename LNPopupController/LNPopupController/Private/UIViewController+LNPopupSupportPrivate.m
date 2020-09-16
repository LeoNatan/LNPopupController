//
//  UIViewController+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 1015 Leo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupSwizzlingUtils.h"

@import ObjectiveC;
@import Darwin;

static const void* LNToolbarHiddenBeforeTransition = &LNToolbarHiddenBeforeTransition;
static const void* LNPopupAdjustingInsets = &LNPopupAdjustingInsets;
static const void* LNPopupAdditionalSafeAreaInsets = &LNPopupAdditionalSafeAreaInsets;
static const void* LNUserAdditionalSafeAreaInsets = &LNUserAdditionalSafeAreaInsets;
static const void* LNPopupIgnorePrepareTabBar = &LNPopupIgnorePrepareTabBar;
static const void* LNPopupBarExtensionView = &LNPopupBarExtensionView;

#ifndef LNPopupControllerEnforceStrictClean
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

#if TARGET_OS_MACCATALYST
//_setSafeAreaInsets:updateSubviewsDuringNextLayoutPass:
static NSString* const sSAIuSDNLP = @"X3NldFNhZmVBcmVhSW5zZXRzOnVwZGF0ZVN1YnZpZXdzRHVyaW5nTmV4dExheW91dFBhc3M6";
//_updateContentOverlayInsetsFromParentIfNecessary
static NSString* const uCOIFPIN = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRnJvbVBhcmVudElmTmVjZXNzYXJ5";
//_viewDelegate
static NSString* const vD = @"X3ZpZXdEZWxlZ2F0ZQ==";
#endif

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

@implementation _LNPopupBarExtensionView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect
{
	self = [super init];
	
	if(self)
	{
		_effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
		[self addSubview:_effectView];
	}
	
	return self;
}

- (void)layoutSubviews
{
	_effectView.frame = self.bounds;
	
	[super layoutSubviews];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

	_effectView.frame = (CGRect){0, 0, CGSizeMake(MAX(20, frame.size.width), MAX(20, frame.size.height))};
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

#pragma mark - UIView

#if TARGET_OS_MACCATALYST
#ifndef LNPopupControllerEnforceStrictClean
@interface UIView (LNPopupLayout) @end
@implementation UIView (LNPopupLayout)

+ (void)load
{
	if(unavailable(iOS 14.0, *))
	{
		//_setSafeAreaInsets:updateSubviewsDuringNextLayoutPass:
		NSString* selName = _LNPopupDecodeBase64String(sSAIuSDNLP);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_sSAI:uSDNLP:));
	}
}

//_setSafeAreaInsets:updateSubviewsDuringNextLayoutPass:
- (void)_sSAI:(UIEdgeInsets)arg1 uSDNLP:(BOOL)arg2
{
	[self _sSAI:arg1 uSDNLP:arg2];
	
	if([self isKindOfClass:LNPopupContentView.class])
	{
		LNPopupContentView* contentView = (id)self;
		
		static SEL delegateSelector;
		static SEL updateSelector;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			//_viewDelegate
			delegateSelector = NSSelectorFromString(_LNPopupDecodeBase64String(vD));
			//_updateContentOverlayInsetsFromParentIfNecessary
			updateSelector = NSSelectorFromString(_LNPopupDecodeBase64String(uCOIFPIN));
		});
		
		[contentView.effectView.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[[obj performSelector:delegateSelector] performSelector:updateSelector];
			[obj _sSAI:__LNEdgeInsetsSum(self.superview.safeAreaInsets, contentView.currentPopupContentViewController.additionalSafeAreaInsets) uSDNLP:arg2];
			//			[obj performSelector:NSSelectorFromString(@"_recursiveEagerlyUpdateSafeAreaInsetsUntilViewController")];
#pragma clang diagnostic pop
		}];
	}
}

@end
#endif
#endif

#pragma mark - UIViewController

@interface UIViewController (LNPopupLayout) @end
@implementation UIViewController (LNPopupLayout)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (@available(iOS 13.0, *))
		{
			LNSwizzleMethod(self,
							@selector(isModalInPresentation),
							@selector(_ln_isModalInPresentation));
			
			LNSwizzleMethod(self,
							@selector(setOverrideUserInterfaceStyle:),
							@selector(_ln_popup_setOverrideUserInterfaceStyle:));
		}
		
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
						@selector(childViewControllerForStatusBarStyle),
						@selector(_ln_childViewControllerForStatusBarStyle));
		
		LNSwizzleMethod(self,
						@selector(childViewControllerForStatusBarHidden),
						@selector(_ln_childViewControllerForStatusBarHidden));
		
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
		
		//setParentViewController:
		selName = _LNPopupDecodeBase64String(sPVC);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_sPVC:));
		
#if ! TARGET_OS_MACCATALYST
		//_viewSafeAreaInsetsFromScene
		selName = _LNPopupDecodeBase64String(vSAIFSBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_vSAIFS));
#endif
#endif
	});
}

- (BOOL)_ln_isModalInPresentation
{
	if(self._ln_popupController_nocreate.popupControllerInternalState >= _LNPopupPresentationStateTransitioning)
	{
		return YES;
	}
	
	return [self _ln_isModalInPresentation];
}

- (void)_ln_popup_setOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle API_AVAILABLE(ios(13.0))
{
	[self _ln_popup_setOverrideUserInterfaceStyle:overrideUserInterfaceStyle];
	
	if(self._isContainedInPopupController)
	{
		[self.popupPresentationContainerViewController.popupContentView setControllerOverrideUserInterfaceStyle:overrideUserInterfaceStyle];
	}
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

UIEdgeInsets _LNPopupSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

static inline __attribute__((always_inline)) UIEdgeInsets _LNUserSafeAreas(id self)
{
	return [objc_getAssociatedObject(self, LNUserAdditionalSafeAreaInsets) UIEdgeInsetsValue];
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
	
	CGFloat additional = self._ln_popupController_nocreate.popupBar.frame.size.height;
	
	if([parentViewController isKindOfClass:UITabBarController.class] || [parentViewController isKindOfClass:UINavigationController.class])
	{
		additional += parentViewController._ln_popupController_nocreate.popupBar.frame.size.height;
	}
	
	_LNSetPopupSafeAreaInsets(self, UIEdgeInsetsMake(0, 0, additional, 0));
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

- (nullable UIViewController *)_common_childviewControllersForStatusBarLogic
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
#if ! TARGET_OS_MACCATALYST
	if(self.popupContentViewController)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:UIApplication.sharedApplication.statusBarOrientationAnimationDuration delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
				[self.popupContentViewController _uLFSBAIO];
				[self._ln_popupController_nocreate.popupContentView _repositionPopupCloseButton];
			} completion:nil];
		});
	}
#endif
}

//_updateLayoutForStatusBarAndInterfaceOrientation
- (void)_uLFSBAIO
{
	[self _uLFSBAIO];
	
	[self _common_uLFSBAIO];
}

//_viewSafeAreaInsetsFromScene
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
	if(@available(ios 13.0, *))
	{
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupBar aboveSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupContentView belowSubview:self._ln_popupController_nocreate.popupBar];
	}
	else {
		[self.bottomDockingViewForPopup_internalOrDeveloper.superview bringSubviewToFront:self.bottomDockingViewForPopup_internalOrDeveloper];
		[self._ln_popupController_nocreate.popupContentView.superview bringSubviewToFront:self._ln_popupController_nocreate.popupContentView];
		[self._ln_popupController_nocreate.popupBar.superview bringSubviewToFront:self._ln_popupController_nocreate.popupBar];
	}
}

- (void)_layoutPopupBarOrderForUse
{
	if(@available(ios 13.0, *))
	{
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupBar belowSubview:self.bottomDockingViewForPopup_internalOrDeveloper];
		[self._ln_popupController_nocreate.popupBar.superview insertSubview:self._ln_popupController_nocreate.popupContentView belowSubview:self._ln_popupController_nocreate.popupBar];
	}
	else {
		[self._ln_popupController_nocreate.popupBar.superview bringSubviewToFront:self._ln_popupController_nocreate.popupBar];
		[self.bottomDockingViewForPopup_internalOrDeveloper.superview bringSubviewToFront:self.bottomDockingViewForPopup_internalOrDeveloper];
		[self._ln_popupController_nocreate.popupContentView.superview bringSubviewToFront:self._ln_popupController_nocreate.popupContentView];
	}
}

- (_LNPopupBarExtensionView*)_ln_bottomBarExtension_nocreate
{
	return objc_getAssociatedObject(self, LNPopupBarExtensionView);
}

- (_LNPopupBarExtensionView*)_ln_bottomBarExtension
{
	if(self.shouldExtendPopupBarUnderSafeArea == NO || self._ln_popupController_nocreate.popupControllerTargetState == LNPopupPresentationStateBarHidden)
	{
		[self._ln_bottomBarExtension_nocreate removeFromSuperview];
		
		return nil;
	}
	
	_LNPopupBarExtensionView* rv = objc_getAssociatedObject(self, LNPopupBarExtensionView);
	if(rv == nil)
	{
		UIBlurEffectStyle blurStyle;
		if (@available(iOS 13.0, *))
		{
			blurStyle = UIBlurEffectStyleSystemChromeMaterial;
		}
		else
		{
			blurStyle = UIBlurEffectStyleLight;
		}
		rv = [[_LNPopupBarExtensionView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
		objc_setAssociatedObject(self, LNPopupBarExtensionView, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self._ln_popupController _updateBarExtensionStyleFromPopupBar];
	}
	
	if(rv.superview != self.view)
	{
		[self.view insertSubview:rv belowSubview:self.popupBar];
//		[self.view addSubview:rv];
	}
	
	return rv;
}

- (void)_ln_popup_viewDidLayoutSubviews
{
	[self _ln_popup_viewDidLayoutSubviews];
	
	if(self.bottomDockingViewForPopup_nocreateOrDeveloper != nil)
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
		
		if(self._ignoringLayoutDuringTransition == NO && self._ln_popupController_nocreate.popupControllerInternalState != LNPopupPresentationStateBarHidden)
		{
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
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

void __LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets, BOOL force)
{
	if(force == NO && ([controller isKindOfClass:UITabBarController.class] || [controller isKindOfClass:UINavigationController.class]))
	{
		[((UITabBarController*)controller).viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
			__LNPopupSupportSetPopupInsetsForViewController(obj, NO, popupEdgeInsets, YES);
		}];
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

void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets)
{
	__LNPopupSupportSetPopupInsetsForViewController(controller, layout, popupEdgeInsets, NO);
}

#pragma mark - UITabBarController

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
#if ! TARGET_OS_MACCATALYST
	if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 13)
	{
		CGSize bottomBarSizeThatFits = [self.tabBar sizeThatFits:CGSizeZero];
		bottomBarFrame.size.height = MAX(bottomBarFrame.size.height, bottomBarSizeThatFits.height);
	}
#endif
	
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
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_tvc));
		
#ifndef LNPopupControllerEnforceStrictClean
		NSString* selName;
		
		//_hideBarWithTransition:isExplicit:
		selName = _LNPopupDecodeBase64String(hBWTiEBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(hBWT:iE:));
		
		//_showBarWithTransition:isExplicit:
		selName = _LNPopupDecodeBase64String(sBWTiEBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(sBWT:iE:));
		
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
		if(self.tabBar.isHidden == NO && self._isTabBarHiddenDuringTransition == NO &&  self._ignoringLayoutDuringTransition == NO)
		{
			self._ln_bottomBarExtension_nocreate.hidden = YES;
			[self._ln_bottomBarExtension_nocreate removeFromSuperview];
		}
		else
		{
			self._ln_bottomBarExtension.hidden = NO;
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

//_hideBarWithTransition:isExplicit:
- (void)hBWT:(NSInteger)t iE:(BOOL)e
{
	self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	
	[self _setTabBarHiddenDuringTransition:YES];
	
	CGRect frame = self.tabBar.frame;
	frame.origin.x = self.view.bounds.size.width;
	self._ln_bottomBarExtension.frame = frame;
	[self hBWT:t iE:e];
	
//	if(t > 0)
//	{
		[self _setIgnoringLayoutDuringTransition:YES];
		
		[self.selectedViewController.transitionCoordinator animateAlongsideTransition: ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			CGFloat bottomSafeArea = self.view.superview.safeAreaInsets.bottom;
			self._ln_bottomBarExtension.frame = CGRectMake(0, self.view.bounds.size.height - bottomSafeArea, self.view.bounds.size.width, bottomSafeArea);
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
			[self __repositionPopupBarToClosed_hack];
		} completion: ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[self _setIgnoringLayoutDuringTransition:NO];
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
			
			self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		}];
//	}
}

//_showBarWithTransition:isExplicit:
- (void)sBWT:(NSInteger)t iE:(BOOL)e
{
	self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
	self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	
	[self _setPrepareTabBarIgnored:t > 0];
	
	[self sBWT:t iE:e];
	
	__block CGRect frame = self.tabBar.frame;
	
	if(t > 0)
	{
		[self _setIgnoringLayoutDuringTransition:YES];
		
		[self.selectedViewController.transitionCoordinator animateAlongsideTransition:^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			
			if(@available(iOS 13.0, *))
			{
				[UIView performWithoutAnimation:^{
					self.tabBar.frame = frame;
				}];
			}
			
			frame.origin.x += self.view.bounds.size.width;
			self._ln_bottomBarExtension.frame = frame;
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
			
			[self _setTabBarHiddenDuringTransition:NO];
			[self _layoutPopupBarOrderForTransition];
			[self __repositionPopupBarToClosed_hack];
		} completion: ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[self _setPrepareTabBarIgnored:NO];
			
			if(context.isCancelled)
			{
				[self _setTabBarHiddenDuringTransition:YES];
			}
			
			self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
			[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
			
			[self _layoutPopupBarOrderForUse];
			
			[self _setIgnoringLayoutDuringTransition:NO];
		}];
	}
}

//_prepareTabBar
- (void)_ln_pTB
{
	CGRect oldBarFrame = self.tabBar.frame;
	
	[self _ln_pTB];
	
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
	
	toolbarBarFrame.origin = CGPointMake(toolbarBarFrame.origin.x, self.view.bounds.size.height - (self.isToolbarHidden ? 0.0 : toolbarBarFrame.size.height) - (self.view.safeAreaInsets.bottom - self.view.window.safeAreaInsets.bottom));
	
	return toolbarBarFrame;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	if(self.presentingViewController != nil && [NSStringFromClass(self.presentationController.class) containsString:@"Preview"])
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
						@selector(setNavigationBarHidden:animated:),
						@selector(_ln_setNavigationBarHidden:animated:));
		
		LNSwizzleMethod(self,
						@selector(viewDidLayoutSubviews),
						@selector(_ln_popup_viewDidLayoutSubviews_nvc));
		
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
		if(self.isToolbarHidden == NO && self._ignoringLayoutDuringTransition == NO)
		{
			self._ln_bottomBarExtension_nocreate.hidden = YES;
			[self._ln_bottomBarExtension_nocreate removeFromSuperview];
		}
		else
		{
			self._ln_bottomBarExtension.hidden = NO;
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
- (void)_sTH:(BOOL)hidden e:(UIRectEdge)edge d:(CGFloat)duration;
{
	self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = NO;
	
	//Move popup bar and content according to current state of the toolbar.
	[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
	
	__block CGRect frame = self.toolbar.frame;
	frame.size.height += self.view.superview.safeAreaInsets.bottom;
	if(edge != UIRectEdgeBottom)
	{
		frame.origin.x = self.view.bounds.size.width;
	}
	else
	{
		frame.origin.y += frame.size.height;
	}
	
	//Trigger the toolbar hide or show transition.
	[self _sTH:hidden e:edge d:duration];
	
	if(hidden == YES)
	{
		self._ln_bottomBarExtension.frame = frame;
	}
	
	self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = hidden == NO ? 0.0 : 1.0;
	
	void (^animations)(void) = ^ {
		//During the transition, animate the popup bar and content together with the toolbar transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		[self _layoutPopupBarOrderForTransition];
		
		CGRect frame;
		if(hidden)
		{
			CGFloat safeArea = self.view.superview.safeAreaInsets.bottom;
			self._ln_bottomBarExtension_nocreate.frame = CGRectMake(0, self.view.bounds.size.height - safeArea, self.view.bounds.size.width, safeArea);
			
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 0.0;
		}
		else
		{
			frame = self.toolbar.frame;
			frame.size.height += self.view.superview.safeAreaInsets.bottom;
			if(edge != UIRectEdgeBottom)
			{
				frame.origin.x = self.view.bounds.size.width;
			}
			self._ln_bottomBarExtension_nocreate.frame = frame;
			
			self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		}
	};
	
	void (^completion)(BOOL finished) = ^ (BOOL finished) {
		//Position the popup bar and content to the superview of the toolbar for the transition.
		[self._ln_popupController_nocreate _setContentToState:self._ln_popupController_nocreate.popupControllerInternalState];
		[self _layoutPopupBarOrderForUse];
	
		self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
		self._ln_popupController_nocreate.popupBar.bottomShadowView.alpha = 1.0;
		
		[self _setIgnoringLayoutDuringTransition:NO];
	};
	
	[self _setIgnoringLayoutDuringTransition:YES];
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

//_hideShowNavigationBarDidStop:finished:context:
- (void)hSNBDS:(id)arg1 f:(id)arg2 c:(id)arg3;
{
	[self hSNBDS:arg1 f:arg2 c:arg3];
	
	self._ln_popupController_nocreate.popupBar.bottomShadowView.hidden = YES;
	
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

#pragma mark - View controller appearance control

@implementation _LN_UIViewController_AppearanceControl

- (void)viewWillAppear:(BOOL)animated
{
	if(self._isContainedInPopupControllerOrDeallocated && self._ln_isInPopupAppearanceTransition == NO)
	{
		return;
	}

	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, _cmd, animated);
}

- (void)viewDidAppear:(BOOL)animated
{
	if(self._isContainedInPopupControllerOrDeallocated && self._ln_isInPopupAppearanceTransition == NO)
	{
		return;
	}
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, _cmd, animated);
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(self._isContainedInPopupControllerOrDeallocated && self._ln_isInPopupAppearanceTransition == NO)
	{
		return;
	}
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, _cmd, animated);
}

- (void)viewDidDisappear:(BOOL)animated
{
	if(self._isContainedInPopupControllerOrDeallocated && self._ln_isInPopupAppearanceTransition == NO)
	{
		return;
	}
	
	Class superclass = LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, _cmd, animated);
}

- (Class)class
{
	return LNDynamicSubclassSuper(self, _LN_UIViewController_AppearanceControl.class);
}

@end
