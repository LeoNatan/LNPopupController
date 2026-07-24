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
#import "_LNTouchPassthroughView.h"

static const CGFloat LNPopupBarHeightCompact = 40.0;
static const CGFloat LNPopupBarHeightProminent = 64.0;
static const CGFloat LNPopupBarHeightFloating = 58.0;
static const CGFloat LNPopupBarHeightFloatingCompact = 48.0;
static const CGFloat LNPopupBarHeightFloatingCatalyst = 70.0;
static const CGFloat LNPopupBarHeightFloatingCompactCatalyst = 70.0;
static const CGFloat LNPopupBarFloatingPadImageWidth = 44.0;
static const CGFloat LNPopupBarFloatingPadWidthLimitLegacy = 954.0;
static const CGFloat LNPopupBarFloatingPadWidthLimitModern = 700;
static const CGFloat LNPopupBarFloatingPadWidthLimitCatalyst = 910;

static const CGFloat LNPopupBarToolbarHeight = 44;

#ifdef DEBUG
#import "LNPopupDebug.h"
static
BOOL _LNEnableBarLayoutDebug(void)
{
	return [__LNDebugUserDefaults() boolForKey:@"__LNPopupBarEnableLayoutDebug"];
}

static
BOOL _LNEnableBarButtonLayoutDebug(void)
{
	return [__LNDebugUserDefaults() boolForKey:@"__PopupSettingBarEnableButtonLayoutDebug"];
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
		additionalHeight += 6;
	}
	
	if(popupBar.resolvedIsFloating && LNPopupEnvironmentHasGlass() == NO)
	{
		additionalHeight += 6;
	}
	
	CGFloat rv;
	
	switch(popupBar.resolvedStyle)
	{
		case LNPopupBarStyleCompact:
			rv = LNPopupBarHeightCompact + additionalHeight;
			break;
		case LNPopupBarStyleProminent:
			rv = LNPopupBarHeightProminent + additionalHeight;
			break;
		case LNPopupBarStyleFloating:
			if(popupBar.resolvedIsFloating && LNPopupBar.isCatalystApp && LNPopupEnvironmentHasGlass())
			{
				rv = LNPopupBarHeightFloatingCatalyst;
			}
			else
			{
				rv = LNPopupBarHeightFloating + additionalHeight;
			}
			break;
		case LNPopupBarStyleFloatingCompact:
			if(popupBar.resolvedIsFloating && LNPopupBar.isCatalystApp && LNPopupEnvironmentHasGlass())
			{
				rv = LNPopupBarHeightFloatingCompactCatalyst;
			}
			else
			{
				rv = LNPopupBarHeightFloatingCompact + additionalHeight;
			}
			break;
		default:
			abort();
	}
	
	return __LNPopupScaledFloat(rv, popupBar.traitCollection);
}

LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style, LNPopupBar* popupBar, BOOL* isFloating, BOOL* isCompact, BOOL* isCustom)
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
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone || popupBar.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
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

LNAlwaysInline
LNPopupBarProgressViewStyle _LNPopupResolveProgressViewStyleFromProgressViewStyle(LNPopupBarProgressViewStyle style)
{
	LNPopupBarProgressViewStyle rv = style;
	if(rv == LNPopupBarProgressViewStyleDefault)
	{
		rv = LNPopupBarProgressViewStyleNone;
	}
	return rv;
}

#if DEBUG

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

#endif

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
	
	_barStyle = barStyle;
		
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle, self, &_resolvedIsFloating, &_resolvedIsCompact, &_resolvedIsCustom);
	
	if(_resolvedStyle != resolvedStyle)
	{
		_resolvedStyle = resolvedStyle;
		
		[self _setNeedsBarButtonItemLayout];
		[self _setNeedsTitleLayoutByRemovingLabels:NO];
		
		[self _fixupSwiftUIControllersWithBarStyle];
		
		[_barContainingController.bottomDockingViewForPopup_nocreateOrDeveloper setNeedsLayout];
		[_barContainingController.view setNeedsLayout];
		
		[self _setNeedsAppearanceUpdate];
		
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
}

