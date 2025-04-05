//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-09-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
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
@property (nonatomic, assign) LNPopupCloseButtonStyle popupCloseButtonStyle UI_APPEARANCE_SELECTOR;

/// The effective popup close button style used by the system. (read-only)
///
/// Use this property's value to determine, at runtime, what the result of `LNPopupCloseButtonStyleDefault` is.
@property (nonatomic, assign, readonly) LNPopupCloseButtonStyle effectivePopupCloseButtonStyle;

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

NS_ASSUME_NONNULL_END
