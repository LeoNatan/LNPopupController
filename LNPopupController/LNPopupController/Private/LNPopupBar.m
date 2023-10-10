//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "LNPopupCustomBarViewController+Private.h"
#import "MarqueeLabel.h"
#import "_LNPopupSwizzlingUtils.h"
#import "NSAttributedString+LNPopupSupport.h"

#ifdef DEBUG
static BOOL _LNEnableBarLayoutDebug(void)
{
	return [NSUserDefaults.standardUserDefaults boolForKey:@"__LNPopupBarEnableLayoutDebug"];
}
#endif

CGFloat _LNPopupBarHeightForPopupBar(LNPopupBar* popupBar)
{
	if(popupBar.customBarViewController) { return popupBar.customBarViewController.preferredContentSize.height; }
	
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
			UIContentSizeCategoryExtraExtraExtraLarge : @9,
			UIContentSizeCategoryAccessibilityMedium : @18,
			UIContentSizeCategoryAccessibilityLarge : @27,
			UIContentSizeCategoryAccessibilityExtraLarge : @36,
			UIContentSizeCategoryAccessibilityExtraExtraLarge : @45,
			UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @54,
		};
	});
	additionalHeight = [additionalHeightMapping[popupBar.traitCollection.preferredContentSizeCategory] doubleValue];
	
	switch(popupBar.resolvedStyle)
	{
		case LNPopupBarStyleCompact:
			return LNPopupBarHeightCompact + additionalHeight;
		case LNPopupBarStyleFloating:
			return LNPopupBarHeightFloating + additionalHeight;
		default:
			return LNPopupBarHeightProminent + additionalHeight;
	}
}

#ifndef LNPopupControllerEnforceStrictClean
//_effectWithStyle:tintColor:invertAutomaticStyle:
static NSString* const _eWSti = @"X2VmZmVjdFdpdGhTdHlsZTp0aW50Q29sb3I6aW52ZXJ0QXV0b21hdGljU3R5bGU6";
static SEL _effectWithStyle_tintColor_invertAutomaticStyle_SEL;
static id(*_effectWithStyle_tintColor_invertAutomaticStyle)(id, SEL, NSUInteger, UIColor*, BOOL);

__attribute__((constructor))
static void __setupFunction(void)
{
	_effectWithStyle_tintColor_invertAutomaticStyle_SEL = NSSelectorFromString(_LNPopupDecodeBase64String(_eWSti));
	Method m = class_getClassMethod(UIBlurEffect.class, _effectWithStyle_tintColor_invertAutomaticStyle_SEL);
	_effectWithStyle_tintColor_invertAutomaticStyle = (void*)method_getImplementation(m);
}
#endif

@interface _LNPopupBarContentView : _LNPopupBarBackgroundView @end
@implementation _LNPopupBarContentView @end

@interface _LNPopupBarTitlesView : UIStackView @end
@implementation _LNPopupBarTitlesView @end

@interface _LNPopupBarShadowView : UIImageView @end
@implementation _LNPopupBarShadowView @end

@protocol _LNPopupToolbarLayoutDelegate <NSObject>

- (void)_toolbarDidLayoutSubviews;

@end

@interface _LNPopupToolbar : UIToolbar

@property (nonatomic, weak) id<_LNPopupToolbarLayoutDelegate> _layoutDelegate;

@end
@implementation _LNPopupToolbar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* rv = [super hitTest:point withEvent:event];
	
	if(rv != nil && rv != self)
	{
		CGRect frameInBarCoords = [self convertRect:rv.bounds fromView:rv];
		CGRect instetFrame = CGRectInset(frameInBarCoords, 2, 0);

		return CGRectContainsPoint(instetFrame, point) ? rv : self;
	}
	
	return rv;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//On iOS 11 and above reset the semantic content attribute to make sure it propagades to all subviews.
	[self setSemanticContentAttribute:self.semanticContentAttribute];
	
	[self._layoutDelegate _toolbarDidLayoutSubviews];
}

- (void)_deepSetSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute toView:(UIView*)view startingFromView:(UIView*)staringView;
{
	if(view == staringView)
	{
		[super setSemanticContentAttribute:semanticContentAttribute];
	}
	else
	{
		[view setSemanticContentAttribute:semanticContentAttribute];
	}
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:obj startingFromView:staringView];
	}];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute
{
	//On iOS 11, due to a bug in UIKit, the semantic content attribute must be propagaded recursively to all subviews, so that the system behaves correctly.
	[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:self startingFromView:self];
}

@end

@protocol __MarqueeLabelType <NSObject>

- (void)resetLabel;
- (void)unpauseLabel;
- (void)pauseLabel;
- (void)restartLabel;
- (BOOL)isPaused;
- (void)shutdownLabel;

@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat animationDelay;
@property (nonatomic, weak) MarqueeLabel* synchronizedLabel;
@property (nonatomic, readonly) NSTimeInterval animationDuration;
@property (nonatomic, assign) BOOL holdScrolling;

@end

@interface __FakeMarqueeLabel : UILabel <__MarqueeLabelType> @end
@implementation __FakeMarqueeLabel

- (void)resetLabel {}
- (void)unpauseLabel {}
- (void)pauseLabel {}
- (void)restartLabel {}
- (void)shutdownLabel {}
- (BOOL)isPaused { return YES; }
- (NSTimeInterval)animationDuration { return 0.0; }

@synthesize rate=_rate, animationDelay=_animationDelay, synchronizedLabel=_synchronizedLabel, holdScrolling=_holdScrolling;

@end

@interface MarqueeLabel () <__MarqueeLabelType> @end

const CGFloat LNPopupBarHeightCompact = 40.0;
const CGFloat LNPopupBarHeightProminent = 64.0;
const CGFloat LNPopupBarHeightFloating = 64.0;
const CGFloat LNPopupBarProminentImageWidth = 48.0;
const CGFloat LNPopupBarFloatingImageWidth = 40.0;

