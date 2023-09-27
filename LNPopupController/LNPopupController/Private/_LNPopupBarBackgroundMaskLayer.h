//
//  _LNPopupBarBackgroundMaskLayer.h
//  LNPopupController
//
//  Created by Leo Natan on 27/09/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarBackgroundMaskLayer: CALayer

@property (nonatomic) BOOL wantsCutout;
@property (nonatomic) CGRect floatingFrame;
@property (nonatomic) CGFloat floatingCornerRadius;

@end


NS_ASSUME_NONNULL_END
