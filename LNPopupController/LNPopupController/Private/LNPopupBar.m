//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "LNPopupCustomBarViewController+Private.h"
#import "MarqueeLabel.h"
#import "_LNPopupBase64Utils.h"

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
	
	//On iOS 11 reset the semantic content attribute to make sure it propagades to all subviews.
	if(@available(iOS 11, *))
	{
		[self setSemanticContentAttribute:self.semanticContentAttribute];
	}
}

- (void)_deepSetSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute toView:(UIView*)view startingFromView:(UIView*)staringView;
{
	if(view == staringView)
	{
		[super setSemanticContentAttribute:semanticContentAttribute];
	}
	else
	{
		NSLog(@"View: %@", view);
		[view setSemanticContentAttribute:semanticContentAttribute];
	}
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:obj startingFromView:staringView];
	}];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute
{
	if(@available(iOS 11, *))
	{
		//On iOS 11, due to a bug in UIKit, the semantic content attribute must be propagaded recursively to all subviews, so that the system behaves correctly.
		[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:self startingFromView:self];
	}
	else
	{
		[super setSemanticContentAttribute:semanticContentAttribute];
	}
}

@end

@protocol __MarqueeLabelType <NSObject>

- (void)resetLabel;
- (void)unpauseLabel;
- (void)pauseLabel;
- (void)restartLabel;
- (BOOL)isPaused;

@end

@interface __FakeMarqueeLabel : UILabel <__MarqueeLabelType> @end
@implementation __FakeMarqueeLabel

- (void)resetLabel {}
- (void)unpauseLabel {}
- (void)pauseLabel {}
- (void)restartLabel {}
- (BOOL)isPaused { return NO; }

@end

@interface MarqueeLabel () <__MarqueeLabelType> @end

const CGFloat LNPopupBarHeightCompact = 40.0;
const CGFloat LNPopupBarHeightProminent = 64.0;
const CGFloat LNPopupBarProminentImageWidth = 48.0;

const NSInteger LNBackgroundStyleInherit = -1;

@implementation LNPopupBar
{
	LNPopupBarStyle _resolvedStyle;
	
	UIVisualEffectView* _backgroundView;
	BOOL _delaysBarButtonItemLayout;
	UIView* _titlesView;
	UILabel<__MarqueeLabelType>* _titleLabel;
	UILabel<__MarqueeLabelType>* _subtitleLabel;
	BOOL _needsLabelsLayout;
	
	UIColor* _userTintColor;
	UIColor* _userBackgroundColor;
	
	UIBlurEffectStyle _actualBackgroundStyle;
	UIBlurEffect* _customBlurEffect;
	
	UIView* _shadowView;
    
    NSArray<__kindof NSLayoutConstraint *> * _progressViewVerticalConstraints;
}

CGFloat _LNPopupBarHeightForBarStyle(LNPopupBarStyle style, LNPopupCustomBarViewController* customBarVC)
{
	if(customBarVC) { return customBarVC.preferredContentSize.height; }
	
	return style == LNPopupBarStyleCompact ? LNPopupBarHeightCompact : LNPopupBarHeightProminent;
}

LNPopupBarStyle _LNPopupResolveBarStyleFromBarStyle(LNPopupBarStyle style)
{
	LNPopupBarStyle rv = style;
	if(rv == LNPopupBarStyleDefault)
	{
		rv = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9 ? LNPopupBarStyleProminent : LNPopupBarStyleCompact;
	}
	return rv;
}

static LNPopupBarProgressViewStyle _LNPopupResolveProgressViewStyleFromProgressViewStyle(LNPopupBarProgressViewStyle style)
{
	LNPopupBarProgressViewStyle rv = style;
	if(rv == LNPopupBarProgressViewStyleDefault)
	{
		rv = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9 ? LNPopupBarProgressViewStyleNone : LNPopupBarProgressViewStyleBottom;
	}
	return rv;
}

