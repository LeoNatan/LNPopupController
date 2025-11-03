//
//  _LNPopupGlassUtils.h
//  LNPopupController
//
//  Created by Léo Natan on 13/8/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
CF_EXTERN_C_BEGIN

extern BOOL LNPopupEnvironmentHasGlass(void);

@interface UIVisualEffect (LNPopupSupport)

@property (nonatomic, readonly) BOOL ln_isGlass;

@end

API_AVAILABLE(ios(26.0))
@interface _LNPopupGlassEffect: UIGlassEffect

+ (instancetype)effectWithStyle:(UIGlassEffectStyle)style NS_SWIFT_NAME(init(style:));
@property (nonatomic, assign) UIGlassEffectStyle style;

@end

API_AVAILABLE(ios(26.0))
@interface _LNPopupBorrowedGlassEffect: UIGlassEffect

+ (instancetype)shineEffect;

@end

API_AVAILABLE(ios(26.0))
@interface _LNPopupGlassWrapperEffect: UIGlassEffect

+ (instancetype)wrapperWithEffect:(UIVisualEffect*)effect;

@property (nonatomic, assign) BOOL disableForeground;
@property (nonatomic, assign) BOOL disableInteractive;
@property (nonatomic, assign) BOOL disableShadow;

@end

CF_EXTERN_C_END
NS_ASSUME_NONNULL_END
