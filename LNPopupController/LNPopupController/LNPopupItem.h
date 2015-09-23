//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An LNPopupItem object manages the buttons and text to be displayed in a popup bar. Each view controller in popup presentation must have an LNPopupItem object that contains the buttons and text it wants displayed in the popup bar.
 */
@interface LNPopupItem : NSObject

/**
 *  The popup item's title.
 *
 *  If no title and subtitle is set, the property will return its view controller's title.
 */
@property (nullable, nonatomic, copy) NSString* title;

/**
 *  The popup item's subtitle.
 */
@property (nullable, nonatomic, copy) NSString* subtitle;

/**
 *  The popup item's progress.
 *
 *  The current progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
 */
@property (nonatomic) float progress;

/**
 *  An array of custom bar button items to display on the left side of the popup bar.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leftBarButtonItems;

/**
 *  An array of custom bar button items to display on the right side of the popup bar.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* rightBarButtonItems;

@end

NS_ASSUME_NONNULL_END