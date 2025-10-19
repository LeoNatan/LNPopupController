//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "LNPopupCustomBarViewController+Private.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "NSAttributedString+LNPopupSupport.h"
#import "LNPopupImageView+Private.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "_LNPopupGlassUtils.h"
#import "_LNPopupTitlesController.h"
#import "_LNPopupTitlesPagingController.h"
#if __has_include(<LNSystemMarqueeLabel.h>)
#import <LNSystemMarqueeLabel.h>
#endif

const CGFloat LNPopupBarHeightCompact = 40.0;
const CGFloat LNPopupBarHeightProminent = 64.0;
const CGFloat LNPopupBarHeightFloating = 58.0;
const CGFloat LNPopupBarHeightFloatingCompact = 48.0;
const CGFloat LNPopupBarFloatingPadImageWidth = 44.0;
const CGFloat LNPopupBarFloatingPadWidthLimitLegacy = 954.0;
const CGFloat LNPopupBarFloatingPadWidthLimitModern = 700;

#ifdef DEBUG
#import "LNPopupDebug.h"

BOOL _LNEnableBarLayoutDebug(void)
{
	return [__LNDebugUserDefaults() boolForKey:@"__LNPopupBarEnableLayoutDebug"];
}
#endif

CGFloat _LNPopupBarHeightForPopupBar(LNPopupBar* popupBar)
{
	if(popupBar.customBarViewController)
	{
		return popupBar.customBarViewController.preferredContentSize.height;
	}
	
	CGFloat additionalHeight = 0;
	static NSDictionary<NSString*, NSNumber*>* additionalHeightMapping = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		additionalHeightMapping = @{
			UIContentSizeCategoryExtraSmall : @0,
			UIContentSizeCategorySmall : @0,
			UIContentSizeCategoryMedium : @0,
			UIContentSizeCategoryLarge : @0,
			UIContentSizeCategoryExtraLarge : @0,
			UIContentSizeCategoryExtraExtraLarge : @0,
			UIContentSizeCategoryExtraExtraExtraLarge : @7,
			UIContentSizeCategoryAccessibilityMedium : @14,
			UIContentSizeCategoryAccessibilityLarge : @21,
			UIContentSizeCategoryAccessibilityExtraLarge : @28,
			UIContentSizeCategoryAccessibilityExtraExtraLarge : @35,
			UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @42,
		};
	});
	additionalHeight = [additionalHeightMapping[popupBar.traitCollection.preferredContentSizeCategory] doubleValue];
	
	if(popupBar.resolvedIsFloating && popupBar.resolvedIsCompact == NO && popupBar.isWidePad)
	{
		additionalHeight += 8;
	}
	
	if(popupBar.resolvedIsFloating && LNPopupEnvironmentHasGlass() == NO)
	{
		additionalHeight += 6;
	}
	
	switch(popupBar.resolvedStyle)
	{
		case LNPopupBarStyleCompact:
			return LNPopupBarHeightCompact + additionalHeight;
		case LNPopupBarStyleProminent:
			return LNPopupBarHeightProminent + additionalHeight;
		case LNPopupBarStyleFloating:
			return LNPopupBarHeightFloating + additionalHeight;
		case LNPopupBarStyleFloatingCompact:
			return LNPopupBarHeightFloatingCompact + additionalHeight;
		default:
			abort();
	}
}

LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style, BOOL* isFloating, BOOL* isCompact, BOOL* isCustom)
{
	//Support the legacy floating style value.
	if(style == (LNPopupBarStyle)3)
	{
		style = LNPopupBarStyleFloating;
	}
	
	if(style == LNPopupBarStyleCustom)
	{
		if(isFloating)
		{
			*isFloating = LNPopupEnvironmentHasGlass();
		}
		if(isCompact)
		{
			*isCompact = NO;
		}
		if(isCustom)
		{
			*isCustom = YES;
		}
		return LNPopupBarStyleCustom;
	}
	
	if(isCustom)
	{
		*isCustom = NO;
	}
	
	LNPopupBarStyle rv = style;
	
	if(LNPopupEnvironmentHasGlass())
	{
		if(isFloating)
		{
			//iOS 26 with glass enabled is always floating.
			*isFloating = YES;
		}
		
		if(rv == LNPopupBarStyleDefault)
		{
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
			{
				rv = LNPopupBarStyleFloatingCompact;
			}
			else
			{
				rv = LNPopupBarStyleFloating;
			}
		}
		
		switch(rv) {
			case LNPopupBarStyleCompact:
			case LNPopupBarStyleFloatingCompact:
				if(isCompact)
				{
					*isCompact = YES;
				}
				return LNPopupBarStyleFloatingCompact;
			case LNPopupBarStyleProminent:
			case LNPopupBarStyleFloating:
				if(isCompact)
				{
					*isCompact = NO;
				}
				return LNPopupBarStyleFloating;
			default:
				abort();
		}
	}
	
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
	
	BOOL isFlt;
	switch(rv)
	{
		case LNPopupBarStyleFloating:
		case LNPopupBarStyleFloatingCompact:
			isFlt = YES;
			break;
		default:
			isFlt = NO;
			break;
	}
	if(isFloating)
	{
		*isFloating = isFlt;
	}
	
	BOOL isCmp;
	switch(rv)
	{
		case LNPopupBarStyleCompact:
		case LNPopupBarStyleFloatingCompact:
			isCmp = YES;
			break;
		default:
			isCmp = NO;
			break;
	}
	if(isCompact)
	{
		*isCompact = isCmp;
	}
	
	return rv;
}

__attribute__((objc_direct_members))
@implementation LNPopupBar
{
	LNPopupImageView* _imageView;
	
	_LNPopupTitlesPagingController* _titlePagingController;
	_LNPopupTitlesController* _titlesController;
	
	BOOL _needsLabelsLayout;
	BOOL _needsLabelsLayoutRemove;
	BOOL _needsAppearanceProxyRefresh;
	BOOL _needsAppearanceUpdate;
	BOOL _needsBarButtonItemLayout;
	
	UIColor* _userTintColor;
	UIColor* _userBackgroundColor;
	
	BOOL _inLayout;
	
	UIWindow* _swiftHacksWindow1;
	UIWindow* _swiftHacksWindow2;
	
	BOOL _animatesItemSetter;
}

static BOOL __animatesItemSetter = NO;
+ (void)setAnimatesItemSetter:(BOOL)animate
{
	__animatesItemSetter = animate;
}

- (LNPopupBarAppearance *)activeAppearance
{
	if(self.activeAppearanceChain.chain.count == 0)
	{
		//Should never visit this code block.
		[self _recalcActiveAppearanceChain];
	}
	
	return (LNPopupBarAppearance*)self.activeAppearanceChain;
}

