//
//  LNPopupBarAppearance.h
//  LNPopupController
//
//  Created by Leo Natan on 6/9/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef NS_SWIFT_UI_ACTOR
#define NS_SWIFT_UI_ACTOR
#endif

API_AVAILABLE(ios(13.0)) NS_SWIFT_UI_ACTOR
@interface LNPopupBarAppearance : UIBarAppearance

/**
 * Display attributes for the popup bar’s title text.
 *
 * You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in @c NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* titleTextAttributes;

/**
 * Display attributes for the popup bar’s subtitle text.
 *
 * You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in @c NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* subtitleTextAttributes;

/**
 * The appearance for plain-style bar button items.
 */
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* buttonAppearance;

/**
 * The color to apply for the bar's highlight.
 */
@property (nonatomic, copy) UIColor* highlightColor;

/**
 * The appearance for done-style bar button items.
 */
@property (nonatomic, readwrite, copy) UIBarButtonItemAppearance* doneButtonAppearance;

/**
 * When enabled, titles and subtitles that are longer than the space available will scroll text over time.
 *
 * Defaults to @c false
 */
@property (nonatomic, assign) BOOL marqueeScrollEnabled;

/**
 * The scroll rate, in points, of the title and subtitle marquee animation.
 *
 * Defaults to @c 30
 */
@property (nonatomic, assign) CGFloat marqueeScrollRate;

/**
 * The delay, in seconds, before starting the title and subtitle marquee animation.
 *
 * Defaults to @c 2
 */
@property (nonatomic, assign) NSTimeInterval marqueeScrollDelay;

/**
 * When enabled, the title and subtitle marquee scroll animations will be coordinated.
 *
 * If either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together.
 *
 * Defaults to @c true
 */
@property (nonatomic, assign) BOOL coordinateMarqueeScroll;

/**
 * Configures the popup bar with marquee scroll enabled and sets the default marquee scroll configuration values.
 */
- (void)configureWithDefaultMarqueeScroll;
/**
 * Configures the popup bar with marquee scroll disabled.
 */
- (void)configureWithDisabledMarqueeScroll;
/**
 * Configures the popup bar with the default highlight color.
 */
- (void)configureWithDefaultHighlightColor;

@end

NS_ASSUME_NONNULL_END
