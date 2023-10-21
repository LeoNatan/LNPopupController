//
//  LNPopupCloseButton.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
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
	
	/// No close button.
	LNPopupCloseButtonStyleNone = 0xFFFF,
	
	LNPopupCloseButtonStyleFlat LN_DEPRECATED_API("Use LNPopupCloseButtonStyle.grabber instead.") = LNPopupCloseButtonStyleGrabber
} NS_SWIFT_NAME(LNPopupCloseButton.Style);

NS_ASSUME_NONNULL_BEGIN

/// The popup content close button.
NS_SWIFT_UI_ACTOR
@interface LNPopupCloseButton : UIButton <UIAppearanceContainer>

/// Gets or sets the style of the popup close button. Has the same effect as setting the `LNPopupContentView.popupCloseButtonStyle` property of the popup content view.
@property (nonatomic) LNPopupCloseButtonStyle style UI_APPEARANCE_SELECTOR;

/// The button’s background view. (read-only)
///
/// The value of this property will be `nil` if ``style`` is not set to `LNPopupCloseButtonStyleRound`.
///
/// @note Although this property is read-only, its own properties are read/write. Use these properties to configure the appearance and behavior of the button’s background view.
@property (nonatomic, strong, readonly) UIVisualEffectView* backgroundView;

@end

NS_ASSUME_NONNULL_END
