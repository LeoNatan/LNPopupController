//
//  LNPopupController.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBar+Private.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import <LNPopupController/LNPopupCloseButton.h>
#import "LNPopupContentView+Private.h"
#import "LNPopupBar+Private.h"

CF_EXTERN_C_BEGIN

#define _LNPopupPresentationStateTransitioning ((LNPopupPresentationState)2)

@interface LNPopupController : NSObject <_LNPopupBarDelegate>

- (instancetype)initWithContainerViewController:(__kindof UIViewController*)containerController;

@property (nonatomic, weak) UIView* bottomBar;

@property (nonatomic, strong) LNPopupBar* popupBar;
@property (nonatomic, strong, readonly) LNPopupBar* popupBarStorage;
@property (nonatomic, strong, readonly) LNPopupBar* popupBarNoCreate;
@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;

@property (nonatomic) LNPopupPresentationState popupControllerPublicState;
@property (nonatomic) LNPopupPresentationState popupControllerInternalState;
@property (nonatomic) LNPopupPresentationState popupControllerTargetState;

@property (nonatomic, weak) id<LNPopupPresentationDelegate> userPopupPresentationDelegate;

@property (nonatomic, strong) __kindof UIViewController* currentContentController;
@property (nonatomic, weak, readonly) __kindof UIViewController* containerController;

@property (nonatomic) CGPoint lastPopupBarLocation;
@property (nonatomic) CFTimeInterval lastSeenMovement;

@property (nonatomic, weak) UIViewController* effectiveStatusBarUpdateController;

@property (assign) BOOL wantsFeedbackGeneration;

- (CGFloat)_percentFromPopupBar;

- (void)_setContentToState:(LNPopupPresentationState)state;
- (void)_setContentToState:(LNPopupPresentationState)state animated:(BOOL)animated;

- (void)presentPopupBarWithContentViewController:(UIViewController*)contentViewController openPopup:(BOOL)open animated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;

- (void)_configurePopupBarFromBottomBar;
- (void)_configurePopupBarFromBottomBarModifyingGroupingIdentifier:(BOOL)modifyingGroupingIdentifier;
- (void)_updateBarExtensionStyleFromPopupBar;

+ (CGFloat)_statusBarHeightForView:(UIView*)view;

- (void)_fixupGestureRecognizer:(UIGestureRecognizer*)obj;

@end

CF_EXTERN_C_END
