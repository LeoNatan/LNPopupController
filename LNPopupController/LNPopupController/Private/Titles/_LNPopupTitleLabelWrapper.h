//
//  _LNPopupTitleLabelWrapper.h
//  LNPopupController
//
//  Created by Léo Natan on 25/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTitleLabelWrapper: UIView

+ (instancetype)wrapperForLabel:(UILabel*)wrapped;

@property (nonatomic, strong) UILabel* wrapped;
@property (nonatomic, strong) NSLayoutConstraint* wrappedWidthConstraint;

@end

NS_ASSUME_NONNULL_END
