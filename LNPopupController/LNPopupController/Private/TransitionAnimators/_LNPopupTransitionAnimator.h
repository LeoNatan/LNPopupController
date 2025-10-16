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
@property (nonatomic, strong, readonly, nullable) UIView<LNPopupTransitionView>* crossfadeView;
@property (nonatomic, readonly) CGRect sourceFrame;
@property (nonatomic, readonly) CGRect targetFrame;
@property (nonatomic, readonly) CGAffineTransform transform;

@property (nonatomic, readonly) CGFloat scaledBarImageViewCornerRadius;
@property (nonatomic, strong, readonly) NSShadow* scaledBarImageViewShadow;

- (void)animateWithAnimator:(UIViewPropertyAnimator*)animator otherAnimations:(void(^)(void))otherAnimations NS_REQUIRES_SUPER;
- (void)beforeAnyAnimation NS_REQUIRES_SUPER;
- (void)performBeforeAdditionalAnimations NS_REQUIRES_SUPER;
- (void)performAdditionalAnimations NS_REQUIRES_SUPER;
- (void)performAdditionalDelayed015Animations NS_REQUIRES_SUPER;
- (void)performAdditionalDelayed05Animations NS_REQUIRES_SUPER;
- (void)performAdditional01Animations NS_REQUIRES_SUPER;
- (void)performAdditional075Animations NS_REQUIRES_SUPER;
- (void)performAdditional04Delayed015Animations NS_REQUIRES_SUPER;
- (void)performAdditional075Delayed015Animations NS_REQUIRES_SUPER;
- (void)performAdditionalCompletion NS_REQUIRES_SUPER;

@property (nonatomic, readonly) LNPopupPresentationState targetState;

@end

NS_ASSUME_NONNULL_END