static UIBlurEffectStyle _LNBlurEffectStyleForSystemBarStyle(UIBarStyle systemBarStyle, LNPopupBarStyle barStyle)
{
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
		
		[self._barDelegate _popupBarStyleDidChange:self];
	}
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
		
		_inheritsVisualStyleFromDockingView = YES;
		
		_userBackgroundStyle = LNBackgroundStyleInherit;
		
		_translucent = YES;
		
		_backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backgroundView.userInteractionEnabled = NO;
		[self addSubview:_backgroundView];
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
		
		[self _innerSetBackgroundStyle:LNBackgroundStyleInherit];
		
		_toolbar = [[_LNPopupToolbar alloc] initWithFrame:self.bounds];
		[_toolbar setBackgroundImage:[UIImage alloc] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
		_toolbar.autoresizingMask = UIViewAutoresizingNone;
		_toolbar.layer.masksToBounds = YES;

		[self addSubview:_toolbar];
		
		_titlesView = [[UIView alloc] initWithFrame:self.bounds];
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
		_titlesView.isAccessibilityElement = YES;
		
		_backgroundView.accessibilityTraits = UIAccessibilityTraitButton;
		_backgroundView.accessibilityIdentifier = @"PopupBarView";
		
		[self _setNeedsTitleLayout];
		[_toolbar addSubview:_titlesView];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.translatesAutoresizingMaskIntoConstraints = NO;
		_progressView.trackImage = [UIImage alloc];
		[_toolbar addSubview:_progressView];
		[self _updateProgressViewWithStyle:self.progressViewStyle];
        
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		
		_needsLabelsLayout = YES;
		
		_imageView = [UIImageView new];
		_imageView.autoresizingMask = UIViewAutoresizingNone;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.accessibilityTraits = UIAccessibilityTraitImage;
		_imageView.isAccessibilityElement = YES;
		_imageView.layer.cornerRadius = 3;
		_imageView.layer.masksToBounds = YES;
        if (@available(iOS 11, *)) {
            // support smart invert and therefore do not invert image view colors
            _imageView.accessibilityIgnoresInvertColors = YES;
        }
		
		[_toolbar addSubview:_imageView];
		
		_shadowView = [UIView new];
		_shadowView.backgroundColor = [UIColor colorWithWhite:169.0 / 255.0 alpha:1.0];
		[self addSubview:_shadowView];
		
		_highlightView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightView.userInteractionEnabled = NO;
		[_highlightView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1]];
		_highlightView.alpha = 0.0;
		[self addSubview:_highlightView];
		
		_marqueeScrollEnabled = [NSProcessInfo processInfo].operatingSystemVersion.majorVersion < 10;
		_coordinateMarqueeScroll = YES;
		
		self.semanticContentAttribute = UISemanticContentAttributeUnspecified;
		self.barItemsSemanticContentAttribute = UISemanticContentAttributePlayback;
		
		self.isAccessibilityElement = NO;
		self.clipsToBounds = YES;
	}
	
	return self;
}

- (void)_updateProgressViewWithStyle:(LNPopupBarProgressViewStyle)style
{
	style = _LNPopupResolveProgressViewStyleFromProgressViewStyle(style);
	
	[_progressView setHidden:style == LNPopupBarProgressViewStyleNone];
	
    if(style == LNPopupBarProgressViewStyleTop)
    {
        _progressViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_progressView(1.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)];
    }
    else
	{
        _progressViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView(1.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)];
    }
    [self addConstraints:_progressViewVerticalConstraints];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[_backgroundView setFrame:self.bounds];
	
	[self _layoutImageView];
	
	[UIView performWithoutAnimation:^{
		_toolbar.frame = CGRectMake(0, 0, self.bounds.size.width, _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController));
		[_toolbar layoutIfNeeded];
		
		[self bringSubviewToFront:_highlightView];
		[self bringSubviewToFront:_toolbar];
		//	[_toolbar bringSubviewToFront:_imageView];
		//	[_toolbar bringSubviewToFront:_titlesView];
		[self bringSubviewToFront:_shadowView];
		
		_shadowView.frame = CGRectMake(0, 0, self.toolbar.bounds.size.width, 1 / self.window.screen.nativeScale);
		
		[self _layoutTitles];
	}];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return _userBackgroundStyle;
}

- (void)_innerSetBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	_userBackgroundStyle = backgroundStyle;
	
	_actualBackgroundStyle = _userBackgroundStyle == LNBackgroundStyleInherit ? _LNBlurEffectStyleForSystemBarStyle(_systemBarStyle, _resolvedStyle) : _userBackgroundStyle;

	_customBlurEffect = [UIBlurEffect effectWithStyle:_actualBackgroundStyle];
	
	[_backgroundView setValue:_customBlurEffect forKey:@"effect"];
	
	if(_userBackgroundStyle == LNBackgroundStyleInherit)
	{
		if(_actualBackgroundStyle == UIBlurEffectStyleDark)
		{
			_backgroundView.backgroundColor = [UIColor clearColor];
		}
		else if(_actualBackgroundStyle == UIBlurEffectStyleLight)
		{
			_backgroundView.backgroundColor = [UIColor colorWithWhite:230.0 / 255.0 alpha:_resolvedStyle == LNPopupBarStyleProminent ? 0.5 : 0.0];
		}
	}
	
	//Recalculate bar tint color
	[self _internalSetBarTintColor:_userBarTintColor];
	
	//Recalculate labels
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
}

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	[self _innerSetBackgroundStyle:backgroundStyle];
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

