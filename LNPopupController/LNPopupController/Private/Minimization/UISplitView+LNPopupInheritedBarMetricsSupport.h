//
//  UISplitView+LNPopupInheritedBarMetricsSupport.h
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LNPopupBar;

@interface UISplitViewController (LNPopupInheritedBarMetricsSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar;

@end

NS_ASSUME_NONNULL_END
