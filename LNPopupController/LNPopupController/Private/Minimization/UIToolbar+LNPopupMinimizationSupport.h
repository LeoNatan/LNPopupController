//
//  UIToolbar+LNPopupMinimizationSupport.h
//  LNPopupController
//
//  Created by Léo Natan on 13/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (LNPopupMinimizationSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar;

@end

NS_ASSUME_NONNULL_END
