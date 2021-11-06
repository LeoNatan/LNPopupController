//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupCloseButton.h>

#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))

NS_ASSUME_NONNULL_BEGIN

/**
 * Holds the popup content container view, as well as the popup close button and the popup interaction gesture recognizer.
 */
@interface LNPopupContentView : UIView <UIAppearanceContainer>

/**
 * The gesture recognizer responsible for interactive opening and closing of the popup. (read-only)
 * 
 * The system installs this gesture recognizer on either the popup bar or the popup content view and uses it to open or close the popup.
 * Be careful with modifying this gesture recognizer. It is shared for interactively opening the popup by panning the popup bar (when it is closed), or interactively closing the popup interactively by panning the popup content view (when the popup is open). If you disable the gesture recognizer after opening the popup, you must monitor the state of the popup and reenable the gesture recognizer once closed by the user or through code.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer* popupInteractionGestureRecognizer;

/**
 * The popup close button style.
 *
 * Defaults to @c LNPopupCloseButtonStyleDefault.
 */
@property (nonatomic) LNPopupCloseButtonStyle popupCloseButtonStyle UI_APPEARANCE_SELECTOR;

/**
 * The popup close button. (read-only)
 */
@property (nonatomic, strong, readonly) LNPopupCloseButton* popupCloseButton;

/**
 * Attempt to automatically move the popup close button under top bars, such as navigation bars.
 *
 * Defaults to @c true.
 */
@property (nonatomic) BOOL popupCloseButtonAutomaticallyUnobstructsTopBars UI_APPEARANCE_SELECTOR;

/**
* The popup content view background effect, used when the popup content controller's view has transparency.
*
* Use @c nil value to inherit the popup bar's background effect if possible, or use a default effect..
*
* Defaults to @c nil.
*/
@property (nonatomic, copy, nullable) UIBlurEffect* backgroundEffect UI_APPEARANCE_SELECTOR;

/**
 * A Boolean value that indicates whether the popup content view is translucent (@c true) or not (@c false).
 *
 * Defaults to @c true.
 */
@property(nonatomic, assign, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;

@end

#pragma mark Deprecations

extern const UIBlurEffectStyle LNBackgroundStyleInherit LN_DEPRECATED_API("Use backgroundEffect instead.");

@interface LNPopupContentView (Deprecated)

/**
 * The popup content view background style, used when the popup content controller's view has transparency.
 *
 * Use @c LNBackgroundStyleInherit value to inherit the popup bar's background style if possible.
 *
 * Defaults to @c LNBackgroundStyleInherit.
 */
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle UI_APPEARANCE_SELECTOR LN_DEPRECATED_API("Use backgroundEffect instead.");

@end

NS_ASSUME_NONNULL_END