- (void)_setHackyMarginsInSuperviewSemanticContext:(NSDirectionalEdgeInsets)hackyMargins
{
	if(NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(__hackyMarginsInSuperviewSemanticContext, hackyMargins))
	{
		return;
	}
	
	__hackyMarginsInSuperviewSemanticContext = hackyMargins;
	
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
		LNDynamicSubclass(self, _LNTouchPassthroughView.class);
		
		self.preservesSuperviewLayoutMargins = YES;
		self.clipsToBounds = NO;
		
		self.usesContentControllersAsDataSource = YES;
		self.allowHapticFeedbackGenerationOnItemPaging = YES;
		
		self.limitFloatingContentWidth = YES;
		self.inheritsBottomBarMetrics = YES;
		
		_inheritsAppearanceFromDockingView = YES;
		_standardAppearance = [LNPopupBarAppearance new];
		
		if(!LNPopupEnvironmentHasGlass())
		{
			_backgroundView = [[_LNPopupBarBackgroundView alloc] initWithEffect:nil];
			_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_backgroundView.userInteractionEnabled = NO;
			[self addSubview:_backgroundView];
		}
		
		_layoutContainer = [_LNTouchPassthroughView new];
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
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle, self, &_resolvedIsFloating, &_resolvedIsCompact, &_resolvedIsCustom);
		
		_toolbar = [[_LNPopupToolbar alloc] initWithFrame:CGRectMake(0, 0, 400, LNPopupBarToolbarHeight)];
		_toolbar._layoutDelegate = self;
		[_toolbar.standardAppearance configureWithTransparentBackground];
		[self _resetToolbarItemSpacing];
		
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

		_progressView = [[_LNPopupBarProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
#if TARGET_OS_MACCATALYST
		if(@available(iOS 26.0, *))
		{
			_progressView.clipsToBounds = YES;
			_progressView.cornerConfiguration = [UICornerConfiguration capsuleConfiguration];
		}
		_progressView.trackTintColor = UIColor.tertiaryLabelColor;
#else
		_progressView.trackImage = [UIImage new];
#endif
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

- (NSString *)description
{
	NSMutableString* rv = super.description.mutableCopy;
	
	[rv appendFormat:@" popupItem: %@", self.popupItem.description];
	
	return rv;
}

- (NSString *)debugDescription
{
	return self.description;
}

- (void)setFrame:(CGRect)frame
{
	if(frame.origin.y == -0)
	{
		frame.origin.y = 0;
	}
	
	if(CGRectEqualToRect(frame, super.frame) == YES)
	{
		return;
	}
	
	[super setFrame:frame];
}

- (void)setCenter:(CGPoint)center
{
	if(CGPointEqualToPoint(center, super.center) == YES)
	{
		return;
	}
	
	[super setCenter:center];
}

- (BOOL)inheritsBottomBarMetrics
{
	if(LNPopupEnvironmentHasGlass())
	{
		return _inheritsBottomBarMetrics;
	}
	
	return NO;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
	
	[self._barDelegate _traitCollectionForPopupBarDidChange:self];
	
	if(previousTraitCollection.horizontalSizeClass != self.traitCollection.horizontalSizeClass && self.barStyle == LNPopupBarStyleDefault)
	{
		//Trigger a refresh to the default style.
		self.barStyle = self.barStyle;
	}
	
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
	UIEdgeInsets layoutMargins = __LNPopupEnvironmentLayoutInsets(self, YES);
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
	
	if(LNPopupBar.isCatalystApp && self.traitCollection.userInterfaceIdiom != UIUserInterfaceIdiomMac)
	{
		rv.leading += 10;
		rv.trailing += 10;
	}
	
	return rv;
}

- (void)_resetToolbarItemSpacing
{
#if TARGET_OS_MACCATALYST
	CGFloat spacing = 4.0;
#else
	CGFloat spacing = 8.0;
#endif
	BOOL hasSwiftUI = _swiftuiHiddenLeadingController != nil || _swiftuiHiddenTrailingController != nil;
	
	if(hasSwiftUI)
	{
		if(LNPopupEnvironmentHasGlass())
		{
			spacing = 12.0;
		}
		else if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 18)
		{
			spacing = 0.0;
		}
	}
	_toolbar.itemSpacing = spacing;
}

- (void)setNeedsLayout
{
	[super setNeedsLayout];
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
		frame = UIEdgeInsetsInsetRect(frame, _LNEdgeInsetsFromDirectionalEdgeInsets(self.superview, __hackyMarginsInSuperviewSemanticContext));
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
		if(LNPopupBar.isCatalystApp)
		{
			limitToUse = __LNPopupScaledFloat(LNPopupBarFloatingPadWidthLimitCatalyst, self.traitCollection);
		}
		else if(LNPopupEnvironmentHasGlass())
		{
			limitToUse = LNPopupBarFloatingPadWidthLimitModern;
		}
		else
		{
			limitToUse = LNPopupBarFloatingPadWidthLimitLegacy;
		}
		
		if(self.limitFloatingContentWidth == YES && contentFrame.size.width > limitToUse && self.isWidePad)
		{
			CGFloat d = (contentFrame.size.width - limitToUse) / 2;
			contentFrame = UIEdgeInsetsInsetRect(contentFrame, UIEdgeInsetsMake(0, d, 0, d));
		}
		
		if(LNPopupEnvironmentHasGlass())
		{
			_contentView.effectView.clipsToBounds = YES;
			if(@available(iOS 26.0, *))
			{
				_contentView.effectView.cornerConfiguration = [self.activeAppearance floatingBackgroundCornerConfigurationForCustomBar:_resolvedIsCustom barHeight:barHeight screen:self.window.screen wantsFullWidth:self.customBarWantsFullBarWidth margins:self.layoutMargins];
				_floatingBackgroundShadowView.cornerConfiguration = _contentView.effectView.cornerConfiguration;
			}
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
				CGFloat inset = (!_resolvedIsCompact ? self.safeAreaInsets.right : self.safeAreaInsets.right);
				insets = UIEdgeInsetsMake(0, inset, 0, inset);
			}
			else
			{
				CGFloat inset = (!_resolvedIsCompact ? self.safeAreaInsets.left : self.safeAreaInsets.left);
				insets = UIEdgeInsetsMake(0, inset, 0, inset);
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
	
	if(CGRectEqualToRect(imageFrameBefore, self.imageView.frame) == NO || wasImageViewHidden != self.imageView.isHidden)
	{
		_needsLabelsLayout = YES;
	}
	
	if(_needsBarButtonItemLayout)
	{
		_needsLabelsLayout = YES;
		
		[self _layoutBarButtonItems];
	}
	
	BOOL isLTR = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionLeftToRight;
	
	UIBarButtonItem* leftFirstItem;
	UIBarButtonItem* rightLastItem;
	UIView* leftFirst;
	UIView* rightLast;
	UIView* leftViewFirst;
	UIView* leftViewLast;
	UIView* rightViewFirst;
	UIView* rightViewLast;
	if(isLTR)
	{
		[self _getLeftmostView:&leftViewFirst rightmostView:&leftViewLast fromBarButtonItems:self.leadingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:&rightViewLast fromBarButtonItems:self.trailingBarButtonItems];
		leftFirstItem = self.leadingBarButtonItems.firstObject;
		rightLastItem = self.trailingBarButtonItems.lastObject;
	}
	else
	{
		[self _getLeftmostView:&leftViewFirst rightmostView:&leftViewLast fromBarButtonItems:self.trailingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:&rightViewLast fromBarButtonItems:self.leadingBarButtonItems];
		leftFirstItem = self.trailingBarButtonItems.firstObject;
		rightLastItem = self.leadingBarButtonItems.lastObject;
	}
	leftFirst = [_toolbar _viewForBarButtonItem:leftFirstItem];
	rightLast = [_toolbar _viewForBarButtonItem:rightLastItem];
	
	BOOL isFirstHidden = NO;
	BOOL isLastHidden = NO;
	if(@available(iOS 16, *))
	{
		isFirstHidden = leftFirstItem.isHidden;
		isLastHidden = rightLastItem.isHidden;
	}
	BOOL firstCustomAndUnhidden = leftFirstItem != nil && !isFirstHidden && leftFirst != nil && [self _isBarButtonViewStandardItem:leftFirst] == NO;
	BOOL lastCustomAndUnhidden = rightLastItem != nil && !isLastHidden && rightLast != nil && [self _isBarButtonViewStandardItem:rightLast] == NO;
	BOOL needsLeftPadding = firstCustomAndUnhidden == NO && leftViewFirst && [self _isBarButtonViewPadded:leftViewFirst inEdge:UIRectEdgeLeft] == NO;
	BOOL needsRightPadding = lastCustomAndUnhidden == NO && rightViewLast && [self _isBarButtonViewPadded:rightViewLast inEdge:UIRectEdgeRight] == NO;
	
	static constexpr CGFloat padding = 16;
	
	CGRect bounds = CGRectMake(0, 0, _contentView.bounds.size.width, LNPopupBarToolbarHeight);
	CGPoint center = CGPointMake(CGRectGetMidX(_contentView.bounds), CGRectGetMidY(_contentView.bounds));
	
	if(needsLeftPadding)
	{
		bounds.size.width -= padding;
		center.x += padding / 2;
	}
	
	if(needsRightPadding)
	{
		bounds.size.width -= padding;
		center.x -= padding / 2;
	}
	
	_toolbar.bounds = bounds;
	_toolbar.center = center;
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
	if(@available(iOS 26.0, *))
	{
		cornerRadius = [_contentView.effectView effectiveRadiusForCorner:UIRectCornerAllCorners];
	}
	else
	{
		cornerRadius = _contentView.cornerRadius / 2.5;
	}
	
#if !TARGET_OS_MACCATALYST
	CGFloat width = 0;
	CGFloat height = 0;
	CGFloat offset = 0;
	CGFloat offsetAfter = 0;
#endif
	if(_resolvedIsFloating)
	{
		[_contentView.contentView insertSubview:_progressView aboveSubview:_toolbar];
		
#if !TARGET_OS_MACCATALYST
		if(LNPopupEnvironmentHasGlass())
		{
			offset = -10;
		}
		width = _contentView.bounds.size.width;
		height = _contentView.bounds.size.height;
#endif
	}
	else
	{
		[self insertSubview:_progressView aboveSubview:_contentView];

#if !TARGET_OS_MACCATALYST
		offset = self.safeAreaInsets.left;
		width = self.bounds.size.width - self.safeAreaInsets.left - self.safeAreaInsets.right;
		height = self.bounds.size.height;
#endif
	}
	
	CGFloat progressViewHeight = [_progressView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
#if TARGET_OS_MACCATALYST
	UIEdgeInsets titleInsets = [self contentInsetsIncludingImage:NO];
	CGRect progressViewFrame = UIEdgeInsetsInsetRect(_contentView.bounds, titleInsets);
	
	CGFloat position = 4;
	if(self.progressViewStyle == LNPopupBarProgressViewStyleTop)
	{
		progressViewFrame.origin.y = position;
		
	}
	else
	{
		progressViewFrame.origin.y = progressViewFrame.size.height - position - progressViewHeight;
	}
	progressViewFrame.size.height = progressViewHeight;
	
	_progressView.frame = progressViewFrame;
#else
	if(self.progressViewStyle == LNPopupBarProgressViewStyleTop)
	{
		_progressView.frame = CGRectMake(cornerRadius + offset, 0, width - 2 * (cornerRadius + offset), progressViewHeight);
	}
	else
	{
		_progressView.frame = CGRectMake(cornerRadius + offset, height - progressViewHeight, width - 2 * (cornerRadius + offset), progressViewHeight);
	}
#endif
	
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
	
	[self _layoutImageView];
	[self _layoutTitles];
	
	if(LNPopupEnvironmentHasGlass())
	{
		[_contentView.contentView bringSubviewToFront:_progressView];
	}
	
	_effectiveContentSize = _contentView.bounds.size;
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
	
	_titlesController = _titlePagingController.viewControllers.firstObject;
	//Clear the popup item so that it loads its values from the popup bar's popup item.
	_titlesController.popupItem = nil;
	
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
		
		if(@available(iOS 26.0, *))
		if(effect.ln_isGlass)
		{
			auto wrapper = [_LNPopupGlassWrapperEffect wrapperWithEffect:effect];
			wrapper.disableForeground = self.activeAppearance.isFloatingBarShineEnabled;
			effect = wrapper;
		}
		
		_contentView.effect = effect;
		
		if(@available(iOS 26.0, *))
		{
			_resolvedIsGlass = effect.ln_isGlass;
			_resolvedIsGlassInteractive = _resolvedIsGlass && ((UIGlassEffect*)effect).isInteractive;
		}
			
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
	if([_attributedTitle isEqualToAttributedString:attributedTitle])
	{
		return;
	}
	
	_attributedTitle = [attributedTitle copy];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
	if([_attributedSubtitle isEqualToAttributedString:attributedSubtitle])
	{
		return;
	}
	
	_attributedSubtitle = [attributedSubtitle copy];
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
}

- (void)setImage:(UIImage *)image
{
	if(_image == image)
	{
		return;
	}
	
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

- (void)setSwiftuiTitleContentViewController:(UIViewController *)swiftuiTitleContentViewController
{
	if(_swiftuiTitleContentViewController == swiftuiTitleContentViewController)
	{
		return;
	}
	
	if(_swiftuiTitleContentViewController.view != nil)
	{
		[_swiftuiTitleContentViewController.view removeFromSuperview];
	}
	
	_swiftuiTitleContentViewController = swiftuiTitleContentViewController;
	
	if(_swiftuiTitleContentViewController != nil)
	{
		[_swiftuiTitleContentViewController.view _ln_freezeInsets];
		_swiftuiTitleContentViewController.view.backgroundColor = UIColor.clearColor;
		_swiftuiTitleContentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	}
	
	[self _setNeedsTitleLayoutByRemovingLabels:YES];
}

- (void)setSwiftuiInheritedFont:(UIFont *)swiftuiInheritedFont
{
	if(_swiftuiInheritedFont == swiftuiInheritedFont || [_swiftuiInheritedFont isEqual:swiftuiInheritedFont])
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
	
	[self _resetToolbarItemSpacing];
	
	if(_swiftuiHiddenLeadingController != nil)
	{
		_swiftuiHiddenLeadingController.view.frame = CGRectMake(-4000, 0, 400, 400);
		[self.window addSubview:_swiftuiHiddenLeadingController.view];
		[_swiftuiHiddenLeadingController.view layoutSubviews];
	}
	
//	if(_swiftHacksWindow1 != nil)
//	{
//		_swiftHacksWindow1.hidden = YES;
//		_swiftHacksWindow1 = nil;
//	}
//	
//	if(_swiftuiHiddenLeadingController != nil)
//	{
//		[UIView performWithoutAnimation:^{
//			_swiftHacksWindow1 = [[UIWindow alloc] initWithWindowScene:self.window.windowScene];
//			_swiftHacksWindow1.frame = CGRectMake(-4000, 0, 400, 400);
//			_swiftHacksWindow1.rootViewController = _swiftuiHiddenLeadingController;
//			_swiftHacksWindow1.hidden = NO;
//			_swiftHacksWindow1.alpha = 0.0;
//			[_swiftHacksWindow1 layoutSubviews];
//		}];
//	}
	
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
	
	[self _resetToolbarItemSpacing];
	
	if(_swiftuiHiddenTrailingController != nil)
	{
		_swiftuiHiddenTrailingController.view.frame = CGRectMake(4000, 0, 400, 400);
		[self.window addSubview:_swiftuiHiddenTrailingController.view];
		[_swiftuiHiddenTrailingController.view layoutSubviews];
	}
	
//	if(_swiftHacksWindow2 != nil)
//	{
//		_swiftHacksWindow2.hidden = YES;
//		_swiftHacksWindow2 = nil;
//	}
//	
//	if(_swiftuiHiddenTrailingController != nil)
//	{
//		[UIView performWithoutAnimation:^{
//			_swiftHacksWindow2 = [[UIWindow alloc] initWithWindowScene:self.window.windowScene];
//			_swiftHacksWindow2.frame = CGRectMake(-4000, 0, 400, 400);
//			_swiftHacksWindow2.rootViewController = _swiftuiHiddenTrailingController;
//			_swiftHacksWindow2.hidden = NO;
//			_swiftHacksWindow2.alpha = 0.0;
//			[_swiftHacksWindow2 layoutSubviews];
//		}];
//	}
	
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
}

static NSPredicate* _LNNonSpaceAndNonHiddenItemsPredicate(BOOL removeHidden)
{
	static NSPredicate* nonSpaceFilterPredicate;
	static NSPredicate* includingHidden;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		nonSpaceFilterPredicate = [NSPredicate predicateWithFormat:@"isSystemItem == NO || !(systemItem IN %@)", @[@(UIBarButtonSystemItemFixedSpace), @(UIBarButtonSystemItemFlexibleSpace)]];
		
		if(@available(iOS 16.0, *))
		{
			includingHidden = [NSCompoundPredicate andPredicateWithSubpredicates:@[nonSpaceFilterPredicate, [NSPredicate predicateWithFormat:@"isHidden == NO"]]];
		}
		else
		{
			includingHidden = nonSpaceFilterPredicate;
		}
	});
	
	return removeHidden ? includingHidden : nonSpaceFilterPredicate;
}

static Class systemBarButtonItemButtonClass = NSClassFromString(LNPopupHiddenString("_UIButtonBarButton"));

- (BOOL)_isBarButtonViewStandardItem:(UIView*)barButtonView
{
	return [barButtonView isKindOfClass:systemBarButtonItemButtonClass] || [barButtonView isKindOfClass:adaptorView];
}

- (BOOL)_isBarButtonViewPadded:(UIView*)barButtonView inEdge:(UIRectEdge)edge
{
	if([self _isBarButtonViewStandardItem:barButtonView] == NO)
	{
		return NO;
	}

	UIView* subview = barButtonView.subviews.firstObject;
	CGPoint subviewCenter = subview.center;
	CGPoint barButtonCenter = CGPointMake(CGRectGetMidX(barButtonView.bounds), CGRectGetMidY(barButtonView.bounds));
	CGFloat widthDelta = barButtonView.bounds.size.width - subview.bounds.size.width;
	
	if(abs(subviewCenter.x - barButtonCenter.x) < 0.005)
	{
		return widthDelta > 25;
	}
	else
	{
		if(edge == UIRectEdgeLeft)
		{
			return subviewCenter.x > barButtonCenter.x;
		}
		else
		{
			return subviewCenter.x < barButtonCenter.x;
		}
	}
}

- (void)_getLeftmostView:(UIView* __strong *)leftmostView rightmostView:(UIView* __strong *)rightmostView fromBarButtonItems:(NSArray<UIBarButtonItem*>*)barButtonItems
{
	NSArray<UIBarButtonItem*>* filtered = [barButtonItems filteredArrayUsingPredicate:_LNNonSpaceAndNonHiddenItemsPredicate(true)];
	
	if(leftmostView != NULL) { *leftmostView = [_toolbar _viewForBarButtonItem:filtered.firstObject]; }
	if(rightmostView != NULL) { *rightmostView = [_toolbar _viewForBarButtonItem:filtered.lastObject]; }
}

- (BOOL)_needSwiftUIFixesForBarButtonItemView:(UIView*)view
{
	return [view _ln_isObjectFromSwiftUI] || [view.subviews.firstObject _ln_isObjectFromSwiftUI];
}

- (UIEdgeInsets)contentInsetsIncludingImage:(BOOL)includeImage
{
	BOOL isLTR = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionLeftToRight;
		
	[_toolbar layoutIfNeeded];
	
	UIBarButtonItem* leftLastItem;
	UIBarButtonItem* rightFirstItem;
	UIView* leftLast;
	UIView* rightFirst;
	UIView* leftViewFirst;
	UIView* leftViewLast;
	UIView* rightViewFirst;
	UIView* rightViewLast;
	if(isLTR)
	{
		[self _getLeftmostView:&leftViewFirst rightmostView:&leftViewLast fromBarButtonItems:self.leadingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:&rightViewLast fromBarButtonItems:self.trailingBarButtonItems];
		leftLastItem = self.leadingBarButtonItems.lastObject;
		rightFirstItem = self.trailingBarButtonItems.firstObject;
	}
	else
	{
		[self _getLeftmostView:&leftViewFirst rightmostView:&leftViewLast fromBarButtonItems:self.trailingBarButtonItems];
		[self _getLeftmostView:&rightViewFirst rightmostView:&rightViewLast fromBarButtonItems:self.leadingBarButtonItems];
		leftLastItem = self.trailingBarButtonItems.lastObject;
		rightFirstItem = self.leadingBarButtonItems.firstObject;
	}
	leftLast = [_toolbar _viewForBarButtonItem:leftLastItem];
	rightFirst = [_toolbar _viewForBarButtonItem:rightFirstItem];
	
#if DEBUG
	if(_LNEnableBarButtonLayoutDebug())
	{
		leftViewFirst.layer.borderWidth = 2.0;
		leftViewFirst.layer.borderColor = UIColor.brownColor.CGColor;
		leftViewFirst.backgroundColor = [UIColor.brownColor colorWithAlphaComponent:0.5];
		
		leftViewLast.layer.borderWidth = 2.0;
		leftViewLast.layer.borderColor = UIColor.brownColor.CGColor;
		leftViewLast.backgroundColor = [UIColor.brownColor colorWithAlphaComponent:0.5];
		
		rightViewFirst.layer.borderWidth = 2.0;
		rightViewFirst.layer.borderColor = UIColor.purpleColor.CGColor;
		rightViewFirst.backgroundColor = [UIColor.purpleColor colorWithAlphaComponent:0.5];
		
		rightViewLast.layer.borderWidth = 2.0;
		rightViewLast.layer.borderColor = UIColor.purpleColor.CGColor;
		rightViewLast.backgroundColor = [UIColor.purpleColor colorWithAlphaComponent:0.5];
	}
	else
	{
		leftViewFirst.layer.borderWidth = 0.0;
		leftViewFirst.layer.borderColor = nil;
		leftViewFirst.backgroundColor = nil;
		
		leftViewLast.layer.borderWidth = 0.0;
		leftViewLast.layer.borderColor = nil;
		leftViewLast.backgroundColor = nil;
		
		rightViewFirst.layer.borderWidth = 0.0;
		rightViewFirst.layer.borderColor = nil;
		rightViewFirst.backgroundColor = nil;
		
		rightViewLast.layer.borderWidth = 0.0;
		rightViewLast.layer.borderColor = nil;
		rightViewLast.backgroundColor = nil;
	}
#endif
	
	[leftViewLast.superview layoutIfNeeded];
	[rightViewFirst.superview layoutIfNeeded];
	
	BOOL isLeftHidden = NO;
	BOOL isRightHidden = NO;
	if(@available(iOS 16, *))
	{
		isLeftHidden = leftLastItem.isHidden;
		isRightHidden = rightFirstItem.isHidden;
	}
	BOOL lastLeftLastSystemAndUnhidden = leftLast != nil && isLeftHidden == NO && [self _isBarButtonViewStandardItem:leftLast] && rightViewFirst == nil;
	BOOL firstRightFirstSystemAndUnhidden = rightFirst != nil && isRightHidden == NO && [self _isBarButtonViewStandardItem:rightFirst] && leftViewLast == nil;
	CGFloat extraLeftPadding = lastLeftLastSystemAndUnhidden ? 12 : leftViewLast && [self _isBarButtonViewPadded:leftViewLast inEdge:UIRectEdgeRight] == NO ? -8 : 0;
	CGFloat extraRightPadding = firstRightFirstSystemAndUnhidden ? 12 : rightViewFirst && [self _isBarButtonViewPadded:rightViewFirst inEdge:UIRectEdgeLeft] == NO ? -8 : 0;
	
	CGRect leftViewFrame = CGRectZero;
	if(leftViewLast != nil)
	{
		leftViewFrame = CGRectInset([_contentView convertRect:leftViewLast.bounds fromView:leftViewLast], extraLeftPadding, 0);
	}
	
	CGRect rightViewFrame = CGRectMake(_contentView.bounds.size.width, 0, 0, 0);
	if(rightViewFirst != nil)
	{
		rightViewFrame = CGRectInset([_contentView convertRect:rightViewFirst.bounds fromView:rightViewFirst], extraRightPadding, 0);
	}
	
	CGFloat emptyPadding = 0.0;
	
	if(LNPopupEnvironmentHasGlass())
	{
		emptyPadding = 16;
	}
	else
	{
		emptyPadding = _resolvedIsFloating ? 8 : 20;
	}
	
	UIEdgeInsets rv = UIEdgeInsetsMake(0,
									   MAX(leftViewFrame.origin.x + leftViewFrame.size.width, emptyPadding),
									   0,
									   MAX(_contentView.bounds.size.width - rightViewFrame.origin.x, emptyPadding));
	
	if(includeImage && self.imageView.isHidden == NO)
	{
		CGFloat imageToTitlePadding = _resolvedIsFloating && (!LNPopupEnvironmentHasGlass() || _resolvedIsCompact) ? 8 : 16;
		
		if(isLTR)
		{
			rv.left += self.imageView.bounds.size.width + imageToTitlePadding;
		}
		else
		{
			rv.right += self.imageView.bounds.size.width + imageToTitlePadding;
		}
	}

	return rv;
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIFont*)_titleFont
{
	if(_swiftuiInheritedFont)
	{
		return _swiftuiInheritedFont;
	}
	
	if(LNPopupBar.isCatalystApp)
	{
		UIFont* headline = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont systemFontOfSize:headline.pointSize weight:UIFontWeightMedium]];
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
	
	return [[UIFontMetrics metricsForTextStyle:textStyle] scaledFontForFont:[UIFont systemFontOfSize:__LNPopupScaledFloat(fontSize, self.traitCollection) weight:fontWeight]];
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
		return [UIFont fontWithDescriptor:_swiftuiInheritedFont.fontDescriptor size:_swiftuiInheritedFont.pointSize - __LNPopupScaledFloat(2.5, self.traitCollection)];
	}
	
	if(LNPopupBar.isCatalystApp)
	{
		UIFont* callout = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
		return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCallout] scaledFontForFont:[UIFont systemFontOfSize:callout.pointSize weight:UIFontWeightRegular]];
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
	
	return [[UIFontMetrics metricsForTextStyle:textStyle] scaledFontForFont:[UIFont systemFontOfSize:__LNPopupScaledFloat(fontSize, self.traitCollection) weight:fontWeight]];
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIColor*)_subtitleColor
{
	return UIColor.secondaryLabelColor;
}

