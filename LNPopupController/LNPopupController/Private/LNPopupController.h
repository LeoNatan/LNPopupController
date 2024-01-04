//
//  LNPopupController.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBar+Private.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import <LNPopupController/LNPopupCloseButton.h>
#import "LNPopupContentView+Private.h"

extern const NSUInteger _LNPopupPresentationStateTransitioning;

@interface LNPopupController : NSObject

- (instancetype)initWithContainerViewController:(__kindof UIViewController*)containerController;

@property (nonatomic, weak) UIView* bottomBar;

@property (nonatomic, strong) LNPopupBar* popupBar;
@property (nonatomic, strong, readonly) LNPopupBar* popupBarStorage;
@property (nonatomic, strong) LNPopupContentView* popupContentView;
@property (nonatomic, strong) UIScrollView* popupContentContainerView;

@property (nonatomic) LNPopupPresentationState popupControllerPublicState;
@property (nonatomic) LNPopupPresentationState popupControllerInternalState;
@property (nonatomic) LNPopupPresentationState popupControllerTargetState;

@property (nonatomic, weak) id<LNPopupPresentationDelegate> userPopupPresentationDelegate;

@property (nonatomic, strong) __kindof UIViewController* currentContentController;
@property (nonatomic, weak) __kindof UIViewController* containerController;

@property (nonatomic) CGPoint lastPopupBarLocation;
@property (nonatomic) CFTimeInterval lastSeenMovement;

@property (nonatomic, weak) UIViewController* effectiveStatusBarUpdateController;

@property (assign) BOOL wantsFeedbackGeneration;

- (CGFloat)_percentFromPopupBar;

- (void)_setContentToState:(LNPopupPresentationState)state;
- (void)_setContentToState:(LNPopupPresentationState)state animated:(BOOL)animated;

- (void)_movePopupBarAndContentToBottomBarSuperview;

- (void)presentPopupBarWithContentViewController:(UIViewController*)contentViewController openPopup:(BOOL)open animated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock;

- (void)_configurePopupBarFromBottomBar;
- (void)_configurePopupBarFromBottomBarModifyingGroupingIdentifier:(BOOL)modifyingGroupingIdentifier;
- (void)_updateBarExtensionStyleFromPopupBar;

+ (CGFloat)_statusBarHeightForView:(UIView*)view;

@end