const UIBlurEffectStyle LNBackgroundStyleInherit = -9876;

static BOOL __animatesItemSetter = NO;

@interface LNPopupBar () <_LNPopupToolbarLayoutDelegate>

@end

@implementation LNPopupBar
{
	BOOL _delaysBarButtonItemLayout;
	
	_LNPopupBarTitlesView* _titlesView;
	NSLayoutConstraint* _titlesViewLeadingConstraint;
	NSLayoutConstraint* _titlesViewTrailingConstraint;
	
	UILabel<__MarqueeLabelType>* _titleLabel;
	UILabel<__MarqueeLabelType>* _subtitleLabel;
	
	BOOL _needsLabelsLayout;
	BOOL _marqueePaused;
	
	UIColor* _userTintColor;
	UIColor* _userBackgroundColor;
	
	_LNPopupToolbar* _toolbar;
	BOOL _inLayout;
}

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
		[self.swiftuiHiddenLeadingController setValue:@(_resolvedStyle == LNPopupBarStyleCompact ? UIUserInterfaceSizeClassCompact : UIUserInterfaceSizeClassRegular) forKey:@"overrideSizeClass"];
	}
	if(self.swiftuiHiddenTrailingController != nil)
	{
		[self.swiftuiHiddenTrailingController setValue:@(_resolvedStyle == LNPopupBarStyleCompact ? UIUserInterfaceSizeClassCompact : UIUserInterfaceSizeClassRegular) forKey:@"overrideSizeClass"];
	}
}

- (void)setBarStyle:(LNPopupBarStyle)barStyle
{
	if(_customBarViewController == nil && barStyle == LNPopupBarStyleCustom)
	{
		barStyle = LNPopupBarStyleDefault;
	}
	
	if(_barStyle != barStyle)
	{
		_barStyle = barStyle;
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
		
		[self _layoutBarButtonItems];
		_needsLabelsLayout = YES;
		
		[self _fixupSwiftUIControllersWithBarStyle];
		
		[_barContainingController.bottomDockingViewForPopup_nocreateOrDeveloper setNeedsLayout];
		[_barContainingController.view setNeedsLayout];
		[self setNeedsLayout];
		
		[self _appearanceDidChange];
		
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
}

- (LNPopupBarStyle)effectiveBarStyle
{
	return _resolvedStyle;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
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
		
		if (@available(iOS 13.4, *))
		{
			UIPointerInteraction* pointerInteraction = [[UIPointerInteraction alloc] initWithDelegate:self];
			[self addInteraction:pointerInteraction];
		}
		
		_inheritsAppearanceFromDockingView = YES;
		_standardAppearance = [LNPopupBarAppearance new];
		
		_backgroundView = [[_LNPopupBarBackgroundView alloc] initWithEffect:nil];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backgroundView.userInteractionEnabled = NO;
		[self addSubview:_backgroundView];
		
		_floatingBackgroundShadowView = [_LNPopupBackgroundShadowView new];
		_floatingBackgroundShadowView.userInteractionEnabled = NO;
		_floatingBackgroundShadowView.alpha = 0.0;
		[self addSubview:_floatingBackgroundShadowView];
		
		_contentView = [[_LNPopupBarContentView alloc] initWithEffect:nil];
		_contentView.clipsToBounds = YES;
		[self addSubview:_contentView];
		
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
		
		self.effectGroupingIdentifier = nil;
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
		
		_toolbar = [[_LNPopupToolbar alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
		_toolbar._layoutDelegate = self;
		[_toolbar.standardAppearance configureWithTransparentBackground];
		
#if DEBUG
		if(_LNEnableBarLayoutDebug())
		{
			_toolbar.standardAppearance.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.7];
			_toolbar.layer.borderColor = UIColor.blackColor.CGColor;
			_toolbar.layer.borderWidth = 1.0;
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
		
		_titlesView = [[_LNPopupBarTitlesView alloc] initWithFrame:_contentView.bounds];
		_titlesView.axis = UILayoutConstraintAxisVertical;
		_titlesView.alignment = UIStackViewAlignmentFill;
		_titlesView.distribution = UIStackViewDistributionFill;
		_titlesView.spacing = 2;
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
		_titlesView.isAccessibilityElement = YES;
		_titlesView.translatesAutoresizingMaskIntoConstraints = NO;
		
		_backgroundView.accessibilityTraits = UIAccessibilityTraitButton;
		_backgroundView.accessibilityIdentifier = @"PopupBarView";
		
		[_contentView.contentView addSubview:_titlesView];
		_titlesViewLeadingConstraint = [_titlesView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor];
		_titlesViewTrailingConstraint = [_contentView.trailingAnchor constraintEqualToAnchor:_titlesView.trailingAnchor];
		[NSLayoutConstraint activateConstraints:@[
			_titlesViewLeadingConstraint,
			_titlesViewTrailingConstraint,
			[_contentView.centerYAnchor constraintEqualToAnchor:_titlesView.centerYAnchor]
		]];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.progressViewStyle = UIProgressViewStyleBar;
		_progressView.trackImage = [UIImage new];
		[_contentView.contentView addSubview:_progressView];
		[self _updateProgressViewWithStyle:self.progressViewStyle];
		
		_needsLabelsLayout = YES;
		
		_imageView = [UIImageView new];
		_imageView.autoresizingMask = UIViewAutoresizingNone;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.accessibilityTraits = UIAccessibilityTraitImage;
		_imageView.isAccessibilityElement = YES;
		_imageView.layer.cornerCurve = kCACornerCurveContinuous;
		_imageView.layer.cornerRadius = 6;
		_imageView.layer.masksToBounds = YES;
		// support smart invert and therefore do not invert image view colors
		_imageView.accessibilityIgnoresInvertColors = YES;
		
		[_contentView.contentView addSubview:_imageView];
		
		_shadowView = [_LNPopupBarShadowView new];
		[_backgroundView.contentView addSubview:_shadowView];
		
		_bottomShadowView = [_LNPopupBarShadowView new];
		_bottomShadowView.hidden = YES;
		[_backgroundView.contentView addSubview:_bottomShadowView];
		
		_highlightView = [[UIView alloc] initWithFrame:_contentView.bounds];
		_highlightView.userInteractionEnabled = NO;
		_highlightView.alpha = 0.0;
		[self addSubview:_highlightView];
		
		self.semanticContentAttribute = UISemanticContentAttributeUnspecified;
		self.barItemsSemanticContentAttribute = UISemanticContentAttributePlayback;
		
		self.isAccessibilityElement = NO;
		
		_wantsBackgroundCutout = YES;
		
		[self _recalcActiveAppearanceChain];
	}
	
	return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	[self _setNeedsTitleLayoutRemovingLabels:NO];
	[self layoutIfNeeded];
	
	[self._barDelegate _traitCollectionForPopupBarDidChange:self];
	if(UIContentSizeCategoryCompareToCategory(previousTraitCollection.preferredContentSizeCategory, self.traitCollection.preferredContentSizeCategory) != NSOrderedSame)
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
	if(_customBarViewController == nil || _customBarViewController.view.translatesAutoresizingMaskIntoConstraints == NO)
	{
		return;
	}
	
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

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_inLayout = YES;

	CGRect frame = self.bounds;
	
	CGFloat barHeight = _LNPopupBarHeightForPopupBar(self);
	frame.size.height = barHeight;
	
	[_backgroundView setFrame:frame];
	_backgroundView.layer.mask.frame = _backgroundView.bounds;
	
	BOOL isFloating = _resolvedStyle == LNPopupBarStyleFloating;
	
	CGRect contentFrame;
	if(isFloating)
	{
		CGFloat inset = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? 30 : 12;
		contentFrame = CGRectOffset(UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(4, MAX(self.safeAreaInsets.left + 12, inset), 4, MAX(self.safeAreaInsets.right + 12, inset))), 0, -2);
		
		_contentView.cornerRadius = 14;
		
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
		
		_floatingBackgroundShadowView.hidden = NO;
		_floatingBackgroundShadowView.frame = contentFrame;
		_floatingBackgroundShadowView.cornerRadius = 14;
		
#if DEBUG
		_floatingBackgroundShadowView.hidden = [NSUserDefaults.standardUserDefaults boolForKey:@"__LNPopupBarHideShadow"];
#endif
	}
	else
	{
		BOOL isProminent = _resolvedStyle == LNPopupBarStyleProminent;
		CGFloat inset = isProminent ? MAX(self.safeAreaInsets.left, self.layoutMargins.left) : self.safeAreaInsets.left;
		contentFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, inset, 0, 0));
		
		_backgroundGradientMaskView.hidden = YES;
		_backgroundView.maskView = nil;
		
		_contentView.cornerRadius = 0;
		_floatingBackgroundShadowView.hidden = YES;
	}
	_contentView.frame = contentFrame;
