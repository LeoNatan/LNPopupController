//
//  SplitViewController.h
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/21/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LNSplitViewControllerColumn) {
	LNSplitViewControllerColumnPrimary,
	LNSplitViewControllerColumnSupplementary, // Valid for UISplitViewControllerStyleTripleColumn only
	LNSplitViewControllerColumnSecondary,
	LNSplitViewControllerColumnCompact, // If a vc is set for this column, it will be used when the UISVC is collapsed, instead of stacking the vc’s for the Primary, Supplementary, and Secondary columns
};

@class LNSplitViewController;

@interface UIViewController (LNSplitViewController)

@property (nullable, nonatomic, readonly, strong) LNSplitViewController* ln_splitViewController;

@end

@interface LNSplitViewController : UISplitViewController

- (nullable __kindof UIViewController *)viewControllerForColumn:(LNSplitViewControllerColumn)column;

@end

@interface SplitViewControllerPrimaryPopup : LNSplitViewController @end
@interface SplitViewControllerSecondaryPopup : LNSplitViewController @end
@interface SplitViewControllerGlobalPopup : LNSplitViewController @end

NS_ASSUME_NONNULL_END
