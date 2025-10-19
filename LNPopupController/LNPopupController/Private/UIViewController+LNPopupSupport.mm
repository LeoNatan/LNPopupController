//
//  UIViewController+LNPopupSupport.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupItem+Private.h"
#import "_LNWeakRef.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "LNMath.h"
#import "LNPopupBar+Private.h"
#import <objc/runtime.h>

#define DEBUG_POPUP_BAR_OFFSET 0

static const void* _LNPopupItemKey = &_LNPopupItemKey;
static const void* _LNPopupControllerKey = &_LNPopupControllerKey;
const void* _LNPopupPresentationContainerViewControllerKey = &_LNPopupPresentationContainerViewControllerKey;
const void* _LNPopupContentViewControllerKey = &_LNPopupContentViewControllerKey;
static const void* _LNPopupInteractionStyleKey = &_LNPopupInteractionStyleKey;
static const void* _LNPopupInteractionSnapPercentKey = &_LNPopupInteractionSnapPercentKey;
static const void* _LNPopupBottomBarSupportKey = &_LNPopupBottomBarSupportKey;
static const void* _LNPopupShouldExtendUnderSafeAreaKey = &_LNPopupShouldExtendUnderSafeAreaKey;

const double LNSnapPercentDefault = 0.32;

extern "C" {
extern LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style);
}

@implementation UIViewController (LNPopupSupportPrivate)

@end

@implementation UIViewController (LNPopupSupport)

- (UIPresentationController*)nonMemoryLeakingPresentationController
{
#if ! LNPopupControllerEnforceStrictClean
	static NSString* sel = LNPopupHiddenString("_existingPresentationControllerImmediate:effective:");;
	static id (*nonLeakingPresentationController)(id, SEL, BOOL, BOOL) = reinterpret_cast<decltype(nonLeakingPresentationController)>(objc_msgSend);

	return nonLeakingPresentationController(self, NSSelectorFromString(sel), NO, NO);
#else
	NSString* selector = [NSString stringWithFormat:@"_%@", NSStringFromSelector(@selector(presentationController))];
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	return [self performSelector:NSSelectorFromString(selector)];
#pragma clang diagnostic pop
#endif
}

- (void)presentPopupBarWithContentViewController:(UIViewController*)controller openPopup:(BOOL)openPopup animated:(BOOL)animated completion:(nullable void(^)(void))completionBlock;
{
	LNDynamicSubclass(controller, _LN_UIViewController_AppearanceControl.class);
	
	if(self.view.window == nil)
	{
		__weak __typeof(self) weakSelf = self;
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			__strong __typeof(weakSelf) strongSelf = weakSelf;
			if(strongSelf == nil)
			{
				return;
			}
			
			[strongSelf presentPopupBarWithContentViewController:controller openPopup:openPopup animated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	if(controller == nil)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Content view controller cannot be nil."];
	}
	
	if(controller == self)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Content view controller cannot be the same as the presenting controller."];
	}
	
	[self._ln_popupController presentPopupBarWithContentViewController:controller openPopup:openPopup animated:animated completion:completionBlock];
}

- (void)presentPopupBarWithContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self presentPopupBarWithContentViewController:controller openPopup:NO animated:animated completion:completionBlock];
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		__weak __typeof(self) weakSelf = self;
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			__strong __typeof(weakSelf) strongSelf = weakSelf;
			if(strongSelf == nil)
			{
				return;
			}
			
			[strongSelf openPopupAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate openPopupAnimated:animated completion:completionBlock];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		__weak __typeof(self) weakSelf = self;
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			__strong __typeof(weakSelf) strongSelf = weakSelf;
			if(strongSelf == nil)
			{
				return;
			}
			
			[strongSelf closePopupAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate closePopupAnimated:animated completion:completionBlock];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		__weak __typeof(self) weakSelf = self;
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			__strong __typeof(weakSelf) strongSelf = weakSelf;
			if(strongSelf == nil)
			{
				return;
			}
			
			[strongSelf dismissPopupBarAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate dismissPopupBarAnimated:animated completion:^{
		//Cleanup
		self.popupContentViewController.popupPresentationContainerViewController = nil;
		self.popupContentViewController = nil;
		
		//The LNPopupController is no longer released here.
		//There should be one popup controller per presenting controller per instance.
		
		if(completionBlock)
		{
			completionBlock();
		}
	}];
}

