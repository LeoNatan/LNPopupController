//
//  LNPopupBar+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBar.h>
#import "LNPopupBarAppearanceChainProxy.h"
#import "LNPopupBarAppearance+Private.h"
#import "_LNPopupBarBackgroundView.h"

extern const CGFloat LNPopupBarHeightCompact;
extern const CGFloat LNPopupBarHeightProminent;
extern const CGFloat LNPopupBarHeightFloating;

inline __attribute__((always_inline)) CGFloat _LNPopupBarHeightForBarStyle(LNPopupBarStyle style, LNPopupCustomBarViewController* customBarVC)
{
	if(customBarVC) { return customBarVC.preferredContentSize.height; }
	
	switch(style)
	{
		case LNPopupBarStyleCompact:
			return LNPopupBarHeightCompact;
		case LNPopupBarStyleFloating:
			return LNPopupBarHeightFloating;
		default:
			return LNPopupBarHeightProminent;
	}
}

inline __attribute__((always_inline)) LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style)
{
	LNPopupBarStyle rv = style;
	if(rv == LNPopupBarStyleDefault)
	{
		if(@available(iOS 17, *)) {
			rv = LNPopupBarStyleFloating;
		}
		else
		{
			rv = LNPopupBarStyleProminent;
		}
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
@property (nonatomic, strong) UIBarAppearance* standardAppearance;

@end

@interface LNPopupBar () <UIPointerInteractionDelegate, _LNPopupBarAppearanceDelegate>

+ (void)setAnimatesItemSetter:(BOOL)animate;

@property (nonatomic, assign, readonly) LNPopupBarStyle resolvedStyle;

@property (nonatomic, strong) UIColor* systemTintColor;
@property (nonatomic, strong) UIColor* systemBackgroundColor;
@property (nonatomic, strong) UIBarAppearance* systemAppearance;
@property (nonatomic, readonly, strong) LNPopupBarAppearance* activeAppearance;
@property (nonatomic, readonly, strong) LNPopupBarAppearanceChainProxy* activeAppearanceChain;

- (void)_recalcActiveAppearanceChain;

@property (nonatomic, strong) UIView* shadowView;
@property (nonatomic, strong) UIView* bottomShadowView;

@property (nonatomic, weak, readwrite) LNPopupItem* popupItem;

@property (nonatomic, weak) id<_LNPopupBarDelegate> _barDelegate;

@property (nonatomic, copy) NSAttributedString* attributedTitle;
@property (nonatomic, copy) NSAttributedString* attributedSubtitle;

@property (nonatomic, strong) UIViewController* swiftuiTitleController;
@property (nonatomic, strong) UIViewController* swiftuiSubtitleController;

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIViewController* swiftuiImageController;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@property (nonatomic, strong, readwrite) UIProgressView* progressView;

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) _LNPopupBarBackgroundView* backgroundView;

@property (nonatomic, strong) _LNPopupBarBackgroundView* floatingBackgroundView;

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
- (void)_cancelGestureRecognizers;

@property (nonatomic) BOOL acceptsSizing;

@property (nonatomic) BOOL _applySwiftUILayoutFixes;

@property (nonatomic, strong) UIViewController* swiftuiHiddenLeadingController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenTrailingController;

- (void)_delayBarButtonLayout;
- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

- (void)_cancelAnyUserInteraction;

@end
