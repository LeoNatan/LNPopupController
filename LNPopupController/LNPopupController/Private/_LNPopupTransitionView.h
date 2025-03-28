//
//  _LNPopupTransitionView.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTransitionView : UIView

+ (instancetype)transitionViewWithSourceView:(UIView*)sourceView;

- (instancetype)initWithSourceView:(UIView*)sourceView;

- (void)setTargetFrameUpdatingTransform:(CGRect)targetFrame;

@property (nonatomic, strong, readonly) UIView* sourceView;

@property (nonatomic, strong) NSShadow* shadow;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL layerAlwaysMasksToBounds;

@property (nonatomic, assign) CGAffineTransform sourceViewTransform;

@end

NS_ASSUME_NONNULL_END
