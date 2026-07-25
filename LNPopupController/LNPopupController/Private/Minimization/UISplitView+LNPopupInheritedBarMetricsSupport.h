//
//  UISplitView+LNPopupInheritedBarMetricsSupport.h
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNForwardingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class LNPopupBar;

@interface _LNPopupSplitViewDelegateWrapper: LNForwardingDelegate <UISplitViewControllerDelegate> @end

@interface UISplitViewController (LNPopupInheritedBarMetricsSupport)

- (BOOL)_ln_isPrimaryShown;
- (BOOL)_ln_shouldAvoidPrimaryColumn;
- (BOOL)_ln_shouldAvoidPrimaryColumnWithVisible:(BOOL)visible forDisplayMode:(UISplitViewControllerDisplayMode)displayMode;
@property (nonatomic, retain, nullable, getter=_ln_frozenAvoidPrimaryColumnValue, setter=_ln_setFrozenAvoidPrimaryColumnValue:) NSNumber* frozenAvoidPrimaryColumnValue;

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar;

@end

NS_ASSUME_NONNULL_END