#if DEBUG
	if(_LNEnableBarLayoutDebug())
	{
		_contentView.colorView.hidden = NO;
		_contentView.colorView.backgroundColor = UIColor.magentaColor;
	}
	
	_contentView.hidden = [NSUserDefaults.standardUserDefaults boolForKey:@"__LNPopupBarHideContentView"];
#endif
	
	_contentView.preservesSuperviewLayoutMargins = !isFloating;
	
	_contentMaskView.frame = self.bounds;
	_backgroundMaskView.frame = self.bounds;
	
	[self _layoutCustomBarController];
	
	[self _layoutImageView];
	
	_toolbar.bounds = CGRectMake(0, 0, _contentView.bounds.size.width, 44);
	_toolbar.center = CGPointMake(CGRectGetMidX(_contentView.bounds), CGRectGetMidY(_contentView.bounds));
	[_toolbar setNeedsLayout];
	[_toolbar layoutIfNeeded];
	
	if(isFloating)
	{
		_highlightView.frame = _contentView.frame;
		_highlightView.layer.cornerRadius = _contentView.cornerRadius;
	}
	else
	{
		_highlightView.frame = self.bounds;
		_highlightView.layer.cornerRadius = 0;
	}
	
	[_contentView.contentView insertSubview:_toolbar aboveSubview:_highlightView];
	[_contentView.contentView insertSubview:_imageView aboveSubview:_toolbar];
	[_contentView.contentView insertSubview:_titlesView aboveSubview:_imageView];
	if(_customBarViewController != nil)
	{
		[_contentView.contentView insertSubview:_customBarViewController.view aboveSubview:_bottomShadowView];
	}
	
	[self insertSubview:_highlightView aboveSubview:_contentView];
	
	UIScreen* screen = self.window.screen ?: UIScreen.mainScreen;
	CGFloat h = 1 / screen.scale;
	_shadowView.frame = CGRectMake(0, 0, _backgroundView.bounds.size.width, h);
	_bottomShadowView.frame = CGRectMake(0, _backgroundView.bounds.size.height - h, _backgroundView.bounds.size.width, h);
	
	CGFloat cornerRadius = _contentView.layer.cornerRadius / 2.5;
	if(self.progressViewStyle == LNPopupBarProgressViewStyleTop)
	{
		_progressView.frame = CGRectMake(cornerRadius, 0, _contentView.bounds.size.width - 2 * cornerRadius, 1.5);
	}
	else
	{
		_progressView.frame = CGRectMake(cornerRadius, _contentView.bounds.size.height - 2.5, _contentView.bounds.size.width - 2 * cornerRadius, 1.5);
	}
	
	[self _layoutTitles];
	
	_inLayout = NO;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	static NSString* willRotate = nil;
	static NSString* didRotate = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//UIWindowWillRotateNotification
		willRotate = _LNPopupDecodeBase64String(@"VUlXaW5kb3dXaWxsUm90YXRlTm90aWZpY2F0aW9u");
		//UIWindowDidRotateNotification
		didRotate = _LNPopupDecodeBase64String(@"VUlXaW5kb3dEaWRSb3RhdGVOb3RpZmljYXRpb24=");
	});
	
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

