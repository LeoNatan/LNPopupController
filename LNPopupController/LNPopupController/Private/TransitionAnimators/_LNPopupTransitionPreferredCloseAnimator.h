//
//  _LNPopupTransitionPreferredCloseAnimator.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionCloseAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionPreferredCloseAnimator : _LNPopupTransitionCloseAnimator

@property (nonatomic, strong, readonly) LNPopupShadowedImageView* view;

@end

NS_ASSUME_NONNULL_END
