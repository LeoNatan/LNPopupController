//
//  LNPopupBarAppearance+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 6/9/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBarAppearance.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface _LNPopupDominantColorTrait : NSObject <UIObjectTraitDefinition> @end

API_AVAILABLE(ios(13.0))
@protocol _LNPopupBarAppearanceDelegate <NSObject>

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance;

@end

@interface LNPopupBarAppearance ()

@property (nonatomic, weak) id<_LNPopupBarAppearanceDelegate> delegate;

- (UIBlurEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection;

@end

NS_ASSUME_NONNULL_END
