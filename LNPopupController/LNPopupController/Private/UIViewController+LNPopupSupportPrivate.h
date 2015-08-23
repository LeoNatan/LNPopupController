//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <LNPopupController/UIViewController+LNPopupSupport.h>

@class LNPopupController;

NS_ASSUME_NONNULL_BEGIN

void _LNPopupSupportFixInsetsForViewController(UIViewController* viewController, BOOL layout);

@interface _LNPopupBottomBarSupport : UIView @end

@interface UIViewController (LNPopupSupportPrivate)

- (nullable UIViewController*)_ln_common_childViewControllerForStatusBarStyle;

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;
@property (nullable, nonatomic, assign, readwrite) UIViewController* popupPresentationContainerViewController;
@property (nullable, nonatomic, strong, readonly) UIViewController* popupContentViewController;

@property (nonnull, nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;

@end

NS_ASSUME_NONNULL_END