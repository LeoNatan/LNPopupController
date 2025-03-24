//
//  _LNPopupTransitionPreferredOpenAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionOpenAnimator.h"
#import <LNPopupController/LNPopupShadowedImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionPreferredOpenAnimator : _LNPopupTransitionOpenAnimator

@property (nonatomic, strong, readonly) LNPopupShadowedImageView* view;

@end

NS_ASSUME_NONNULL_END