static inline __attribute__((always_inline)) LNPopupBarProgressViewStyle _LNPopupResolveProgressViewStyleFromProgressViewStyle(LNPopupBarProgressViewStyle style)
{
	LNPopupBarProgressViewStyle rv = style;
	if(rv == LNPopupBarProgressViewStyleDefault)
	{
		rv = LNPopupBarProgressViewStyleNone;
	}
	return rv;
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

- (void)_fixupSwiftUIControllersWithBarStyle
{
	if(self.swiftuiHiddenLeadingController != nil)
	{
		[self.swiftuiHiddenLeadingController setValue:@(_resolvedIsCompact ? UIUserInterfaceSizeClassCompact : UIUserInterfaceSizeClassRegular) forKey:@"overrideSizeClass"];
	}
	if(self.swiftuiHiddenTrailingController != nil)
	{
		[self.swiftuiHiddenTrailingController setValue:@(_resolvedIsCompact ? UIUserInterfaceSizeClassCompact : UIUserInterfaceSizeClassRegular) forKey:@"overrideSizeClass"];
	}
}

- (void)setBarStyle:(LNPopupBarStyle)barStyle
{
	if(_customBarViewController == nil && barStyle == LNPopupBarStyleCustom)
	{
		barStyle = LNPopupBarStyleDefault;
	}
	
	if(_customBarViewController != nil && barStyle != LNPopupBarStyleCustom)
	{
		barStyle = LNPopupBarStyleCustom;
	}
	
	if(_barStyle != barStyle)
	{
		_barStyle = barStyle;
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle, &_resolvedIsFloating, &_resolvedIsCompact, &_resolvedIsCustom);
		
		[self _setNeedsBarButtonItemLayout];
		[self _setNeedsTitleLayoutByRemovingLabels:NO];
		
		[self _fixupSwiftUIControllersWithBarStyle];
		
		[_barContainingController.bottomDockingViewForPopup_nocreateOrDeveloper setNeedsLayout];
		[_barContainingController.view setNeedsLayout];
		
		[self _setNeedsAppearanceUpdate];
		
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
}

- (void)_setHackyMargins:(NSDirectionalEdgeInsets)_hackyMargins
{
	__hackyMargins = _hackyMargins;
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
	[self setNeedsLayout];
}

- (LNPopupBarStyle)effectiveBarStyle
{
	return _resolvedStyle;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if(_resolvedIsGlass)
	{
		return;
	}
	
	id block = ^ { self.highlightView.alpha = highlighted ? 1.0 : 0.0; };
	
	if(animated)
	{
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:block completion:nil];
	}
	else
	{
		[UIView performWithoutAnimation:block];
	}
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		self.preservesSuperviewLayoutMargins = YES;
		self.clipsToBounds = NO;
		
		self.usesContentControllersAsDataSource = YES;
		self.allowHapticFeedbackGenerationOnItemPaging = YES;
		
		self.limitFloatingContentWidth = YES;
		self.supportsMinimization = YES;
		
		_inheritsAppearanceFromDockingView = YES;
		_standardAppearance = [LNPopupBarAppearance new];
		
		if(!LNPopupEnvironmentHasGlass())
		{
			_backgroundView = [[_LNPopupBarBackgroundView alloc] initWithEffect:nil];
			_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_backgroundView.userInteractionEnabled = NO;
			[self addSubview:_backgroundView];
		}
		
		_layoutContainer = [UIView new];
		[self addSubview:_layoutContainer];
		
		_floatingBackgroundShadowView = [_LNPopupBackgroundShadowView new];
		_floatingBackgroundShadowView.userInteractionEnabled = NO;
		[_layoutContainer addSubview:_floatingBackgroundShadowView];
		
		_contentView = [[_LNPopupBarContentView alloc] initWithEffect:nil];
		_contentView.clipsToBounds = NO;
		[_layoutContainer addSubview:_contentView];
		
		if(@available(iOS 13.4, *))
		{
			UIPointerInteraction* pointerInteraction = [[UIPointerInteraction alloc] initWithDelegate:self];
			[_contentView addInteraction:pointerInteraction];
		}
		
		if(!LNPopupEnvironmentHasGlass())
		{
			_contentMaskView = [UIView new];
			_contentMaskView.backgroundColor = UIColor.whiteColor;
			_contentMaskView.frame = self.bounds;
			_contentView.maskView = _contentMaskView;
			
			_backgroundMaskView = [UIView new];
			_backgroundMaskView.backgroundColor = UIColor.whiteColor;
			_backgroundMaskView.frame = self.bounds;
			_backgroundView.effectView.maskView = _backgroundMaskView;
			
			_backgroundGradientMaskView = [_LNPopupBarBackgroundMaskView new];
			_backgroundView.maskView = _backgroundGradientMaskView;
		}
		
		self.effectGroupingIdentifier = nil;
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle, &_resolvedIsFloating, &_resolvedIsCompact, &_resolvedIsCustom);
		
		_toolbar = [[_LNPopupToolbar alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
		_toolbar._layoutDelegate = self;
		[_toolbar.standardAppearance configureWithTransparentBackground];
		
#if DEBUG
		if(_LNEnableBarLayoutDebug())
		{
			_toolbar.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.7];
			_toolbar.layer.borderColor = UIColor.blackColor.CGColor;
			_toolbar.layer.borderWidth = 1.0;
		}
		else
		{
			_toolbar.backgroundColor = nil;
			_toolbar.layer.borderColor = nil;
			_toolbar.layer.borderWidth = 0.0;
		}
#endif
		_toolbar.compactAppearance = _toolbar.standardAppearance;
		if(@available(iOS 15.0, *))
		{
			_toolbar.scrollEdgeAppearance = nil;
			_toolbar.compactScrollEdgeAppearance = nil;
		}
		_toolbar.autoresizingMask = UIViewAutoresizingNone;
		_toolbar.layer.masksToBounds = YES;
		[_contentView.contentView addSubview:_toolbar];
		
		_titlePagingController = [[_LNPopupTitlesPagingController alloc] initWithPopupBar:self];
		_titlesController = [[_LNPopupTitlesController alloc] initWithPopupBar:self];
		
		[_titlePagingController setViewControllers:@[_titlesController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
		
		_backgroundView.accessibilityTraits = UIAccessibilityTraitButton;
		_backgroundView.accessibilityIdentifier = @"PopupBarView";
		
		[_contentView.contentView addSubview:_titlePagingController.view];

		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.progressViewStyle = UIProgressViewStyleBar;
		_progressView.trackImage = [UIImage new];
		[_contentView.contentView addSubview:_progressView];
		[self _updateProgressViewWithStyle:self.progressViewStyle];
		
		_needsLabelsLayout = YES;
		
		_imageView = [[LNPopupImageView alloc] initWithContainingPopupBar:self];;
		_imageView.autoresizingMask = UIViewAutoresizingNone;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.accessibilityTraits = UIAccessibilityTraitImage;
		_imageView.isAccessibilityElement = YES;
		_imageView.layer.cornerCurve = kCACornerCurveContinuous;
		_imageView.cornerRadius = 6;
		
		// support smart invert and therefore do not invert image view colors
		_imageView.accessibilityIgnoresInvertColors = YES;
		
		[_contentView.contentView addSubview:_imageView];
		
		if(!LNPopupEnvironmentHasGlass())
		{
			_shadowView = [_LNPopupBarShadowView new];
			[_backgroundView.contentView addSubview:_shadowView];
			
			_bottomShadowView = [_LNPopupBarShadowView new];
			_bottomShadowView.hidden = YES;
			[_backgroundView.contentView addSubview:_bottomShadowView];
		}
		
		_highlightView = [[UIView alloc] initWithFrame:_contentView.bounds];
		_highlightView.userInteractionEnabled = NO;
		_highlightView.alpha = 0.0;
		
		self.semanticContentAttribute = UISemanticContentAttributeUnspecified;
		self.barItemsSemanticContentAttribute = UISemanticContentAttributePlayback;
		
		self.isAccessibilityElement = NO;
		
		_wantsBackgroundCutout = YES;
		
		if(@available(iOS 17.0, *))
		{
			[self registerForTraitChanges:@[LNPopupBarEnvironmentTrait.class] withHandler:^(__kindof id<UITraitEnvironment>  _Nonnull traitEnvironment, UITraitCollection * _Nonnull previousCollection) {
				[traitEnvironment _setNeedsRecalcActiveAppearanceChain];
				[traitEnvironment _setNeedsAppearanceUpdate];
			}];
		}
		
		[self _setNeedsRecalcActiveAppearanceChain];
	}
	
	return self;
}

#if DEBUG

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

#endif

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
	
	[self._barDelegate _traitCollectionForPopupBarDidChange:self];
	if(previousTraitCollection.userInterfaceStyle != self.traitCollection.userInterfaceStyle)
	{
		[self _setNeedsAppearanceUpdate];
	}
	
	if(UIContentSizeCategoryCompareToCategory(previousTraitCollection.preferredContentSizeCategory, self.traitCollection.preferredContentSizeCategory) != NSOrderedSame)
	{
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
	
	if(_LNPopupBarHeightForPopupBar(self) != self.bounds.size.height)
	{
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
}

- (void)_updateProgressViewWithStyle:(LNPopupBarProgressViewStyle)style
{
	style = _LNPopupResolveProgressViewStyleFromProgressViewStyle(style);
	
	[_progressView setHidden:style == LNPopupBarProgressViewStyleNone];
	
	[self setNeedsLayout];
}

- (void)updateConstraints
{
	if(_customBarViewController)
	{
		CGRect frame = self.bounds;
		
		CGFloat barHeight = _LNPopupBarHeightForPopupBar(self);
		frame.size.height = barHeight;
		[_contentView setFrame:frame];
	}
	
	[super updateConstraints];
}

- (void)_layoutCustomBarController
{
	_customBarViewController.view.preservesSuperviewLayoutMargins = NO;
	
	if(_customBarViewController == nil || _customBarViewController.view.translatesAutoresizingMaskIntoConstraints == NO)
	{
		return;
	}
	
	_customBarViewController.view.autoresizingMask = UIViewAutoresizingNone;
	
	CGRect frame = _contentView.bounds;
	frame.size.height = _customBarViewController.preferredContentSize.height;
	_customBarViewController.view.frame = frame;
}

- (void)setWantsBackgroundCutout:(BOOL)wantsBackgroundCutout
{
	[self setWantsBackgroundCutout:wantsBackgroundCutout allowImplicitAnimations:NO];
}

- (void)setWantsBackgroundCutout:(BOOL)wantsBackgroundCutout allowImplicitAnimations:(BOOL)allowImplicitAnimations
{
	if(_wantsBackgroundCutout != wantsBackgroundCutout)
	{
		_wantsBackgroundCutout = wantsBackgroundCutout;
		[_backgroundGradientMaskView setWantsCutout:wantsBackgroundCutout animated:allowImplicitAnimations];
	}
}

- (NSDirectionalEdgeInsets)floatingLayoutMargins
{
	UIEdgeInsets layoutMargins = LNPopupEnvironmentLayoutInsets(self, UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone);
	CGFloat extra = 0;
	if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
	{
		extra = 1;
	}
	
	NSDirectionalEdgeInsets rv = NSDirectionalEdgeInsetsZero;
	BOOL isRTL = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	if(isRTL)
	{
		rv.leading = layoutMargins.right + extra;
		rv.trailing = layoutMargins.left + extra;
	}
	else
	{
		rv.leading = layoutMargins.left + extra;
		rv.trailing = layoutMargins.right + extra;
	}
	return rv;
}

- (void)layoutSubviews
{
	if(_needsAppearanceProxyRefresh)
	{
		[self _recalcActiveAppearanceChain];
	}
	
	if(_needsAppearanceUpdate)
	{
		[self _updateAppearance];
	}
	
	[super layoutSubviews];
	
	_inLayout = YES;

	CGRect frame = self.bounds;
	
	CGFloat barHeight = _LNPopupBarHeightForPopupBar(self);
	frame.size.height = barHeight;
	_layoutContainer.frame = frame;
	
	if(_resolvedIsCustom == NO || self.customBarWantsFullBarWidth == NO)
	{
		frame = UIEdgeInsetsInsetRect(frame, _LNEdgeInsetsFromDirectionalEdgeInsets(self, __hackyMargins));
	}
	
	if(CGRectEqualToRect(_backgroundViewFrameDuringAnimation, CGRectZero))
	{
		_backgroundView.frame = frame;
	}
	else
	{
		_backgroundView.frame = _backgroundViewFrameDuringAnimation;
	}
	if(!LNPopupEnvironmentHasGlass())
	{
		_backgroundView.layer.mask.frame = _backgroundView.bounds;
	}
	
	BOOL isCustom = _resolvedStyle == LNPopupBarStyleCustom;
	BOOL isRTL = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	
	CGRect contentFrame;
	if(_resolvedIsFloating)
	{
		if(LNPopupEnvironmentHasGlass())
		{
			if(_resolvedIsCustom && self.customBarWantsFullBarWidth)
			{
				contentFrame = frame;
			}
			else
			{
				contentFrame = UIEdgeInsetsInsetRect(frame, _LNEdgeInsetsFromDirectionalEdgeInsets(self, self.floatingLayoutMargins));
			}
		}
		else
		{
			CGFloat inset = self.limitFloatingContentWidth || self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact ? 12 : 30;
			contentFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(4, MAX(self.safeAreaInsets.left + 12, inset), 4, MAX(self.safeAreaInsets.right + 12, inset)));
		}
		
		CGFloat limitToUse;
		if(LNPopupEnvironmentHasGlass())
		{
			limitToUse = LNPopupBarFloatingPadWidthLimitModern;
		}
		else
		{
			limitToUse = LNPopupBarFloatingPadWidthLimitLegacy;
		}
		
		if(self.limitFloatingContentWidth == YES && contentFrame.size.width > limitToUse && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGFloat d = (contentFrame.size.width - limitToUse) / 2;
			contentFrame = UIEdgeInsetsInsetRect(contentFrame, UIEdgeInsetsMake(0, d, 0, d));
		}
		
		if(LNPopupEnvironmentHasGlass())
		{
			_contentView.effectView.clipsToBounds = YES;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
			if(@available(iOS 26.0, *))
			{
				_contentView.effectView.cornerConfiguration = [self.activeAppearance floatingBackgroundCornerConfigurationForCustomBar:_resolvedIsCustom barHeight:barHeight screen:self.window.screen wantsFullWidth:self.customBarWantsFullBarWidth margins:self.layoutMargins];
				_floatingBackgroundShadowView.cornerConfiguration = _contentView.effectView.cornerConfiguration;
			}
#endif
		}
		else
		{
			_contentView.cornerRadius = 14;
			_floatingBackgroundShadowView.cornerRadius = _contentView.cornerRadius;
		}
		
		if(!LNPopupEnvironmentHasGlass())
		{
			_backgroundGradientMaskView.hidden = NO;
			_backgroundGradientMaskView.frame = _backgroundView.bounds;
			_backgroundGradientMaskView.floatingFrame = contentFrame;
			_backgroundGradientMaskView.floatingCornerRadius = _contentView.cornerRadius;
			[_backgroundGradientMaskView setWantsCutout:self.wantsBackgroundCutout animated:NO];
			[_backgroundGradientMaskView setNeedsDisplay];
			
			if(_backgroundView.maskView != _backgroundGradientMaskView)
			{
				_backgroundView.maskView = _backgroundGradientMaskView;
			}
		}
		
		_floatingBackgroundShadowView.hidden = _resolvedIsGlass;
		_floatingBackgroundShadowView.frame = contentFrame;
#if DEBUG
		_floatingBackgroundShadowView.hidden = _resolvedIsGlass || [__LNDebugUserDefaults() boolForKey:@"__LNPopupBarHideShadow"];
#endif
	}
	else
	{
		if(isCustom)
		{
			contentFrame = frame;
		}
		else
		{
			UIEdgeInsets insets;
			if(isRTL)
			{
				CGFloat inset = (!_resolvedIsCompact ? MAX(self.safeAreaInsets.right, self.layoutMargins.right) : self.safeAreaInsets.right) - 8;
				insets = UIEdgeInsetsMake(0, 0, 0, inset);
			}
			else
			{
				CGFloat inset = (!_resolvedIsCompact ? MAX(self.safeAreaInsets.left, self.layoutMargins.left) : self.safeAreaInsets.left) - 8;
				insets = UIEdgeInsetsMake(0, inset, 0, 0);
			}
			
			contentFrame = UIEdgeInsetsInsetRect(frame, insets);
		}
		
		_backgroundGradientMaskView.hidden = YES;
		_backgroundView.maskView = nil;
		
		_floatingBackgroundShadowView.hidden = YES;
		
		_contentView.cornerRadius = 0;
	}
	_contentView.frame = contentFrame;
#if DEBUG
	_contentView.hidden = [__LNDebugUserDefaults() boolForKey:@"__LNPopupBarHideContentView"];
#endif
	
	_contentView.preservesSuperviewLayoutMargins = !_resolvedIsFloating && !isCustom;
	
	_contentMaskView.frame = [_contentView convertRect:self.bounds fromView:self];
	_backgroundMaskView.frame = self.bounds;
	
	[self _layoutCustomBarController];
	
	CGRect imageFrameBefore = self.imageView.frame;
	BOOL wasImageViewHidden = self.imageView.isHidden;
	[self _layoutImageView];
	
	if(CGRectEqualToRect(imageFrameBefore, self.imageView.frame) == NO || wasImageViewHidden != self.imageView.isHidden)
	{
		_needsLabelsLayout = YES;
	}
	
	if(_needsBarButtonItemLayout)
	{
		_needsLabelsLayout = YES;
		
		[UIView performWithoutAnimation:^{
			[self _layoutBarButtonItems];
			[_toolbar layoutIfNeeded];
			
			if(_animatesItemSetter)
			{
				[_toolbar setAlpha:0.0];
			}
		}];
		
		if(_animatesItemSetter)
		{
			NSTimeInterval duration = UIView.inheritedAnimationDuration == 0.0 ? 0.3 : UIView.inheritedAnimationDuration;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:duration delay:0.0 options:0 animations:^{
					_toolbar.alpha = 1.0;
				} completion:nil];
			});
		}
		
		_animatesItemSetter = NO;
	}
	_toolbar.bounds = CGRectMake(0, 0, _contentView.bounds.size.width, 44);
	_toolbar.center = CGPointMake(CGRectGetMidX(_contentView.bounds), CGRectGetMidY(_contentView.bounds));
	[_toolbar layoutIfNeeded];
	
	if(_resolvedIsGlassInteractive)
	{
		[_highlightView removeFromSuperview];
	}
	else if(_resolvedIsFloating)
	{
		[_contentView.contentView insertSubview:_highlightView belowSubview:_toolbar];
		_highlightView.frame = _contentView.bounds;
		_highlightView.layer.cornerRadius = _contentView.cornerRadius;
	}
	else
	{
		[self insertSubview:_highlightView aboveSubview:_backgroundView];
		_highlightView.frame = self.bounds;
		_highlightView.layer.cornerRadius = 0;
	}
	
	[_contentView.contentView insertSubview:_imageView aboveSubview:_toolbar];
	[_contentView.contentView insertSubview:_titlePagingController.view aboveSubview:_imageView];
	
	UIScreen* screen = self.window.screen ?: UIScreen.mainScreen;
	if(!LNPopupEnvironmentHasGlass())
	{
		CGFloat h = 1 / screen.scale;
		_shadowView.frame = CGRectMake(0, 0, _backgroundView.bounds.size.width, h);
		_bottomShadowView.frame = CGRectMake(0, _backgroundView.bounds.size.height - h, _backgroundView.bounds.size.width, h);
	}
	
	CGFloat cornerRadius;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	if(@available(iOS 26.0, *))
	{
		cornerRadius = [_contentView.effectView effectiveRadiusForCorner:UIRectCornerAllCorners];
	}
	else
	{
#endif
		cornerRadius = _contentView.cornerRadius / 2.5;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	}
