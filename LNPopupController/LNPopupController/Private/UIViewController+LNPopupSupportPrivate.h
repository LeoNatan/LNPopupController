//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/UIViewController+LNPopupSupport.h>
#import "_LNPopupBarBackgroundView.h"

CF_EXTERN_C_BEGIN

@class LNPopupController;

NS_ASSUME_NONNULL_BEGIN

static inline __attribute__((always_inline)) UIEdgeInsets __LNEdgeInsetsSum(UIEdgeInsets userEdgeInsets, UIEdgeInsets popupUserEdgeInsets)
{
	UIEdgeInsets final = userEdgeInsets;
	final.bottom += popupUserEdgeInsets.bottom;
	final.top += popupUserEdgeInsets.top;
	final.left += popupUserEdgeInsets.left;
	final.right += popupUserEdgeInsets.right;
	
	return final;
}

extern BOOL __ln_popup_suppressViewControllerLifecycle;

UIEdgeInsets _LNPopupSafeAreaInsets(id self);
void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets);

@interface _LNPopupBottomBarSupport : UIView @end

@interface UIViewController (LNPopupSupport)

@property (nullable, nonatomic, weak, readwrite) UIViewController* popupPresentationContainerViewController;
@property (nullable, nonatomic, strong, readwrite) UIViewController* popupContentViewController;

- (BOOL)_isContainedInPopupController;
- (BOOL)_isContainedInOpenPopupController;
- (BOOL)_isContainedInPopupControllerOrDeallocated;

- (nullable UIPresentationController*)nonMemoryLeakingPresentationController;

@property (nullable, nonatomic, weak, setter=_ln_setDiscoveredTransitionView:, getter=_ln_discoveredTransitionView) LNPopupImageView* ln_discoveredTransitionView;

- (nullable UIView*)_ln_transitionViewForPopupTransitionFromPresentationState:(LNPopupPresentationState)fromState toPresentationState:(LNPopupPresentationState)toState view:(out id<LNPopupTransitionView> _Nonnull __strong * _Nonnull)outView;

@end

@interface UIViewController (LNCustomContainerPopupSupport)

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;

@property (nonnull, nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;
- (nullable _LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate;

- (CGRect)defaultFrameForBottomDockingView_internal;
- (CGRect)_defaultFrameForBottomDockingViewForPopupBar:(LNPopupBar*)LNPopupBar;

- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper;
- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper;

- (CGFloat)_ln_popupOffsetForPopupBarStyle:(LNPopupBarStyle)barStyle;

+ (void)_ln_beginTransitioningLockWithWindow:(UIWindow*)window userInteractionsEnabled:(BOOL)userInteractionEnabled allowedViews:(NSArray* __nullable)allowedViews lockRotation:(BOOL)lockRotation;
+ (void)_ln_endTransitioningLockWithWindow:(UIWindow*)window unlockingRotation:(BOOL)unlockRotation;

@end

@interface UIViewController (LNPopupLayout)

- (void)_ln_updateSafeAreaInsets;

- (BOOL)_ln_shouldDisplayBottomShadowViewDuringTransition;

- (BOOL)_ln_reallyShouldExtendPopupBarUnderSafeArea;

- (void)_ln_setPopupPresentationState:(LNPopupPresentationState)newState;

- (BOOL)_ignoringLayoutDuringTransition;

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension_nocreate;
- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension;

- (void)_userFacing_viewWillAppear:(BOOL)animated;
- (void)_userFacing_viewIsAppearing:(BOOL)animated;
- (void)_userFacing_viewDidAppear:(BOOL)animated;
- (void)_userFacing_viewWillDisappear:(BOOL)animated;
- (void)_userFacing_viewDidDisappear:(BOOL)animated;

- (BOOL)_ln_isObjectFromSwiftUI;

- (BOOL)_ln_shouldPopupContentAnyFadeForTransition;
- (BOOL)_ln_shouldPopupContentViewFadeForTransition;

- (nullable UIViewController*)_ln_childViewControllerForStatusBarLogic __attribute__((objc_direct));

@end

@interface _LN_UIViewController_AppearanceControl : UIViewController @end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END
