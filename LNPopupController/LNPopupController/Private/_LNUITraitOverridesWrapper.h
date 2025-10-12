//
//  _LNUITraitOverridesWrapper.h
//  LNPopupController
//
//  Created by Léo Natan on 12/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupContentView;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(17.0))
@interface _LNUITraitOverridesWrapper : NSObject <UITraitOverrides>

- (instancetype)initWithTraitOverrides:(id<UITraitOverrides>)traitOverrides contentView:(LNPopupContentView*)contentView;

@end

NS_ASSUME_NONNULL_END