#endif
	CGFloat width = 0;
	CGFloat height = 0;
	CGFloat offset = 0;
	CGFloat offsetAfter = 0;
	if(_resolvedIsFloating)
	{
		[_contentView.contentView insertSubview:_progressView aboveSubview:_toolbar];
		if(LNPopupEnvironmentHasGlass())
		{
			offset = -10;
		}
		width = _contentView.bounds.size.width;
		height = _contentView.bounds.size.height;
	}
	else
	{
		[self insertSubview:_progressView aboveSubview:_contentView];
		
		offset = self.safeAreaInsets.left;
		width = self.bounds.size.width - self.safeAreaInsets.left - self.safeAreaInsets.right;
		height = self.bounds.size.height;
	}
	
	if(self.progressViewStyle == LNPopupBarProgressViewStyleTop)
	{
		_progressView.frame = CGRectMake(cornerRadius + offset, 0, width - 2 * (cornerRadius + offset), 1.5);
	}
	else
	{
		_progressView.frame = CGRectMake(cornerRadius + offset, height - 2.5, width - 2 * cornerRadius, 1.5);
	}
	
	CGFloat titleSpacing = 1 + (1 / MAX(1, screen.scale));
	if(_resolvedIsCompact)
	{
		titleSpacing = 0;
	}
	
	if(UIContentSizeCategoryCompareToCategory(self.traitCollection.preferredContentSizeCategory, UIContentSizeCategoryExtraExtraExtraLarge) != NSOrderedAscending)
	{
		CGFloat additionalHeight = 0;
		static NSDictionary<NSString*, NSNumber*>* additionalHeightMapping = nil;
		static dispatch_once_t token;
		dispatch_once(&token, ^{
			additionalHeightMapping = @{
				UIContentSizeCategoryExtraSmall : @0,
				UIContentSizeCategorySmall : @0,
				UIContentSizeCategoryMedium : @0,
				UIContentSizeCategoryLarge : @0,
				UIContentSizeCategoryExtraLarge : @0,
				UIContentSizeCategoryExtraExtraLarge : @0,
				UIContentSizeCategoryExtraExtraExtraLarge : @-1.5,
				UIContentSizeCategoryAccessibilityMedium : @-3,
				UIContentSizeCategoryAccessibilityLarge : @-5.5,
				UIContentSizeCategoryAccessibilityExtraLarge : @-7,
				UIContentSizeCategoryAccessibilityExtraExtraLarge : @-8.5,
				UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @-10,
			};
		});
		additionalHeight = [additionalHeightMapping[self.traitCollection.preferredContentSizeCategory] doubleValue];
		
		if(_resolvedIsCompact)
		{
			additionalHeight = 0.5 * additionalHeight;
		}
		
		titleSpacing += additionalHeight;
	}
	
	_titlesController.spacing = titleSpacing;
	
	[self _layoutTitles];
	
	if(LNPopupEnvironmentHasGlass())
	{
		[_contentView.contentView bringSubviewToFront:_progressView];
	}
	
	_inLayout = NO;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	static NSString* willRotate = LNPopupHiddenString("UIWindowWillRotateNotification");
	static NSString* didRotate = LNPopupHiddenString("UIWindowDidRotateNotification");
	
	if(self.window)
	{
		[NSNotificationCenter.defaultCenter removeObserver:self name:willRotate object:self.window];
		[NSNotificationCenter.defaultCenter removeObserver:self name:didRotate object:self.window];
	}
	
	[super willMoveToWindow:newWindow];
	
	if(newWindow)
	{
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_windowWillRotate:) name:willRotate object:newWindow];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_windowDidRotate:) name:didRotate object:newWindow];
	}
}

