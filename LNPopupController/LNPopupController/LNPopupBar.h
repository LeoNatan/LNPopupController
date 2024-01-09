//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>
#import <LNPopupController/LNPopupItem.h>
#import <LNPopupController/LNPopupCustomBarViewController.h>
#import <LNPopupController/LNPopupBarAppearance.h>

#define LN_UNAVAILABLE_PREVIEWING_MSG "Add context menu interaction or register for previewing directly on the popup bar view."

NS_ASSUME_NONNULL_BEGIN

/// Available styles for the popup bar.
typedef NS_ENUM(NSInteger, LNPopupBarStyle) {
	/// The default bar style for the current environment.
	LNPopupBarStyleDefault,
	
	/// Compact bar style.
	LNPopupBarStyleCompact,
	
	/// Prominent bar style.
	LNPopupBarStyleProminent,
	
	/// Floating bar style.
	LNPopupBarStyleFloating,
	
	/// Custom bar style.
	///
	/// Do not set this style directly. Instead, set the `LNPopupBar.customBarViewController` property and the framework will use this style.
	LNPopupBarStyleCustom = 0xFFFF
} NS_SWIFT_NAME(LNPopupBar.Style);

/// Available styles for the popup bar progress view.
typedef NS_ENUM(NSInteger, LNPopupBarProgressViewStyle) {
	/// Use the most appropriate style for the current operating system version.
	LNPopupBarProgressViewStyleDefault,
	
	/// Progress view on bottom
	LNPopupBarProgressViewStyleBottom,
	
	/// Progress view on bottom
    LNPopupBarProgressViewStyleTop,
	
	/// No progress view
	LNPopupBarProgressViewStyleNone = 0xFFFF
} NS_SWIFT_NAME(LNPopupBar.ProgressViewStyle);

NS_SWIFT_UI_ACTOR
/// A popup bar is a control that displays popup information. Content is populated from ``LNPopupItem`` items.
@interface LNPopupBar : UIView <UIAppearanceContainer>

/// If `true`, the popup bar will automatically inherit its appearance from the bottom docking view.
@property (nonatomic, assign) BOOL inheritsAppearanceFromDockingView UI_APPEARANCE_SELECTOR;

/// The currently displayed popup item. (read-only)
@property (nullable, nonatomic, weak, readonly) LNPopupItem* popupItem;

/// An array of custom bar button items. (read-only)
///
/// For compact popup bars, this property is equivalent to `trailingBarButtonItems`.
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* barButtonItems;

/// An array of custom bar button items to display on the left side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leadingBarButtonItems;

/// An array of custom bar button items to display on the right side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* trailingBarButtonItems;

/// An image view displayed when the bar style is prominent. (read-only)
@property (nonatomic, strong, readonly) UIImageView* imageView;

/// The popup bar style.
@property (nonatomic, assign) LNPopupBarStyle barStyle UI_APPEARANCE_SELECTOR;

/// The effective popup bar style used by the system. (read-only)
///
/// Use this property's value to determine, at runtime, what the result of `LNPopupBarStyleDefault` is.
@property (nonatomic, assign, readonly) LNPopupBarStyle effectiveBarStyle;

/// Describes the appearance attributes for the popup bar to use.
@property (nonatomic, copy, null_resettable) LNPopupBarAppearance* standardAppearance UI_APPEARANCE_SELECTOR API_AVAILABLE(ios(13.0));

/// The popup bar's progress view style.
@property (nonatomic, assign) LNPopupBarProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR;

/// The progress view displayed on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UIProgressView* progressView;

/// A semantic description of the bar items, used to determine the order of bar items when switching between left-to-right and right-to-left layouts.
///
/// Defaults to `UISemanticContentAttributePlayback`.
///
/// See also `UIView.semanticContentAttribute`
@property (nonatomic) UISemanticContentAttribute barItemsSemanticContentAttribute;

/// The gesture recognizer responsible for opening the popup when the user taps on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UITapGestureRecognizer* popupOpenGestureRecognizer;

/// The gesture recognizer responsible for highlighting the popup bar when the user touches on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer* barHighlightGestureRecognizer;

/// Set this property to an ``LNPopupCustomBarViewController`` subclass object to provide a popup bar with custom content.
@property (nullable, nonatomic, strong) __kindof LNPopupCustomBarViewController* customBarViewController;

@end

#pragma mark Deprecations

extern const UIBlurEffectStyle LNBackgroundStyleInherit LN_UNAVAILABLE_API("Use LNPopupBarAppearance instead.");

@interface LNPopupBar (Deprecated)

/// If `true`, the popup bar will automatically inherit its style from the bottom docking view.
@property (nonatomic, assign) BOOL inheritsVisualStyleFromDockingView LN_UNAVAILABLE_API("Use inheritsAppearanceFromDockingView instead.");

/// The popup bar background style that specifies its appearance.
///
/// Use `LNBackgroundStyleInherit` value to inherit the docking view's bar style if possible, or use a system default.
///
/// Defaults to `LNBackgroundStyleInherit`.
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle LN_UNAVAILABLE_API("Use LNPopupBarAppearance.backgroundEffect instead.");

/// The tint color to apply to the popup bar background.
@property (nullable, nonatomic, strong) UIColor* barTintColor LN_UNAVAILABLE_API("Use LNPopupBarAppearance.backgroundColor instead.");

/// A Boolean value that indicates whether the popup bar is translucent (`true`) or not (`false`).
@property(nonatomic, assign, getter=isTranslucent) BOOL translucent LN_UNAVAILABLE_API("Use LNPopupBarAppearance.configureWithOpaqueBackground() instead.");

/// Display attributes for the popup bar’s title text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* titleTextAttributes LN_UNAVAILABLE_API("Use LNPopupBarAppearance.titleTextAttributes instead.");

/// Display attributes for the popup bar’s subtitle text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* subtitleTextAttributes LN_UNAVAILABLE_API("Use LNPopupBarAppearance.subtitleTextAttributes instead.");

/// When enabled, titles and subtitles that are longer than the space available will scroll text over time.
///
/// Defaults to `false`.
@property (nonatomic, assign) BOOL marqueeScrollEnabled LN_UNAVAILABLE_API("Use LNPopupBarAppearance.marqueeScrollEnabled instead.");

/// The scroll rate, in points, of the title and subtitle marquee animation.
///
/// Defaults to `30`.
@property (nonatomic, assign) CGFloat marqueeScrollRate LN_UNAVAILABLE_API("Use LNPopupBarAppearance.marqueeScrollRate instead.");

/// The delay, in seconds, before starting the title and subtitle marquee animation.
///
/// Defaults to `2`.
@property (nonatomic, assign) NSTimeInterval marqueeScrollDelay LN_UNAVAILABLE_API("Use LNPopupBarAppearance.marqueeScrollDelay instead.");

/// When enabled, the title and subtitle marquee scroll animations will be coordinated.
///
/// If either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL coordinateMarqueeScroll LN_UNAVAILABLE_API("Use LNPopupBarAppearance.coordinateMarqueeScroll instead.");

/// An array of custom bar button items to display on the left side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leftBarButtonItems LN_UNAVAILABLE_API("Use leadingBarButtonItems instead.");

/// An array of custom bar button items to display on the right side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* rightBarButtonItems LN_UNAVAILABLE_API("Use barButtonItems or trailingBarButtonItems instead.");

@end

NS_ASSUME_NONNULL_END
