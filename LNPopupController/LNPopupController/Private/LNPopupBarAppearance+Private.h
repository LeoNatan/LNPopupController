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

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance API_AVAILABLE(ios(13.0));

@end

@interface LNPopupBarAppearance ()

@property (nonatomic, weak) id<_LNPopupBarAppearanceDelegate> delegate;

- (UIBlurEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection;

@end

NS_ASSUME_NONNULL_END
