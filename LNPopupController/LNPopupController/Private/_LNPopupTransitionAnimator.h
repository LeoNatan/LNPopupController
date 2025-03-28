//
//  _LNPopupTransitionAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupBar.h>
#import <LNPopupController/LNPopupContentView.h>
#import <LNPopupController/UIViewController+LNPopupSupport.h>
#import "_LNPopupTransitionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionAnimator : NSObject

- (instancetype)initWithTransitionView:(nullable _LNPopupTransitionView*)transitionView userView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView;

@property (nonatomic, strong, readonly) UIView* view;
@property (nonatomic, strong, readonly) LNPopupBar* popupBar;
@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;

@property (nonatomic, strong, readonly, nullable) _LNPopupTransitionView* transitionView;
@property (nonatomic, readonly) CGRect sourceFrame;
@property (nonatomic, readonly) CGRect targetFrame;
@property (nonatomic, readonly) CGAffineTransform transform;
@property (nonatomic, readonly) CGFloat scaledBarImageViewCornerRadius;
@property (nonatomic, strong, readonly) NSShadow* scaledBarImageViewShadow;

- (void)animateWithAnimator:(UIViewPropertyAnimator*)animator otherAnimations:(void(^)(void))otherAnimations;
- (void)beforeAnyAnimation;
- (void)performBeforeAdditionalAnimations;
- (void)performAdditionalAnimations;
- (void)performAdditionalCompletion;

@property (nonatomic, readonly) LNPopupPresentationState targetState;

@end

NS_ASSUME_NONNULL_END
