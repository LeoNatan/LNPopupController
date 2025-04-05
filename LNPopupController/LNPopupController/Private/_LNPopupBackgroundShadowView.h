//
//  _LNPopupBackgroundShadowView.h
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBackgroundShadowView : UIView

@property (nonatomic, strong) NSShadow* shadow;
@property (nonatomic, assign) CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