- (void)_internalSetBarTintColor:(UIColor*)barTintColor
{
	_userBarTintColor = barTintColor;
	
	UIColor* colorToUse = [_userBarTintColor ?: _systemBarTintColor colorWithAlphaComponent:0.67];
	
	if(_translucent == NO)
	{
		colorToUse = colorToUse ? [colorToUse colorWithAlphaComponent:1.0] : (_actualBackgroundStyle == UIBlurEffectStyleLight || _actualBackgroundStyle == UIBlurEffectStyleExtraLight) ? [UIColor whiteColor] : [UIColor blackColor];
	}
	
	self.backgroundColor = colorToUse;
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
	
	[self _innerSetBackgroundStyle:_userBackgroundStyle];
}

- (void)setProgressViewStyle:(LNPopupBarProgressViewStyle)progressViewStyle
{
	if(_progressViewStyle != progressViewStyle)
	{
		[self removeConstraints:_progressViewVerticalConstraints];
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
}

- (void)setTranslucent:(BOOL)translucent
{
	_translucent = translucent;
	
	_backgroundView.hidden = _translucent == NO;
	
	[self _internalSetBarTintColor:_userBarTintColor];
}

- (void)setTitle:(NSString *)title
{
	_title = [title copy];
	
	if(_coordinateMarqueeScroll)
	{
		[self _setNeedsTitleLayout];
	}
	else
	{
		_titleLabel.text = _title;
	}
}

- (void)setSubtitle:(NSString *)subtitle
{
	_subtitle = [subtitle copy];
	
	if(_coordinateMarqueeScroll)
	{
		[self _setNeedsTitleLayout];
	}
	else
	{
		_subtitleLabel.text = _subtitle;
	}
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	
	[self _layoutImageView];
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
	
	//On iOS 10 and below, there is a bug when setting a UIToolbar's semanticContentAttribute which may cause incorrect layout. So lets trigger 
	if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 10)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_toolbar setNeedsLayout];
			[_toolbar layoutIfNeeded];
		});
	}
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
		return rv;
	}
	
	MarqueeLabel* rv = [[MarqueeLabel alloc] initWithFrame:_titlesView.bounds rate:20 andFadeLength:10];
	rv.leadingBuffer = 5.0;
	rv.trailingBuffer = 15.0;
	rv.animationDelay = 2.0;
	rv.marqueeType = MLContinuous;
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
	[barButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		UIView* itemView = [self _viewForBarButtonItem:barButtonItem];
		
		if(itemView == nil)
		{
			return;
		}
		
		*leftmostView = *leftmostView == nil ? itemView : itemView.frame.origin.x < (*leftmostView).frame.origin.x ? itemView : *leftmostView;
		*rightmostView = *rightmostView == nil ? itemView : itemView.frame.origin.x > (*rightmostView).frame.origin.x ? itemView : *rightmostView;
	}];
}

- (void)_updateTitleInsetsForCompactBar:(UIEdgeInsets*)titleInsets
{
	UIView* leftmostViewLeft;
	UIView* rightmostViewLeft;
	[self _getLeftmostView:&leftmostViewLeft rightmostView:&rightmostViewLeft fromBarButtonItems:self.leftBarButtonItems];
	
	UIView* leftmostViewRight;
	UIView* rightmostViewRight;
	[self _getLeftmostView:&leftmostViewRight rightmostView:&rightmostViewRight fromBarButtonItems:self.rightBarButtonItems];
	
	CGFloat widthLeft = rightmostViewLeft.frame.origin.x + rightmostViewLeft.frame.size.width - leftmostViewLeft.frame.origin.x;
	CGFloat widthRight = rightmostViewRight.frame.origin.x + rightmostViewRight.frame.size.width - leftmostViewRight.frame.origin.x;
	
	if(@available(iOS 11, *))
	{
		widthLeft += self.window.safeAreaInsets.left;
		widthRight += self.window.safeAreaInsets.right;
	}
	else
	{
		widthLeft += 1.5 * self.layoutMargins.left;
		widthRight += 1.5 * self.layoutMargins.right;
	}
	
	//The added padding is for iOS 10 and below, or for certain conditions where iOS 11 won't put its own padding
	titleInsets->left = widthLeft;
	titleInsets->right = widthRight;
}

