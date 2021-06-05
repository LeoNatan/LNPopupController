//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupItem.h>
#import <LNPopupController/LNPopupCustomBarViewController.h>

#define LN_UNAVAILABLE_API(x) __attribute__((unavailable(x)))
#define LN_UNAVAILABLE_PREVIEWING_MSG "Add context menu interaction or register for previewing directly on the popup bar view."

#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))

NS_ASSUME_NONNULL_BEGIN

extern const UIBlurEffectStyle LNBackgroundStyleInherit;

/**
 * Available styles for the popup bar 
 */
typedef NS_ENUM(NSInteger, LNPopupBarStyle) {
	/**
	 * The default bar style for the current environment
	 */
	LNPopupBarStyleDefault,
	
	/**
	 * Compact bar style
	 */
	LNPopupBarStyleCompact,
	/**
	 * Prominent bar style
	 */
	LNPopupBarStyleProminent,
	/**
	 * Custom bar style
	 *
	 * @note Do not set this style directly. Instead, set @c LNPopupBar.customBarViewController and the framework will use this style.
	 */
	LNPopupBarStyleCustom
};

typedef NS_ENUM(NSInteger, LNPopupBarProgressViewStyle) {
	/**
	 * Use the most appropriate style for the current operating system version—uses none for iOS 10 and above, otherwise bottom.
	 */
	LNPopupBarProgressViewStyleDefault,
	
	/**
	 * Progress view on bottom
	 */
	LNPopupBarProgressViewStyleBottom,
    /**
     * Progress view on bottom
     */
    LNPopupBarProgressViewStyleTop,
	/**
	 * No progress view
	 */
	LNPopupBarProgressViewStyleNone
};

/**
 * A popup bar is a control that displays popup information. Content is popuplated from @c LNPopupItem items.
 */
@interface LNPopupBar : UIView <UIAppearanceContainer>

/**
 * If @c true, the popup bar will automatically inherit its style from the bottom docking view.
 */
@property (nonatomic, assign) BOOL inheritsVisualStyleFromDockingView UI_APPEARANCE_SELECTOR;

/**
 * The currently displayed popup item. (read-only)
 */
@property (nullable, nonatomic, weak, readonly) LNPopupItem* popupItem;

/**
 * An array of custom bar button items. (read-only)
 *
 * @note For compact popup bars, this property is equivalent to @c trailingBarButtonItems.
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* barButtonItems;

/**
 * An array of custom bar button items to display on the left side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leadingBarButtonItems;

/**
 * An array of custom bar button items to display on the right side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* trailingBarButtonItems;

/**
 * An image view displayed when the bar style is prominent. (read-only)
 */
@property (nonatomic, strong, readonly) UIImageView* imageView;

/**
 * The popup bar style.
 */
@property (nonatomic, assign) LNPopupBarStyle barStyle UI_APPEARANCE_SELECTOR;

/**
 * The popup bar's progress style.
 */
@property (nonatomic, assign) LNPopupBarProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR;

/**
* The progress view displayed on the popup bar.
*/
@property (nonatomic, strong, readonly) UIProgressView* progressView;

/**
 * The popup bar background style that specifies its appearance.
 *
 * Use @c LNBackgroundStyleInherit value to inherit the docking view's bar style if possible, or use a system default.
 *
 * Defaults to @c LNBackgroundStyleInherit.
 */
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle UI_APPEARANCE_SELECTOR;

/**
 * The tint color to apply to the popup bar background.
 */
@property (nullable, nonatomic, strong) UIColor* barTintColor UI_APPEARANCE_SELECTOR;

/**
 * A Boolean value that indicates whether the popup bar is translucent (@c true) or not (@c false).
 */
@property(nonatomic, assign, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;

/**
 * Display attributes for the popup bar’s title text.
 *
 * You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in @c NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* titleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 * Display attributes for the popup bar’s subtitle text.
 *
 * You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in @c NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id>* subtitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 * A semantic description of the bar items, used to determine the order of bar items when switching between left-to-right and right-to-left layouts.
 *
 * Defaults to @c UISemanticContentAttributePlayback
 *
 * See also @c UIView.semanticContentAttribute
 */
@property (nonatomic) UISemanticContentAttribute barItemsSemanticContentAttribute;

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
 * The gesture recognizer responsible for opening the popup when the user taps on the popup bar. (read-only)
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer* popupOpenGestureRecognizer;

/**
 * The gesture recognizer responsible for highlighting the popup bar when the user touches on the popup bar. (read-only)
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer* barHighlightGestureRecognizer;

/**
 * Set this property to an @c LNPopupCustomBarViewController subclass object to provide a popup bar with custom content controller.
 */
@property (nullable, nonatomic, strong) __kindof LNPopupCustomBarViewController* customBarViewController;

@end

#pragma mark Deprecatations

#if ! TARGET_OS_MACCATALYST
LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG)
/// This no longer has any effect. Add context menu interaction or register for previewing directly on the popup bar view.
@protocol LNPopupBarPreviewingDelegate <NSObject>

@required

- (nullable UIViewController*)previewingViewControllerForPopupBar:(LNPopupBar*)popupBar LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG);

@optional

- (void)popupBar:(LNPopupBar*)popupBar commitPreviewingViewController:(UIViewController*)viewController LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG);

@end

@interface LNPopupBar (Deprecated)

/**
 * This no longer has any effect. Add context menu interaction or register for previewing directly on the popup bar view.
 */
@property (nullable, nonatomic, weak) id<LNPopupBarPreviewingDelegate> previewingDelegate LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG);

/**
 * An array of custom bar button items to display on the left side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leftBarButtonItems LN_DEPRECATED_API("Use leadingBarButtonItems instead.");

/**
 * An array of custom bar button items to display on the right side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* rightBarButtonItems LN_DEPRECATED_API("Use barButtonItems or trailingBarButtonItems instead.");

@end
#endif

NS_ASSUME_NONNULL_END