- (void)_windowWillRotate:(NSNotification*)note
{
	if([note.userInfo[@"LNPopupIgnore"] boolValue])
	{
		return;
	}
	
	[self setWantsBackgroundCutout:NO allowImplicitAnimations:NO];
}

- (void)_windowDidRotate:(NSNotification*)note
{
	if([note.userInfo[@"LNPopupIgnore"] boolValue])
	{
		return;
	}
	
	[self setWantsBackgroundCutout:YES allowImplicitAnimations:YES];
}

static NSString* __ln_effectGroupingIdentifierKey = LNPopupHiddenString("groupName");

- (void)_applyGroupingIdentifier:(NSString*)groupingIdentifier toVisualEffectView:(UIVisualEffectView*)visualEffectView
{
	if(visualEffectView == nil)
	{
		return;
	}
	
	if([[visualEffectView valueForKey:__ln_effectGroupingIdentifierKey] isEqualToString:groupingIdentifier])
	{
		return;
	}
	
	[visualEffectView setValue:groupingIdentifier ?: [NSString stringWithFormat:@"<%@:%p> Backdrop Group", self.class, self] forKey:__ln_effectGroupingIdentifierKey];
}

- (void)_applyGroupingIdentifierToVisualEffectView:(UIVisualEffectView*)visualEffectView
{
	[self _applyGroupingIdentifier:self.effectGroupingIdentifier toVisualEffectView:visualEffectView];
}

- (NSString *)effectGroupingIdentifier
{
	return [self.backgroundView.effectView valueForKey:__ln_effectGroupingIdentifierKey];
}

