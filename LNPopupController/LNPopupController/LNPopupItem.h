//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupBarAppearance.h>

NS_ASSUME_NONNULL_BEGIN

#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))

#ifndef NS_SWIFT_UI_ACTOR
#define NS_SWIFT_UI_ACTOR
#endif

/**
 * An @c LNPopupItem object manages the buttons and text to be displayed in a popup bar. Each view controller in popup presentation must have an @c LNPopupItem object that contains the buttons and text it wants displayed in the popup bar.
 */
NS_SWIFT_UI_ACTOR
@interface LNPopupItem : NSObject

/**
 * The popup item's title.
 *
 * @note If no title or subtitle is set, the property will return its view controller's title.
 */
@property (nullable, nonatomic, copy) NSString* title;

/**
 * The popup item's attributed title.
 *
 * @note If no title or subtitle is set, the property will return its view controller's title.
 */
@property (nullable, nonatomic, copy) NSAttributedString* attributedTitle;

/**
 * The popup item's subtitle.
 */
@property (nullable, nonatomic, copy) NSString* subtitle;

/**
 * The popup item's attributed subtitle.
 */
@property (nullable, nonatomic, copy) NSAttributedString* attributedSubtitle;

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
 * Sets the bar button items of the popup bar, optionally animating the transition to the new items.
 *
 * @note For compact popup bars, this is equivalent to @c setTrailingBarButtonItems:animated:.
 */
- (void)setBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)barButtonItems animated:(BOOL)animated;

/**
 * An array of custom bar button items to display on the leading side of the popup bar.
 *
 * @note For prominent popup bars, these buttons are positioned on the trailing side, before items in @c trailingBarButtonItems.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leadingBarButtonItems;

/**
 * Sets the leading bar button items of the popup bar, optionally animating the transition to the new items.
 *
 * @note For prominent popup bars, these buttons are positioned on the trailing side, before items in @c trailingBarButtonItems.
 */
- (void)setLeadingBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)leadingBarButtonItems animated:(BOOL)animated;

/**
 * An array of custom bar button items to display on the trailing side of the popup bar.
 *
 * @note For prominent popup bars, this property is synonymous with @c barButtonItems.
 */
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* trailingBarButtonItems;

/**
 * Sets the trailing bar button items of the popup bar, optionally animating the transition to the new items.
 *
 * @note For prominent popup bars, this property is synonymous with @c setBarButtonItems:animated:.
 */
- (void)setTrailingBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)trailingBarButtonItems animated:(BOOL)animated;

/**
 * When set and this item is displayed, overrides the hosting popup bar's @c standardAppearance as well as any appearance inherited from the docking view. See @c LNPopupBarAppearance.standardAppearance for further details.
 */
@property (nonatomic, readwrite, copy, nullable) LNPopupBarAppearance* standardAppearance API_AVAILABLE(ios(13.0));

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
