//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "MarqueeLabel.h"

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
	
	UIImageView* _imageView;
	
	UIView* _shadowView;
}

CGFloat _LNPopupBarHeightForBarStyle(LNPopupBarStyle style)
{
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

UIBlurEffectStyle _LNBlurEffectStyleForSystemBarStyle(UIBarStyle systemBarStyle, LNPopupBarStyle barStyle)
{
	return systemBarStyle == UIBarStyleBlack ? UIBlurEffectStyleDark : barStyle == LNPopupBarStyleCompact ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleLight;
}

@synthesize backgroundStyle = _userBackgroundStyle, barTintColor = _userBarTintColor;

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
		_userBackgroundStyle = LNBackgroundStyleInherit;
		
		_backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_backgroundView];
		
		[self setBackgroundStyle:LNBackgroundStyleInherit];
		
		_toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
		[_toolbar setBackgroundImage:[UIImage alloc] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
		_toolbar.autoresizingMask = UIViewAutoresizingNone;
		_toolbar.layer.masksToBounds = YES;
		[self addSubview:_toolbar];
		
		_titlesView = [[UIView alloc] initWithFrame:self.bounds];
		_titlesView.userInteractionEnabled = NO;
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		
		_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
		_titlesView.isAccessibilityElement = YES;
		
		[self _setNeedsTitleLayout];
		[self.toolbar addSubview:_titlesView];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.translatesAutoresizingMaskIntoConstraints = NO;
		_progressView.trackImage = [UIImage alloc];
		[_toolbar addSubview:_progressView];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView(2)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		
		_needsLabelsLayout = YES;
		
		_imageView = [UIImageView new];
		_imageView.autoresizingMask = UIViewAutoresizingNone;
		_imageView.accessibilityTraits = UIAccessibilityTraitImage;
		_imageView.isAccessibilityElement = YES;
		_imageView.layer.cornerRadius = 3;
		_imageView.layer.masksToBounds = YES;
		
		[self.toolbar addSubview:_imageView];
		
		_shadowView = [UIView new];
		_shadowView.backgroundColor = [UIColor colorWithWhite:169.0 / 255.0 alpha:1.0];
		[self.toolbar addSubview:_shadowView];
		
		_highlightView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightView.userInteractionEnabled = NO;
		[_highlightView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1]];
		_highlightView.alpha = 0.0;
		[self.toolbar addSubview:_highlightView];
		
		_resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
		
		_marqueeScrollEnabled = [NSProcessInfo processInfo].operatingSystemVersion.majorVersion < 10;
		_coordinateMarqueeScroll = YES;
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[_backgroundView setFrame:self.bounds];
	
	[UIView performWithoutAnimation:^{
		_toolbar.frame = CGRectMake(0, 0, self.bounds.size.width, _LNPopupBarHeightForBarStyle(_resolvedStyle));
		[_toolbar layoutIfNeeded];
	}];
	
	[_toolbar bringSubviewToFront:_highlightView];
	[_toolbar bringSubviewToFront:_imageView];
	[_toolbar bringSubviewToFront:_titlesView];
	[_toolbar bringSubviewToFront:_shadowView];
	
	_shadowView.frame = CGRectMake(0, 0, self.toolbar.bounds.size.width, 1 / self.window.screen.scale);
	_shadowView.hidden = _resolvedStyle == LNPopupBarStyleProminent;
	
	[self _layoutImageView];
	[self _layoutTitles];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return _userBackgroundStyle;
}

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	_userBackgroundStyle = backgroundStyle;
	
	_actualBackgroundStyle = _userBackgroundStyle == LNBackgroundStyleInherit ? _LNBlurEffectStyleForSystemBarStyle(_systemBarStyle, _resolvedStyle) : _userBackgroundStyle;
	[_backgroundView setValue:[UIBlurEffect effectWithStyle:_actualBackgroundStyle] forKey:@"effect"];
	
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
	
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
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

- (void)setBarTintColor:(UIColor *)barTintColor
{
	_userBarTintColor = barTintColor;
	
	_backgroundView.tintColor = _userBarTintColor ?: _systemBarTintColor;
	
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
}

- (UIColor *)backgroundColor
{
	return _userBackgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	_userBackgroundColor = backgroundColor;
	
	[super setBackgroundColor:_userBackgroundColor ?: _systemBackgroundColor];
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
	
	[self setBackgroundColor:_userBackgroundColor];
}

- (void)setSystemBarStyle:(UIBarStyle)systemBarStyle
{
	_systemBarStyle = systemBarStyle;
	
	[self setBackgroundStyle:_userBackgroundStyle];
}