- (void)setEffectGroupingIdentifier:(NSString *)groupingIdentifier
{
	if(LNPopupEnvironmentHasGlass())
	{
		return;
	}
	
	[self _applyGroupingIdentifier:groupingIdentifier toVisualEffectView:self.backgroundView.effectView];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (UIColor *)backgroundColor
{
	return _userBackgroundColor;
}

- (void)_internalSetBackgroundColor:(UIColor *)backgroundColor
{
	_userBackgroundColor = backgroundColor;
	
	[super setBackgroundColor:_userBackgroundColor ?: _systemBackgroundColor];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[self _internalSetBackgroundColor:backgroundColor];
}

- (void)setSystemBackgroundColor:(UIColor *)systemBackgroundColor
{
	_systemBackgroundColor = systemBackgroundColor;
	
	[self _internalSetBackgroundColor:_userBackgroundColor];
}

- (void)setSystemAppearance:(UIBarAppearance *)systemAppearance
{
	if([_systemAppearance isEqual:systemAppearance] == YES)
	{
		return;
	}
	
	_systemAppearance = [systemAppearance copy];
	
	[self _setNeedsRecalcActiveAppearanceChain];
}

- (void)setStandardAppearance:(LNPopupBarAppearance *)standardAppearance
{
	if([_standardAppearance isEqual:standardAppearance] == YES)
	{
		return;
	}
	
	_standardAppearance = [standardAppearance copy];
	if(_standardAppearance == nil)
	{
		_standardAppearance = [LNPopupBarAppearance new];
	}
	
	[self _setNeedsRecalcActiveAppearanceChain];
}

- (void)setInlineAppearance:(LNPopupBarAppearance *)inlineAppearance
{
	if([_inlineAppearance isEqual:inlineAppearance] == YES)
	{
		return;
	}
	
	_inlineAppearance = [inlineAppearance copy];
	
	[self _setNeedsRecalcActiveAppearanceChain];
}

- (void)_setNeedsRecalcActiveAppearanceChain
{
	_needsAppearanceProxyRefresh = YES;
	
	[self setNeedsLayout];
}

- (void)_recalcActiveAppearanceChain
{
	_needsAppearanceProxyRefresh = NO;
	
	NSMutableArray* chain = [NSMutableArray new];
	
	BOOL isInline = self.traitCollection.popupBarEnvironment == LNPopupBarEnvironmentInline;
	
	if(isInline && self.popupItem.inlineAppearance != nil)
	{
		[chain addObject:self.popupItem.inlineAppearance];
	}
	
	if(isInline && self.inlineAppearance != nil)
	{
		[chain addObject:self.inlineAppearance];
	}
	
	if(self.popupItem.standardAppearance != nil)
	{
		[chain addObject:self.popupItem.standardAppearance];
	}
	
	if(self.systemAppearance != nil)
	{
		[chain addObject:self.systemAppearance];
	}
	
	[chain addObject:self.standardAppearance];
	
	if([chain isEqualToArray:_activeAppearanceChain.chain])
	{
		return;
	}
	else if(_activeAppearanceChain != nil)
	{
		[_activeAppearanceChain setChainDelegate:nil];
	}
	
	_activeAppearanceChain = [[LNPopupBarAppearanceChainProxy alloc] initWithAppearanceChain:chain];
	[_activeAppearanceChain setChainDelegate:self];
	
	[self _setNeedsAppearanceUpdate];
}

- (void)setPopupItem:(LNPopupItem *)popupItem
{
	[self._barDelegate _popupBar:self setUserPopupItem:popupItem];
}

- (void)_setPopupItem:(LNPopupItem*)popupItem
{
	_popupItem = popupItem;
	
	[self _setNeedsRecalcActiveAppearanceChain];
}

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance
{
	[self _setNeedsAppearanceUpdate];
}

- (void)_setNeedsAppearanceUpdate
{
	_needsAppearanceUpdate = YES;
	
	[self setNeedsLayout];
}

- (void)_updateAppearance
{
	_needsAppearanceUpdate = NO;
	
	_highlightView.backgroundColor = self.activeAppearance.highlightColor;
	
	_resolvedIsGlass = NO;
	_resolvedIsGlassInteractive = NO;
	if(_resolvedIsFloating)
	{
		UIVisualEffect* effect = [self.activeAppearance floatingBackgroundEffectForPopupBar:self containerController:self.barContainingController traitCollection:self.traitCollection];
		
		BOOL oldIsGlass = _contentView.effect.ln_isGlass;
		BOOL newIsGlass = effect.ln_isGlass;
		BOOL needsClear = _contentView.effect != nil && oldIsGlass != newIsGlass;
		if(needsClear)
		{
			[_contentView clearEffect];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		if(effect.ln_isGlass)
		{
			auto wrapper = [_LNPopupGlassWrapperEffect wrapperWithEffect:effect];
			wrapper.disableForeground = self.activeAppearance.isFloatingBarShineEnabled;
			effect = wrapper;
		}
#endif
		
		_contentView.effect = effect;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		{
			_resolvedIsGlass = effect.ln_isGlass;
			_resolvedIsGlassInteractive = _resolvedIsGlass && ((UIGlassEffect*)effect).isInteractive;
		}
#endif
			
		__auto_type floatingBackgroundColor = self.activeAppearance.floatingBackgroundColor;
		__auto_type floatingBackgroundImage = self.activeAppearance.floatingBackgroundImage;
		
		_contentView.foregroundColor = floatingBackgroundColor;
		_contentView.foregroundImage = floatingBackgroundImage;
		_contentView.foregroundImageContentMode = self.activeAppearance.floatingBackgroundImageContentMode;
		[_contentView hideOrShowImageViewIfNecessary];
		
		if(!_resolvedIsGlass)
		{
			_contentView.clipsToBounds = YES;
		}
		else
		{
			_contentView.clipsToBounds = NO;
		}
	}
	else
	{
		[_contentView clearEffect];
		_contentView.foregroundColor = nil;
		_contentView.foregroundImage = nil;
		_contentView.foregroundImageContentMode = (UIViewContentMode)0;
		[_contentView hideOrShowImageViewIfNecessary];
	}
	
	if(!LNPopupEnvironmentHasGlass())
	{
		__auto_type backgroundColor = self.activeAppearance.backgroundColor;
		__auto_type backgroundImage = self.activeAppearance.backgroundImage;
		
		_backgroundView.effect = self.activeAppearance.backgroundEffect;
		_backgroundView.foregroundColor = backgroundColor;
		_backgroundView.foregroundImage = backgroundImage;
		_backgroundView.foregroundImageContentMode = self.activeAppearance.backgroundImageContentMode;
		[_backgroundView hideOrShowImageViewIfNecessary];
	}
	
	_toolbar.standardAppearance.buttonAppearance = self.activeAppearance.buttonAppearance ?: _toolbar.standardAppearance.buttonAppearance;
	
	if(@available(iOS 26.0, *))
	{
		_toolbar.standardAppearance.prominentButtonAppearance = self.activeAppearance.prominentButtonAppearance ?: _toolbar.standardAppearance.prominentButtonAppearance;
	}
	else
	{
		_toolbar.standardAppearance.doneButtonAppearance = self.activeAppearance.prominentButtonAppearance ?: _toolbar.standardAppearance.doneButtonAppearance;
	}
	
	if(!LNPopupEnvironmentHasGlass())
	{
		_shadowView.image = self.activeAppearance.shadowImage;
		_shadowView.backgroundColor = self.activeAppearance.shadowColor;
		_bottomShadowView.image = self.activeAppearance.shadowImage;
		_bottomShadowView.backgroundColor = self.activeAppearance.shadowColor;
		
		_shadowView.hidden = _resolvedIsFloating ? YES : NO;
		if(_resolvedIsFloating)
		{
			_bottomShadowView.hidden = YES;
		}
	}
	
	_floatingBackgroundShadowView.shadow = self.activeAppearance.floatingBarBackgroundShadow;
	
	_imageView.shadow = self.activeAppearance.imageShadow;

	if(@available(iOS 26.0, *))
	{
		_contentView.shiny = self.activeAppearance.isFloatingBarShineEnabled;
	}
	
	[self.customBarViewController _activeAppearanceDidChange:self.activeAppearance];
	
	//Recalculate labels
	[self _setNeedsTitleLayoutByRemovingLabels:YES];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (void)setProgressViewStyle:(LNPopupBarProgressViewStyle)progressViewStyle
{
	if(_progressViewStyle != progressViewStyle)
	{
		[self _updateProgressViewWithStyle:progressViewStyle];
	}
	
	_progressViewStyle = progressViewStyle;
}

- (UIColor *)tintColor
{
	return _userTintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
	_userTintColor = tintColor;
	
	[super setTintColor:_userTintColor ?: _systemTintColor];
}

- (void)setSystemTintColor:(UIColor *)systemTintColor
{
	_systemTintColor = systemTintColor;
	
	[self setTintColor:_userTintColor];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
	_attributedTitle = [attributedTitle copy];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
	_attributedSubtitle = [attributedSubtitle copy];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	
	[self setNeedsLayout];
}

- (void)setSwiftuiImageController:(UIViewController *)swiftuiImageController
{
	if(_swiftuiImageController != nil)
	{
		[_swiftuiImageController.view removeFromSuperview];
		[_swiftuiImageController removeObserver:self forKeyPath:@"preferredContentSize"];
	}
	
	_swiftuiImageController = swiftuiImageController;
	if(_swiftuiImageController != nil)
	{
		[_swiftuiImageController addObserver:self forKeyPath:@"preferredContentSize" options:NSKeyValueObservingOptionNew context:NULL];
		
		_swiftuiImageController.view.backgroundColor = UIColor.clearColor;
		
		_swiftuiImageController.view.translatesAutoresizingMaskIntoConstraints = NO;
		[_imageView addSubview:_swiftuiImageController.view];
		[NSLayoutConstraint activateConstraints:@[
			[_imageView.topAnchor constraintEqualToAnchor:_swiftuiImageController.view.topAnchor],
			[_imageView.bottomAnchor constraintEqualToAnchor:_swiftuiImageController.view.bottomAnchor],
			[_imageView.leadingAnchor constraintEqualToAnchor:_swiftuiImageController.view.leadingAnchor],
			[_imageView.trailingAnchor constraintEqualToAnchor:_swiftuiImageController.view.trailingAnchor],
		]];
	}
	
	[self _layoutImageView];
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)setSwiftuiTitleContentView:(UIView *)swiftuiTitleContentView
{
	if(_swiftuiTitleContentView == swiftuiTitleContentView)
	{
		return;
	}
	
	if(_swiftuiTitleContentView != nil)
	{
		[_swiftuiTitleContentView removeFromSuperview];
	}
	
	_swiftuiTitleContentView = swiftuiTitleContentView;
	
	if(_swiftuiTitleContentView != nil)
	{
		[_swiftuiTitleContentView _ln_freezeInsets];
		_swiftuiTitleContentView.backgroundColor = UIColor.clearColor;
		_swiftuiTitleContentView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	
	[self _setNeedsTitleLayoutByRemovingLabels:YES];
}

- (void)setSwiftuiInheritedFont:(UIFont *)swiftuiInheritedFont
{
	if([_swiftuiInheritedFont isEqual:swiftuiInheritedFont])
	{
		return;
	}
	
	_swiftuiInheritedFont = swiftuiInheritedFont;
	
	[self _setNeedsTitleLayoutByRemovingLabels:YES];
}

- (void)setSwiftuiHiddenLeadingController:(UIViewController *)swiftuiHiddenLeadingController
{
	if(_swiftuiHiddenLeadingController == swiftuiHiddenLeadingController)
	{
		return;
	}
	
	if(_swiftuiHiddenLeadingController != nil)
	{
		[_swiftuiHiddenLeadingController.view removeFromSuperview];
	}
	
	_swiftuiHiddenLeadingController = swiftuiHiddenLeadingController;
	_swiftuiHiddenLeadingController.view.frame = CGRectMake(0, 0, 400, 400);
	
	if(_swiftHacksWindow1 != nil)
	{
		_swiftHacksWindow1.hidden = YES;
		_swiftHacksWindow1 = nil;
	}
	
	if(_swiftuiHiddenLeadingController != nil)
	{
		[UIView performWithoutAnimation:^{
			_swiftHacksWindow1 = [[UIWindow alloc] initWithWindowScene:self.window.windowScene];
			_swiftHacksWindow1.frame = CGRectMake(-4000, 0, 400, 400);
			_swiftHacksWindow1.rootViewController = _swiftuiHiddenLeadingController;
			_swiftHacksWindow1.hidden = NO;
			_swiftHacksWindow1.alpha = 0.0;
			[_swiftHacksWindow1 layoutSubviews];
		}];
	}
	
	[self _fixupSwiftUIControllersWithBarStyle];
}

- (void)setSwiftuiHiddenTrailingController:(UIViewController *)swiftuiHiddenTrailingController
{
	if(_swiftuiHiddenTrailingController == swiftuiHiddenTrailingController)
	{
		return;
	}
	
	if(_swiftuiHiddenTrailingController != nil)
	{
		[_swiftuiHiddenTrailingController.view removeFromSuperview];
	}
	
	_swiftuiHiddenTrailingController = swiftuiHiddenTrailingController;
	_swiftuiHiddenTrailingController.view.frame = CGRectMake(0, 0, 400, 400);
	
	if(_swiftHacksWindow2 != nil)
	{
		_swiftHacksWindow2.hidden = YES;
		_swiftHacksWindow2 = nil;
	}
	
	if(_swiftuiHiddenTrailingController != nil)
	{
		[UIView performWithoutAnimation:^{
			_swiftHacksWindow2 = [[UIWindow alloc] initWithWindowScene:self.window.windowScene];
			_swiftHacksWindow2.frame = CGRectMake(-4000, 0, 400, 400);
			_swiftHacksWindow2.rootViewController = _swiftuiHiddenTrailingController;
			_swiftHacksWindow2.hidden = NO;
			_swiftHacksWindow2.alpha = 0.0;
			[_swiftHacksWindow2 layoutSubviews];
		}];
	}
	
	[self _fixupSwiftUIControllersWithBarStyle];
}

- (void)setAccessibilityCenterHint:(NSString *)accessibilityCenterHint
{
	_accessibilityCenterHint = accessibilityCenterHint;
	
	[_titlesController updateAccessibility];
}

- (void)setAccessibilityCenterLabel:(NSString *)accessibilityCenterLabel
{
	_accessibilityCenterLabel = accessibilityCenterLabel;
	
	[_titlesController updateAccessibility];
}

- (void)setAccessibilityImageLabel:(NSString *)accessibilityImageLabel
{
	_accessibilityImageLabel = accessibilityImageLabel;
	
	_imageView.accessibilityLabel = accessibilityImageLabel;
}

- (void)setAccessibilityProgressLabel:(NSString *)accessibilityProgressLabel
{
	_accessibilityProgressLabel = accessibilityProgressLabel;
	
	_progressView.accessibilityLabel = accessibilityProgressLabel;
}

- (void)setAccessibilityProgressValue:(NSString *)accessibilityProgressValue
{
	_accessibilityProgressValue = accessibilityProgressValue;
	
	_progressView.accessibilityValue = accessibilityProgressValue;
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute
{
	[super setSemanticContentAttribute:semanticContentAttribute];
	_toolbar.semanticContentAttribute = semanticContentAttribute;
	
	[self setNeedsLayout];
}

- (void)setBarItemsSemanticContentAttribute:(UISemanticContentAttribute)barItemsSemanticContentAttribute
{
	_barItemsSemanticContentAttribute = barItemsSemanticContentAttribute;
	
	[self _setNeedsBarButtonItemLayout];
	
	[self setNeedsLayout];
}

#if __has_include(<LNSystemMarqueeLabel.h>)
BOOL __LNPopupUseSystemMarqueeLabel(void)
{
	static BOOL bundleRequest;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bundleRequest = [[NSBundle.mainBundle objectForInfoDictionaryKey:@"LNPopupUseSystemMarqueeLabel"] boolValue];
	});
	return bundleRequest || [NSUserDefaults.standardUserDefaults boolForKey:@"LNPopupUseSystemMarqueeLabel"];
}
#endif

- (UIView*)_viewForBarButtonItem:(UIBarButtonItem*)barButtonItem
{
	UIView* itemView = [barButtonItem valueForKey:@"view"];
	
	static NSString* adaptorView = LNPopupHiddenString("_UITAMICAdaptorView");
	
	if([itemView.superview isKindOfClass:NSClassFromString(adaptorView)])
	{
		itemView = itemView.superview;
	}
	
	return itemView;
}

- (void)_getLeftmostView:(UIView* __strong *)leftmostView rightmostView:(UIView* __strong *)rightmostView fromBarButtonItems:(NSArray<UIBarButtonItem*>*)barButtonItems
{
	NSArray<UIBarButtonItem*>* filtered = [barButtonItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isSystemItem == NO || (systemItem != %@ && systemItem != %@)) && isHidden == NO", @(UIBarButtonSystemItemFixedSpace), @(UIBarButtonSystemItemFlexibleSpace)]];
	
	NSArray<UIBarButtonItem*>* sorted = [filtered sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(UIBarButtonItem*  _Nonnull obj1, UIBarButtonItem*  _Nonnull obj2) {
		
		UIView* v1 = [self _viewForBarButtonItem:obj1];
		UIView* v2 = [self _viewForBarButtonItem:obj2];
		
		return [@(v1.frame.origin.x) compare:@(v2.frame.origin.x)];
	}];
	
	if(leftmostView != NULL) { *leftmostView = [self _viewForBarButtonItem:sorted.firstObject]; }
	if(rightmostView != NULL) { *rightmostView = [self _viewForBarButtonItem:sorted.lastObject]; }
}

- (void)_updateTitleInsetsForCompactBar:(UIEdgeInsets*)titleInsets
{
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	
	UIView* leftViewLast;
	UIView* rightViewFirst;
	
	[_toolbar layoutIfNeeded];
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		[self _getLeftmostView:NULL rightmostView:&leftViewLast fromBarButtonItems:self.leadingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:NULL fromBarButtonItems:self.trailingBarButtonItems];
	}
	else
	{
		[self _getLeftmostView:NULL rightmostView:&leftViewLast fromBarButtonItems:self.trailingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:NULL fromBarButtonItems:self.leadingBarButtonItems];
	}
	
#if DEBUG
	if(_LNEnableBarLayoutDebug())
	{
		leftViewLast.backgroundColor = UIColor.brownColor;
		rightViewFirst.backgroundColor = UIColor.purpleColor;
	}
#endif
	
	[leftViewLast.superview layoutIfNeeded];
	[rightViewFirst.superview layoutIfNeeded];
	
	CGRect leftViewLastFrame = CGRectZero;
	if(leftViewLast != nil)
	{
		leftViewLastFrame = [_toolbar convertRect:leftViewLast.bounds fromView:leftViewLast];
	}
	
	CGRect rightViewFirstFrame = CGRectMake(_toolbar.bounds.size.width, 0, 0, 0);
	if(rightViewFirst != nil)
	{
		rightViewFirstFrame = [_toolbar convertRect:rightViewFirst.bounds fromView:rightViewFirst];
	}
	
	CGFloat widthLeft = 0;
	CGFloat widthRight = 0;
	
	widthLeft = leftViewLastFrame.origin.x + leftViewLastFrame.size.width;
	widthRight = _contentView.bounds.size.width - rightViewFirstFrame.origin.x;
	
//	widthLeft = MAX(widthLeft, self.layoutMargins.left);
//	widthRight = MAX(widthRight, self.layoutMargins.right);
	
//	titleInsets->left = MAX(widthLeft + 8, widthRight + 8);
//	titleInsets->right = MAX(widthLeft + 8, widthRight + 8);
	titleInsets->left = widthLeft + 8;
	titleInsets->right = widthRight + 8;
}

- (void)_updateTitleInsetsForProminentBar:(UIEdgeInsets*)titleInsets
{
	BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
	
	UIView* leftViewLast;
	UIView* rightViewFirst;
	
	[_toolbar layoutIfNeeded];
	
	NSArray* allItems = _toolbar.items;

	static Class systemBarButtonItemButtonClass = NSClassFromString(LNPopupHiddenString("_UIButtonBarButton"));
	BOOL isTrailingSystem;
	
	if(isRTL == NO)
	{
		[self _getLeftmostView:&rightViewFirst rightmostView:NULL fromBarButtonItems:allItems];
		leftViewLast = _imageView.hidden ? nil : _imageView;
		isTrailingSystem = [rightViewFirst isKindOfClass:systemBarButtonItemButtonClass];
	}
	else
	{
		[self _getLeftmostView:NULL rightmostView:&leftViewLast fromBarButtonItems:allItems];
		rightViewFirst = _imageView.hidden ? nil : _imageView;
		isTrailingSystem = [leftViewLast isKindOfClass:systemBarButtonItemButtonClass];
	}
	
#if DEBUG
	if(_LNEnableBarLayoutDebug())
	{
		leftViewLast.layer.borderWidth = 2.0;
		leftViewLast.layer.borderColor = UIColor.brownColor.CGColor;
		leftViewLast.backgroundColor = UIColor.brownColor;
		rightViewFirst.layer.borderWidth = 2.0;
		rightViewFirst.layer.borderColor = UIColor.purpleColor.CGColor;
		rightViewFirst.backgroundColor = UIColor.purpleColor;
	}
	else
	{
		leftViewLast.layer.borderWidth = 0.0;
		leftViewLast.layer.borderColor = nil;
		leftViewLast.backgroundColor = nil;
		rightViewFirst.layer.borderWidth = 0.0;
		rightViewFirst.layer.borderColor = nil;
		rightViewFirst.backgroundColor = nil;
	}
#endif
	
	if(isRTL == YES)
	{
		[leftViewLast.superview layoutIfNeeded];
	}
	else
	{
		[rightViewFirst.superview layoutIfNeeded];
	}
	
	CGFloat imageToTitlePadding = _resolvedIsFloating && (!LNPopupEnvironmentHasGlass() || _resolvedIsCompact) ? 8 : 16;
	
	CGRect leftViewLastFrame = CGRectZero;
	if(leftViewLast != nil)
	{
		leftViewLastFrame = [_contentView convertRect:leftViewLast.bounds fromView:leftViewLast];
		
		if(leftViewLast == _imageView)
		{
			leftViewLastFrame.size.width += imageToTitlePadding;
		}
		else
		{
			leftViewLastFrame.size.width -= (__applySwiftUILayoutFixes ? -8 : isTrailingSystem ? 8 : 0);
		}
	}
	else
	{
		leftViewLastFrame.size.width += _resolvedIsFloating ? 20 : 8;
	}
	
	CGRect rightViewFirstFrame = CGRectMake(_contentView.bounds.size.width, 0, 0, 0);
	if(rightViewFirst != nil)
	{
		rightViewFirstFrame = [_contentView convertRect:rightViewFirst.bounds fromView:rightViewFirst];
		
		if(rightViewFirst == _imageView)
		{
			rightViewFirstFrame.origin.x -= imageToTitlePadding;
		}
		else
		{
			rightViewFirstFrame.origin.x += (__applySwiftUILayoutFixes ? -8 : isTrailingSystem ? 8 : 0);
		}
	}
	else
	{
		rightViewFirstFrame.origin.x -= 20;
	}
	
	CGFloat widthLeft = 0;
	CGFloat widthRight = 0;
	
	widthLeft = leftViewLastFrame.origin.x + leftViewLastFrame.size.width;
	widthRight = _contentView.bounds.size.width - rightViewFirstFrame.origin.x;
	
	if(_resolvedIsFloating == NO)
	{
		widthLeft = MAX(widthLeft, _contentView.layoutMargins.left);
		widthRight = MAX(widthRight, _contentView.layoutMargins.right);
	}
	
	titleInsets->left = widthLeft;
	titleInsets->right = widthRight;
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIFont*)_titleFont
{
	if(_swiftuiInheritedFont)
	{
		return _swiftuiInheritedFont;
	}
	
	CGFloat fontSize = 15;
	UIFontWeight fontWeight = UIFontWeightSemibold;
	UIFontTextStyle textStyle = UIFontTextStyleHeadline;
	
	switch(_resolvedStyle)
	{
		case LNPopupBarStyleFloating:
			fontSize = 15;
			fontWeight = UIFontWeightSemibold;
			textStyle = UIFontTextStyleHeadline;
			break;
		case LNPopupBarStyleProminent:
			fontSize = 15;
			fontWeight = UIFontWeightMedium;
			textStyle = UIFontTextStyleBody;
			break;
		case LNPopupBarStyleFloatingCompact:
			fontSize = 13;
			fontWeight = UIFontWeightSemibold;
			textStyle = UIFontTextStyleHeadline;
			break;
		case LNPopupBarStyleCompact:
			fontSize = 13.5;
			fontWeight = UIFontWeightMedium;
			textStyle = UIFontTextStyleSubheadline;
			break;
		default:
			break;
	}
	
	return [[UIFontMetrics metricsForTextStyle:textStyle] scaledFontForFont:[UIFont systemFontOfSize:fontSize weight:fontWeight]];
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIColor*)_titleColor
{
	return UIColor.labelColor;
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIFont*)_subtitleFont
{
	if(_swiftuiInheritedFont)
	{
		return [UIFont fontWithDescriptor:_swiftuiInheritedFont.fontDescriptor size:_swiftuiInheritedFont.pointSize - 2.5];
	}
	
	CGFloat fontSize = 15;
	UIFontWeight fontWeight = UIFontWeightRegular;
	UIFontTextStyle textStyle = UIFontTextStyleBody;
	
	switch(_resolvedStyle)
	{
		case LNPopupBarStyleFloating:
			fontSize = 12.5;
			fontWeight = UIFontWeightRegular;
			textStyle = UIFontTextStyleSubheadline;
			break;
		case LNPopupBarStyleProminent:
			fontSize = 15;
			fontWeight = UIFontWeightRegular;
			textStyle = UIFontTextStyleBody;
			break;
		case LNPopupBarStyleFloatingCompact:
		case LNPopupBarStyleCompact:
			fontSize = 12;
			fontWeight = UIFontWeightRegular;
			textStyle = UIFontTextStyleSubheadline;
			break;
		default:
			break;
	}
	
	return [[UIFontMetrics metricsForTextStyle:textStyle] scaledFontForFont:[UIFont systemFontOfSize:fontSize weight:fontWeight]];
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIColor*)_subtitleColor
{
	return UIColor.secondaryLabelColor;
}

- (void)_layoutTitles
{
	UIEdgeInsets titleInsets = UIEdgeInsetsZero;
	
	if(_resolvedStyle == LNPopupBarStyleCompact)
	{
		[self _updateTitleInsetsForCompactBar:&titleInsets];
	}
	else
	{
		[self _updateTitleInsetsForProminentBar:&titleInsets];
	}
	
#if DEBUG
	if(_LNEnableBarLayoutDebug())
	{
		_titlePagingController.view.backgroundColor = [UIColor.orangeColor colorWithAlphaComponent:0.6];
	}
	else
	{
		_titlePagingController.view.backgroundColor = nil;
	}
#endif
	
	if(_needsLabelsLayout == YES)
	{
		[_titlesController layoutTitlesRemovingLabels:_needsLabelsLayoutRemove];
		
		_needsLabelsLayoutRemove = NO;
		_needsLabelsLayout = NO;
	}
	
	CGRect frameBefore = _titlePagingController.view.frame;
	
	_titlePagingController.view.frame = CGRectMake(titleInsets.left, 0, _contentView.bounds.size.width - titleInsets.left - titleInsets.right, _contentView.bounds.size.height);
	CGPoint center = _titlePagingController.view.center;
	center.y = _contentView.contentView.center.y;
	_titlePagingController.view.center = center;
	
	if(CGRectEqualToRect(frameBefore, _titlePagingController.view.frame) == NO)
	{
		[_titlePagingController.view layoutIfNeeded];
	}
}

- (void)_setNeedsTitleLayoutByRemovingLabels:(BOOL)remove
{
	_needsLabelsLayout = YES;
	
	if(remove)
	{
		_needsLabelsLayoutRemove = YES;
	}
	
	[self setNeedsLayout];
}

static CGSize LNMakeSizeWithAspectRatioInsideSize(CGSize aspectRatio, CGSize size)
{
	CGFloat outerAspectRatio = size.width / size.height;
	CGFloat fAspectRatio = aspectRatio.width / aspectRatio.height;
	
	if(fAspectRatio < outerAspectRatio)
	{
		return CGSizeMake(size.height * fAspectRatio, size.height);
	}
	else if(fAspectRatio > outerAspectRatio)
	{
		return CGSizeMake(size.width, size.width / fAspectRatio);
	}
	else
	{
		return size;
	}
}

- (CGSize)_imageViewSizeWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height
{
	if(_imageView.image == nil && _swiftuiImageController == nil)
	{
		return CGSizeMake(width, height);
	}
	
	if(_swiftuiImageController != nil)
	{
		return LNMakeSizeWithAspectRatioInsideSize(_swiftuiImageController.preferredContentSize, CGSizeMake(width, height));
	}
	
	if(_imageView.contentMode != UIViewContentModeScaleAspectFit)
	{
		return CGSizeMake(width, height);
	}
	
	return LNMakeSizeWithAspectRatioInsideSize(_imageView.image.size, CGSizeMake(width, height));
}

- (void)_layoutImageView
{
	BOOL previouslyHidden = _imageView.hidden;
	CGSize previousSize = _imageView.bounds.size;
	
	if(_resolvedStyle == LNPopupBarStyleCompact)
	{
		_imageView.hidden = YES;
		
		return;
	}
	
	_imageView.image = _image;
	_imageView.hidden = _image == nil && _swiftuiImageController == nil;
	
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	
	CGFloat maxImageDimension = _contentView.bounds.size.height - 18;
	CGFloat barHeight = _contentView.bounds.size.height;
	
	CGFloat safeLeading;
	
	if(LNPopupEnvironmentHasGlass())
	{
		safeLeading = _resolvedIsCompact || self.traitCollection.popupBarEnvironment == LNPopupBarEnvironmentInline ? 16 : 20;
	}
	else
	{
		safeLeading = 8;
	}
	
	if(_resolvedIsFloating && _resolvedIsCompact == NO && self.isWidePad == YES)
	{
		safeLeading += 2;
		maxImageDimension = LNPopupBarFloatingPadImageWidth;
	}
	
	CGSize imageViewSize = [self _imageViewSizeWithMaxWidth:maxImageDimension maxHeight:maxImageDimension];
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		_imageView.center = CGPointMake(safeLeading + imageViewSize.width / 2, barHeight / 2);
	}
	else
	{
		_imageView.center = CGPointMake(_contentView.bounds.size.width - safeLeading - imageViewSize.width / 2, barHeight / 2);
	}
	
	_imageView.bounds = (CGRect){0, 0, imageViewSize};
	
	if(previouslyHidden != _imageView.hidden || CGSizeEqualToSize(previousSize, imageViewSize) == NO)
	{
		[self _setNeedsTitleLayoutByRemovingLabels:NO];
	}
}

- (void)_setTitleViewMarqueesPaused:(BOOL)paused
{
	_titlesController.marqueePaused = paused;
}

- (void)_setNeedsBarButtonItemLayout
{
	_animatesItemSetter = __animatesItemSetter;
	_needsBarButtonItemLayout = YES;
	
	[self setNeedsLayout];
}

- (void)_layoutBarButtonItems
{
	_needsBarButtonItemLayout = NO;
	
	UIUserInterfaceLayoutDirection barItemsLayoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_barItemsSemanticContentAttribute];
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];

	BOOL normalButtonsOrder = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight || barItemsLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	
	NSEnumerationOptions enumerationOptions = normalButtonsOrder ? 0 : NSEnumerationReverse;
	
	NSMutableArray* items = [NSMutableArray new];
	
	UIBarButtonItem* flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	if(_resolvedStyle != LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}
	
	[self.leadingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	if(_resolvedStyle == LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}

	[self.trailingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	[_toolbar setItems:items animated:NO];
	[_toolbar layoutIfNeeded];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)_updateViewsAfterCustomBarViewControllerUpdate
{
	BOOL hide = _customBarViewController != nil;
	_imageView.hidden = hide;
	_toolbar.hidden = hide;
	_titlePagingController.view.hidden = hide;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"preferredContentSize"] == YES && object == _customBarViewController)
	{
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
	
	if([keyPath isEqualToString:@"preferredContentSize"] == YES && object == _swiftuiImageController)
	{
		[self _layoutImageView];
		[self _setNeedsTitleLayoutByRemovingLabels:NO];
	}
}

