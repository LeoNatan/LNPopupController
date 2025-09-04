//
//  LNPopupBarAppearance+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2021-06-20.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBarAppearance.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupDominantColorTrait : NSObject <UIObjectTraitDefinition> @end

@protocol _LNPopupBarAppearanceDelegate <NSObject>

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance;

@end

@interface LNPopupBarAppearance ()

@property (nonatomic, weak) id<_LNPopupBarAppearanceDelegate> delegate;

- (UIBlurEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
- (UICornerConfiguration*)floatingBackgroundCornerConfigurationForCustomBar:(BOOL)isCustomBar API_AVAILABLE(ios(26.0));
#endif

@end

NS_ASSUME_NONNULL_END
