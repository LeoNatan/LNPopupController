//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
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

@interface UIViewController (LNPopupSupportPrivate)

- (void)_ln_updateSafeAreaInsets;

- (BOOL)_ln_shouldDisplayBottomShadowViewDuringTransition;

- (BOOL)_ln_reallyShouldExtendPopupBarUnderSafeArea;

- (void)_ln_setPopupPresentationState:(LNPopupPresentationState)newState;

- (nullable UIViewController*)_ln_common_childViewControllerForStatusBarStyle;
- (nullable UIPresentationController*)nonMemoryLeakingPresentationController;

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;
@property (nullable, nonatomic, weak, readwrite) UIViewController* popupPresentationContainerViewController;
@property (nullable, nonatomic, strong, readwrite) UIViewController* popupContentViewController;

@property (nonnull, nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;
- (nullable _LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate;

- (BOOL)_isContainedInPopupController;
- (BOOL)_isContainedInOpenPopupController;
- (BOOL)_isContainedInPopupControllerOrDeallocated;

- (BOOL)_ignoringLayoutDuringTransition;

- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper;
- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper;

- (CGFloat)_ln_popupOffsetForPopupBarStyle:(LNPopupBarStyle)barStyle;

- (CGRect)defaultFrameForBottomDockingView_internal;
- (CGRect)_defaultFrameForBottomDockingViewForPopupBar:(LNPopupBar*)LNPopupBar;

- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension_nocreate;
- (_LNPopupBarBackgroundView*)_ln_bottomBarExtension;

- (void)_userFacing_viewWillAppear:(BOOL)animated;
- (void)_userFacing_viewIsAppearing:(BOOL)animated;
- (void)_userFacing_viewDidAppear:(BOOL)animated;
- (void)_userFacing_viewWillDisappear:(BOOL)animated;
- (void)_userFacing_viewDidDisappear:(BOOL)animated;

- (BOOL)_ln_isObjectFromSwiftUI;

@end

@interface _LN_UIViewController_AppearanceControl : UIViewController @end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END
