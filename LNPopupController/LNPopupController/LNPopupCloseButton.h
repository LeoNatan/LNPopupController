//
//  LNPopupCloseButton.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>

/// Available styles for the popup close button.
typedef NS_ENUM(NSInteger, LNPopupCloseButtonStyle) {
	/// The default close button style for the current environment.
	LNPopupCloseButtonStyleDefault,
	
	/// Round close button style.
	LNPopupCloseButtonStyleRound,
	
	/// Chevron close button style.
	LNPopupCloseButtonStyleChevron,
	
	/// Grabber close button style.
	LNPopupCloseButtonStyleGrabber,
	
	/// Glass close button style.
	///
	/// Glass buttons are only available on iOS 26.0 and later. Otherwise, round will be used.
	LNPopupCloseButtonStyleGlass = 0x100,
	
	/// Clear glass close button style.
	///
	/// Glass buttons are only available on iOS 26.0 and later. Otherwise, round will be used.
	LNPopupCloseButtonStyleClearGlass = 0x101,
	
	/// Prominent glass close button style.
	///
	/// Glass buttons are only available on iOS 26.0 and later. Otherwise, round will be used.
	LNPopupCloseButtonStyleProminentGlass = 0x102,
	
	/// Prominent clear glass close button style.
	///
	/// Glass buttons are only available on iOS 26.0 and later. Otherwise, round will be used.
	LNPopupCloseButtonStyleProminentClearGlass = 0x103,
	
	/// No close button.
	LNPopupCloseButtonStyleNone = 0xFFFF,
	
	LNPopupCloseButtonStyleFlat LN_DEPRECATED_API("Use LNPopupCloseButtonStyle.grabber instead.") = LNPopupCloseButtonStyleGrabber
} NS_SWIFT_NAME(LNPopupCloseButton.Style);

/// Available styles for the popup close button.
typedef NS_ENUM(NSInteger, LNPopupCloseButtonPositioning) {
	/// The default close button positioning, most suitable for the button style.
	LNPopupCloseButtonPositioningDefault,
	
	/// Leading close button positioning.
	LNPopupCloseButtonPositioningLeading,
	
	/// Center close button positioning.
	LNPopupCloseButtonPositioningCenter,
	
	/// Trailing close button positioning.
	LNPopupCloseButtonPositioningTrailing
} NS_SWIFT_NAME(LNPopupCloseButton.Positioning);

NS_ASSUME_NONNULL_BEGIN

/// The popup content close button.
NS_SWIFT_UI_ACTOR
@interface LNPopupCloseButton : UIButton <UIAppearanceContainer>

/// Gets or sets the style of the popup close button. Has the same effect as setting the `LNPopupContentView.popupCloseButtonStyle` property of the popup content view.
@property (nonatomic, assign) LNPopupCloseButtonStyle style UI_APPEARANCE_SELECTOR;

/// Gets or sets the positioning of the popup close button. Has the same effect as setting the `LNPopupContentView.popupCloseButtonPositioning` property of the popup content view.
///
/// The value of this property only has effect if the system positions the popup close button.
@property (nonatomic, assign) LNPopupCloseButtonPositioning positioning UI_APPEARANCE_SELECTOR;

/// The effective popup close button style used by the system. (read-only)
///
/// Use this property's value to determine, at runtime, what close button style the system has chosen to use.
@property (nonatomic, assign, readonly) LNPopupCloseButtonStyle effectiveStyle;

/// The effective popup close button positioning used by the system. (read-only)
///
/// Use this property's value to determine, at runtime, what close button positioning the system has chosen to use.
@property (nonatomic, assign, readonly) LNPopupCloseButtonPositioning effectivePositioning;

/// The button’s background view. (read-only)
///
/// The value of this property will be `nil` if `style` is set to any value other than `LNPopupCloseButtonStyleRound`.
///
/// Although this property is read-only, its own properties are read/write. Use these properties to configure the appearance and behavior of the button’s background view.
@property (nonatomic, strong, readonly) UIVisualEffectView* backgroundView;

@end

NS_ASSUME_NONNULL_END