- (void)_updateTitleInsetsForProminentBar:(UIEdgeInsets*)titleInsets
{
	UIView* leftmostView;
	UIView* rightmostView;
	
	NSMutableArray* allItems = [NSMutableArray new];
	[allItems addObjectsFromArray:self.leftBarButtonItems];
	[allItems addObjectsFromArray:self.rightBarButtonItems];
	
	[self _getLeftmostView:&leftmostView rightmostView:&rightmostView fromBarButtonItems:allItems];
	
	CGFloat width = rightmostView.frame.origin.x + rightmostView.frame.size.width - leftmostView.frame.origin.x;
	if(@available(iOS 11, *))
	{
		width += self.window.safeAreaInsets.right;
	}
	else
	{
		width += 2 * self.layoutMargins.right;
	}
	titleInsets->right += width;
}

- (void)_layoutTitles
{
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	UIEdgeInsets titleInsets = UIEdgeInsetsZero;
	
	CGFloat imageLeading;
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		imageLeading = self.layoutMargins.left;
		if (@available(iOS 11.0, *)) {
			imageLeading = MAX(self.window.safeAreaInsets.left, imageLeading);
		}
	}
	else
	{
		imageLeading = self.layoutMargins.right;
		if (@available(iOS 11.0, *)) {
			imageLeading = MAX(self.window.safeAreaInsets.right, imageLeading);
		}
	}
	
	if(_resolvedStyle == LNPopupBarStyleProminent)
	{
		titleInsets.left = _imageView.hidden ? 0 : imageLeading + _imageView.frame.size.width + 17.5;
		
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
	frame.size.height = self.bounds.size.height;
	frame.origin.x = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight ? titleInsets.left : titleInsets.right;
	
	_titlesView.frame = frame;
	
	if(_needsLabelsLayout == YES)
	{
		if(_titleLabel == nil)
		{
			_titleLabel = [self _newMarqueeLabel];
			[_titlesView addSubview:_titleLabel];
		}
		
		NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
		if(_resolvedStyle == LNPopupBarStyleCompact)
		{
			paragraph.alignment = NSTextAlignmentCenter;
		}
		else
		{
			paragraph.alignment = NSTextAlignmentNatural;
		}
		
		if(_marqueeScrollEnabled == NO)
		{
			paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
		}
		
		NSMutableDictionary* defaultTitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: _resolvedStyle == LNPopupBarStyleProminent ? [UIFont systemFontOfSize:18 weight:UIFontWeightRegular] : [UIFont systemFontOfSize:12]} mutableCopy];
		[defaultTitleAttribures addEntriesFromDictionary:_titleTextAttributes];
		
		NSMutableDictionary* defaultSubtitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: _resolvedStyle == LNPopupBarStyleProminent ? [UIFont systemFontOfSize:14 weight:UIFontWeightRegular] : [UIFont systemFontOfSize:12]} mutableCopy];
		[defaultSubtitleAttribures addEntriesFromDictionary:_subtitleTextAttributes];
		
		BOOL reset = NO;
		
		if([_titleLabel.text isEqualToString:_title] == NO && _title != nil)
		{
			_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_title attributes:defaultTitleAttribures];
			reset = YES;
		}
		
		if(_subtitleLabel == nil)
		{
			_subtitleLabel = [self _newMarqueeLabel];
			[_titlesView addSubview:_subtitleLabel];
		}
		
		if([_subtitleLabel.text isEqualToString:_subtitle] == NO && _subtitle != nil)
		{
			_subtitleLabel.attributedText = [[NSAttributedString alloc] initWithString:_subtitle attributes:defaultSubtitleAttribures];
			reset = YES;
		}
		
		if(reset)
		{
			[_titleLabel resetLabel];
			[_subtitleLabel resetLabel];
		}
	}
	
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
	
	CGRect titleLabelFrame = _titlesView.bounds;
	
	CGFloat barHeight = _LNPopupBarHeightForBarStyle(_resolvedStyle, _customBarViewController);
	titleLabelFrame.size.height = barHeight;
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
	_imageView.hidden = _image == nil;
	
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
	
	if(layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		CGFloat safeLeading = self.layoutMargins.left;
		if (@available(iOS 11.0, *)) {
			safeLeading = MAX(self.window.safeAreaInsets.left, safeLeading);
		}
		
		_imageView.center = CGPointMake(safeLeading + LNPopupBarProminentImageWidth / 2, LNPopupBarHeightProminent / 2);
	}
	else
	{
		CGFloat safeLeading = self.layoutMargins.right;
		if (@available(iOS 11.0, *)) {
			safeLeading = MAX(self.window.safeAreaInsets.right, safeLeading);
		}
		
		_imageView.center = CGPointMake(self.bounds.size.width - safeLeading - LNPopupBarProminentImageWidth / 2, LNPopupBarHeightProminent / 2);
	}
	
	_imageView.bounds = CGRectMake(0, 0, LNPopupBarProminentImageWidth, LNPopupBarProminentImageWidth);
	
	if(previouslyHidden != _imageView.hidden)
	{
		[self _setNeedsTitleLayout];
	}
}

