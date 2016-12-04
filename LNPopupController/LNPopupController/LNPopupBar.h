//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupItem.h>

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
	LNPopupBarStyleProminent
};

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
@property(nullable, nonatomic, copy) NSDictionary<NSString*, id>* titleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 *  Display attributes for the popup bar’s subtitle text.
 *
 *  You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in NSAttributedString.h.
 */
@property(nullable, nonatomic, copy) NSDictionary<NSString*, id>* subtitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 * When enabled, titles and subtitles that are longer than the space available will scroll text over time. By default, this is set to @c false for iOS 10 and above, or @c true otherwise.
 */
@property(nonatomic, assign) BOOL marqueeScrollEnabled;

/**
 * When enabled, the title and subtitle marquee scroll will be coordinated, and if either the title or subtitle of the current popup item change, the animation will reset so the two can scroll together. Enabled by default.
 */
@property(nonatomic, assign) BOOL coordinateMarqueeScroll;

@end

NS_ASSUME_NONNULL_END
