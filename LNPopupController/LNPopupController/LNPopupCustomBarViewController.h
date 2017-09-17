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

/*
 * The @c preferredContentSize is used for height calculation of the popup bar.
 */
@property (nonatomic, assign) CGSize preferredContentSize;

/**
 * Called by the framework to notify the popup content view controller that one or more keys of the the popup item have been updated, or the entire popup item has changed.
 *
 * @note You must call the @c super implementation of this method.
 */
- (void)popupItemDidUpdate NS_REQUIRES_SUPER;

@end