static
BOOL _LNRectEqualToRectWithinTolerance(CGRect rect1, CGRect rect2, CGFloat tolerance)
{
	if(CGRectEqualToRect(rect1, rect2))
	{
		return YES;
	}
	
	
	if(CGPointEqualToPoint(rect1.origin, rect2.origin) && rect1.size.height == rect2.size.height && abs(rect1.size.width-rect2.size.width) <= tolerance)
	{
		return YES;
	}
	
	return NO;
}

- (void)_layoutTitles
{
	UIEdgeInsets titleInsets = [self contentInsetsIncludingImage:YES];
	
#if DEBUG
	if(_LNEnableBarTitleLayoutDebug())
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
		[_titlesController setNeedsTitleLayoutRemovingLabels:_needsLabelsLayoutRemove];
		
		_needsLabelsLayoutRemove = NO;
		_needsLabelsLayout = NO;
	}
	
	CGRect frameBefore = _titlePagingController.view.frame;
	
	CGRect frame = UIEdgeInsetsInsetRect(_contentView.bounds, titleInsets);
	//Without this, UIPageViewController breaks in spectacular ways with certain non-round frame sizes 🤦‍♂️
	frame.size.width = round(frame.size.width);
	
#if TARGET_OS_MACCATALYST
	if(CGRectEqualToRect(frameBefore, frame) == NO)
