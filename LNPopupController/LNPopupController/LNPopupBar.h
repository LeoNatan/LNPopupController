//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupItem.h>
#import <LNPOpupController/LNPopupCustomBarViewController.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger LNBackgroundStyleInherit;

/**
 * Available styles for the popup bar 
 */
typedef NS_ENUM(NSUInteger, LNPopupBarStyle) {
	/**
	 * Use the most appropriate style for the current operating system version; uses prominent style for iOS 10 and above, otherwise compact.
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
	 * Do not set this style directly. Instead set LNPopupBar.customBarViewController and the framework will use this style.
	 */
	LNPopupBarStyleCustom
};

typedef NS_ENUM(NSUInteger, LNPopupBarProgressStyle) {
    /**
     * progress view will on the bottom of bar
     */
    LNPopupBarProgressStyleBottom,
    /**
     * progress view will on the top of bar.
     */
    LNPopupBarProgressStyleTop,
    
    
};

@protocol LNPopupBarPreviewingDelegate <NSObject>

@required

/**
 *  Called when the user performs a peek action on the popup bar.
 *
 *  The default implementation returns nil, thus no preview is displayed.
 *
 *  @return The view controller whose view you want to provide as the preview (peek), or nil to disable preview.
 */
- (nullable UIViewController*)previewingViewControllerForPopupBar:(LNPopupBar*)popupBar;

@optional

/**
 *  Called when the user performs a pop action on the popup bar.
 *
 *  The default implementation does not commit the view controller.
 */
- (void)popupBar:(LNPopupBar*)popupBar commitPreviewingViewController:(UIViewController*)viewController;

@end

/**
 *  A popup bar is a control that displays popup information. Content is popuplated from LNPopupItem items.
 */
@interface LNPopupBar : UIView <UIAppearanceContainer>

/**
 *  The currently displayed popup item. (read-only)
 */
@property(nullable, nonatomic, weak, readonly) LNPopupItem* popupItem;

/**
 *  An array of custom bar button items to display on the left side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* leftBarButtonItems;

/**
 *  An array of custom bar button items to display on the right side. (read-only)
 */
@property (nullable, nonatomic, copy, readonly) NSArray<UIBarButtonItem*>* rightBarButtonItems;

/**
 *  The popup bar style.
 */
@property (nonatomic, assign) LNPopupBarStyle barStyle UI_APPEARANCE_SELECTOR;

/**
 *  The popup bar's progress style.
 */
@property (nonatomic, assign) LNPopupBarProgressStyle progressStyle;

/**
 *  The popup bar background style that specifies its appearance.
 *  Use LNBackgroundStyleInherit value to inherit the docking view's bar style if possible.
 */
@property (nonatomic, assign) UIBlurEffectStyle backgroundStyle UI_APPEARANCE_SELECTOR;

/**
 *  The tint color to apply to the popup bar background.
 */
@property (nullable, nonatomic, strong) UIColor* barTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Display attributes for the popup bar’s title text.
 *
 *  You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString*, id>* titleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 *  Display attributes for the popup bar’s subtitle text.
 *
 *  You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in NSAttributedString.h.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString*, id>* subtitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 * When enabled, titles and subtitles that are longer than the space available will scroll text over time. By default, this is set to @c false for iOS 10 and above, or @c true otherwise.
 */
@property (nonatomic, assign) BOOL marqueeScrollEnabled;

/**
 * When enabled, the title and subtitle marquee scroll will be coordinated, and if either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together. Enabled by default.
 */
@property (nonatomic, assign) BOOL coordinateMarqueeScroll;

/**
 *  The gesture recognizer responsible for opening the popup when the user taps on the popup bar. (read-only)
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer* popupOpenGestureRecognizer;

/**
 *  The gesture recognizer responsible for highlighting the popup bar when the user touches on the popup bar. (read-only)
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer* barHighlightGestureRecognizer;

/**
 * The previowing delegate object mediates the presentation of views from the preview (peek) view controller and the commit (pop) view controller. In practice, these two are typically the same view controller. The delegate performs this mediation through your implementation of the methods of the LNPopupBarPreviewingDelegate protocol.
 */
@property (nullable, nonatomic, weak) id<LNPopupBarPreviewingDelegate> previewingDelegate;

/**
 * Set this property with an LNPopupCustomBarViewController subclass object to provide a popup bar with custom content.
 */
@property (nullable, nonatomic, strong) LNPopupCustomBarViewController* customBarViewController;

@end

NS_ASSUME_NONNULL_END
