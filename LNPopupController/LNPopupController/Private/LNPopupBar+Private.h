//
//  LNPopupBar+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar.h"

extern const CGFloat LNPopupBarHeight;

@protocol _LNPopupBarSupport <NSObject>

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, retain) UIColor* barTintColor;

@end

@interface LNPopupBar ()

@property (nonatomic, strong) UIToolbar* toolbar;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted;

@property (nonatomic, strong) UIProgressView* progressView;

- (void)_delayBarButtonLayout;
- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_removeAnimationFromBarItems;

@end