- (void)setCustomBarViewController:(LNPopupCustomBarViewController*)customBarViewController
{
	if(_customBarViewController == customBarViewController)
	{
		return;
	}
	
	if(customBarViewController != nil)
	{
		LNDynamicSubclass(customBarViewController, _LNPopupCustomBarViewController_AppearanceControl.class);
	}
	
	[self layoutIfNeeded];
	
	if(customBarViewController.containingPopupBar && customBarViewController.containingPopupBar != self)
	{
		//Cleanly move the custom bar view controller from the previous popup bar.
		customBarViewController.containingPopupBar.customBarViewController = nil;
	}
	
	_customBarViewController.containingPopupBar = nil;
	[self._barDelegate _popupBar:self updateCustomBarController:_customBarViewController cleanup:YES];
	[_customBarViewController.view removeFromSuperview];
	[_customBarViewController removeObserver:self forKeyPath:@"preferredContentSize"];
	
	_customBarViewController = customBarViewController;
	
	if(_customBarViewController != nil)
	{
		_customBarViewController.containingPopupBar = self;
		[self._barDelegate _popupBar:self updateCustomBarController:_customBarViewController cleanup:NO];
		[_customBarViewController addObserver:self forKeyPath:@"preferredContentSize" options:NSKeyValueObservingOptionNew context:NULL];
		
		[_customBarViewController _activeAppearanceDidChange:self.activeAppearance];
		
		[_contentView.contentView insertSubview:_customBarViewController.view aboveSubview:_contentView];
		
		if(_customBarViewController.view.translatesAutoresizingMaskIntoConstraints == NO)
		{
			[NSLayoutConstraint activateConstraints:@[
				[self.contentView.leadingAnchor constraintEqualToAnchor:_customBarViewController.view.leadingAnchor],
				[self.contentView.trailingAnchor constraintEqualToAnchor:_customBarViewController.view.trailingAnchor],
				[self.contentView.centerXAnchor constraintEqualToAnchor:_customBarViewController.view.centerXAnchor],
			]];
		}
	}
	
	[self _updateViewsAfterCustomBarViewControllerUpdate];
	[self setBarStyle:_customBarViewController != nil ? LNPopupBarStyleCustom : LNPopupBarStyleDefault];
	[self _setNeedsAppearanceUpdate];;
	
	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)setLeadingBarButtonItems:(NSArray<UIBarButtonItem*> *)leadingBarButtonItems
{	
	_leadingBarButtonItems = [leadingBarButtonItems copy];
	
	if(@available(iOS 26.0, *))
	{
		[self _setNeedsBarButtonItemLayout];
	}
	else
	{
		[self _layoutBarButtonItems];
	}
}

