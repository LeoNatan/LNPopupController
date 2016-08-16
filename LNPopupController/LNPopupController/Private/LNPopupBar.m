//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "__MarqueeLabel.h"

const CGFloat LNPopupBarHeightCompact = 40.0;
const CGFloat LNPopupBarHeightProminent = 60.0;

const NSInteger LNBackgroundStyleInherit = -1;

@implementation LNPopupBar
{
	UIVisualEffectView* _backgroundView;
	BOOL _delaysBarButtonItemLayout;
	UIView* _titlesView;
	__MarqueeLabel* _titleLabel;
	__MarqueeLabel* _subtitleLabel;
	BOOL _needsLabelsLayout;
	
	UIColor* _userTintColor;
	UIColor* _userBackgroundColor;
	
	UIBlurEffectStyle _actualBackgroundStyle;
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

- (void)setHighlighted:(BOOL)highlighted
{
	self.highlightView.hidden = !highlighted;
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
		_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_toolbar.layer.masksToBounds = YES;
		[self addSubview:_toolbar];
		
		_highlightView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightView.userInteractionEnabled = NO;
		[_highlightView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
		_highlightView.hidden = YES;
		[self addSubview:_highlightView];
		
		_titlesView = [[UIView alloc] initWithFrame:self.bounds];
		_titlesView.userInteractionEnabled = NO;
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		
		_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
		_titlesView.isAccessibilityElement = YES;
		
		[self _layoutTitles];
		[self.toolbar addSubview:_titlesView];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.translatesAutoresizingMaskIntoConstraints = NO;
		_progressView.trackImage = [UIImage alloc];
		[_toolbar addSubview:_progressView];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView(1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		
		_needsLabelsLayout = YES;
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[_backgroundView setFrame:self.bounds];
	
	[self.toolbar bringSubviewToFront:_titlesView];
	
	[self _layoutTitles];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return _userBackgroundStyle;
}

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	_userBackgroundStyle = backgroundStyle;
	
	LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(self.barStyle);
	
	_actualBackgroundStyle = _userBackgroundStyle == LNBackgroundStyleInherit ? _LNBlurEffectStyleForSystemBarStyle(_systemBarStyle, resolvedStyle) : _userBackgroundStyle;
	_backgroundView.effect = [UIBlurEffect effectWithStyle:_actualBackgroundStyle];
	
	if(_userBackgroundStyle == LNBackgroundStyleInherit)
	{
		if(_actualBackgroundStyle == UIBlurEffectStyleDark)
		{
			_backgroundView.backgroundColor = [UIColor clearColor];
		}
		else if(_actualBackgroundStyle == UIBlurEffectStyleLight)
		{
			_backgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
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
	
	[self _setNeedsTitleLayout];
}

- (void)setSubtitle:(NSString *)subtitle
{
	_subtitle = [subtitle copy];
	
	[self _setNeedsTitleLayout];
}

- (void)setAccessibilityCenterHint:(NSString *)accessibilityCenterHint
{
	_accessibilityCenterHint = accessibilityCenterHint;
	
	[self _setNeedsAccessibilityUpdate];
}

- (void)setAccessibilityCenterLabel:(NSString *)accessibilityCenterLabel
{
	_accessibilityCenterLabel = accessibilityCenterLabel;
	
	[self _setNeedsAccessibilityUpdate];
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

- (__MarqueeLabel*)_newMarqueeLabel
{
	__MarqueeLabel* rv = [[__MarqueeLabel alloc] initWithFrame:_titlesView.bounds rate:20 andFadeLength:10];
	rv.leadingBuffer = 5.0;
	rv.trailingBuffer = 15.0;
	rv.animationDelay = 2.0;
	rv.marqueeType = MLContinuous;
	return rv;
}

- (void)_layoutTitles
{
	dispatch_async(dispatch_get_main_queue(), ^{
		__block CGFloat leftMargin = 0;
		__block CGFloat rightMargin = self.bounds.size.width;
		
		[self.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
		 {
			 UIView* itemView = [barButtonItem valueForKey:@"view"];
			 leftMargin = itemView.frame.origin.x + itemView.frame.size.width + 10;
		 }];
		
		[self.rightBarButtonItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
		 {
			 UIView* itemView = [barButtonItem valueForKey:@"view"];
			 rightMargin = itemView.frame.origin.x - 10;
		 }];
		
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
			paragraph.alignment = NSTextAlignmentCenter;
			
			LNPopupBarStyle resolvedStyle = _LNPopupResolveBarStyleFromBarStyle(self.barStyle);
			
			NSMutableDictionary* defaultTitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: [UIFont systemFontOfSize:resolvedStyle == LNPopupBarStyleProminent ? 16 : 12], NSForegroundColorAttributeName: _actualBackgroundStyle != UIBlurEffectStyleDark ? [UIColor blackColor] : [UIColor whiteColor]} mutableCopy];
			[defaultTitleAttribures addEntriesFromDictionary:_titleTextAttributes];
			
			NSMutableDictionary* defaultSubtitleAttribures = [@{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: _actualBackgroundStyle != UIBlurEffectStyleDark ? [UIColor greenColor] : [UIColor whiteColor]} mutableCopy];
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
		
		CGFloat barHeight = _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.barStyle));
		titleLabelFrame.size.height = barHeight;
		if(_subtitle.length > 0)
		{
			CGRect subtitleLabelFrame = _titlesView.bounds;
			subtitleLabelFrame.size.height = barHeight;
			
			titleLabelFrame.origin.y -= _titleLabel.font.lineHeight / 2;
			subtitleLabelFrame.origin.y += _subtitleLabel.font.lineHeight / 2;
			
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
		
		[self _setNeedsAccessibilityUpdate];
		
		_titleLabel.frame = titleLabelFrame;
		
		_needsLabelsLayout = NO;
	});
}

- (void)_setNeedsAccessibilityUpdate
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
	
	[self _layoutTitles];
	
	[l1 removeFromSuperview];
	[l2 removeFromSuperview];
}

- (void)_setTitleLableFontsAccordingToBarStyleAndTint
{
	if(_actualBackgroundStyle != UIBlurEffectStyleDark)
	{
		_titleLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor blackColor];
		_subtitleLabel.textColor = _subtitleTextAttributes[NSForegroundColorAttributeName] ?: [UIColor blackColor];
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
	fixed.width = -2;
	[items addObject:fixed];
	
	CGFloat spacerWidth = 10;
	if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
	{
		spacerWidth = 20;
	}
	
	[_leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx, BOOL * _Nonnull stop) {
		[items addObject:barButtonItem];
		
		if(idx != _leftBarButtonItems.count - 1)
		{
			UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
			spacer.width = spacerWidth;
			[items addObject:spacer];
		}
	}];
	
	[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]];

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
	fixed.width = -2;
	[items addObject:fixed];
	
	[_toolbar setItems:items animated:YES];
	
	[self _layoutTitles];
	
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

- (void)_removeAnimationFromBarItems
{
	[_toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem* barButtonItem, NSUInteger idx, BOOL* stop)
	 {
		 UIView* itemView = [barButtonItem valueForKey:@"view"];
		 [itemView.layer removeAllAnimations];
	 }];
}

@end
