//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/UIViewController+LNPopupSupport.h>
#import "_LNPopupBarBackgroundView.h"

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

UIEdgeInsets _LNPopupSafeAreas(id self);
void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets);

@interface _LNPopupBottomBarSupport : UIView @end

@interface UIViewController (LNPopupSupportPrivate)

- (BOOL)_ln_shouldDisplayBottomShadowViewDuringTransition;

- (BOOL)_ln_reallyShouldExtendPopupBarUnderSafeArea;

- (void)_ln_setPopupPresentationState:(LNPopupPresentationState)newState;

- (nullable UIViewController*)_ln_common_childViewControllerForStatusBarStyle;
- (nullable UIPresentationController*)nonMemoryLeakingPresentationController;

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;
@property (nullable, nonatomic, weak, readwrite) UIViewController* popupPresentationContainerViewController;
@property (nullable, nonatomic, strong, readonly) UIViewController* popupContentViewController;

@property (nonnull, nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;
- (nullable _LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate;

- (BOOL)_isContainedInPopupController;
- (BOOL)_isContainedInPopupControllerOrDeallocated;

- (BOOL)_ignoringLayoutDuringTransition;

- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper;
- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper;

- (CGRect)defaultFrameForBottomDockingView_internal;
- (CGRect)defaultFrameForBottomDockingView_internalOrDeveloper;

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension_nocreate;
- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension;

- (void)_userFacing_viewWillAppear:(BOOL)animated;
- (void)_userFacing_viewDidAppear:(BOOL)animated;
- (void)_userFacing_viewWillDisappear:(BOOL)animated;
- (void)_userFacing_viewDidDisappear:(BOOL)animated;

@end

@interface _LN_UIViewController_AppearanceControl : UIViewController @end

NS_ASSUME_NONNULL_END
