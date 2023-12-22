//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>
#import <LNPopupController/LNPopupCloseButton.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR
/// Holds the popup content container view, as well as the popup close button and the popup interaction gesture recognizer.
@interface LNPopupContentView : UIView <UIAppearanceContainer>

/// The gesture recognizer responsible for interactive opening and closing of the popup. (read-only)
///
/// The system installs this gesture recognizer on either the popup bar or the popup content view and uses it to open or close the popup.
/// Be careful with modifying this gesture recognizer. It is shared for interactively opening the popup by panning the popup bar (when it is closed), or interactively closing the popup interactively by panning the popup content view (when the popup is open). If you disable the gesture recognizer after opening the popup, you must monitor the state of the popup and reenable the gesture recognizer once closed by the user or through code.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer* popupInteractionGestureRecognizer;

/// The popup close button style.
///
/// Defaults to `LNPopupCloseButtonStyleDefault`.
@property (nonatomic) LNPopupCloseButtonStyle popupCloseButtonStyle UI_APPEARANCE_SELECTOR;

/// The popup close button. (read-only)
@property (nonatomic, strong, readonly) LNPopupCloseButton* popupCloseButton;

/// The popup content view background effect, used when the popup content controller's view has transparency.
///
/// Use `nil` value to inherit the popup bar's background effect if possible, or use a default effect.
///
/// Defaults to `nil`.
@property (nonatomic, copy, nullable) UIBlurEffect* backgroundEffect UI_APPEARANCE_SELECTOR;

/// A Boolean value that indicates whether the popup content view is translucent (`true`) or not (`false`).
///
/// Defaults to `true`.
@property(nonatomic, assign, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;

@end

#pragma mark Deprecations

extern const UIBlurEffectStyle LNBackgroundStyleInherit LN_UNAVAILABLE_API("Use backgroundEffect instead.");

@interface LNPopupContentView (Deprecated)

/// Attempt to automatically move the popup close button under top bars, such as navigation bars.
///
/// Note: No longer supported. Instead, implement `UIViewController.positionPopupCloseButton()` and position the button in your content controller's view hierarchy.
@property (nonatomic) BOOL popupCloseButtonAutomaticallyUnobstructsTopBars LN_UNAVAILABLE_API("No longer supported. Instead, implement UIViewController.positionPopupCloseButton() and position the button in your content controller's view hierarchy.");

/// The popup content view background style, used when the popup content controller's view has transparency.
///
/// Use `LNBackgroundStyleInherit` value to inherit the popup bar's background style if possible.
///
/// Defaults to `LNBackgroundStyleInherit`.
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle LN_UNAVAILABLE_API("Use backgroundEffect instead.");

@end

NS_ASSUME_NONNULL_END
