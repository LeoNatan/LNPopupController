//
//  _LNPopupBarBackgroundView.h
//  LNPopupController
//
//  Created by Leo Natan on 6/26/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarBackgroundView : UIVisualEffectView

@property (nonatomic, strong, readonly) UIView* colorView;
@property (nonatomic, strong, readonly) UIImageView* imageView;

@end

NS_ASSUME_NONNULL_END
