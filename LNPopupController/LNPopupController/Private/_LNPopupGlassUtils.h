//
//  _LNPopupGlassUtils.h
//  LNPopupController
//
//  Created by Léo Natan on 13/8/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
CF_EXTERN_C_BEGIN

extern BOOL LNPopupEnvironmentHasGlass(void);

API_AVAILABLE(ios(26.0))
@interface LNPopupGlassEffect: UIGlassEffect

@property (nonatomic, assign) UIGlassEffectStyle style;

@end

CF_EXTERN_C_END
NS_ASSUME_NONNULL_END
