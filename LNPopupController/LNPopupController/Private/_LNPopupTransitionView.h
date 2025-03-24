//
//  _LNPopupTransitionView.h
//  LNPopupController
//
//  Created by Léo Natan on 22/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionView : UIView

- (instancetype)initWithFrame:(CGRect)frame sourceView:(UIView*)sourceView;

- (void)setTargetFrameUpdatingTransform:(CGRect)targetFrame;

@property (nonatomic, strong) NSShadow* shadow;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGAffineTransform sourceViewTransform;

@end

NS_ASSUME_NONNULL_END
