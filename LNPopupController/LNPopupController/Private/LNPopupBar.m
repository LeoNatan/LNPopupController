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

#ifndef LNPopupControllerEnforceStrictClean
//_effectWithStyle:tintColor:invertAutomaticStyle:
static NSString* const _eWSti = @"X2VmZmVjdFdpdGhTdHlsZTp0aW50Q29sb3I6aW52ZXJ0QXV0b21hdGljU3R5bGU6";
static SEL _effectWithStyle_tintColor_invertAutomaticStyle_SEL;
static id(*_effectWithStyle_tintColor_invertAutomaticStyle)(id, SEL, NSUInteger, UIColor*, BOOL);

__attribute__((constructor))
static void __setupFunction()
{
	_effectWithStyle_tintColor_invertAutomaticStyle_SEL = NSSelectorFromString(_LNPopupDecodeBase64String(_eWSti));
	Method m = class_getClassMethod(UIBlurEffect.class, _effectWithStyle_tintColor_invertAutomaticStyle_SEL);
	_effectWithStyle_tintColor_invertAutomaticStyle = (void*)method_getImplementation(m);
}
#endif

@interface _LNPopupBarContentView : UIView @end
@implementation _LNPopupBarContentView @end

@interface _LNPopupBarTitlesView : UIView @end
@implementation _LNPopupBarTitlesView @end

@interface _LNPopupBarShadowView : UIView @end
@implementation _LNPopupBarShadowView @end

@interface _LNPopupToolbar : UIToolbar @end
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
const CGFloat LNPopupBarProminentImageWidth = 48.0;

const UIBlurEffectStyle LNBackgroundStyleInherit = -9876;

@implementation LNPopupBar
{
	LNPopupBarStyle _resolvedStyle;

	BOOL _delaysBarButtonItemLayout;
	UIView* _titlesView;
	UILabel<__MarqueeLabelType>* _titleLabel;
	UILabel<__MarqueeLabelType>* _subtitleLabel;
	BOOL _needsLabelsLayout;
	BOOL _marqueePaused;
	
	UIColor* _userTintColor;
	UIColor* _userBackgroundColor;
	
	UIBlurEffectStyle _actualBackgroundStyle;
	UIBlurEffect* _customBlurEffect;
	
	UIToolbar* _toolbar;
	UIView* _shadowView;
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

static inline __attribute__((always_inline)) UIBlurEffectStyle _LNBlurEffectStyleForSystemBarStyle(UIBarStyle systemBarStyle, LNPopupBarStyle barStyle)
{
	if (@available(iOS 13.0, *))
	{
		//On iOS 13 and above, return .chromeMaterial regardless of bar style (this is how Music.app appears)
		if(systemBarStyle == UIBarStyleBlack)
		{
#if TARGET_OS_MACCATALYST
			return UIBlurEffectStyleSystemMaterialDark;
#else
			return UIBlurEffectStyleSystemChromeMaterialDark;
#endif
		}
		
#if TARGET_OS_MACCATALYST
		return UIBlurEffectStyleSystemMaterial;
#else
		return UIBlurEffectStyleSystemChromeMaterial;
#endif
	}
	
	return systemBarStyle == UIBarStyleBlack ? UIBlurEffectStyleDark : barStyle == LNPopupBarStyleCompact ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleLight;
}

@synthesize backgroundStyle = _userBackgroundStyle, barTintColor = _userBarTintColor;

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
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
		[self setNeedsLayout];
		
		[self._barDelegate _popupBarMetricsDidChange:self];
	}
}

