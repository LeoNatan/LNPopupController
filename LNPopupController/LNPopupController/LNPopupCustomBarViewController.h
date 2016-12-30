//
//  LNPopupBarContentViewController.h
//  LNPopupController
//
//  Created by Leo Natan on 15/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;

@interface LNPopupCustomBarViewController : UIViewController

/**
 * The containing popup bar. (read-only)
 */
@property (nonatomic, weak, readonly) LNPopupBar* containingPopupBar;

@property (nonatomic, assign) BOOL wantsDefaultTapGestureRecognizer;
@property (nonatomic, assign) BOOL wantsDefaultPanGestureRecognizer;

/**
 * Called by the framework to notify the popup content view controller that one or more keys of the the popup item have been updated, or the entire popup item has changed.
 */
- (void)popupItemDidUpdate NS_REQUIRES_SUPER;

@end
