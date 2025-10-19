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
	/// Starting with iOS 26, non-floating bar styles are no longer supported and will be converted to `.floatingCompact` at runtime.
	LNPopupBarStyleCompact LN_DEPRECATED_API_OS("Non-floating bars are no longer supported on iOS 26.0 and later.", ios(2.0, 26.0)) = 1,
	
	/// Prominent bar style.
	///
	/// Starting with iOS 26, non-floating bar styles are no longer supported and will be converted to `.floating` at runtime.
	LNPopupBarStyleProminent LN_DEPRECATED_API_OS("Non-floating bars are no longer supported on iOS 26.0 and later.", ios(2.0, 26.0)) = 2,
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
@protocol LNPopupBarDataSource <NSObject>

@optional

/// Asks the data source to provide the initial popup item for the popup bar. This method will only be called if ``LNPopupBar/popupItem`` is `nil` when presenting a content controller.
///
/// If this method is not implemented, you must set a popup item for the popup bar **before** attempting to present it.
- (nonnull LNPopupItem*)initialPopupItemForPopupBar:(LNPopupBar*)popupBar;

// Paging support. The following methods must be implemented by the data source in order to enable paging.

/// Asks the data source to provide a popup item before the specified popup item. Return `nil` to indicate there is no item before.
- (nullable LNPopupItem*)popupBar:(LNPopupBar*)popupBar popupItemBeforePopupItem:(LNPopupItem*)popupItem NS_SWIFT_NAME(popupBar(_:popupItemBefore:));
/// Asks the data source to provide a popup item after the specified popup item. Return `nil` to indicate there is no item after.
- (nullable LNPopupItem*)popupBar:(LNPopupBar*)popupBar popupItemAfterPopupItem:(LNPopupItem*)popupItem NS_SWIFT_NAME(popupBar(_:popupItemAfter:));

@end

NS_SWIFT_UI_ACTOR
@protocol LNPopupBarDelegate <NSObject>

@optional

/// Notifies the delegate when a new popup item is displayed on the popup bar.
/// - Parameters:
///   - popupBar: The popup bar
///   - newPopupItem: The new popup item
///   - previousPopupItem: The previous popup item, if any
- (void)popupBar:(LNPopupBar*)popupBar didDisplayPopupItem:(LNPopupItem*)newPopupItem previousPopupItem:(LNPopupItem* __nullable)previousPopupItem NS_SWIFT_NAME(popupBar(_:didDisplay:previous:));

@end

NS_SWIFT_UI_ACTOR
/// A popup bar is a view that displays popup information. Content is populated from ``LNPopupItem`` items.
@interface LNPopupBar : UIView <UIAppearanceContainer>

/// If `true`, the popup bar will automatically inherit its appearance from the bottom docking view.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL inheritsAppearanceFromDockingView UI_APPEARANCE_SELECTOR;

/// Controls whether the popup bar uses popup items from the content controller directly.
///
/// When **`true`**, the content controller's ``UIKit/UIViewController/popupItem`` property is used to populate the user interface of the popup bar. Presenting a different content controller switches the displayed popup item to the new controller's ``UIKit/UIViewController/popupItem``. Attempting to manually set the popup bar's item directly is ignored and setting the ``dataSource`` has no effect. This is the default behavior.
///
/// When **`false`**, allows setting the popup item directly for the popup bar, or through the ``dataSource``'s ``LNPopupBarDataSource/initialPopupItem(for:)``. Also allows popup item paging by setting the data source and implementing **both** ``LNPopupBarDataSource/popupBar(_:popupItemBefore:)`` and ``LNPopupBarDataSource/popupBar(_:popupItemAfter:)`` methods.
///
/// Changes to popup item properties are observed and the UI is automatically updated.
///
/// Defaults to `true`.
@property (nonatomic) BOOL usesContentControllersAsDataSource;

/// The currently displayed popup item.
///
/// When ``usesContentControllersAsDataSource`` is set to `false`, changes to this property trigger a call to ``UIKit/UIViewController/popupItemDidChange(_:)`` to let you know when the popup item changes (for example, by paging).
///
/// See ``usesContentControllersAsDataSource`` for more information.
@property (nullable, nonatomic, strong) LNPopupItem* popupItem;

/// The popup bar's data source.
///
/// To enable data source usage, first set the popup bar's ``usesContentControllersAsDataSource`` to `false`, then set a data source.
///
/// Data sources can serve two distinct purposes; first, to provide an initial popup item to be used when presenting a popup bar, and, second, to allow for popup item paging.
///
///	To provide an initial popup item, implement ``LNPopupBarDataSource/initialPopupItem(for:)``. The system calls this method when it requires an initial popup item.
///
/// To implement popup item paging, in your data source, implement **both** ``LNPopupBarDataSource/popupBar(_:popupItemBefore:)`` and ``LNPopupBarDataSource/popupBar(_:popupItemAfter:)`` methods. The system will ask for popup items before and/or after the specified popup item as the user attempts to swipe on the popup bar.
@property (nullable, nonatomic, weak) id<LNPopupBarDataSource> dataSource;

/// The popup bar's delegate.
@property (nullable, nonatomic, weak) id<LNPopupBarDelegate> delegate;

/// An array of custom bar button items. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* barButtonItems;

/// An array of custom bar button items to display on the leading side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leadingBarButtonItems LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

/// An array of custom bar button items to display on the trailing side. (read-only)
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* trailingBarButtonItems LN_DEPRECATED_API("Non-floating bars are no longer supported on iOS 26.0 and later.");

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
/// Defaults to `UIUISemanticContentAttribute.playback`.
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
/// This only has effect on iOS 26.0 and later.
@property (nonatomic, assign) BOOL customBarWantsFullBarWidth;

/// Enables or disables minimization into the bottom docking view.
///
/// Supported on iOS 26.0 and later, for tab bar container controllers.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL supportsMinimization;

/// Controls whether paging popup items generates haptic feedback to the user.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL allowHapticFeedbackGenerationOnItemPaging;

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
