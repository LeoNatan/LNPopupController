//
//  _LNPopupTransitionCloseAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionCloseAnimator : _LNPopupTransitionAnimator

- (instancetype)initWithUserView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView currentContentController:(UIViewController*)currentContentController containerController:(UIViewController*)containerController;

@property (nonatomic, strong) UIViewController* currentContentController;
@property (nonatomic, strong) UIViewController* containerController;

@end

NS_ASSUME_NONNULL_END
