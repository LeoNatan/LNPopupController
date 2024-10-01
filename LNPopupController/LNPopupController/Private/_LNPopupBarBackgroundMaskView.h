//
//  _LNPopupBarBackgroundMaskView.h
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-27.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarBackgroundMaskView: UIView

@property (nonatomic, readonly) BOOL wantsCutout;
- (void)setWantsCutout:(BOOL)wantsCutout animated:(BOOL)animated;

@property (nonatomic) CGRect floatingFrame;
@property (nonatomic) CGFloat floatingCornerRadius;

@end


NS_ASSUME_NONNULL_END
