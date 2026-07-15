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
#import "UIScreen+LNPopupSupportPrivate.h"
#import "LNPopupBar+Private.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "LNPopupContentView+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionAnimator : NSObject

- (instancetype)initWithTransitionView:(nullable _LNPopupTransitionView*)transitionView userView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView effectiveInteractionStyle:(LNPopupInteractionStyle)interactionStyle;

@property (nonatomic, strong, readonly) UIView* view;
@property (nonatomic, strong, readonly) LNPopupBar* popupBar;
@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;

@property (nonatomic, strong, readonly, nullable) _LNPopupTransitionView* transitionView;
@property (nonatomic, strong, readonly, nullable) UIView<LNPopupTransitionView>* crossfadeView;
@property (nonatomic, readonly) CGRect sourceFrame;
@property (nonatomic, readonly) CGRect targetFrame;
@property (nonatomic, readonly) CGAffineTransform transform;

@property (nonatomic, readonly) BOOL wantsContentTransition;
@property (nonatomic, strong, readonly) UIView* contentTransitionWrapperView API_AVAILABLE(ios(26.0));
@property (nonatomic, strong, readonly) _LNPopupTransitionView* contentViewTransitionView API_AVAILABLE(ios(26.0));
@property (nonatomic, strong, readonly) UIVisualEffectView* contentTransitionEffectView API_AVAILABLE(ios(26.0));
@property (nonatomic, strong, readonly) UIVisualEffect* popupBarEffect;
@property (nonatomic, strong, readonly) UIVisualEffect* sourceContentTransitionEffect API_AVAILABLE(ios(26.0));
@property (nonatomic, strong, readonly) UIVisualEffect* targetContentTransitionEffect API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) CGRect sourceContentFrame API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) CGRect targetContentFrame API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) LNPopupViewCorners sourceContentCornerRadius API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) LNPopupViewCorners targetContentCornerRadius API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) CGFloat sourceContentAlpha API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) CGFloat targetContentAlpha API_AVAILABLE(ios(26.0));
@property (nonatomic, strong, readonly) _LNPopupTransitionView* popupBarTransitionView API_AVAILABLE(ios(26.0));

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
- (void)performAdditional025Delayed060Animations NS_REQUIRES_SUPER;
- (void)performAdditionalCompletion NS_REQUIRES_SUPER;

@property (nonatomic, readonly) LNPopupPresentationState targetState;

@end

NS_ASSUME_NONNULL_END
