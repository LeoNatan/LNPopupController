//
//  LNPopupBar+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBar.h>
#import "LNPopupBarAppearanceChainProxy.h"
#import "LNPopupBarAppearance+Private.h"
#import "_LNPopupBarBackgroundView.h"
#import "_LNPopupBackgroundShadowView.h"
#import "_LNPopupBarBackgroundMaskView.h"
#import "_LNPopupGlassUtils.h"
#import "_LNPopupTransitionView.h"

#import "MarqueeLabel.h"
#if __has_include(<LNSystemMarqueeLabel.h>)
#import <LNSystemMarqueeLabel.h>
#endif

CF_EXTERN_C_BEGIN

#ifdef DEBUG
extern BOOL _LNEnableBarLayoutDebug(void);
#endif

#if __has_include(<LNSystemMarqueeLabel.h>)
extern BOOL __LNPopupUseSystemMarqueeLabel(void);
#endif

extern const CGFloat LNPopupBarHeightCompact;
extern const CGFloat LNPopupBarHeightProminent;
extern const CGFloat LNPopupBarHeightFloating;

extern CGFloat _LNPopupBarHeightForPopupBar(LNPopupBar* popupBar);

extern LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style, BOOL* isFloating, BOOL* isCompact, BOOL* isCustom);

@protocol _LNPopupBarDelegate <NSObject>

- (void)_traitCollectionForPopupBarDidChange:(LNPopupBar*)bar;
- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar;
- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar shouldLayout:(BOOL)layout;
- (void)_popupBarStyleDidChange:(LNPopupBar*)bar;
- (void)_popupBar:(LNPopupBar*)bar updateCustomBarController:(LNPopupCustomBarViewController*)customController cleanup:(BOOL)cleanup;
- (void)_removeInteractionGestureForPopupBar:(LNPopupBar*)bar;

- (void)_popupBar:(LNPopupBar*)bar setUserPopupItem:(LNPopupItem*)newItem;
- (void)_popupBar:(LNPopupBar*)bar setPagedPopupItem:(LNPopupItem*)newItem;
- (void)_generatePagingFeedbackForPopupBar:(LNPopupBar*)bar;

@end

@protocol _LNPopupBarSupport <NSObject>

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIBarAppearance* standardAppearance;

@end

@interface _LNPopupBarContentView : _LNPopupBarBackgroundView

@property (nonatomic, assign, getter=isShiny) BOOL shiny;

@end

@class _LNPopupToolbar;

@interface LNPopupBar () <UIPointerInteractionDelegate, _LNPopupBarAppearanceDelegate>

+ (void)setAnimatesItemSetter:(BOOL)animate;

@property (nonatomic, assign, readonly) LNPopupBarStyle resolvedStyle;
@property (nonatomic, assign, readonly) BOOL resolvedIsFloating;
@property (nonatomic, assign, readonly) BOOL resolvedIsCompact;
@property (nonatomic, assign, readonly) BOOL resolvedIsCustom;
@property (nonatomic, assign, readonly) BOOL resolvedIsFloatingCustom;
@property (nonatomic, assign, readonly) BOOL resolvedIsGlass;
@property (nonatomic, assign, readonly) BOOL resolvedIsGlassInteractive;

@property (nonatomic, strong) UIColor* systemTintColor;
@property (nonatomic, strong) UIColor* systemBackgroundColor;
@property (nonatomic, strong) UIBarAppearance* systemAppearance;
@property (nonatomic, readonly, strong) LNPopupBarAppearance* activeAppearance;
@property (nonatomic, readonly, strong) LNPopupBarAppearanceChainProxy* activeAppearanceChain;

- (void)_setNeedsRecalcActiveAppearanceChain;

@property (nonatomic, strong) _LNPopupToolbar* toolbar;

@property (nonatomic, strong) UIImageView* shadowView;
@property (nonatomic, strong) UIImageView* bottomShadowView;

- (void)_setPopupItem:(LNPopupItem*)popupItem;