- (void)setNeedsPopupBarAppearanceUpdate
{
	[self._ln_popupController_nocreate _configurePopupBarFromBottomBar];
}

- (LNPopupPresentationState)popupPresentationState
{
	return self._ln_popupController_nocreate.popupControllerPublicState;
}

- (id<LNPopupPresentationDelegate>)popupPresentationDelegate
{
	return self._ln_popupController.userPopupPresentationDelegate;
}

- (void)setPopupPresentationDelegate:(id<LNPopupPresentationDelegate>)popupPresentationDelegate
{
	self._ln_popupController.userPopupPresentationDelegate = popupPresentationDelegate;
}

- (BOOL)_isContainedInPopupController
{
	if(self.popupPresentationContainerViewController != nil)
	{
		return YES;
	}
	
	return [self.parentViewController _isContainedInPopupController];
}

- (BOOL)_isContainedInOpenPopupController
{
	if(self.popupPresentationContainerViewController != nil)
	{
		return self.popupPresentationContainerViewController._ln_popupController_nocreate.popupControllerPublicState == LNPopupPresentationStateOpen;
	}
	
	return [self.parentViewController _isContainedInOpenPopupController];
}

- (BOOL)_isContainedInPopupControllerOrDeallocated
{
	if(objc_getAssociatedObject(self, _LNPopupPresentationContainerViewControllerKey) != nil)
	{
		return YES;
	}
	
	return [self.parentViewController _isContainedInPopupControllerOrDeallocated];
}

- (UIViewController *)popupPresentationContainerViewController
{
	return [(_LNWeakRef*)objc_getAssociatedObject(self, _LNPopupPresentationContainerViewControllerKey) object];
}

- (void)setPopupPresentationContainerViewController:(UIViewController *)popupPresentationContainerViewController
{
	[self willChangeValueForKey:@"popupPresentationContainerViewController"];
	_LNWeakRef* weakRef = [_LNWeakRef refWithObject:popupPresentationContainerViewController];
	objc_setAssociatedObject(self, _LNPopupPresentationContainerViewControllerKey, weakRef, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"popupPresentationContainerViewController"];
}

- (UIViewController *)popupContentViewController
{
	return objc_getAssociatedObject(self, _LNPopupContentViewControllerKey);
}

- (void)setPopupContentViewController:(UIViewController *)popupContentViewController
{
	[self willChangeValueForKey:@"popupContentViewController"];
	objc_setAssociatedObject(self, _LNPopupContentViewControllerKey, popupContentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"popupContentViewController"];
}

