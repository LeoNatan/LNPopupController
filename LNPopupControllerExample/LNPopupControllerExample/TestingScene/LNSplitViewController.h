//
//  SplitViewController.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-10-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class LNSplitViewController;

@interface LNSplitViewController : UISplitViewController @end

@interface LNSplitViewControllerPrimaryPopup : LNSplitViewController @end
@interface LNSplitViewControllerSecondaryPopup : LNSplitViewController @end
@interface LNSplitViewControllerGlobalPopup : LNSplitViewController @end

NS_ASSUME_NONNULL_END
