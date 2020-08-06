//
//  LNPopupBarContentViewController.h
//  LNPopupController
//
//  Created by Leo Natan on 15/12/2016.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;

@interface LNPopupCustomBarViewController : UIViewController

/**
 * The containing popup bar. (read-only)
 */
@property (nonatomic, weak, readonly) LNPopupBar* containingPopupBar;

/**
 * Indicates whether the default tap gesture recognizer should be added to the popup bar.
 *
 * Defaults to @c YES.
 */
@property (nonatomic, assign, readonly) BOOL wantsDefaultTapGestureRecognizer;

/**
 * Indicates whether the default pan gesture recognizer should be added to the popup bar.
 *
 * Defaults to @c YES.
 */
@property (nonatomic, assign, readonly) BOOL wantsDefaultPanGestureRecognizer;

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
