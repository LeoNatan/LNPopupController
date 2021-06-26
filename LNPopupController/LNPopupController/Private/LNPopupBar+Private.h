//
//  LNPopupBar+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBar.h>
#import "LNPopupBarAppearance+Private.h"
#import "_LNPopupBarBackgroundView.h"

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
		rv = LNPopupBarStyleProminent;
	}
	return rv;
}

@protocol _LNPopupBarDelegate <NSObject>

- (void)_traitCollectionForPopupBarDidChange:(LNPopupBar*)bar;
- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar;
- (void)_popupBarStyleDidChange:(LNPopupBar*)bar;
- (void)_popupBar:(LNPopupBar*)bar updateCustomBarController:(LNPopupCustomBarViewController*)customController cleanup:(BOOL)cleanup;
- (void)_removeInteractionGestureForPopupBar:(LNPopupBar*)bar;

@end

@protocol _LNPopupBarSupport <NSObject>

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIBarAppearance* standardAppearance API_AVAILABLE(ios(13.0));

@end

@interface LNPopupBar () <UIPointerInteractionDelegate, _LNPopupBarAppearanceDelegate>

@property (nonatomic, strong) UIColor* systemTintColor;
@property (nonatomic, strong) UIColor* systemBackgroundColor;
@property (nonatomic, strong) UIBarAppearance* systemAppearance;
@property (nonatomic, readonly, strong) _LNPopupBarAppearanceChainProxy* activeAppearanceChain;

- (void)_recalcActiveAppearanceChain;

@property (nonatomic, strong) UIView* bottomShadowView;

@property (nonatomic, weak, readwrite) LNPopupItem* popupItem;

@property (nonatomic, weak) id<_LNPopupBarDelegate> _barDelegate;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIViewController* swiftuiImageController;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@property (nonatomic, strong, readwrite) UIProgressView* progressView;

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) _LNPopupBarBackgroundView* backgroundView;
@property (nonatomic, strong) UIVisualEffectView* interactionBackgroundView;

@property (nonatomic, strong) NSString* effectGroupingIdentifier;
- (void)_applyGroupingIdentifierToVisualEffectView:(UIVisualEffectView*)visualEffectView;

@property (nonatomic, copy) NSString* accessibilityCenterLabel;
@property (nonatomic, copy) NSString* accessibilityCenterHint;
@property (nonatomic, copy) NSString* accessibilityImageLabel;
@property (nonatomic, copy) NSString* accessibilityProgressLabel;
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* leadingBarButtonItems;
@property (nonatomic, copy, readwrite) NSArray<UIBarButtonItem*>* trailingBarButtonItems;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer* popupOpenGestureRecognizer;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer* barHighlightGestureRecognizer;

@property (nonatomic) BOOL _applySwiftUILayoutFixes;

- (void)_delayBarButtonLayout;
- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_removeAnimationFromBarItems;

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

- (void)_cancelAnyUserInteraction;

@end