- (void)_setHighlightAlpha:(CGFloat)alpha animated:(BOOL)animated
{
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	id block = ^ { self.highlightView.alpha = highlighted ? 1.0 : 0.0; };
	
	if(animated)
	{
		[UIView animateWithDuration:0.2 animations:block];
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
		self.clipsToBounds = YES;
		
		if (@available(iOS 13.4, *))
		{
			UIPointerInteraction* pointerInteraction = [[UIPointerInteraction alloc] initWithDelegate:self];
			[self addInteraction:pointerInteraction];
		}
		
		_inheritsVisualStyleFromDockingView = YES;
		
		_userBackgroundStyle = LNBackgroundStyleInherit;
		
		_translucent = YES;
		
		_backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backgroundView.userInteractionEnabled = NO;
		[self addSubview:_backgroundView];
		
		_contentView = [_LNPopupBarContentView new];
		[self addSubview:_contentView];
		
		_interactionBackgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_interactionBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_interactionBackgroundView.userInteractionEnabled = NO;
		[_contentView addSubview:_interactionBackgroundView];
		
		self.effectGroupingIdentifier = nil;
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
		
		[self _innerSetBackgroundStyle:LNBackgroundStyleInherit tintColor:self._internalBarTintColor];
		
		_toolbar = [[_LNPopupToolbar alloc] initWithFrame:self.bounds];
		[_toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
		_toolbar.autoresizingMask = UIViewAutoresizingNone;
		_toolbar.layer.masksToBounds = YES;
		[_contentView addSubview:_toolbar];
		
		_titlesView = [[_LNPopupBarTitlesView alloc] initWithFrame:self.bounds];
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
		_titlesView.isAccessibilityElement = YES;
		
		_backgroundView.accessibilityTraits = UIAccessibilityTraitButton;
		_backgroundView.accessibilityIdentifier = @"PopupBarView";
		
		[self _setNeedsTitleLayout];
		[_contentView addSubview:_titlesView];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.progressViewStyle = UIProgressViewStyleBar;
		_progressView.trackImage = [UIImage new];
		[_contentView addSubview:_progressView];
		[self _updateProgressViewWithStyle:self.progressViewStyle];
		
		_needsLabelsLayout = YES;
		
		_imageView = [UIImageView new];
		_imageView.autoresizingMask = UIViewAutoresizingNone;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.accessibilityTraits = UIAccessibilityTraitImage;
		_imageView.isAccessibilityElement = YES;
		if (@available(iOS 13.0, *)) {
			_imageView.layer.cornerCurve = kCACornerCurveCircular;
		}
		_imageView.layer.cornerRadius = 6;
		_imageView.layer.masksToBounds = YES;
		// support smart invert and therefore do not invert image view colors
		_imageView.accessibilityIgnoresInvertColors = YES;
		
		[_contentView addSubview:_imageView];
		
		_shadowView = [_LNPopupBarShadowView new];
		_shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
		[_backgroundView.contentView addSubview:_shadowView];
		
		_bottomShadowView = [_LNPopupBarShadowView new];
		_bottomShadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
		_bottomShadowView.hidden = YES;
		[_contentView addSubview:_bottomShadowView];
		
		_highlightView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightView.userInteractionEnabled = NO;
		if (@available(iOS 13.0, *)) {
			_highlightView.backgroundColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
				if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
				{
					return [UIColor.whiteColor colorWithAlphaComponent:0.15];
				}
				else
				{
					return [UIColor.systemGray2Color colorWithAlphaComponent:0.35];
				}
			}];
		} else {
			_highlightView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
		}
		_highlightView.alpha = 0.0;
		[_contentView addSubview:_highlightView];
		
		_marqueeScrollEnabled = NO;
		_marqueeScrollRate = 30;
		_marqueeScrollDelay = 2.0;
		_coordinateMarqueeScroll = YES;
		
		self.semanticContentAttribute = UISemanticContentAttributeUnspecified;
		self.barItemsSemanticContentAttribute = UISemanticContentAttributePlayback;
		
		self.isAccessibilityElement = NO;
	}
	
	return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[self._barDelegate _traitCollectionForPopupBarDidChange:self];
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

		CGFloat barHeight = _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController);
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

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect frame = self.bounds;
	
	CGFloat barHeight = _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController);
	frame.size.height = barHeight;
	[_contentView setFrame:frame];
	[_backgroundView setFrame:frame];
	
	[self _layoutCustomBarController];
	
	[self _layoutImageView];
	
	CGFloat swiftuiOffset = __applySwiftUILayoutFixes ? 20 : 0;
	
	CGSize toolbarSize = [_toolbar sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
	_toolbar.bounds = CGRectMake(0, 0, self.bounds.size.width - swiftuiOffset, toolbarSize.height);
	_toolbar.center = CGPointMake(_contentView.center.x - swiftuiOffset / 2, _contentView.center.y - 1);
	[_toolbar layoutIfNeeded];
	
	[_contentView sendSubviewToBack:_interactionBackgroundView];
	[_contentView insertSubview:_highlightView aboveSubview:_interactionBackgroundView];
	[_contentView insertSubview:_toolbar aboveSubview:_highlightView];
	[_contentView insertSubview:_imageView aboveSubview:_toolbar];
	[_contentView insertSubview:_titlesView aboveSubview:_imageView];
	[_contentView insertSubview:_shadowView aboveSubview:_titlesView];
	[_contentView insertSubview:_bottomShadowView aboveSubview:_shadowView];
	if(_customBarViewController != nil)
	{
		[_contentView insertSubview:_customBarViewController.view aboveSubview:_bottomShadowView];
	}
	
	UIScreen* screen = self.window.screen ?: UIScreen.mainScreen;
	CGFloat h = 1 / screen.scale;
	_shadowView.frame = CGRectMake(0, 0, _contentView.bounds.size.width, h);
	_bottomShadowView.frame = CGRectMake(0, _contentView.bounds.size.height - h, _contentView.bounds.size.width, h);
	
	if(self.progressViewStyle == LNPopupBarProgressViewStyleTop)
	{
		_progressView.frame = CGRectMake(0, 0, _contentView.bounds.size.width, 1.5);
	}
	else
	{
		_progressView.frame = CGRectMake(0, _contentView.bounds.size.height - 2.5, _contentView.bounds.size.width, 1.5);
	}
	
	[self _layoutTitles];
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
	if(@available(iOS 13.0, *))
	{
		[visualEffectView setValue:groupingIdentifier ?: [NSString stringWithFormat:@"<%@:%p> Backdrop Group", self.class, self] forKey:self._effectGroupingIdentifierKey];
	}
}

