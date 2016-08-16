//
//  LNPopupBar+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar.h"

extern const CGFloat LNPopupBarHeightCompact;
extern const CGFloat LNPopupBarHeightProminent;

extern CGFloat _LNPopupBarHeightForBarStyle(LNPopupBarStyle style);
extern LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style);


@protocol _LNPopupBarSupport <NSObject>

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, retain) UIColor* barTintColor;

@end

@interface LNPopupBar ()

@property (nonatomic, assign) UIBarStyle systemBarStyle;
@property (nonatomic, strong) UIColor* systemTintColor;
@property (nonatomic, strong) UIColor* systemBarTintColor;
@property (nonatomic, strong) UIColor* systemBackgroundColor;

@property(nonatomic, weak, readwrite) LNPopupItem* popupItem;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, strong) UIToolbar* toolbar;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted;

@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, copy) NSString* accessibilityCenterLabel;
@property (nonatomic, copy) NSString* accessibilityCenterHint;
@property (nonatomic, copy) NSString* accessibilityProgressLabel;
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* leftBarButtonItems;
@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* rightBarButtonItems;

- (void)_delayBarButtonLayout;
- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_removeAnimationFromBarItems;

@end