- (void)_setTitleLableFontsAccordingToBarStyleAndTint
{
	if(_actualBackgroundStyle != UIBlurEffectStyleDark)
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: _resolvedStyle == LNPopupBarStyleProminent ? [UIColor colorWithWhite:(38.0 / 255.0) alpha:1.0] : [UIColor blackColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: _resolvedStyle == LNPopupBarStyleProminent ? [UIColor colorWithWhite:(38.0 / 255.0) alpha:1.0] : [UIColor darkGrayColor];
	}
	else
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor whiteColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor whiteColor];
	}
}

- (void)_setTitleViewMarqueesPaused:(BOOL)paused
{
	if(paused)
	{
		[_titleLabel restartLabel];
		[_titleLabel pauseLabel];
		[_subtitleLabel restartLabel];
		[_subtitleLabel pauseLabel];
	}
	else
	{
		[_titleLabel unpauseLabel];
		if(_subtitle.length > 0)
		{
			[_subtitleLabel unpauseLabel];
			
		}
	}
}

- (void)_delayBarButtonLayout
{
	_delaysBarButtonItemLayout = YES;
}

- (void)_layoutBarButtonItems
{
	if(self.leftBarButtonItems.count + self.rightBarButtonItems.count == 0)
	{
		return;
	}
	
	UIUserInterfaceLayoutDirection barItemsLayoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_barItemsSemanticContentAttribute];
	UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];

	BOOL normalButtonsOrder = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight || barItemsLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	
	NSEnumerationOptions enumerationOptions = normalButtonsOrder ? 0 : NSEnumerationReverse;
	
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
	
	NSMutableArray* items = [NSMutableArray new];
	
	UIBarButtonItem* flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	flexibleSpacer.tag = 666;
	if(resolvedStyle == LNPopupBarStyleProminent || resolvedStyle == LNPopupBarStyleCustom)
	{
		[items addObject:flexibleSpacer];
	}
	
	[self.leftBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
	}];
	
	if(resolvedStyle == LNPopupBarStyleCompact)
	{
		[items addObject:flexibleSpacer];
	}

	[self.rightBarButtonItems enumerateObjectsWithOptions:enumerationOptions usingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
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
		[self._barDelegate _popupBarStyleDidChange:self];
	}
}

- (void)setCustomBarViewController:(LNPopupCustomBarViewController*)customBarViewController
{
	if(_customBarViewController != customBarViewController)
	{
		_customBarViewController.containingPopupBar = nil;
		[_customBarViewController.view removeFromSuperview];
		[_customBarViewController removeObserver:self forKeyPath:@"preferredContentSize"];
		
		_customBarViewController = customBarViewController;
		_customBarViewController.containingPopupBar = self;
		[_customBarViewController addObserver:self forKeyPath:@"preferredContentSize" options:NSKeyValueObservingOptionNew context:NULL];
		
		_customBarViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_customBarViewController.view];
		[NSLayoutConstraint activateConstraints:@[[self.topAnchor constraintEqualToAnchor:_customBarViewController.view.topAnchor],
												  [self.leftAnchor constraintEqualToAnchor:_customBarViewController.view.leftAnchor],
												  [self.rightAnchor constraintEqualToAnchor:_customBarViewController.view.rightAnchor],
												  [self.bottomAnchor constraintEqualToAnchor:_customBarViewController.view.bottomAnchor]]];
		
		[self _updateViewsAfterCustomBarViewControllerUpdate];
		
		[self setBarStyle:LNPopupBarStyleCustom];
	}
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
	_leftBarButtonItems = [leftBarButtonItems copy];
	
	if(_delaysBarButtonItemLayout == NO)
	{
		[self _layoutBarButtonItems];
	}
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
	_rightBarButtonItems = [rightBarButtonItems copy];
	
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

- (void)_removeAnimationFromBarItems
{
	[_toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
	 {
		 UIView* itemView = [barButtonItem valueForKey:@"view"];
		 [itemView.layer removeAllAnimations];
	 }];
}

- (void)dealloc
{
	[_customBarViewController removeObserver:self forKeyPath:@"preferredContentSize"];
}

@end