- (NSString*)_effectGroupingIdentifierKey
{
	static NSString* gN = @"Z3JvdXBOYW1l";
	static NSString* rv = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		rv = _LNPopupDecodeBase64String(gN);
	});
	return rv;
}

- (void)_applyGroupingIdentifier:(NSString*)groupingIdentifier toVisualEffectView:(UIVisualEffectView*)visualEffectView
{
	if(visualEffectView == nil)
	{
		return;
	}
	
	if([[visualEffectView valueForKey:self._effectGroupingIdentifierKey] isEqualToString:groupingIdentifier])
	{
		return;
	}
	
	[visualEffectView setValue:groupingIdentifier ?: [NSString stringWithFormat:@"<%@:%p> Backdrop Group", self.class, self] forKey:self._effectGroupingIdentifierKey];
}

- (void)_applyGroupingIdentifierToVisualEffectView:(UIVisualEffectView*)visualEffectView
{
	[self _applyGroupingIdentifier:self.effectGroupingIdentifier toVisualEffectView:visualEffectView];
}

- (NSString *)effectGroupingIdentifier
{
	return [self.backgroundView.effectView valueForKey:self._effectGroupingIdentifierKey];
}

- (void)setEffectGroupingIdentifier:(NSString *)groupingIdentifier
{
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
	_systemAppearance = [systemAppearance copy];
	
	[self _recalcActiveAppearanceChain];
}

- (void)setStandardAppearance:(LNPopupBarAppearance *)standardAppearance
{
	_standardAppearance = [standardAppearance copy];
	if(_standardAppearance == nil)
	{
		_standardAppearance = [LNPopupBarAppearance new];
	}
	
	[self _recalcActiveAppearanceChain];
}

- (void)_recalcActiveAppearanceChain
{
	NSMutableArray* chain = [NSMutableArray new];
	
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
	else if(_activeAppearanceChain)
	{
		[_activeAppearanceChain setChainDelegate:nil];
	}
	
	_activeAppearanceChain = [[LNPopupBarAppearanceChainProxy alloc] initWithAppearanceChain:chain];
	[_activeAppearanceChain setChainDelegate:self];
	
	[self _appearanceDidChange];
}

- (void)setPopupItem:(LNPopupItem *)popupItem
{
	_popupItem = popupItem;
	
	[self _recalcActiveAppearanceChain];
}

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance
{
	[self _appearanceDidChange];
}

- (void)_appearanceDidChange
{
	_highlightView.backgroundColor = self.activeAppearance.highlightColor;
	
	BOOL isFloating = _resolvedStyle == LNPopupBarStyleFloating;
	
	if(isFloating)
	{
		_contentView.effect = self.activeAppearance.floatingBackgroundEffect;
		
		__auto_type floatingBackgroundColor = self.activeAppearance.floatingBackgroundColor;
		__auto_type floatingBackgroundImage = self.activeAppearance.floatingBackgroundImage;
		
		_contentView.colorView.backgroundColor = floatingBackgroundColor;
		_contentView.imageView.image = floatingBackgroundImage;
		_contentView.imageView.contentMode = self.activeAppearance.floatingBackgroundImageContentMode;
		
		_contentView.colorView.hidden = floatingBackgroundColor == nil;
		_contentView.imageView.hidden = floatingBackgroundImage == nil;
	}
	else
	{
		_contentView.effect = nil;
		_contentView.colorView.backgroundColor = UIColor.clearColor;
		_contentView.imageView.image = nil;
		_contentView.imageView.contentMode = 0;
		_contentView.colorView.hidden = YES;
		_contentView.imageView.hidden = YES;
	}
	
	__auto_type backgroundColor = self.activeAppearance.backgroundColor;
	__auto_type backgroundImage = self.activeAppearance.backgroundImage;
	
	_backgroundView.effect = self.activeAppearance.backgroundEffect;
	_backgroundView.colorView.backgroundColor = backgroundColor;
	_backgroundView.imageView.image = backgroundImage;
	_backgroundView.imageView.contentMode = self.activeAppearance.backgroundImageContentMode;
	
	_backgroundView.colorView.hidden = backgroundColor == nil;
	_backgroundView.imageView.hidden = backgroundImage == nil;
	
	_toolbar.standardAppearance.buttonAppearance = self.activeAppearance.buttonAppearance ?: _toolbar.standardAppearance.buttonAppearance;
	_toolbar.standardAppearance.doneButtonAppearance = self.activeAppearance.doneButtonAppearance ?: _toolbar.standardAppearance.doneButtonAppearance;
	
	_shadowView.image = self.activeAppearance.shadowImage;
	_shadowView.backgroundColor = self.activeAppearance.shadowColor;
	_bottomShadowView.image = self.activeAppearance.shadowImage;
	_bottomShadowView.backgroundColor = self.activeAppearance.shadowColor;
	
	_shadowView.hidden = _resolvedStyle == LNPopupBarStyleFloating ? YES : NO;
	if(_resolvedStyle == LNPopupBarStyleFloating)
	{
		_bottomShadowView.hidden = YES;
	}
	
	_floatingBackgroundShadowView.shadow = self.activeAppearance.floatingBarBackgroundShadow;

	[self.customBarViewController _activeAppearanceDidChange:self.activeAppearance];
	
	//Recalculate labels
	[self _setNeedsTitleLayoutRemovingLabels:YES];
	[self _recalculateCoordinatedMarqueeScrollIfNeeded];
	
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
	
	[self _setNeedsTitleLayoutRemovingLabels:NO];
}

- (void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
	_attributedSubtitle = [attributedSubtitle copy];
	
	[self _setNeedsTitleLayoutRemovingLabels:NO];
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	
	[self _layoutImageView];
	[self _setNeedsTitleLayoutRemovingLabels:NO];
}

