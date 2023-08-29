//
//  _LNPopupBarBackgroundView.h
//  LNPopupController
//
//  Created by Leo Natan on 6/26/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarBackgroundView : UIView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect;

@property (nonatomic, strong, readonly) UIVisualEffectView* effectView;
@property (nonatomic, copy, nullable) UIVisualEffect* effect;
@property (nonatomic, strong, readonly) UIView* contentView;

@property (nonatomic, strong, readonly) UIView* colorView;
@property (nonatomic, strong, readonly) UIImageView* imageView;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL castsShadow;

@end

NS_ASSUME_NONNULL_END