#else
	if(_LNRectEqualToRectWithinTolerance(frameBefore, frame, 1) == NO)
#endif
	{
		_titlePagingController.view.alpha = frame.size.width < 44 ? 0.0 : 1.0;
		_titlePagingController.view.frame = frame;
		
		BOOL hasSwiftUI = _swiftuiHiddenLeadingController != nil || _swiftuiHiddenTrailingController != nil;
		
		if(hasSwiftUI && UIView.inheritedAnimationDuration == 0.0)
		{
			[UIView animateWithDuration:0.1 animations:^{
				[_titlePagingController.view layoutIfNeeded];
				[_titlesController.view layoutIfNeeded];
			}];
		}
		else
		{
			[_titlePagingController.view layoutIfNeeded];
			[_titlesController.view layoutIfNeeded];
		}
	}
}

- (void)_setNeedsTitleLayoutByRemovingLabels:(BOOL)remove
{
	_needsLabelsLayout = YES;
	
	if(remove)
	{
		_needsLabelsLayoutRemove = YES;
	}
	
	if(_inLayout == NO)
	{
		[self setNeedsLayout];
	}
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
	
	if(_resolvedIsFloating && (_resolvedIsCompact == NO || LNPopupBar.isCatalystApp) && self.isWidePad == YES)
	{
		maxImageDimension = __LNPopupScaledFloat(LNPopupBarFloatingPadImageWidth, self.traitCollection);
	}
	
	CGSize imageViewSize = [self _imageViewSizeWithMaxWidth:maxImageDimension maxHeight:maxImageDimension];
	
	UIEdgeInsets buttonInsets = [self contentInsetsIncludingImage:NO];
	
	CGRect frame = UIEdgeInsetsInsetRect(_contentView.bounds, buttonInsets);
	_imageView.alpha = frame.size.width < imageViewSize.width ? 0.0 : 1.0;
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		_imageView.center = CGPointMake(buttonInsets.left + imageViewSize.width / 2, barHeight / 2);
	}
	else
	{
		_imageView.center = CGPointMake(_contentView.bounds.size.width - buttonInsets.right - imageViewSize.width / 2, barHeight / 2);
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
	
	if(_inLayout == NO)
	{
		[self setNeedsLayout];
	}
}

