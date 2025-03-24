//
//  _LNPopupTransitionAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupBar.h>
#import <LNPopupController/LNPopupContentView.h>
#import "_LNPopupTransitionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionAnimator : NSObject

- (instancetype)initWithUserView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView;

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

@end

NS_ASSUME_NONNULL_END
