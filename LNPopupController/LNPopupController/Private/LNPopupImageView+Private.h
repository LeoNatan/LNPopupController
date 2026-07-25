//
//  LNPopupImageView+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupImageView.h>
#import "LNPopupBar+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNPopupBarImageView: LNPopupImageView

@property (nonatomic) CGFloat allowedAlpha;

- (instancetype)initWithContainingPopupBar:(LNPopupBar*)popupBar;

@end

NS_ASSUME_NONNULL_END