- (void)_layoutBarButtonItems
{
	UIUserInterfaceLayoutDirection barItemsLayoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_barItemsSemanticContentAttribute];
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];

	BOOL normalButtonsOrder = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight || barItemsLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	
	NSEnumerationOptions enumerationOptions = normalButtonsOrder ? 0 : NSEnumerationReverse;
	
	NSMutableArray* items = [NSMutableArray new];
	
	UIBarButtonItem* flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

	[self.leadingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	[items addObject:flexibleSpacer];

	[self.trailingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	if(ln_unavailable(iOS 27.0, *))
	{
		for(UIBarButtonItem* item in items)
		{
			UIView* view = [item valueForKey:@"view"];
			if(view == nil)
			{
				continue;
			}
			
			if([self _needSwiftUIFixesForBarButtonItemView:view])
			{
				view.translatesAutoresizingMaskIntoConstraints = NO;
			}
		}
	}
	
	[_toolbar setItems:items animated:_animatesItemSetter];
	
	if(LNPopupEnvironmentHasGlass())
	{
		//This causes layout issues on iOS 18.x and below in LNPopupUI. So limit to 26.0+ (it's for animation anyway)
		[_toolbar layoutIfNeeded];
	}
	
	[self _setNeedsTitleLayoutByRemovingLabels:NO];
	
	_needsBarButtonItemLayout = NO;
	_animatesItemSetter = NO;
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
	
//	if(@available(iOS 26.0, *))
	{
		[self _setNeedsBarButtonItemLayout];
	}
//	else
//	{
//		[self _layoutBarButtonItems];
//	}
}

- (void)setTrailingBarButtonItems:(NSArray<UIBarButtonItem*> *)trailingBarButtonItems
{
	_trailingBarButtonItems = [trailingBarButtonItems copy];
	
//	if(@available(iOS 26.0, *))
	{
		[self _setNeedsBarButtonItemLayout];
	}
//	else
//	{
//		[self _layoutBarButtonItems];
//	}
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
	//Keep this for legacy LNPopupUI sake
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
#if TARGET_OS_MACCATALYST
	return YES;
#else
	static BOOL isCatalystApp;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		isCatalystApp = NSProcessInfo.processInfo.isMacCatalystApp;
		if(@available(iOS 14.0, *))
		{
			isCatalystApp = isCatalystApp || NSProcessInfo.processInfo.iOSAppOnMac;
		}
	});
	
	return isCatalystApp;
#endif
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

	if(@available(iOS 27.0, *))
	{
		return nil;
	}
	else
	{
		UIPointerHoverEffect* effect = [UIPointerHoverEffect effectWithPreview:[[UITargetedPreview alloc] initWithView:interaction.view]];
		effect.prefersScaledContent = YES;
		effect.prefersShadow = NO;
		effect.preferredTintMode = UIPointerEffectTintModeNone;
		
		UIPointerShape* shape = nil;//[UIPointerShape shapeWithRoundedRect:interaction.view.frame];
		
		return [UIPointerStyle styleWithEffect:effect shape:shape];
	}
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
	
	[self setNeedsLayout];
	[self layoutIfNeeded];
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

#pragma mark Deprecations

@implementation LNPopupBar (Deprecations)

- (BOOL)supportsMinimization
{
	return self.inheritsBottomBarMetrics;
}

- (void)setSupportsMinimization:(BOOL)supportsMinimization
{
	self.inheritsBottomBarMetrics = supportsMinimization;
}

@end