- (void)setSwiftuiImageController:(UIViewController *)swiftuiImageController
{
	if(_swiftuiImageController != nil)
	{
		[_swiftuiImageController.view removeFromSuperview];
	}
	
	_swiftuiImageController = swiftuiImageController;
	_swiftuiImageController.view.backgroundColor = UIColor.clearColor;
	
	_swiftuiImageController.view.translatesAutoresizingMaskIntoConstraints = NO;
	[_imageView addSubview:_swiftuiImageController.view];
	[NSLayoutConstraint activateConstraints:@[
		[_imageView.topAnchor constraintEqualToAnchor:_swiftuiImageController.view.topAnchor],
		[_imageView.bottomAnchor constraintEqualToAnchor:_swiftuiImageController.view.bottomAnchor],
		[_imageView.leadingAnchor constraintEqualToAnchor:_swiftuiImageController.view.leadingAnchor],
		[_imageView.trailingAnchor constraintEqualToAnchor:_swiftuiImageController.view.trailingAnchor],
	]];
	
	[self _layoutImageView];
	[self _setNeedsTitleLayoutRemovingLabels:NO];
}

- (void)setSwiftuiTitleContentView:(UIView *)swiftuiTitleContentView
{
	if(_swiftuiTitleContentView != nil)
	{
		[_swiftuiTitleContentView removeFromSuperview];
	}
	
	_swiftuiTitleContentView = swiftuiTitleContentView;
	_swiftuiTitleContentView.backgroundColor = UIColor.clearColor;
	_swiftuiTitleContentView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self _setNeedsTitleLayoutRemovingLabels:YES];
}

- (void)setSwiftuiHiddenLeadingController:(UIViewController *)swiftuiHiddenLeadingController
{
	if(_swiftuiHiddenLeadingController != nil)
	{
		[_swiftuiHiddenLeadingController.view removeFromSuperview];
	}
	
	_swiftuiHiddenLeadingController = swiftuiHiddenLeadingController;
	_swiftuiHiddenLeadingController.view.frame = CGRectMake(-200, -200, 100, 160);
	[self addSubview:_swiftuiHiddenLeadingController.view];
	
	[self _fixupSwiftUIControllersWithBarStyle];
}

- (void)setSwiftuiHiddenTrailingController:(UIViewController *)swiftuiHiddenTrailingController
{
	if(_swiftuiHiddenTrailingController != nil)
	{
		[_swiftuiHiddenTrailingController.view removeFromSuperview];
	}
	
	_swiftuiHiddenTrailingController = swiftuiHiddenTrailingController;
	_swiftuiHiddenTrailingController.view.frame = CGRectMake(-200, -200, 100, 160);
	[self addSubview:_swiftuiHiddenTrailingController.view];
	
	[self _fixupSwiftUIControllersWithBarStyle];
}

- (void)setAccessibilityCenterHint:(NSString *)accessibilityCenterHint
{
	_accessibilityCenterHint = accessibilityCenterHint;
	
	[self _updateAccessibility];
}

- (void)setAccessibilityCenterLabel:(NSString *)accessibilityCenterLabel
{
	_accessibilityCenterLabel = accessibilityCenterLabel;
	
	[self _updateAccessibility];
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
	
	[self _layoutBarButtonItems];
	
	[self setNeedsLayout];
}

- (UILabel<__MarqueeLabelType>*)_labelWithMarqueeEnabled:(BOOL)marqueeEnabled
{
	UILabel<__MarqueeLabelType>* _rv = nil;
	
	if(!marqueeEnabled)
	{
		__FakeMarqueeLabel* rv = [__FakeMarqueeLabel new];
		rv.minimumScaleFactor = 1.0;
		rv.lineBreakMode = NSLineBreakByTruncatingTail;
		_rv = rv;
	}
	else
	{
		MarqueeLabel* rv = [[MarqueeLabel alloc] initWithFrame:CGRectZero rate:self.activeAppearance.marqueeScrollRate andFadeLength:10];
		rv.leadingBuffer = 0.0;
		rv.trailingBuffer = 20.0;
		rv.animationDelay = self.activeAppearance.marqueeScrollDelay;
		rv.marqueeType = MLContinuous;
		rv.holdScrolling = YES;
		_rv = rv;
	}
	
	_rv.numberOfLines = 1;
	_rv.adjustsFontForContentSizeCategory = YES;
	_rv.translatesAutoresizingMaskIntoConstraints = NO;
	[_rv setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
	return _rv;
}

- (UIView*)_viewForBarButtonItem:(UIBarButtonItem*)barButtonItem
{
	UIView* itemView = [barButtonItem valueForKey:@"view"];
	//_UITAMICAdaptorView
	if([itemView.superview isKindOfClass:NSClassFromString(_LNPopupDecodeBase64String(@"X1VJVEFNSUNBZGFwdG9yVmlldw=="))])
	{
		itemView = itemView.superview;
	}
	
	return itemView;
}

- (void)_getLeftmostView:(UIView* __strong *)leftmostView rightmostView:(UIView* __strong *)rightmostView fromBarButtonItems:(NSArray<UIBarButtonItem*>*)barButtonItems
{
	NSArray<UIBarButtonItem*>* filtered = [barButtonItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemItem == NO || (systemItem != %@ && systemItem != %@)", @(UIBarButtonSystemItemFixedSpace), @(UIBarButtonSystemItemFlexibleSpace)]];
	
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
	[_toolbar layoutIfNeeded];
	
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
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	
	UIView* leftViewLast;
	UIView* rightViewFirst;
	
	NSArray* allItems = _toolbar.items;

	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		[self _getLeftmostView:&rightViewFirst rightmostView:NULL fromBarButtonItems:allItems];
		leftViewLast = _imageView.hidden ? nil : _imageView;
	}
	else
	{
		[self _getLeftmostView:NULL rightmostView:&leftViewLast fromBarButtonItems:allItems];
		rightViewFirst = _imageView.hidden ? nil : _imageView;
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
	
	BOOL isFloating = _resolvedStyle == LNPopupBarStyleFloating;
	CGFloat imageToTitlePadding = isFloating ? 8 : 16;
	
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
			leftViewLastFrame.size.width -= (__applySwiftUILayoutFixes ? -8 : 8);
		}
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
			rightViewFirstFrame.origin.x += (__applySwiftUILayoutFixes ? -8 : 8);
		}
	}
	
	CGFloat widthLeft = 0;
	CGFloat widthRight = 0;
	
	widthLeft = leftViewLastFrame.origin.x + leftViewLastFrame.size.width;
	widthRight = _contentView.bounds.size.width - rightViewFirstFrame.origin.x;
	
	if(isFloating == NO)
	{
		widthLeft = MAX(widthLeft, _contentView.layoutMargins.left);
		widthRight = MAX(widthRight, _contentView.layoutMargins.right);
	}
	
	//The added padding is for iOS 10 and below, or for certain conditions where iOS 11 won't put its own padding
	titleInsets->left = widthLeft;
	titleInsets->right = widthRight;
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIFont*)_titleFont
{
	CGFloat fontSize = 15;
	UIFontWeight fontWeight = UIFontWeightMedium;
	UIFontTextStyle fontTextStyle = UIFontTextStyleSubheadline;
	
	switch(_resolvedStyle)
	{
		case LNPopupBarStyleFloating:
			fontSize = 15;
			fontWeight = UIFontWeightMedium;
			fontTextStyle = UIFontTextStyleBody;
			break;
		case LNPopupBarStyleProminent:
			fontSize = 18;
			fontWeight = UIFontWeightRegular;
			fontTextStyle = UIFontTextStyleBody;
			break;
		case LNPopupBarStyleCompact:
			fontSize = 14;
			fontWeight = UIFontWeightRegular;
			fontTextStyle = UIFontTextStyleBody;
			break;
		default:
			break;
	}
	
	return [[UIFontMetrics metricsForTextStyle:fontTextStyle] scaledFontForFont:[UIFont systemFontOfSize:fontSize weight:fontWeight]];
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIColor*)_titleColor
{
	return UIColor.labelColor;
}

