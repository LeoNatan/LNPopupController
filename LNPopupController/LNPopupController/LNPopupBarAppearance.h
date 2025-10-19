//
//  LNPopupBarAppearance.h
//  LNPopupController
//
//  Created by Léo Natan on 2021-06-20.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR
/// An object for customizing the appearance of popup bars.
///
/// After creating a ``LNPopupBarAppearance`` object, use the methods and properties of this class to specify the appearance of items in the popup bar. Use the inherited properties from `UIBarAppearance` to configure the background and shadow attributes of the popup bar itself.
@interface LNPopupBarAppearance : UIBarAppearance

/// Display attributes for the popup bar’s title text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* titleTextAttributes NS_REFINED_FOR_SWIFT;

/// Display attributes for the popup bar’s subtitle text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* subtitleTextAttributes NS_REFINED_FOR_SWIFT;

/// The appearance for plain-style bar button items.
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* buttonAppearance;

/// The appearance for done-style bar button items.
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* prominentButtonAppearance;

/// The appearance for done-style bar button items.
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* doneButtonAppearance LN_DEPRECATED_API("Use prominentButtonAppearance instead.");

/// The color to apply for the bar's highlight.
///
/// Starting with iOS 26.0, when a glass effect is used for the popup bar, setting a highlight color has no effect.
@property (nonatomic, copy) UIColor* highlightColor;

/// Configures the popup bar with the default highlight color.
///
/// Starting with iOS 26.0, when a glass effect is used for the popup bar, setting a highlight color has no effect.
- (void)configureWithDefaultHighlightColor;

/// When enabled, titles and subtitles that are longer than the space available will scroll text over time.
///
/// Defaults to `false`.
@property (nonatomic, assign) BOOL marqueeScrollEnabled;

/// The scroll rate, in points, of the title and subtitle marquee animation.
///
/// Defaults to `30`.
@property (nonatomic, assign) CGFloat marqueeScrollRate;

/// The delay, in seconds, before starting the title and subtitle marquee animation.
///
/// Defaults to `2`.
@property (nonatomic, assign) NSTimeInterval marqueeScrollDelay;

/// When enabled, the title and subtitle marquee scroll animations will be coordinated.
///
/// If either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together.
///
/// Defaults to `true`.
@property (nonatomic, assign) BOOL coordinateMarqueeScroll;

/// Configures the popup bar with marquee scroll enabled and sets the default marquee scroll configuration values.
- (void)configureWithDefaultMarqueeScroll;

/// Configures the popup bar with marquee scroll disabled.
- (void)configureWithDisabledMarqueeScroll;

/// The shadow displayed underneath the popup bar image view.
@property (nonatomic, copy, nullable) NSShadow* imageShadow;

- (void)configureWithDefaultImageShadow;
- (void)configureWithStaticImageShadow;
- (void)configureWithNoImageShadow;

/// A specific visual effect to use for the bar floating background. This effect is composited first when constructing the bar's floating background.
///
/// Starting with iOS 26.0, glass (default) and blur effects are supported.
@property (nonatomic, copy, nullable) UIVisualEffect* floatingBackgroundEffect;

/// A color to use for the bar floating background. This color is composited over ``floatingBackgroundEffect``.
@property (nonatomic, copy, nullable) UIColor* floatingBackgroundColor;

/// An image to use for the bar floating background. This image is composited over the ``floatingBackgroundColor``, and resized per the `floatingBackgroundImageContentMode`.
@property (nonatomic, strong, nullable) UIImage* floatingBackgroundImage;

/// The content mode to use when rendering the ``floatingBackgroundImage``. Defaults to `UIViewContentMode.scaleToFill`. `UIViewContentMode.redraw` will be reinterpreted as `UIViewContentMode.scaleToFill`.
@property (nonatomic, assign) UIViewContentMode floatingBackgroundImageContentMode;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
/// A configuration that defines the corners of the floating background view.
///
/// Set to `nil` to use the system default.
@property (nonatomic, copy, nullable) UICornerConfiguration* floatingBackgroundCornerConfiguration NS_REFINED_FOR_SWIFT API_AVAILABLE(ios(26.0));
#endif

/// The shadow displayed underneath the bar floating background.
///
/// Starting with iOS 26.0, when a glass effect is used for the popup bar, setting a bar background shadow has no effect. Instead, the glass shadow is used.
@property (nonatomic, copy, nullable) NSShadow* floatingBarBackgroundShadow;

/// Enables outer shine on a floating popup bar.
///
/// Defaults to `false`.
///
/// Shine is only supported on iOS 26.0 and later.
@property (nonatomic, assign, getter=isFloatingBarShineEnabled) BOOL floatingBarShineEnabled;

/// Reset floating background and shadow properties to their defaults.
- (void)configureWithDefaultFloatingBackground;

/// Reset floating background and shadow properties to display theme-appropriate opaque colors.
- (void)configureWithOpaqueFloatingBackground;

/// Reset floating background and shadow properties to be transparent.
- (void)configureWithTransparentFloatingBackground;

@end

NS_ASSUME_NONNULL_END
