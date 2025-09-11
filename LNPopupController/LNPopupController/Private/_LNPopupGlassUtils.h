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

@interface UIVisualEffect (LNPopupSupport)

@property (nonatomic, readonly) BOOL ln_isGlass;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5

API_AVAILABLE(ios(26.0))
@interface LNPopupGlassEffect: UIGlassEffect

@property (nonatomic, assign) UIGlassEffectStyle style;

@end

#endif

CF_EXTERN_C_END
NS_ASSUME_NONNULL_END