- (void)setTrailingBarButtonItems:(NSArray<UIBarButtonItem*> *)trailingBarButtonItems
{
	_trailingBarButtonItems = [trailingBarButtonItems copy];
	
	if(@available(iOS 26.0, *))
	{
		[self _setNeedsBarButtonItemLayout];
	}
	else
	{
		[self _layoutBarButtonItems];
	}
}

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	CGSize nextSize = CGSizeMake(size.width, _LNPopupBarHeightForPopupBar(self));
	[self.customBarViewController viewWillTransitionToSize:nextSize withTransitionCoordinator:coordinator];
}

- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[_customBarViewController willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)dealloc
{
	[_customBarViewController _userFacing_viewWillDisappear:NO];
	[_customBarViewController _userFacing_viewDidDisappear:NO];
	[_customBarViewController removeObserver:self forKeyPath:@"preferredContentSize"];
}

- (NSArray<UIBarButtonItem *> *)barButtonItems
{
	return self.trailingBarButtonItems;
}

- (void)_cancelAnyUserInteraction
{
	[self._barDelegate _removeInteractionGestureForPopupBar:self];
}

- (void)set_applySwiftUILayoutFixes:(BOOL)_applySwiftUILayoutFixes
{
	if(__applySwiftUILayoutFixes != _applySwiftUILayoutFixes)
	{
		__applySwiftUILayoutFixes = _applySwiftUILayoutFixes;
		
		[self _setNeedsBarButtonItemLayout];;
	}
}