- (void)_applyGroupingIdentifierToVisualEffectView:(UIVisualEffectView*)visualEffectView
{
	[self _applyGroupingIdentifier:self.effectGroupingIdentifier toVisualEffectView:visualEffectView];
}

- (NSString *)effectGroupingIdentifier
{
	if(@available(iOS 13.0, *))
	{
		return [self.backgroundView valueForKey:self._effectGroupingIdentifierKey];
	}
	
	return nil;
}

- (void)setEffectGroupingIdentifier:(NSString *)groupingIdentifier
{
	[self _applyGroupingIdentifier:groupingIdentifier toVisualEffectView:self.backgroundView];
	[self _applyGroupingIdentifier:groupingIdentifier toVisualEffectView:self.interactionBackgroundView];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return _userBackgroundStyle;
}

- (void)_innerSetBackgroundStyle:(UIBlurEffectStyle)backgroundStyle tintColor:(UIColor*)tintColor
{
	_userBackgroundStyle = backgroundStyle;
	
	_actualBackgroundStyle = _userBackgroundStyle == LNBackgroundStyleInherit ? _LNBlurEffectStyleForSystemBarStyle(_systemBarStyle, _resolvedStyle) : _userBackgroundStyle;

	BOOL hasOS13 = NO;
#ifndef LNPopupControllerEnforceStrictClean
	if(@available(iOS 13.0, *))
	{
		hasOS13 = YES;
	}
	
	if(tintColor != nil && hasOS13)
	{
		_customBlurEffect = _effectWithStyle_tintColor_invertAutomaticStyle(UIBlurEffect.class, _effectWithStyle_tintColor_invertAutomaticStyle_SEL, 100, tintColor, NO);
	}
	else
	{
#endif
		_customBlurEffect = [UIBlurEffect effectWithStyle:_actualBackgroundStyle];
#ifndef LNPopupControllerEnforceStrictClean
	}
#endif
	
	if(hasOS13 == NO)
	{
		_interactionBackgroundView.alpha = _backgroundView.alpha = tintColor != nil ? 0.0 : 1.0;
		self.backgroundColor = tintColor;
	}
	
	_interactionBackgroundView.effect = _backgroundView.effect = _customBlurEffect;
	
	if(_userBackgroundStyle == LNBackgroundStyleInherit)
	{
		if(@available(iOS 13.0, *))
		{
			_interactionBackgroundView.backgroundColor = _backgroundView.backgroundColor = nil;
		}
		else if(_actualBackgroundStyle == UIBlurEffectStyleDark)
		{
			_interactionBackgroundView.backgroundColor = _backgroundView.backgroundColor = [UIColor clearColor];
		}
		else if(_actualBackgroundStyle == UIBlurEffectStyleLight)
		{
			_interactionBackgroundView.backgroundColor = _backgroundView.backgroundColor = [UIColor colorWithWhite:230.0 / 255.0 alpha:_resolvedStyle == LNPopupBarStyleProminent ? 0.5 : 0.0];
		}
	}
	
	//Recalculate labels
	[self _setTitleLabelFontsAccordingToBarStyleAndTint];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	[self _innerSetBackgroundStyle:backgroundStyle tintColor:self._internalBarTintColor];
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

- (UIColor*)barTintColor
{
	return _userBarTintColor;
}

- (UIColor*)_internalBarTintColor
{
	return _userBarTintColor ?: _systemBarTintColor;
}

- (void)_internalSetBarTintColor:(UIColor*)barTintColor
{
	_userBarTintColor = barTintColor;
	
	UIColor* colorToUse = _userBarTintColor ?: _systemBarTintColor;
	
	if(_translucent == NO)
	{
		if (@available(iOS 13.0, *)) {
			colorToUse = colorToUse ? [colorToUse colorWithAlphaComponent:1.0] : UIColor.systemBackgroundColor;
		} else {
			colorToUse = colorToUse ? [colorToUse colorWithAlphaComponent:1.0] : (_actualBackgroundStyle == UIBlurEffectStyleLight || _actualBackgroundStyle == UIBlurEffectStyleExtraLight) ? [UIColor whiteColor] : [UIColor blackColor];
		}
	}
	
	[self _innerSetBackgroundStyle:self.backgroundStyle tintColor:colorToUse];
	
	[self._barDelegate _popupBarStyleDidChange:self];
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
	[self _internalSetBarTintColor:barTintColor];
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

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes
{
	_titleTextAttributes = titleTextAttributes;
}

- (void)setSubtitleTextAttributes:(NSDictionary<NSString *,id> *)subtitleTextAttributes
{
	_subtitleTextAttributes = subtitleTextAttributes;
}

- (void)setSystemBackgroundColor:(UIColor *)systemBackgroundColor
{
	_systemBackgroundColor = systemBackgroundColor;
	
	[self _internalSetBackgroundColor:_userBackgroundColor];
}

- (void)setSystemBarStyle:(UIBarStyle)systemBarStyle
{
	_systemBarStyle = systemBarStyle;
	
	[self _innerSetBackgroundStyle:_userBackgroundStyle tintColor:self._internalBarTintColor];
}

- (void)setProgressViewStyle:(LNPopupBarProgressViewStyle)progressViewStyle
{
	if(_progressViewStyle != progressViewStyle)
	{
		[self _updateProgressViewWithStyle:progressViewStyle];
	}
	
	_progressViewStyle = progressViewStyle;
}

- (void)setSystemBarTintColor:(UIColor *)systemBarTintColor
{
	_systemBarTintColor = systemBarTintColor;
	
	[self _internalSetBarTintColor:_userBarTintColor];
}

- (void)setSystemTintColor:(UIColor *)systemTintColor
{
	_systemTintColor = systemTintColor;
	
	[self setTintColor:_userTintColor];
}

- (void)setSystemShadowColor:(UIColor *)systemShadowColor
{
	_systemShadowColor = systemShadowColor;
	
	_shadowView.backgroundColor = systemShadowColor;
	_bottomShadowView.backgroundColor = systemShadowColor;
}

- (void)setTranslucent:(BOOL)translucent
{
	_translucent = translucent;
	
	_interactionBackgroundView.hidden = _backgroundView.hidden = _translucent == NO;
	
	[self _internalSetBarTintColor:_userBarTintColor];
}

- (void)setTitle:(NSString *)title
{
	_title = [title copy];
	
	[self _setNeedsTitleLayout];
}

- (void)setSubtitle:(NSString *)subtitle
{
	_subtitle = [subtitle copy];
	
	[self _setNeedsTitleLayout];
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	
	[self _layoutImageView];
	[self _setNeedsTitleLayout];
}

- (void)setSwiftuiImageController:(UIViewController *)swiftuiImageController
{
	if(_swiftuiImageController != nil)
	{
		[_swiftuiImageController.view removeFromSuperview];
	}
	
	_swiftuiImageController = swiftuiImageController;
	
	_swiftuiImageController.view.translatesAutoresizingMaskIntoConstraints = NO;
	[_imageView addSubview:_swiftuiImageController.view];
	[NSLayoutConstraint activateConstraints:@[
		[_imageView.topAnchor constraintEqualToAnchor:_swiftuiImageController.view.topAnchor],
		[_imageView.bottomAnchor constraintEqualToAnchor:_swiftuiImageController.view.bottomAnchor],
		[_imageView.leadingAnchor constraintEqualToAnchor:_swiftuiImageController.view.leadingAnchor],
		[_imageView.trailingAnchor constraintEqualToAnchor:_swiftuiImageController.view.trailingAnchor],
	]];
	
	[self _layoutImageView];
	[self _setNeedsTitleLayout];
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

- (UILabel<__MarqueeLabelType>*)_newMarqueeLabel
{
	if(_marqueeScrollEnabled == NO)
	{
		__FakeMarqueeLabel* rv = [[__FakeMarqueeLabel alloc] initWithFrame:_titlesView.bounds];
		rv.minimumScaleFactor = 1.0;
		rv.lineBreakMode = NSLineBreakByTruncatingTail;
		return rv;
	}
	
	MarqueeLabel* rv = [[MarqueeLabel alloc] initWithFrame:_titlesView.bounds rate:_marqueeScrollRate andFadeLength:10];
	rv.leadingBuffer = 0.0;
	rv.trailingBuffer = 20.0;
	rv.animationDelay = _marqueeScrollDelay;
	rv.marqueeType = MLContinuous;
	rv.holdScrolling = YES;
	return rv;
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
	
	[leftViewLast.superview layoutIfNeeded];
	[rightViewFirst.superview layoutIfNeeded];
	
	CGRect leftViewLastFrame = CGRectZero;
	if(leftViewLast != nil)
	{
		leftViewLastFrame = [self convertRect:leftViewLast.bounds fromView:leftViewLast];
	}
	
	CGRect rightViewFirstFrame = CGRectMake(self.bounds.size.width, 0, 0, 0);
	if(rightViewFirst != nil)
	{
		rightViewFirstFrame = [self convertRect:rightViewFirst.bounds fromView:rightViewFirst];
	}
	
	CGFloat widthLeft = 0;
	CGFloat widthRight = 0;
	
	widthLeft = leftViewLastFrame.origin.x + leftViewLastFrame.size.width;
	widthRight = self.bounds.size.width - rightViewFirstFrame.origin.x;
	
	widthLeft = MAX(widthLeft, self.layoutMargins.left);
	widthRight = MAX(widthRight, self.layoutMargins.right);
	
	//The added padding is for iOS 10 and below, or for certain conditions where iOS 11 won't put its own padding
	titleInsets->left = widthLeft;
	titleInsets->right = widthRight;
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
	
	[leftViewLast.superview layoutIfNeeded];
	[rightViewFirst.superview layoutIfNeeded];
	
	CGRect leftViewLastFrame = CGRectZero;
	if(leftViewLast != nil)
	{
		leftViewLastFrame = [self convertRect:leftViewLast.bounds fromView:leftViewLast];
		
		if(leftViewLast == _imageView)
		{
			leftViewLastFrame.size.width += MIN(self.layoutMargins.left, 20);
		}
	}
	
	CGRect rightViewFirstFrame = CGRectMake(self.bounds.size.width, 0, 0, 0);
	if(rightViewFirst != nil)
	{
		rightViewFirstFrame = [self convertRect:rightViewFirst.bounds fromView:rightViewFirst];
		
		if(rightViewFirst == _imageView)
		{
			rightViewFirstFrame.origin.x -= MIN(self.layoutMargins.left, 20);
		}
	}
	
	CGFloat widthLeft = 0;
	CGFloat widthRight = 0;
	
	widthLeft = leftViewLastFrame.origin.x + leftViewLastFrame.size.width;
	widthRight = self.bounds.size.width - rightViewFirstFrame.origin.x;
	
	widthLeft = MAX(widthLeft, self.layoutMargins.left);
	widthRight = MAX(widthRight, self.layoutMargins.right);
	
	//The added padding is for iOS 10 and below, or for certain conditions where iOS 11 won't put its own padding
	titleInsets->left = widthLeft;
	titleInsets->right = widthRight;
}

- (void)_layoutTitles
{
	UIEdgeInsets titleInsets = UIEdgeInsetsZero;
	
	if(_resolvedStyle == LNPopupBarStyleProminent)
	{
		[self _updateTitleInsetsForProminentBar:&titleInsets];
	}
	else
	{
		[self _updateTitleInsetsForCompactBar:&titleInsets];
	}
	
	titleInsets.left = MAX(titleInsets.left, self.layoutMargins.left);
	titleInsets.right = MAX(titleInsets.right, self.layoutMargins.right);
	
	CGRect frame = _titlesView.frame;
	frame.size.width = self.bounds.size.width - titleInsets.left - titleInsets.right;
	frame.size.height = _contentView.bounds.size.height;
	frame.origin.x = titleInsets.left;
	
	_titlesView.frame = frame;
	
	if(_needsLabelsLayout == YES)
	{
		if(_titleLabel == nil)
		{
			_titleLabel = [self _newMarqueeLabel];
			_titleLabel.font = _resolvedStyle == LNPopupBarStyleProminent ? [UIFont systemFontOfSize:18 weight:UIFontWeightRegular] : [UIFont systemFontOfSize:14];
			[_titlesView addSubview:_titleLabel];
		}
		
		BOOL reset = NO;
		
		NSAttributedString* attr = _title ? [[NSAttributedString alloc] initWithString:_title attributes:_titleTextAttributes] : nil;
		if(_title != nil && [_titleLabel.attributedText isEqualToAttributedString:attr] == NO)
		{
			_titleLabel.attributedText = attr;
			reset = YES;
		}
		
		if(_subtitleLabel == nil)
		{
			_subtitleLabel = [self _newMarqueeLabel];
			_subtitleLabel.font = _resolvedStyle == LNPopupBarStyleProminent ? [UIFont systemFontOfSize:14 weight:UIFontWeightRegular] : [UIFont systemFontOfSize:11];
			[_titlesView addSubview:_subtitleLabel];
		}
		
		attr = _subtitle ? [[NSAttributedString alloc] initWithString:_subtitle attributes:_subtitleTextAttributes] : nil;
		if(_subtitle != nil && [_subtitleLabel.attributedText isEqualToAttributedString:attr] == NO)
		{
			_subtitleLabel.attributedText = attr;
			reset = YES;
		}
		
		if(reset)
		{
			[_titleLabel resetLabel];
			[_subtitleLabel resetLabel];
		}
	}
	
	[self _setTitleLabelFontsAccordingToBarStyleAndTint];
	
	CGRect titleLabelFrame = _titlesView.bounds;
	
	CGFloat barHeight = _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController);
	titleLabelFrame.size.height = barHeight;
	
	//Add some padding for compact bar
	if(@available(iOS 13.0, *))
	{
		if(_resolvedStyle == LNPopupBarStyleCompact)
		{
			titleLabelFrame.origin.x += 8;
			titleLabelFrame.size.width -= 16;
		}
	}
	
	if(_subtitle.length > 0)
	{
		CGRect subtitleLabelFrame = _titlesView.bounds;
		subtitleLabelFrame.size.height = barHeight;
		
		if(_resolvedStyle == LNPopupBarStyleProminent)
		{
			titleLabelFrame.origin.y -= _titleLabel.font.lineHeight / 2.1;
			subtitleLabelFrame.origin.y += _subtitleLabel.font.lineHeight / 1.5;
		}
		else
		{
			//Add some padding for compact bar
			if(@available(iOS 13.0, *))
			{
				subtitleLabelFrame.origin.x += 8;
				subtitleLabelFrame.size.width -= 16;
			}
			
			titleLabelFrame.origin.y -= _titleLabel.font.lineHeight / 2;
			subtitleLabelFrame.origin.y += _subtitleLabel.font.lineHeight / 2;
		}
		
		_subtitleLabel.frame = subtitleLabelFrame;
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
		if(_needsLabelsLayout == YES)
		{
			[_subtitleLabel resetLabel];
			[_subtitleLabel pauseLabel];
			_subtitleLabel.hidden = YES;
		}
	}
	
	[self _updateAccessibility];
	
	_titleLabel.frame = titleLabelFrame;
	
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
		if(_title.length > 0)
		{
			[accessibilityLabel appendString:_title];
			[accessibilityLabel appendString:@"\n"];
		}
		if(_subtitle.length > 0)
		{
			[accessibilityLabel appendString:_subtitle];
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

- (void)_setNeedsTitleLayout
{
	_needsLabelsLayout = YES;
	
	UIView* l1 = _titleLabel;
	UIView* l2 = _subtitleLabel;
	
	_titleLabel = nil;
	_subtitleLabel = nil;
	
	[l1 removeFromSuperview];
	[l2 removeFromSuperview];
	
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
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		CGFloat safeLeading = MAX(self.window.safeAreaInsets.left, self.layoutMargins.left);
		_imageView.center = CGPointMake(safeLeading + LNPopupBarProminentImageWidth / 2, LNPopupBarHeightProminent / 2);
	}
	else
	{
		CGFloat safeLeading = MAX(self.window.safeAreaInsets.right, self.layoutMargins.right);
		_imageView.center = CGPointMake(self.bounds.size.width - safeLeading - LNPopupBarProminentImageWidth / 2, LNPopupBarHeightProminent / 2);
	}
	
	_imageView.bounds = CGRectMake(0, 0, LNPopupBarProminentImageWidth, LNPopupBarProminentImageWidth);
	
	if(previouslyHidden != _imageView.hidden)
	{
		[self _setNeedsTitleLayout];
	}
}

- (void)_setTitleLabelFontsAccordingToBarStyleAndTint
{
	if (@available(iOS 13.0, *))
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor labelColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor secondaryLabelColor];
		
		return;
	}
	
	if(_actualBackgroundStyle != UIBlurEffectStyleDark)
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: _resolvedStyle == LNPopupBarStyleProminent ? [UIColor colorWithWhite:(38.0 / 255.0) alpha:1.0] : [UIColor blackColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: _resolvedStyle == LNPopupBarStyleProminent ? [UIColor colorWithWhite:(38.0 / 255.0) alpha:1.0] : [UIColor blackColor];
	}
	else
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor whiteColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor whiteColor];
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
	if(resolvedStyle == LNPopupBarStyleProminent || resolvedStyle == LNPopupBarStyleCustom)
	{
		[items addObject:flexibleSpacer];
	}
	
	if(resolvedStyle == LNPopupBarStyleProminent && __applySwiftUILayoutFixes)
	{
		UIView* spacing = [UIView new];
		spacing.translatesAutoresizingMaskIntoConstraints = NO;
		[spacing.widthAnchor constraintEqualToConstant:20].active = YES;
//		[spacing.heightAnchor constraintEqualToConstant:20].active = YES;
//		spacing.backgroundColor = UIColor.greenColor;
		
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:spacing]];
	}
	
	[self.leadingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	if(resolvedStyle == LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}
	else if(__applySwiftUILayoutFixes)
	{
		UIView* spacing = [UIView new];
		spacing.translatesAutoresizingMaskIntoConstraints = NO;
		[spacing.widthAnchor constraintEqualToConstant:20].active = YES;
//		[spacing.heightAnchor constraintEqualToConstant:20].active = YES;
//		spacing.backgroundColor = UIColor.greenColor;
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:spacing]];
	}

	[self.trailingBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	UIBarButtonItem* fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	fixedSpacer.width = _resolvedStyle == LNPopupBarStyleProminent ? 2 : -2;
	[items addObject:fixedSpacer];
	
	[_toolbar setItems:items animated:YES];
	
	[self _setNeedsTitleLayout];
	
	_delaysBarButtonItemLayout = NO;
}