@property (nonatomic, weak) __kindof UIViewController* barContainingController;
@property (nonatomic, weak) id<_LNPopupBarDelegate> _barDelegate;

@property (nonatomic, copy) NSAttributedString* attributedTitle;
@property (nonatomic, copy) NSAttributedString* attributedSubtitle;

@property (nonatomic, readonly) NSDirectionalEdgeInsets floatingLayoutMargins;
@property (nonatomic, setter=_setHackyMargins:) NSDirectionalEdgeInsets _hackyMargins;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) UIView* highlightView;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@property (nonatomic, strong, readwrite) UIProgressView* progressView;

@property (nonatomic, strong) UIView* layoutContainer;
@property (nonatomic, strong) _LNPopupBarContentView* contentView;
@property (nonatomic, strong) UIView* contentMaskView;

@property (nonatomic, strong) _LNPopupBarBackgroundView* backgroundView;
@property (nonatomic, strong) UIView* backgroundMaskView;
@property (nonatomic) BOOL wantsBackgroundCutout;
- (void)setWantsBackgroundCutout:(BOOL)wantsBackgroundCutout allowImplicitAnimations:(BOOL)allowImplicitAnimations;
@property (nonatomic, strong) _LNPopupBarBackgroundMaskView* backgroundGradientMaskView;

@property (nonatomic, strong) _LNPopupBackgroundShadowView* floatingBackgroundShadowView;

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

@property (nonatomic, strong) UIFont* swiftuiInheritedFont;

@property (nonatomic, strong) UIView* swiftuiTitleContentView;
@property (nonatomic, strong) UIViewController* swiftuiTitleContentViewController;

@property (nonatomic, strong) UIViewController* swiftuiImageController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenLeadingController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenTrailingController;

- (void)_layoutBarButtonItems;

- (void)_setTitleViewMarqueesPaused:(BOOL)paused;

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

- (void)_cancelAnyUserInteraction;

+ (BOOL)isCatalystApp;
- (BOOL)isWidePad;

@property (nonatomic, strong) _LNPopupTransitionView* os26TransitionView;

@property (nonatomic) CGRect backgroundViewFrameDuringAnimation;

@end

@interface _LNTransitionPopupBar: LNPopupBar @end

@protocol _LNPopupToolbarLayoutDelegate <NSObject>

- (void)_toolbarDidLayoutSubviews;

@end

@interface LNPopupBar () <_LNPopupToolbarLayoutDelegate>

- (void)_windowWillRotate:(NSNotification*)note;
- (void)_windowDidRotate:(NSNotification*)note;
- (UIFont*)_titleFont;
- (UIColor*)_titleColor;
- (UIFont*)_subtitleFont;
- (UIColor*)_subtitleColor;

@end

@interface _LNPopupToolbar : UIToolbar

@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic, weak) id<_LNPopupToolbarLayoutDelegate> _layoutDelegate;

- (void)forceLayoutOnButtons;

@end

@interface _LNPopupBarShadowView : UIImageView @end

@protocol LNMarqueeLabel <NSObject>

@property (nonatomic, getter=isMarqueeScrollEnabled) BOOL marqueeScrollEnabled;
@property (nonatomic, getter=isRunning) BOOL running;

@property (nonatomic, copy) NSArray<id<LNMarqueeLabel>>* synchronizedLabels;

- (void)reset;

@end

@interface LNNonMarqueeLabel : UILabel <LNMarqueeLabel> @end
@interface LNLegacyMarqueeLabel: LNMarqueeLabel <LNMarqueeLabel> @end
#if __has_include(<LNSystemMarqueeLabel.h>)
@interface LNSystemMarqueeLabel () <LNMarqueeLabel> @end
#endif

@interface _LNPopupBottomBarSupport : UIView @end

@interface _LNPopupBarExtensionView : _LNPopupBarBackgroundView @end

//@interface _LNPopupBarGlassGroupBackground : NSObject <UIObjectTraitDefinition> @end

CF_EXTERN_C_END
