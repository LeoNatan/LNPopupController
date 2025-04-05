//
//  _LNPopupTransitionCloseAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionCloseAnimator : _LNPopupTransitionAnimator

- (instancetype)initWithTransitionView:(nullable _LNPopupTransitionView*)transitionView userView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView currentContentController:(UIViewController*)currentContentController containerController:(UIViewController*)containerController;

@property (nonatomic, strong) UIViewController* currentContentController;
@property (nonatomic, strong) UIViewController* containerController;

@end

NS_ASSUME_NONNULL_END
