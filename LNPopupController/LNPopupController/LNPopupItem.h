//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))

/**
 * An @c LNPopupItem object manages the buttons and text to be displayed in a popup bar. Each view controller in popup presentation must have an @c LNPopupItem object that contains the buttons and text it wants displayed in the popup bar.
 */
@interface LNPopupItem : NSObject

/**
 * The popup item's title.
 *
 * @note If no title or subtitle is set, the property will return its view controller's title.
 */
@property (nullable, nonatomic, copy) NSString* title;

/**
 * The popup item's subtitle.
 */
@property (nullable, nonatomic, copy) NSString* subtitle;

/**
 * The popup item's image.
 *
 * @note The image will only be displayed on prominent popup bars.
 */
@property (nullable, nonatomic, strong) UIImage* image;

/**
 * The popup item's progress.
 *
 * The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
 */
@property (nonatomic) float progress;

/**
 * An array of custom bar button items to display on the popup bar.
 *
 * @note For compact popup bars, this property is equivalent to @c trailingBarButtonItems.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* barButtonItems;

/**
 * An array of custom bar button items to display on the leading side of the popup bar.
 *
 * @note For prominent popup bars, these buttons are positioned on the trailing side, before items in @c trailingBarButtonItems.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leadingBarButtonItems;

/**
 * An array of custom bar button items to display on the trailing side of the popup bar.
 *
 * @note For prominent popup bars, this property is synonymous with @c barButtonItems.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* trailingBarButtonItems;

@end

@interface LNPopupItem (Accessibility)

/**
 * The accessibility label of the image, in a localized string.
 */
@property (nonatomic, copy, nullable) NSString* accessibilityImageLabel;

/**
 * The accessibility label of the progress, in a localized string.
 */
@property (nonatomic, copy, nullable) NSString* accessibilityProgressLabel;

/**
 * The accessibility value of the progress, in a localized string.
 */
@property (nonatomic, copy, nullable) NSString* accessibilityProgressValue;

@end

@interface LNPopupItem (Deprecated)

@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leftBarButtonItems LN_DEPRECATED_API("Use leadingBarButtonItems instead.");

@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* rightBarButtonItems LN_DEPRECATED_API("Use barButtonItems or trailingBarButtonItems instead.");

@end

NS_ASSUME_NONNULL_END