//DO NOT CHANGE NAME! Used by LNPopupUI
- (UIFont*)_subtitleFont
{
	CGFloat fontSize = 15;
	UIFontWeight fontWeight = UIFontWeightRegular;
	
	switch(_resolvedStyle)
	{
		case LNPopupBarStyleFloating:
			fontSize = 12.5;
			fontWeight = UIFontWeightRegular;
			break;
		case LNPopupBarStyleProminent:
			fontSize = 14;
			fontWeight = UIFontWeightRegular;
			break;
		case LNPopupBarStyleCompact:
			fontSize = 11;
			fontWeight = UIFontWeightRegular;
			break;
		default:
			break;
	}
	
	return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleFootnote] scaledFontForFont:[UIFont systemFontOfSize:fontSize weight:fontWeight]];
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
	
	_titlesViewLeadingConstraint.constant = titleInsets.left;
	_titlesViewTrailingConstraint.constant = titleInsets.right;
	
#if DEBUG
	if(_LNEnableBarLayoutDebug())
	{
		_titlesView.backgroundColor = [UIColor.orangeColor colorWithAlphaComponent:0.6];
	}
#endif
	
	BOOL reset = NO;
	
	if(_needsLabelsLayout == YES)
	{
		if(_swiftuiTitleContentView != nil)
		{
			[_titlesView addArrangedSubview:_swiftuiTitleContentView];
			[_titlesView layoutIfNeeded];
			UIView* textView = _swiftuiTitleContentView.subviews.firstObject;
			[NSLayoutConstraint activateConstraints:@[
				[_swiftuiTitleContentView.heightAnchor constraintEqualToAnchor:textView.heightAnchor],
			]];
		}
		else
		{
			if(_titleLabel == nil)
			{
				_titleLabel = [self _labelWithMarqueeEnabled:self.activeAppearance.marqueeScrollEnabled];
#if DEBUG
				if(_LNEnableBarLayoutDebug())
				{
					_titleLabel.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.5];
				}
#endif
				_titleLabel.textColor = self._titleColor;
				_titleLabel.font = self._titleFont;
				if(_resolvedStyle == LNPopupBarStyleCompact)
				{
					_titleLabel.textAlignment = NSTextAlignmentCenter;
				}
				
				[_titlesView addArrangedSubview:_titleLabel];
			}
			
			NSAttributedString* attr = _attributedTitle.length > 0 ? [NSAttributedString ln_attributedStringWithAttributedString:_attributedTitle defaultAttributes:self.activeAppearance.titleTextAttributes] : nil;
			if(attr != nil && [_titleLabel.attributedText isEqualToAttributedString:attr] == NO)
			{
				_titleLabel.attributedText = attr;
				reset = YES;
			}
			
			if(_subtitleLabel == nil)
			{
				_subtitleLabel = [self _labelWithMarqueeEnabled:self.activeAppearance.marqueeScrollEnabled];
#if DEBUG
				if(_LNEnableBarLayoutDebug())
				{
					_subtitleLabel.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];
				}
#endif
				_subtitleLabel.textColor = self._subtitleColor;
				_subtitleLabel.font = self._subtitleFont;
				if(_resolvedStyle == LNPopupBarStyleCompact)
				{
					_subtitleLabel.textAlignment = NSTextAlignmentCenter;
				}
				
				[_titlesView addArrangedSubview:_subtitleLabel];
			}
			
			attr = _attributedSubtitle.length > 0 ? [NSAttributedString ln_attributedStringWithAttributedString:_attributedSubtitle defaultAttributes:self.activeAppearance.subtitleTextAttributes] : nil;
			if(attr != nil && [_subtitleLabel.attributedText isEqualToAttributedString:attr] == NO)
			{
				_subtitleLabel.attributedText = attr;
				reset = YES;
			}
		}
		
		if(reset)
		{
			[_titleLabel resetLabel];
			[_subtitleLabel resetLabel];
		}
		
		if(_attributedSubtitle.length > 0)
		{
			_subtitleLabel.hidden = NO;
			
			if(_needsLabelsLayout == YES)
			{
				if([_subtitleLabel isPaused] && [_titleLabel isPaused] == NO)
				{
					[_subtitleLabel unpauseLabel];
				}
			}
		}
		else
		{
			_subtitleLabel.hidden = YES;
			
			if(_needsLabelsLayout == YES)
			{
				[_subtitleLabel resetLabel];
				[_subtitleLabel pauseLabel];
			}
		}
	}
		
	[self _updateAccessibility];
	
	[self _recalculateCoordinatedMarqueeScrollIfNeeded];
	
	_needsLabelsLayout = NO;
}

