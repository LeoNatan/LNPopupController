//
//  _LNPopupBarShadowedImageView.h
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-25.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBar+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarShadowedImageView : UIImageView

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithContainingPopupBar:(LNPopupBar*)popupBar NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithImage:(nullable UIImage *)image NS_UNAVAILABLE;
- (instancetype)initWithImage:(nullable UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage NS_UNAVAILABLE;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, copy) NSShadow* shadow;

@end

NS_ASSUME_NONNULL_END
