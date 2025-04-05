//
//  _LNPopupBarAppearanceLegacySupport.h
//  LNPopupController
//
//  Created by Leo Natan on 09/01/2024.
//  Copyright © 2024 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupBarAppearanceLegacySupport : NSObject

/// A specific blur effect to use for the bar background. This effect is composited first when constructing the bar's background.
@property (nonatomic, readwrite, copy, nullable) UIBlurEffect *backgroundEffect;
/// A color to use for the bar background. This color is composited over backgroundEffects.
@property (nonatomic, readwrite, copy, nullable) UIColor *backgroundColor;
/// An image to use for the bar background. This image is composited over the backgroundColor, and resized per the backgroundImageContentMode.
@property (nonatomic, readwrite, strong, nullable) UIImage *backgroundImage;
/// The content mode to use when rendering the backgroundImage. Defaults to UIViewContentModeScaleToFill. UIViewContentModeRedraw will be reinterpreted as UIViewContentModeScaleToFill.
@property (nonatomic, readwrite, assign) UIViewContentMode backgroundImageContentMode;

/// A color to use for the shadow. Its specific behavior depends on the value of shadowImage. If shadowImage is nil, then the shadowColor is used to color the bar's default shadow; a nil or clearColor shadowColor will result in no shadow. If shadowImage is a template image, then the shadowColor is used to tint the image; a nil or clearColor shadowColor will also result in no shadow. If the shadowImage is not a template image, then it will be rendered regardless of the value of shadowColor.
@property (nonatomic, readwrite, copy, nullable) UIColor *shadowColor;
/// Use an image for the shadow. See shadowColor for how they interact.
@property (nonatomic, readwrite, strong, nullable) UIImage *shadowImage;

/// Display attributes for the popup bar’s title text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* titleTextAttributes NS_REFINED_FOR_SWIFT;

/// Display attributes for the popup bar’s subtitle text.
///
/// You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* subtitleTextAttributes NS_REFINED_FOR_SWIFT;

/// The appearance for plain-style bar button items.
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* buttonAppearance API_AVAILABLE(ios(13.0));

/// The appearance for done-style bar button items.
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* doneButtonAppearance API_AVAILABLE(ios(13.0));

/// The color to apply for the bar's highlight.
@property (nonatomic, copy) UIColor* highlightColor;

/// Configures the popup bar with the default highlight color.
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

/// A specific blur effect to use for the bar floating background. This effect is composited first when constructing the bar's floating background.
@property (nonatomic, copy, nullable) UIBlurEffect* floatingBackgroundEffect;

/// A color to use for the bar floating background. This color is composited over `floatingBackgroundEffect`.
@property (nonatomic, copy, nullable) UIColor* floatingBackgroundColor;

/// An image to use for the bar floating background. This image is composited over the `floatingBackgroundColor`, and resized per the `floatingBackgroundImageContentMode`.
@property (nonatomic, strong, nullable) UIImage* floatingBackgroundImage;

/// The content mode to use when rendering the `floatingBackgroundImage`. Defaults to `UIViewContentModeScaleToFill`. `UIViewContentModeRedraw` will be reinterpreted as `UIViewContentModeScaleToFill`.
@property (nonatomic, assign) UIViewContentMode floatingBackgroundImageContentMode;

/// The shadow displayed underneath the bar floating background.
@property (nonatomic, copy, nullable) NSShadow* floatingBarBackgroundShadow;

/// Reset floating background and shadow properties to their defaults.
- (void)configureWithDefaultFloatingBackground;

- (UIBlurEffect *)floatingBackgroundEffectForTraitCollection:(UITraitCollection*)traitCollection;

@end

NS_ASSUME_NONNULL_END
