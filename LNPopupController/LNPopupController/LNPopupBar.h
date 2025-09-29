//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>
#import <LNPopupController/LNPopupItem.h>
#import <LNPopupController/LNPopupCustomBarViewController.h>
#import <LNPopupController/LNPopupBarAppearance.h>
#import <LNPopupController/LNPopupImageView.h>

#define LN_UNAVAILABLE_PREVIEWING_MSG "Add context menu interaction or register for previewing directly on the popup bar view."

NS_ASSUME_NONNULL_BEGIN

/// Available styles for the popup bar.
typedef NS_ENUM(NSInteger, LNPopupBarStyle) {
	/// The default bar style for the current environment.
	LNPopupBarStyleDefault,
	
	/// Floating bar style.
	LNPopupBarStyleFloating = 9,
	
	/// Compact floating bar style.
	LNPopupBarStyleFloatingCompact = 8,
	
	/// Custom bar style.
	///
	/// Do not set this style directly. Instead, set the `LNPopupBar.customBarViewController` property and the framework will use this style.
	LNPopupBarStyleCustom = 0xFFFF,
	
	// Deprecated, will be removed eventually:
	
	/// Compact bar style.
	///
	/// - Note: Starting with iOS 26, non-floating bar styles are no longer supported. Will convert to `.floatingCompact` at runtime.
	LNPopupBarStyleCompact LN_DEPRECATED_API_OS("No longer supported, starting with iOS 26.0.", ios(2.0, 26.0)) = 1,
	
	/// Prominent bar style.
	///
	/// - Note: Starting with iOS 26, non-floating bar styles are no longer supported. Will convert to `.floating` at runtime.
	LNPopupBarStyleProminent LN_DEPRECATED_API_OS("No longer supported, starting with iOS 26.0.", ios(2.0, 26.0)) = 2,
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
@property (nonatomic, strong, readonly) LNPopupImageView* imageView;

/// The popup bar style.
@property (nonatomic, assign) LNPopupBarStyle barStyle UI_APPEARANCE_SELECTOR;

/// The effective popup bar style used by the system. (read-only)
///
/// Use this property's value to determine, at runtime, what bar style the system has chosen to use.
@property (nonatomic, assign, readonly) LNPopupBarStyle effectiveBarStyle;

/// In wide enough environments, such as iPadOS, limit the width of content of floating bars to a system-determined value.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL limitFloatingContentWidth;

/// Describes the appearance attributes for the popup bar to use when in standard environment.
@property (nonatomic, copy, null_resettable) LNPopupBarAppearance* standardAppearance UI_APPEARANCE_SELECTOR;

/// Describes the appearance attributes for the popup bar to use when in inline environment.
///
/// Set to `nil` to use the standard appearance when the bar is an inline environment.
///
/// Defaults to `nil`.
@property (nonatomic, copy, nullable) LNPopupBarAppearance* inlineAppearance UI_APPEARANCE_SELECTOR;

/// The popup bar's progress view style.
@property (nonatomic, assign) LNPopupBarProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR;

/// The progress view displayed on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UIProgressView* progressView;

/// A semantic description of the bar items, used to determine the order of bar items when switching between left-to-right and right-to-left layouts.
///
/// Defaults to `UISemanticContentAttribute.playback`.
///
/// See also `UIView.semanticContentAttribute`
@property (nonatomic) UISemanticContentAttribute barItemsSemanticContentAttribute;

/// The gesture recognizer responsible for opening the popup when the user taps on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UITapGestureRecognizer* popupOpenGestureRecognizer;

/// The gesture recognizer responsible for highlighting the popup bar when the user touches on the popup bar. (read-only)
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer* barHighlightGestureRecognizer;

/// Set this property to an ``LNPopupCustomBarViewController`` subclass object to provide a popup bar with custom content.
@property (nullable, nonatomic, strong) __kindof LNPopupCustomBarViewController* customBarViewController;

/// Indicates whether the full bar width should be used for the custom bar.
///
/// This only has effect on iOS 26.
@property (nonatomic, assign) BOOL customBarWantsFullBarWidth;

/// Enables or disables minimization into the bottom docking view.
///
/// Defaults to `true`.
///
/// - Note: Supported on iOS 26 and above, for tab bar container controllers.
@property (nonatomic, assign) BOOL supportsMinimization;

@end

typedef NS_ENUM(NSInteger, LNPopupBarEnvironment) {
	/// Indicates the absence of any information about whether or not the trait collection is
	/// from a popup bar presentation.
	LNPopupBarEnvironmentUnspecified,
	
	/// The environment for when the popup bar is laid out either:
	///   - above the bottom bar when it is visible; or,
	///   - at the bottom of the container controller's view.
	LNPopupBarEnvironmentRegular,
	
	/// The environment for when the popup bar is laid out inline with
	/// the collapsed bottom bar.
	LNPopupBarEnvironmentInline,
} NS_SWIFT_NAME(LNPopupBar.Environment);

NS_REFINED_FOR_SWIFT
/// A trait that specifies the `LNPopupBarEnvironment`, if any, of the view or view controller. It is set on popup bars, views inside custom popup bars and popup content view controllers. Defaults to `LNPopupBarEnvironmentUnspecified`.
@interface LNPopupBarEnvironmentTrait : NSObject <UINSIntegerTraitDefinition> @end

@interface UITraitCollection (LNPopupBarEnvironmentSupport)

/// The popup bar environment represents whether a given trait collection is from a popup bar, a view in a custom popup bar or a popup content view controller.
@property (nonatomic, readonly) LNPopupBarEnvironment popupBarEnvironment NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
