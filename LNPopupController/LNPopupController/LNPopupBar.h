//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
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
typedef NS_ENUM(NSUInteger, LNPopupBarStyle) {
	/**
	 * Use the most appropriate style for the current operating system version—uses prominent style for iOS 10 and above, otherwise compact.
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
	 * @note Do not set this style directly. Instead set @c LNPopupBar.customBarViewController and the framework will use this style.
	 */
	LNPopupBarStyleCustom
};

typedef NS_ENUM(NSUInteger, LNPopupBarProgressViewStyle) {
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
 * If @c YES, the popup bar will automatically inherit its style from the bottom docking view.
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
 * Use @c LNBackgroundStyleInherit value to inherit the docking view's bar style if possible.
 */
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle UI_APPEARANCE_SELECTOR;

/**
 * The tint color to apply to the popup bar background.
 */
@property (nullable, nonatomic, strong) UIColor* barTintColor UI_APPEARANCE_SELECTOR;

/**
 * A Boolean value that indicates whether the popup bar is translucent (@c YES) or not (@c NO).
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
 * When enabled, titles and subtitles that are longer than the space available will scroll text over time. By default, this is set to @c false for iOS 10 and above, @c true otherwise.
 */
@property (nonatomic, assign) BOOL marqueeScrollEnabled;

/**
 * When enabled, the title and subtitle marquee scroll will be coordinated, and if either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together. Enabled by default.
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
@protocol LNPopupBarPreviewingDelegate <NSObject>

@required

/**
 * Called when the user performs a peek action on the popup bar.
 *
 * The default implementation returns @c nil and no preview is displayed.
 *
 * @return The view controller whose view you want to provide as the preview (peek), or @c nil to disable preview.
 */
- (nullable UIViewController*)previewingViewControllerForPopupBar:(LNPopupBar*)popupBar LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG);

@optional

/**
 * Called when the user performs a pop action on the popup bar.
 *
 * The default implementation does not commit the view controller.
 */
- (void)popupBar:(LNPopupBar*)popupBar commitPreviewingViewController:(UIViewController*)viewController LN_UNAVAILABLE_API(LN_UNAVAILABLE_PREVIEWING_MSG);

@end

@interface LNPopupBar (Deprecated)

/**
 * The previewing delegate object mediates the presentation of views from the preview (peek) view controller and the commit (pop) view controller. In practice, these two are typically the same view controller. The delegate performs this mediation through your implementation of the methods of the @c LNPopupBarPreviewingDelegate protocol.
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