- (LNPopupItem *)popupItem
{
	LNPopupItem* rv = objc_getAssociatedObject(self, _LNPopupItemKey);
	
	if(rv == nil)
	{
		rv = [LNPopupItem new];
		objc_setAssociatedObject(self, _LNPopupItemKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[rv _setContainerController:self];
	}
	
	return rv;
}

- (void)setPopupItem:(LNPopupItem *)popupItem
{
	LNPopupItem* previousItem = objc_getAssociatedObject(self, _LNPopupItemKey);
	
	objc_setAssociatedObject(self, _LNPopupItemKey, popupItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[popupItem _setContainerController:self];
	
	if([self respondsToSelector:@selector(popupItemDidChange:)])
	{
		[self popupItemDidChange:previousItem];
	}
}

- (BOOL)positionPopupCloseButton:(LNPopupCloseButton*)popupCloseButton
{
	return NO;
}

- (nullable UIView*)viewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState
{
	return self._ln_discoveredTransitionView;
}

- (nullable UIView*)_ln_transitionViewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState view:(out id<LNPopupTransitionView> _Nonnull __strong * _Nonnull)outView
{
	return nil;
}

- (void)viewWillMoveToPopupContainerContentView:(LNPopupContentView *)popupContentView
{
	
}

- (void)viewDidMoveToPopupContainerContentView:(LNPopupContentView *)popupContentView
{
	
}

- (LNPopupBar *)popupBar
{
	return self._ln_popupController.popupBar;
}

- (LNPopupContentView *)popupContentView
{
	return self._ln_popupController.popupContentView;
}

- (LNPopupInteractionStyle)popupInteractionStyle
{
	return (LNPopupInteractionStyle)[objc_getAssociatedObject(self, _LNPopupInteractionStyleKey) unsignedIntegerValue];
}

- (LNPopupInteractionStyle)effectivePopupInteractionStyle
{
	return _LNPopupResolveInteractionStyleFromInteractionStyle((LNPopupInteractionStyle)[objc_getAssociatedObject(self, _LNPopupInteractionStyleKey) unsignedIntegerValue]);
}

- (void)setPopupInteractionStyle:(LNPopupInteractionStyle)popupInteractionStyle
{
	objc_setAssociatedObject(self, _LNPopupInteractionStyleKey, @(popupInteractionStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)popupSnapPercent
{
	NSNumber* rv = objc_getAssociatedObject(self, _LNPopupInteractionSnapPercentKey);
	
	if(rv == nil)
	{
		return LNSnapPercentDefault;
	}
	
	return [rv doubleValue];
}

- (void)setPopupSnapPercent:(double)popupDragPercent
{
	objc_setAssociatedObject(self, _LNPopupInteractionSnapPercentKey, @(_ln_clamp(popupDragPercent, 0.1, 0.9)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__kindof UIView *)viewForPopupInteractionGestureRecognizer
{
	return self.view;
}

- (BOOL)allowPopupHapticFeedbackGeneration
{
	return self._ln_popupController.wantsFeedbackGeneration;
}

- (void)setAllowPopupHapticFeedbackGeneration:(BOOL)allowPopupHapticFeedbackGeneration
{
	self._ln_popupController.wantsFeedbackGeneration = allowPopupHapticFeedbackGeneration;
}

static const void* _LNPopupContentControllerDiscoveredTransitionView = &_LNPopupContentControllerDiscoveredTransitionView;

- (void)_ln_setDiscoveredTransitionView:(LNPopupImageView *)ln_discoveredShadowedImageView
{
	id objToSet = nil;
	if(ln_discoveredShadowedImageView != nil)
	{
		objToSet = [_LNWeakRef refWithObject:ln_discoveredShadowedImageView];
	}
	objc_setAssociatedObject(self, _LNPopupContentControllerDiscoveredTransitionView, objToSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LNPopupImageView *)_ln_discoveredTransitionView
{
	_LNWeakRef* rv = objc_getAssociatedObject(self, _LNPopupContentControllerDiscoveredTransitionView);
	if(rv != nil && rv.object == nil)
	{
		[self _ln_setDiscoveredTransitionView:nil];
	}
	return rv.object;
}

@end

@implementation UIViewController (LNCustomContainerPopupSupport)

- (LNPopupController*)_ln_popupController_nocreate
{
	return objc_getAssociatedObject(self, _LNPopupControllerKey);
}

- (LNPopupController *)_ln_popupController
{
	LNPopupController* rv = [self _ln_popupController_nocreate];
	
	if(rv == nil)
	{
		rv = [[LNPopupController alloc] initWithContainerViewController:self];
		objc_setAssociatedObject(self, _LNPopupControllerKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return rv;
}

- (_LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate
{
	return objc_getAssociatedObject(self, _LNPopupBottomBarSupportKey);
}

- (_LNPopupBottomBarSupport *)_ln_bottomBarSupport
{
	_LNPopupBottomBarSupport* rv = [self _ln_bottomBarSupport_nocreate];
	
	if(rv == nil)
	{
		rv = [[_LNPopupBottomBarSupport alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0)];
		
		objc_setAssociatedObject(self, _LNPopupBottomBarSupportKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		[self.view addSubview:rv];
	}
	
	return rv;
}


- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper
{
	return self.bottomDockingViewForPopupBar ?: self.bottomDockingViewForPopup_internal ?: self._ln_bottomBarSupport_nocreate;
}

- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper
{
	return self.bottomDockingViewForPopupBar ?: self.bottomDockingViewForPopup_internal ?: self._ln_bottomBarSupport;
}

- (nullable UIView *)bottomDockingViewForPopup_internal
{
	return nil;
}

- (nullable UIView *)bottomDockingViewForPopupBar
{
	return nil;
}

- (BOOL)isBottomDockingViewForPopupBarHidden
{
	return NO;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	return UIEdgeInsetsZero;
}

- (CGRect)defaultFrameForBottomDockingView
{
	return self.bottomDockingViewForPopupBar.frame;
}

- (CGFloat)bottomDockingViewMarginForPopupBar
{
	return 0;
}

- (CGFloat)_ln_popupOffsetForPopupBar:(LNPopupBar*)popupBar
{
#if DEBUG_POPUP_BAR_OFFSET
	return -80;
#else
	if(self.bottomDockingViewForPopupBar != nil && self.isBottomDockingViewForPopupBarHidden == NO)
	{
		//User docking view, use user offset.
		return -self.bottomDockingViewMarginForPopupBar;
	}
	
	if(!popupBar.resolvedIsFloating)
	{
		return 0.0;
	}
	
	if(popupBar.resolvedIsCustom && popupBar.customBarWantsFullBarWidth)
	{
		return 0.0;
	}
	
	if(LNPopupBar.isCatalystApp)
	{
		return -7.0;
	}
	
	if(self.view.window.safeAreaInsets.bottom == 0)
	{
		return LNPopupEnvironmentHasGlass() ? -10.0 : -4.0;
	}
	
	if(LNPopupEnvironmentHasGlass())
	{
		if(self.presentingViewController != nil && [NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"])
		{
			return -20;
		}
	}
	
	BOOL isPad = self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad;
	BOOL isRegular = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
	
	return isPad || isRegular ? 0.0 : LNPopupEnvironmentHasGlass() ? 12.0 : 0.0;
#endif
}

- (CGRect)defaultFrameForBottomDockingView_internal
{
	CGFloat safeAreaAddition = self.view.safeAreaInsets.bottom - _LNPopupSafeAreaInsets(self).bottom;
	
	if(self.presentingViewController != nil && [NSStringFromClass(self.nonMemoryLeakingPresentationController.class) containsString:@"Preview"])
	{
		safeAreaAddition = 0;
	}
	
	return CGRectMake(0, self.view.bounds.size.height - safeAreaAddition, self.view.bounds.size.width, safeAreaAddition);
}

- (CGRect)_defaultFrameForBottomDockingViewForPopupBar:(LNPopupBar*)popupBar
{
	return self.bottomDockingViewForPopupBar != nil && self.isBottomDockingViewForPopupBarHidden == NO ? [self defaultFrameForBottomDockingView] : [self defaultFrameForBottomDockingView_internal];
}

- (BOOL)shouldExtendPopupBarUnderSafeArea
{
	if(LNPopupEnvironmentHasGlass())
	{
		return NO;
	}
	
	return [(objc_getAssociatedObject(self, _LNPopupShouldExtendUnderSafeAreaKey) ?: @1) boolValue];
}

- (void)setShouldExtendPopupBarUnderSafeArea:(BOOL)shouldExtendPopupBarUnderSafeArea
{
	if(LNPopupEnvironmentHasGlass())
	{
		return;
	}
	
	objc_setAssociatedObject(self, _LNPopupShouldExtendUnderSafeAreaKey, @(shouldExtendPopupBarUnderSafeArea), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	self._ln_bottomBarExtension.alpha = shouldExtendPopupBarUnderSafeArea ? 1.0 : 0.0;
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
}

- (BOOL)shouldFadePopupBarOnDismiss
{
	if(LNPopupEnvironmentHasGlass())
	{
		return NO;
	}
	
	BOOL bottomBarExtensionIsVisible = self._ln_bottomBarExtension_nocreate.isHidden == NO && self._ln_bottomBarExtension_nocreate.alpha > 0 && self._ln_bottomBarExtension_nocreate.frame.size.height > 0;
	BOOL backgroundVisible = self.ln_popupController.popupBar.backgroundView.isHidden == NO && self.ln_popupController.popupBar.backgroundView.alpha > 0;
	BOOL scrollEdgeAppearanceRequiresFade = NO;
	if(@available(iOS 15, *))
	{
		scrollEdgeAppearanceRequiresFade = self.ln_popupController.bottomBar.hidden == NO && [self.ln_popupController.bottomBar _ln_scrollEdgeAppearanceRequiresFadeForPopupBar:self.popupBar];
	}
	
	return backgroundVisible && (bottomBarExtensionIsVisible || scrollEdgeAppearanceRequiresFade);
}

- (BOOL)requiresIndirectSafeAreaManagement
{
	return NO;
}

+ (void)_ln_beginTransitioningLockWithWindow:(UIWindow*)window userInteractionsEnabled:(BOOL)userInteractionEnabled allowedViews:(NSArray*)allowedViews lockRotation:(BOOL)lockRotation
{
//	NSLog(@"_ln_beginTransitioningLockWithWindow: %@ userInteractionsEnabled: %@ allowedViews: %@ lockRotation: %@", window, @(userInteractionEnabled), allowedViews, @(lockRotation));
	
	[window _ln_setLockedForPopupTransition:YES];
	if(userInteractionEnabled)
	{
		[window _ln_setPopupInteractionOnly:allowedViews];
	}
	else
	{
		window.userInteractionEnabled = NO;
	}
	
#if ! LNPopupControllerEnforceStrictClean
	static SEL sel = NSSelectorFromString(LNPopupHiddenString("beginDisablingInterfaceAutorotation"));
	if(lockRotation && [window respondsToSelector:sel])
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[window performSelector:sel];
#pragma clang diagnostic pop
	}
#endif
}

+ (void)_ln_endTransitioningLockWithWindow:(UIWindow*)window unlockingRotation:(BOOL)unlockRotation
{
//	NSLog(@"_ln_endTransitioningLockWithWindow: %@ unlockingRotation %@", window, @(unlockRotation));
	
	[window _ln_setPopupInteractionOnly:nil];
	window.userInteractionEnabled = YES;
	
#if ! LNPopupControllerEnforceStrictClean
	static SEL sel = NSSelectorFromString(LNPopupHiddenString("endDisablingInterfaceAutorotationAnimated:"));
	
	if(unlockRotation && [window respondsToSelector:sel])
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[window performSelector:sel];
#pragma clang diagnostic pop
	}
#endif
	
	[window _ln_setLockedForPopupTransition:NO];
}

@end

@implementation UINavigationController (LNPopupSupport)

- (BOOL)positionPopupCloseButton:(LNPopupCloseButton*)popupCloseButton
{
	return [self.topViewController positionPopupCloseButton:popupCloseButton];
}

- (nullable UIView*)viewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState
{
	return [self.topViewController viewForPopupTransitionFromPresentationState:fromState toPresentationState:toState];
}

- (nullable UIView*)_ln_transitionViewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState view:(out id<LNPopupTransitionView> _Nonnull __strong * _Nonnull)outView
{
	return [self.topViewController _ln_transitionViewForPopupTransitionFromPresentationState:fromState toPresentationState:toState view:outView];
}

@end

@implementation UITabBarController (LNPopupSupport)

- (BOOL)positionPopupCloseButton:(LNPopupCloseButton*)popupCloseButton
{
	return [self.selectedViewController positionPopupCloseButton:popupCloseButton];
}

- (nullable UIView*)viewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState
{
	return [self.selectedViewController viewForPopupTransitionFromPresentationState:fromState toPresentationState:toState];
}

- (nullable UIView*)_ln_transitionViewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState view:(out id<LNPopupTransitionView> _Nonnull __strong * _Nonnull)outView
{
	return [self.selectedViewController _ln_transitionViewForPopupTransitionFromPresentationState:fromState toPresentationState:toState view:outView];
}

@end
