//
//  LNPopupCloseButton.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Available styles for the popup close button
 */
typedef NS_ENUM(NSUInteger, LNPopupCloseButtonStyle) {
	/**
	 * Use the most appropriate close button style for the current operating system version; uses cehvron button style for iOS 10 and above, otherwise round button.
	 */
	LNPopupCloseButtonStyleDefault,
	
	/**
	 * Round close button style
	 */
	LNPopupCloseButtonStyleRound,
	/**
	 * Chevron close button style
	 */
	LNPopupCloseButtonStyleChevron,
	/**
	 * No close button
	 */
	LNPopupCloseButtonStyleNone = 0xFFFF
};

NS_ASSUME_NONNULL_BEGIN

@interface LNPopupCloseButton : UIButton

/**
 *  The button’s style. (read-only)
 *
 *  The current style of the popup close button. In order to change the button's style, set the `popupCloseButtonStyle` property of the content view.
 */
@property (nonatomic, readonly) LNPopupCloseButtonStyle style;

/**
 *  The button’s background view. (read-only)
 *  
 *  Although this property is read-only, its own properties are read/write. Use these properties to configure the appearance and behavior of the button’s background view.
 */
@property (nonatomic, strong, readonly) UIVisualEffectView* backgroundView;

@end
NS_ASSUME_NONNULL_END
