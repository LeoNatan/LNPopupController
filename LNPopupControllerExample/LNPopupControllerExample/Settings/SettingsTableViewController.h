//
//  SettingsTableViewController.h
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const PopupSettingsBarStyle;
extern NSString* const PopupSettingsInteractionStyle;
extern NSString* const PopupSettingsProgressViewStyle;
extern NSString* const PopupSettingsCloseButtonStyle;
extern NSString* const PopupSettingsMarqueeStyle;
extern NSString* const PopupSettingsEnableCustomizations;
extern NSString* const PopupSettingsExtendBar;
extern NSString* const PopupSettingsHidesBottomBarWhenPushed;
extern NSString* const PopupSettingsVisualEffectViewBlurEffect;
extern NSString* const PopupSettingsTouchVisualizerEnabled;
extern NSString* const PopupSettingsCustomBarEverywhereEnabled;
extern NSString* const PopupSettingsContextMenuEnabled;

@interface SettingsTableViewController : UITableViewController

+ (instancetype)newSettingsTableViewController;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
