//
//  LNPopupShadowedImageView+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupShadowedImageView.h"
#import "LNPopupBar+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNPopupShadowedImageView ()

- (instancetype)initWithContainingPopupBar:(LNPopupBar*)popupBar;

@property (nonatomic, strong, nullable) NSNumber* transitionCornerRadius;
@property (nonatomic, copy, nullable) NSShadow* transitionShadow;

@end

NS_ASSUME_NONNULL_END
