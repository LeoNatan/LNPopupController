//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>
#import <LNPopupController/LNPopupBarAppearance.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR
/// An `LNPopupItem` object manages the buttons and text to be displayed in a popup bar. Each view controller in popup presentation must have an `LNPopupItem` object that contains the buttons and text it wants displayed in the popup bar.
@interface LNPopupItem : NSObject

/// The popup item's identifier.
///
/// Defaults to a unique identifier.
@property (nonatomic, copy) NSString* identifier;

/// The popup item's title.
///
/// If no title or subtitle is set, the system will use the view controller's title.
@property (nullable, nonatomic, copy) NSString* title;

/// The popup item's attributed title.
///
/// If no title or subtitle is set, the system will use the view controller's title.
@property (nullable, nonatomic, copy) NSAttributedString* attributedTitle NS_REFINED_FOR_SWIFT;

/// The popup item's subtitle.
@property (nullable, nonatomic, copy) NSString* subtitle;

/// The popup item's attributed subtitle.
@property (nullable, nonatomic, copy) NSAttributedString* attributedSubtitle NS_REFINED_FOR_SWIFT;

/// The popup item's image.
///
/// The image will only be displayed on prominent popup bars.
@property (nullable, nonatomic, strong) UIImage* image;

/// The popup item's progress.
///
/// The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
@property (nonatomic) float progress;

/// An array of custom bar button items to display on the popup bar.
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* barButtonItems;

/// Sets the bar button items of the popup bar, optionally animating the transition to the new items.
///
/// For compact popup bars, this is equivalent to ``setTrailingBarButtonItems:animated:``.
- (void)setBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)barButtonItems animated:(BOOL)animated;

/// The user information dictionary associated with the popup item.
@property (nullable, nonatomic, copy) NSDictionary* userInfo;

/// When set and this item is displayed, overrides the hosting popup bar's `standardAppearance` as well as any appearance inherited from the system.
///
/// See `LNPopupBarAppearance.standardAppearance` for further details.
@property (nonatomic, readwrite, copy, nullable) LNPopupBarAppearance* standardAppearance;

/// When set and this item is displayed, overrides the hosting popup bar's `inlineAppearance` as well as any appearance inherited from the system.
///
/// Set to `nil` to use the standard appearance when the bar is an inline environment.
///
/// See `LNPopupBarAppearance.inlineAppearance` for further details.
@property (nonatomic, readwrite, copy, nullable) LNPopupBarAppearance* inlineAppearance;

@end

@interface LNPopupItem (Accessibility)

/// The accessibility label of the image, in a localized string.
@property (nonatomic, copy, nullable) NSString* accessibilityImageLabel;

/// The accessibility label of the progress, in a localized string.
@property (nonatomic, copy, nullable) NSString* accessibilityProgressLabel;

/// The accessibility value of the progress, in a localized string.
@property (nonatomic, copy, nullable) NSString* accessibilityProgressValue;

@end

// Deprecations

@interface LNPopupItem ()

@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leftBarButtonItems LN_UNAVAILABLE_API("Use leadingBarButtonItems instead.");

@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* rightBarButtonItems LN_UNAVAILABLE_API("Use barButtonItems or trailingBarButtonItems instead.");

/// An array of custom bar button items to display on the leading side of the popup bar.
///
/// For prominent popup bars, these buttons are positioned on the trailing side, before items in ``trailingBarButtonItems``.
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* leadingBarButtonItems LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

/// Sets the leading bar button items of the popup bar, optionally animating the transition to the new items.
///
/// For prominent popup bars, these buttons are positioned on the trailing side, before items in ``trailingBarButtonItems``.
- (void)setLeadingBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)leadingBarButtonItems animated:(BOOL)animated LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

/// An array of custom bar button items to display on the trailing side of the popup bar.
///
/// For prominent popup bars, this property is equivalent to ``barButtonItems``.
@property(nullable, nonatomic, copy) NSArray<UIBarButtonItem*>* trailingBarButtonItems LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

/// Sets the trailing bar button items of the popup bar, optionally animating the transition to the new items.
///
/// For prominent popup bars, this property is equivalent to ``setBarButtonItems:animated:``.
- (void)setTrailingBarButtonItems:(nullable NSArray<UIBarButtonItem*>*)trailingBarButtonItems animated:(BOOL)animated  LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

@end

NS_ASSUME_NONNULL_END
