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

extern const NSInteger LNBarStyleInherit;

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
 *  A Boolean value indicating whether the popup bar is translucent (YES) or not (NO).
 */
@property (nonatomic, assign, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;
/**
 *  The popup bar style that specifies its appearance. 
 *  Use LNBarStyleInherit value to inherit the docking view's bar style if possible.
 */
@property (nonatomic, assign) UIBarStyle barStyle UI_APPEARANCE_SELECTOR;
/**
 *  The tint color to apply to the popup bar background.
 */
@property (nullable, nonatomic, strong) UIColor* barTintColor UI_APPEARANCE_SELECTOR;
/**
 *  The background image to use
 */
@property (nullable, nonatomic, strong) UIImage* backgroundImage UI_APPEARANCE_SELECTOR;
/**
 *  The shadow image to be used for the popup bar.
 *
 *  The default value is nil, which corresponds to the default shadow image. When non-nil, this property represents a custom shadow image to show instead of the default. For a custom shadow image to be shown, a custom background image must also be set with the setBackgroundImage: method. If the default background image is used, then the default shadow image will be used regardless of the value of this property.
 */
@property(nullable, nonatomic, strong) UIImage* shadowImage UI_APPEARANCE_SELECTOR;
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

@end

NS_ASSUME_NONNULL_END
