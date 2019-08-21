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

inline __attribute__((always_inline)) CGFloat _LNPopupBarHeightForBarStyle(LNPopupBarStyle style, LNPopupCustomBarViewController* customBarVC)
{
	if(customBarVC) { return customBarVC.preferredContentSize.height; }
	
	return style == LNPopupBarStyleCompact ? LNPopupBarHeightCompact : LNPopupBarHeightProminent;
}

inline __attribute__((always_inline)) LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style)
{
	LNPopupBarStyle rv = style;
	if(rv == LNPopupBarStyleDefault)
	{
		rv = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9 ? LNPopupBarStyleProminent : LNPopupBarStyleCompact;
	}
	return rv;
}

@protocol _LNPopupBarDelegate <NSObject>

- (void)_traitCollectionForPopupBarDidChange:(LNPopupBar*)bar;
- (void)_popupBarStyleDidChange:(LNPopupBar*)bar;

@end

@protocol _LNPopupBarSupport <NSObject>

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, retain) UIColor* barTintColor;
@property(nonatomic, assign, getter=isTranslucent) BOOL translucent;

@end

@interface LNPopupBar ()

@property (nonatomic, assign) UIBarStyle systemBarStyle;
@property (nonatomic, strong) UIColor* systemTintColor;
@property (nonatomic, strong) UIColor* systemBarTintColor;
@property (nonatomic, strong) UIColor* systemBackgroundColor;
@property (nonatomic, strong) UIColor* systemShadowColor;

@property (nonatomic, weak, readwrite) LNPopupItem* popupItem;

@property (nonatomic, weak) id<_LNPopupBarDelegate> _barDelegate;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) UIToolbar* toolbar;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, strong) UIVisualEffectView* backgroundView;

@property (nonatomic, copy) NSString* accessibilityCenterLabel;
@property (nonatomic, copy) NSString* accessibilityCenterHint;
@property (nonatomic, copy) NSString* accessibilityImageLabel;
@property (nonatomic, copy) NSString* accessibilityProgressLabel;
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* leftBarButtonItems;
@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* rightBarButtonItems;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer* popupOpenGestureRecognizer;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer* barHighlightGestureRecognizer;


- (void)_delayBarButtonLayout;
- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_removeAnimationFromBarItems;

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end
