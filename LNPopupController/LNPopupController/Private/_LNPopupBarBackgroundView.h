//
//  _LNPopupBarBackgroundView.h
//  LNPopupController
//
//  Created by Léo Natan on 2021-06-20.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarBackgroundView : UIView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect;

@property (nonatomic, strong, readonly) UIVisualEffectView* effectView;
@property (nonatomic, copy, nullable) UIVisualEffect* effect;
@property (nonatomic, strong, readonly) UIView* contentView;

@property(nonatomic, copy, nullable) UIColor* foregroundColor;
@property(nonatomic, strong, nullable) UIImage* foregroundImage;
@property(nonatomic) UIViewContentMode foregroundImageContentMode;
- (void)hideOrShowImageViewIfNecessary;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong, readonly) UIView* transitionShadingView;

@end

NS_ASSUME_NONNULL_END
