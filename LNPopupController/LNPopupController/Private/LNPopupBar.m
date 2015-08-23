//
//  LNPopupBar.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "__MarqueeLabel.h"

const CGFloat LNPopupBarHeight = 40.0;

@implementation LNPopupBar
{
	UIToolbar* _backgroundView;
	BOOL _delaysBarButtonItemLayout;
	UIView* _titlesView;
	__MarqueeLabel* _titleLabel;
	__MarqueeLabel* _subtitleLabel;
	BOOL _needsLabelsLayout;
}

- (void)setHighlighted:(BOOL)highlighted
{
	self.highlightView.hidden = !highlighted;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	CGRect fullFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, LNPopupBarHeight);
	
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_backgroundView = [[UIToolbar alloc] initWithFrame:frame];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_backgroundView];
		
		_toolbar = [[UIToolbar alloc] initWithFrame:fullFrame];
		[_toolbar setBackgroundImage:[UIImage alloc] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
		_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_toolbar.layer.masksToBounds = YES;
		[self addSubview:_toolbar];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.translatesAutoresizingMaskIntoConstraints = NO;
		_progressView.trackImage = [UIImage alloc];
		[_toolbar addSubview:_progressView];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView(1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
		
		_highlightView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightView.userInteractionEnabled = NO;
		[_highlightView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
		_highlightView.hidden = YES;
		[self addSubview:_highlightView];
		
		_titlesView = [[UIView alloc] initWithFrame:fullFrame];
		_titlesView.userInteractionEnabled = NO;
		_titlesView.autoresizingMask = UIViewAutoresizingNone;
		[self _layoutTitles];
		[self.toolbar addSubview:_titlesView];
		
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

- (UIBarStyle)barStyle
{
	return _backgroundView.barStyle;
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
	_backgroundView.barStyle = barStyle;
	
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
}

- (UIColor*)barTintColor
{
	return _backgroundView.barTintColor;
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
	_backgroundView.barTintColor = barTintColor;
	
	[self _setTitleLableFontsAccordingToBarStyleAndTint];
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

- (__MarqueeLabel*)_newMarqueeLabel
{
	__MarqueeLabel* rv = [[__MarqueeLabel alloc] initWithFrame:_titlesView.bounds rate:20 andFadeLength:10];
	rv.font = [UIFont systemFontOfSize:12];
	rv.leadingBuffer = 5.0;
	rv.trailingBuffer = 15.0;
	rv.animationDelayBefore = 2.0;
	rv.animationDelayAfter = 0.0;
	rv.marqueeType = MLContinuous;
	rv.textAlignment = NSTextAlignmentCenter;
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
			
			BOOL reset = NO;
			
			if([_titleLabel.text isEqualToString:_title] == NO)
			{
				_titleLabel.text = _title;
				reset = YES;
			}
			
			if(_subtitleLabel == nil)
			{
				_subtitleLabel = [self _newMarqueeLabel];
				[_titlesView addSubview:_subtitleLabel];
			}
			
			if([_subtitleLabel.text isEqualToString:_subtitle] == NO)
			{
				_subtitleLabel.text = _subtitle;
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
		titleLabelFrame.size.height = 40;
		if(_subtitle.length > 0)
		{
			CGRect subtitleLabelFrame = _titlesView.bounds;
			subtitleLabelFrame.size.height = 40;
			
			titleLabelFrame.origin.y -= _titleLabel.font.lineHeight / 2;
			subtitleLabelFrame.origin.y += _subtitleLabel.font.lineHeight / 2;
			
			if(_needsLabelsLayout == YES)
			{
//				NSTimeInterval titleDuration = [_titleLabel animationDuration];
//				NSTimeInterval subtitleDuration = [_subtitleLabel animationDuration];
//				
//				if(_titleLabel.animationDuration < _subtitleLabel.animationDuration)
//				{
//					_titleLabel.animationDelayAfter = -20; //(subtitleDuration - titleDuration);
//				}
//				else
//				{
//					_subtitleLabel.animationDelayAfter = - 20;//(subtitleDuration - titleDuration);
//				}
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
		
		_titleLabel.frame = titleLabelFrame;
		
		_needsLabelsLayout = NO;
	});
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
	if(self.barStyle == UIBarStyleDefault)
	{
		_titleLabel.textColor = [UIColor blackColor];
		_subtitleLabel.textColor = [UIColor grayColor];
	}
	else
	{
		_titleLabel.textColor = [UIColor whiteColor];
		_subtitleLabel.textColor = [UIColor whiteColor];
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