- (void)setSystemBarTintColor:(UIColor *)systemBarTintColor
{
	_systemBarTintColor = systemBarTintColor;
	
	[self setBarTintColor:_userBarTintColor];
}

- (void)setSystemTintColor:(UIColor *)systemTintColor
{
	_systemTintColor = systemTintColor;
	
	[self setTintColor:_userTintColor];
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

- (void)_layoutTitles
{
	dispatch_async(dispatch_get_main_queue(), ^{
		__block CGFloat leftMargin = 20;
		CGFloat rightMargin = self.bounds.size.width;
		
		if(_resolvedStyle == LNPopupBarStyleProminent)
		{
			leftMargin += (_imageView.hidden ? 0 : _imageView.bounds.size.width) + 17.5;
		}
		
		__block UIView* firstRightItemView = nil;
		
		[self.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
		 {
			 UIView* itemView = [barButtonItem valueForKey:@"view"];
			 
			 if(_resolvedStyle == LNPopupBarStyleCompact)
			 {
				 leftMargin = itemView.frame.origin.x + itemView.frame.size.width + 10;
			 }
			 else if(firstRightItemView == nil)
			 {
				 firstRightItemView = itemView;
			 }
		 }];
		
		[self.rightBarButtonItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
		 {
			 UIView* itemView = [barButtonItem valueForKey:@"view"];
			 
			 if(firstRightItemView == nil)
			 {
				 firstRightItemView = itemView;
			 }
		 }];
		
		rightMargin = (firstRightItemView == nil ? self.bounds.size.width - 10 : firstRightItemView.frame.origin.x) - (_resolvedStyle == LNPopupBarStyleProminent ? 5 : 10);
		
		CGRect frame = _titlesView.frame;
		frame.origin.x = leftMargin;
		frame.size.width = rightMargin - leftMargin;
		_titlesView.frame = frame;
		
		if(_needsLabelsLayout == YES)
		{
			if(_titleLabel == nil)
			{
				_titleLabel = [self _newMarqueeLabel];
				[_titlesView addSubview:_titleLabel];
			}
			
			NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
			if(_resolvedStyle == LNPopupBarHeightCompact)
			{
				paragraph.alignment = NSTextAlignmentCenter;
			}
			else
			{
				paragraph.alignment = NSTextAlignmentLeft;
				paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
			}
			
			NSMutableDictionary* defaultTitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: _resolvedStyle == LNPopupBarStyleProminent ? [UIFont systemFontOfSize:18 weight:UIFontWeightRegular] : [UIFont systemFontOfSize:12]} mutableCopy];
			[defaultTitleAttribures addEntriesFromDictionary:_titleTextAttributes];
			
			NSMutableDictionary* defaultSubtitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: [UIFont systemFontOfSize:12]} mutableCopy];
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
		
		CGFloat barHeight = _LNPopupBarHeightForBarStyle(_resolvedStyle);
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
	});
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
	
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
	
	if(resolvedStyle == LNPopupBarStyleCompact)
	{
		_imageView.hidden = YES;
		
		return;
	}
	
	_imageView.image = _image;
	_imageView.hidden = _image == nil;
	
	_imageView.center = CGPointMake(20 + LNPopupBarProminentImageWidth / 2, LNPopupBarHeightProminent / 2);
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
	NSMutableArray* items = [NSMutableArray new];
	
	UIBarButtonItem* fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	fixed.width = _resolvedStyle == LNPopupBarStyleProminent ? 2 : -2;
	[items addObject:fixed];
	
	CGFloat spacerWidth = 6;
	if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		spacerWidth = 12;
	}
	
	UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(_barStyle);
	if(resolvedStyle == LNPopupBarStyleProminent)
	{
		[items addObject:spacer];
	}
	
	[_leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
		
		if(resolvedStyle == LNPopupBarStyleProminent || idx != _leftBarButtonItems.count - 1)
		{
			UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
			spacer.width = spacerWidth;
			[items addObject:spacer];
		}
	}];
	
	if(resolvedStyle == LNPopupBarStyleCompact)
	{
		[items addObject:spacer];
	}

	[_rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
		
		if(idx != _rightBarButtonItems.count - 1)
		{
			UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
			spacer.width = spacerWidth;
			[items addObject:spacer];
		}
	}];
	
	fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	fixed.width = _resolvedStyle == LNPopupBarStyleProminent ? 2 : -2;
	[items addObject:fixed];
	
	[_toolbar setItems:items animated:YES];
	
	[self _setNeedsTitleLayout];
	
	_delaysBarButtonItemLayout = NO;
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

@end