- (void)_updateAccessibility
{
	if(_accessibilityCenterLabel.length > 0)
	{
		_titlesView.accessibilityLabel = _accessibilityCenterLabel;
	}
	else
	{
		NSMutableString* accessibilityLabel = [NSMutableString new];
		if(_attributedTitle.length > 0)
		{
			[accessibilityLabel appendString:_attributedTitle.string];
			[accessibilityLabel appendString:@"\n"];
		}
		if(_attributedSubtitle.length > 0)
		{
			[accessibilityLabel appendString:_attributedSubtitle.string];
		}
		_titlesView.accessibilityLabel = accessibilityLabel;
	}
	
	if(_accessibilityCenterHint.length > 0)
	{
		_titlesView.accessibilityHint = _accessibilityCenterHint;
	}
	else
	{
		_titlesView.accessibilityHint = NSLocalizedString(@"Double tap to open.", @"");
	}
}

- (void)_setNeedsTitleLayoutRemovingLabels:(BOOL)remove
{
	_needsLabelsLayout = YES;
	
	if(remove)
	{
		UIView* l1 = _titleLabel;
		UIView* l2 = _subtitleLabel;
		
		_titleLabel = nil;
		_subtitleLabel = nil;
		
		[l1 removeFromSuperview];
		[l2 removeFromSuperview];
	}
	
	[self setNeedsLayout];
}

- (void)_layoutImageView
{
	BOOL previouslyHidden = _imageView.hidden;
	
	if(_resolvedStyle == LNPopupBarStyleCompact)
	{
		_imageView.hidden = YES;
		
		return;
	}
	
	_imageView.image = _image;
	_imageView.hidden = _image == nil && _swiftuiImageController == nil;
	
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	
	BOOL isFloating = _resolvedStyle == LNPopupBarStyleFloating;
	CGFloat imageSize = isFloating ? LNPopupBarFloatingImageWidth : LNPopupBarProminentImageWidth;
	CGFloat barHeight = _contentView.bounds.size.height;
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		CGFloat safeLeading = isFloating ? 8 : 0;
		_imageView.center = CGPointMake(safeLeading + imageSize / 2, barHeight / 2);
	}
	else
	{
		CGFloat safeLeading = isFloating ? 8 : 0;
		_imageView.center = CGPointMake(_contentView.bounds.size.width - safeLeading - imageSize / 2, barHeight / 2);
	}
	
	_imageView.bounds = CGRectMake(0, 0, imageSize, imageSize);
	
	if(previouslyHidden != _imageView.hidden)
	{
		[self _setNeedsTitleLayoutRemovingLabels:NO];
	}
}

- (void)_setTitleViewMarqueesPaused:(BOOL)paused
{
	_marqueePaused = paused;
	
	if(_marqueePaused)
	{
		[_titleLabel shutdownLabel];
		[_subtitleLabel shutdownLabel];
		
		_titleLabel.holdScrolling = YES;
		_subtitleLabel.holdScrolling = YES;
	}
	else
	{
		[_titleLabel restartLabel];
		[_subtitleLabel restartLabel];
		
		[self _recalculateCoordinatedMarqueeScrollIfNeeded];
	}
}

- (void)_delayBarButtonLayout
{
	_delaysBarButtonItemLayout = YES;
}

- (void)_layoutBarButtonItems
{
	UIUserInterfaceLayoutDirection barItemsLayoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_barItemsSemanticContentAttribute];
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];

	BOOL normalButtonsOrder = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight || barItemsLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	
	NSEnumerationOptions enumerationOptions = normalButtonsOrder ? 0 : NSEnumerationReverse;
	
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
	
	NSMutableArray* items = [NSMutableArray new];
	
	UIBarButtonItem* flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	if(resolvedStyle != LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}
	
	[self.leadingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	if(resolvedStyle == LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}

	[self.trailingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	[_toolbar setItems:items animated:__animatesItemSetter];
	
	[self _setNeedsTitleLayoutRemovingLabels:NO];
	
	_delaysBarButtonItemLayout = NO;
}

- (void)_updateViewsAfterCustomBarViewControllerUpdate
{
	BOOL hide = _customBarViewController != nil;
	_imageView.hidden = hide;
	_toolbar.hidden = hide;
	_titlesView.hidden = hide;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"preferredContentSize"] == YES && object == _customBarViewController)
	{
		[self._barDelegate _popupBarMetricsDidChange:self];
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
		LNDynamicallySubclass(customBarViewController, _LNPopupCustomBarViewController_AppearanceControl.class);
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
		
		[self.contentView addSubview:_customBarViewController.view];
		
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
	
	[self setNeedsLayout];
}

- (void)setLeadingBarButtonItems:(NSArray<UIBarButtonItem*> *)leadingBarButtonItems
{	
	_leadingBarButtonItems = [leadingBarButtonItems copy];
	
	if(_delaysBarButtonItemLayout == NO)
	{
		[self _layoutBarButtonItems];
	}
}