- (void)_cancelGestureRecognizers
{
	for(UIGestureRecognizer* gr in self.gestureRecognizers)
	{
		BOOL enabled = gr.enabled;
		gr.enabled = NO;
		gr.enabled = enabled;
	}
}

+ (BOOL)isCatalystApp
{
	BOOL isCatalystApp = NSProcessInfo.processInfo.isMacCatalystApp;
	if(@available(iOS 14.0, *))
	{
		isCatalystApp = isCatalystApp || NSProcessInfo.processInfo.iOSAppOnMac;
	}
	
	return isCatalystApp;
}

- (BOOL)isWidePad
{
	if(LNPopupBar.isCatalystApp)
	{
		return YES;
	}
	
	return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

- (void)setLimitFloatingContentWidth:(BOOL)limitFloatingContentWidth
{
	_limitFloatingContentWidth = limitFloatingContentWidth;
	
	[self setNeedsLayout];
}

- (void)setBackgroundViewFrameDuringAnimation:(CGRect)backgroundViewFrameDuringAnimation
{
	_backgroundViewFrameDuringAnimation = backgroundViewFrameDuringAnimation;
	
	[self setNeedsLayout];
}

- (void)setDataSource:(id<LNPopupBarDataSource>)dataSource
{
	_dataSource = dataSource;
	
	_titlePagingController.pagingEnabled = _dataSource != nil && [_dataSource respondsToSelector:@selector(popupBar:popupItemBeforePopupItem:)] && [_dataSource respondsToSelector:@selector(popupBar:popupItemAfterPopupItem:)];
}

#pragma mark UIPointerInteractionDelegate

- (nullable UIPointerRegion *)pointerInteraction:(UIPointerInteraction *)interaction regionForRequest:(UIPointerRegionRequest *)request defaultRegion:(UIPointerRegion *)defaultRegion API_AVAILABLE(ios(13.4))
{
	if(_customBarViewController && [_customBarViewController respondsToSelector:@selector(pointerInteraction:regionForRequest:defaultRegion:)])
	{
		return [_customBarViewController pointerInteraction:interaction regionForRequest:request defaultRegion:defaultRegion];
	}
	
	return defaultRegion;
}

- (UIPointerStyle *)pointerInteraction:(UIPointerInteraction *)interaction styleForRegion:(UIPointerRegion *)region API_AVAILABLE(ios(13.4))
{
	if(_customBarViewController && [_customBarViewController respondsToSelector:@selector(pointerInteraction:styleForRegion:)])
	{
		return [_customBarViewController pointerInteraction:interaction styleForRegion:region];
	}
	
	if(_customBarViewController != nil && _customBarViewController.wantsDefaultHighlightGestureRecognizer == NO)
	{
		return nil;
	}
	
	UIPointerHoverEffect* effect = [UIPointerHoverEffect effectWithPreview:[[UITargetedPreview alloc] initWithView:interaction.view]];
	effect.prefersScaledContent = YES;
	effect.prefersShadow = NO;
	effect.preferredTintMode = UIPointerEffectTintModeNone;
	
	UIPointerShape* shape = nil;//[UIPointerShape shapeWithRoundedRect:interaction.view.frame];
	
	return [UIPointerStyle styleWithEffect:effect shape:shape];
}

- (void)pointerInteraction:(UIPointerInteraction *)interaction willEnterRegion:(UIPointerRegion *)region animator:(id<UIPointerInteractionAnimating>)animator  API_AVAILABLE(ios(13.4))
{
	if(_customBarViewController && [_customBarViewController respondsToSelector:@selector(pointerInteraction:willEnterRegion:animator:)])
	{
		[_customBarViewController pointerInteraction:interaction willEnterRegion:region animator:animator];
		
		return;
	}
	
	if(_customBarViewController == nil || _customBarViewController.wantsDefaultHighlightGestureRecognizer == YES)
	{
		[animator addAnimations:^{
			[self setHighlighted:YES animated:YES];
		}];
	}
}

- (void)pointerInteraction:(UIPointerInteraction *)interaction willExitRegion:(UIPointerRegion *)region animator:(id<UIPointerInteractionAnimating>)animator  API_AVAILABLE(ios(13.4))
{
	if(_customBarViewController && [_customBarViewController respondsToSelector:@selector(pointerInteraction:willExitRegion:animator:)])
	{
		[_customBarViewController pointerInteraction:interaction willExitRegion:region animator:animator];
		
		return;
	}
	
	if(_customBarViewController == nil || _customBarViewController.wantsDefaultHighlightGestureRecognizer == YES)
	{
		[animator addAnimations:^{
			[self setHighlighted:NO animated:YES];
		}];
	}
}

#pragma mark _LNPopupToolbarLayoutDelegate

- (void)_toolbarDidLayoutSubviews
{
	if(_inLayout)
	{
		return;
	}
	
	[self _layoutTitles];
}

@end

#pragma mark LNPopupBarEnvironmentTrait

@implementation LNPopupBarEnvironmentTrait

+ (NSInteger)defaultValue
{
	return LNPopupBarEnvironmentUnspecified;
}

+ (NSString *)name
{
	return @"LNPopupBarEnvironmentTrait";
}

+ (NSString *)identifier
{
	return @"com.LeoNatan.LNPopupController.LNPopupBarEnvironmentTrait";
}

@end

@implementation UITraitCollection (LNPopupBarEnvironmentSupport)

- (LNPopupBarEnvironment)popupBarEnvironment
{
	if(@available(iOS 17.0, *))
	{
		return (LNPopupBarEnvironment)[self valueForNSIntegerTrait:LNPopupBarEnvironmentTrait.class];
	}
	
	return LNPopupBarEnvironmentUnspecified;
}

@end

