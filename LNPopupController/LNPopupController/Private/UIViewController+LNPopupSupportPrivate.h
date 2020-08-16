//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import <LNPopupController/UIViewController+LNPopupSupport.h>

@class LNPopupController;

NS_ASSUME_NONNULL_BEGIN

void _LNPopupSupportSetPopupInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets popupEdgeInsets);

@interface _LNPopupBottomBarSupport : UIView @end

@interface _LNPopupBarExtensionView : UIView

@property (nonatomic, strong, readonly) UIVisualEffectView *effectView;

@end

@interface UIViewController (LNPopupSupportPrivate)

- (void)_ln_setPopupPresentationState:(LNPopupPresentationState)newState;

- (nullable UIViewController*)_ln_common_childViewControllerForStatusBarStyle;

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;
@property (nullable, nonatomic, assign, readwrite) UIViewController* popupPresentationContainerViewController;
@property (nullable, nonatomic, strong, readonly) UIViewController* popupContentViewController;

@property (nonnull, nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;
- (nullable _LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate;

- (BOOL)_isContainedInPopupController;
- (BOOL)_isContainedInPopupControllerOrDeallocated;
- (BOOL)_ln_isInPopupAppearanceTransition;
- (void)_ln_beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated;
- (void)_ln_endAppearanceTransition;

- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper;
- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper;

- (CGRect)defaultFrameForBottomDockingView_internal;
- (CGRect)defaultFrameForBottomDockingView_internalOrDeveloper;

- (_LNPopupBarExtensionView*)_ln_bottomBarExtension_nocreate;
- (_LNPopupBarExtensionView*)_ln_bottomBarExtension;

@end

@interface _LN_UIViewController_AppearanceControl : UIViewController @end

NS_ASSUME_NONNULL_END