- (void)setTrailingBarButtonItems:(NSArray<UIBarButtonItem*> *)trailingBarButtonItems
{
	_trailingBarButtonItems = [trailingBarButtonItems copy];
	
	if(_delaysBarButtonItemLayout == NO)
	{
		[self _layoutBarButtonItems];
	}
}

- (void)_recalculateCoordinatedMarqueeScrollIfNeeded
{
	if(self.activeAppearance.marqueeScrollEnabled == NO)
	{
		return;
	}
	
	if(_marqueePaused == YES)
	{
		return;
	}
	
	MarqueeLabel* titleLabel = (id)_titleLabel;
	MarqueeLabel* subtitleLabel = (id)_subtitleLabel;
	
	titleLabel.animationDelay = self.activeAppearance.marqueeScrollDelay;
	subtitleLabel.animationDelay = self.activeAppearance.marqueeScrollDelay;
	
	if(self.activeAppearance.coordinateMarqueeScroll == YES && _attributedTitle.length > 0 && _attributedSubtitle.length > 0)
	{
		titleLabel.holdScrolling = YES;
		subtitleLabel.holdScrolling = YES;
		
		if(titleLabel.animationDuration < _subtitleLabel.animationDuration)
		{
			titleLabel.synchronizedLabel = nil;
			subtitleLabel.synchronizedLabel = (id)_titleLabel;
			titleLabel.holdScrolling = NO;
			titleLabel.holdScrolling = YES;
			subtitleLabel.holdScrolling = NO;
		}
		else
		{
			titleLabel.synchronizedLabel = (id)_subtitleLabel;
			subtitleLabel.synchronizedLabel = nil;
			titleLabel.holdScrolling = NO;
			subtitleLabel.holdScrolling = NO;
			subtitleLabel.holdScrolling = YES;
		}
	}
	else
	{
		titleLabel.holdScrolling = NO;
		subtitleLabel.holdScrolling = NO;
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
		
		[self _layoutBarButtonItems];
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
	
	[animator addAnimations:^{
		if(_customBarViewController == nil || _customBarViewController.wantsDefaultHighlightGestureRecognizer == YES)
		{
			[self setHighlighted:YES animated:YES];
		}
	}];
}

- (void)pointerInteraction:(UIPointerInteraction *)interaction willExitRegion:(UIPointerRegion *)region animator:(id<UIPointerInteractionAnimating>)animator  API_AVAILABLE(ios(13.4))
{
	if(_customBarViewController && [_customBarViewController respondsToSelector:@selector(pointerInteraction:willExitRegion:animator:)])
	{
		[_customBarViewController pointerInteraction:interaction willExitRegion:region animator:animator];
		
		return;
	}
	
	[animator addAnimations:^{
		if(_customBarViewController == nil || _customBarViewController.wantsDefaultHighlightGestureRecognizer == YES)
		{
			[self setHighlighted:NO animated:YES];
		}
	}];
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

#pragma mark - Deprecations

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation LNPopupBar (Deprecated)

- (BOOL)inheritsVisualStyleFromDockingView
{
	return self.inheritsAppearanceFromDockingView;
}

- (void)setInheritsVisualStyleFromDockingView:(BOOL)inheritsVisualStyleFromDockingView
{
	self.inheritsAppearanceFromDockingView = inheritsVisualStyleFromDockingView;
}

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	UIBlurEffectStyle blurEffectStyle = backgroundStyle == LNBackgroundStyleInherit ? UIBlurEffectStyleSystemChromeMaterial : backgroundStyle;
	
	self.standardAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return [[self.standardAppearance.backgroundEffect valueForKey:@"style"] unsignedIntegerValue];
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
	self.standardAppearance.backgroundColor = barTintColor;
}

- (UIColor *)barTintColor
{
	return self.standardAppearance.backgroundColor;
}

- (void)setTranslucent:(BOOL)translucent
{
	if(translucent)
	{
		[self.standardAppearance configureWithDefaultBackground];
	}
	else
	{
		[self.standardAppearance configureWithOpaqueBackground];
	}
}

- (BOOL)isTranslucent
{
	return self.standardAppearance.backgroundEffect == nil;
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
	self.standardAppearance.titleTextAttributes = titleTextAttributes;
}

- (NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
	return self.standardAppearance.titleTextAttributes;
}

- (void)setSubtitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)subtitleTextAttributes
{
	self.standardAppearance.subtitleTextAttributes = subtitleTextAttributes;
}

- (NSDictionary<NSAttributedStringKey,id> *)subtitleTextAttributes
{
	return self.standardAppearance.subtitleTextAttributes;
}

- (void)setMarqueeScrollEnabled:(BOOL)marqueeScrollEnabled
{
	self.standardAppearance.marqueeScrollEnabled = marqueeScrollEnabled;
}

- (BOOL)marqueeScrollEnabled
{
	return self.standardAppearance.marqueeScrollEnabled;
}

- (void)setMarqueeScrollRate:(CGFloat)marqueeScrollRate
{
	self.standardAppearance.marqueeScrollRate = marqueeScrollRate;
}

- (CGFloat)marqueeScrollRate
{
	return self.standardAppearance.marqueeScrollRate;
}

- (void)setMarqueeScrollDelay:(NSTimeInterval)marqueeScrollDelay
{
	self.standardAppearance.marqueeScrollDelay = marqueeScrollDelay;
}

- (NSTimeInterval)marqueeScrollDelay
{
	return self.standardAppearance.marqueeScrollDelay;
}

- (void)setCoordinateMarqueeScroll:(BOOL)coordinateMarqueeScroll
{
	self.standardAppearance.coordinateMarqueeScroll = coordinateMarqueeScroll;
}

- (BOOL)coordinateMarqueeScroll
{
	return self.standardAppearance.coordinateMarqueeScroll;
}

- (NSArray<UIBarButtonItem *> *)leftBarButtonItems
{
	return self.leadingBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)rightBarButtonItems
{
	return self.trailingBarButtonItems;
}

@end

#pragma clang diagnostic pop