- (void)_updateViewsAfterCustomBarViewControllerUpdate
{
	BOOL hide = _customBarViewController != nil;
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
	
	[self layoutIfNeeded];
	
	if (customBarViewController.containingPopupBar)
	{
		//Cleanly move the custom bar view controller from the previos popup bar.
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

- (void)setMarqueeScrollEnabled:(BOOL)marqueeScrollEnabled
{
	_marqueeScrollEnabled = marqueeScrollEnabled;
	
	[self _setNeedsTitleLayout];
}

- (void)setMarqueeScrollRate:(CGFloat)marqueeScrollRate
{
	_marqueeScrollRate = marqueeScrollRate;
	
	_titleLabel.rate = _marqueeScrollRate;
	_subtitleLabel.rate = _marqueeScrollRate;
	
	[self _recalculateCoordinatedMarqueeScrollIfNeeded];
}

- (void)setMarqueeScrollDelay:(NSTimeInterval)marqueeScrollDelay
{
	_marqueeScrollDelay = marqueeScrollDelay;
	
	[self _recalculateCoordinatedMarqueeScrollIfNeeded];
}

- (void)setCoordinateMarqueeScroll:(BOOL)coordinateMarqueeScroll
{
	_coordinateMarqueeScroll = coordinateMarqueeScroll;
	
	[self _recalculateCoordinatedMarqueeScrollIfNeeded];
}

- (void)_recalculateCoordinatedMarqueeScrollIfNeeded
{
	if(_marqueeScrollEnabled == NO)
	{
		return;
	}
	
	if(_marqueePaused == YES)
	{
		return;
	}
	
	MarqueeLabel* titleLabel = (id)_titleLabel;
	MarqueeLabel* subtitleLabel = (id)_subtitleLabel;
	
	titleLabel.animationDelay = _marqueeScrollDelay;
	subtitleLabel.animationDelay = _marqueeScrollDelay;
	
	if(_coordinateMarqueeScroll == YES && _title.length > 0 && _subtitle.length > 0)
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

- (void)_removeAnimationFromBarItems
{
	[_toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
	 {
		 UIView* itemView = [barButtonItem valueForKey:@"view"];
		 [itemView.layer removeAllAnimations];
	 }];
}

- (void)_transitionCustomBarViewControllerWithPopupContainerSize:(CGSize)size withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	CGSize nextSize = CGSizeMake(size.width, _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController));
	[self.customBarViewController viewWillTransitionToSize:nextSize withTransitionCoordinator:coordinator];
}

- (void)_transitionCustomBarViewControllerWithPopupContainerTraitCollection:(UITraitCollection *)newCollection withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[_customBarViewController willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)dealloc
{
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

@end

#pragma mark - Deprecations

@implementation LNPopupBar (Deprecated)

- (NSArray<UIBarButtonItem *> *)leftBarButtonItems
{
	return self.leadingBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)rightBarButtonItems
{
	return self.trailingBarButtonItems;
}

@end
