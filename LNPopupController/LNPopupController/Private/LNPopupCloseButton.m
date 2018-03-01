//
//  LNPopupCloseButton.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupCloseButton.h"
@import ObjectiveC;
#import "LNChevronView.h"

@implementation LNPopupCloseButton
{
	UIVisualEffectView* _effectView;
	UIView* _highlightView;
	LNPopupCloseButtonStyle _style;
	
	LNChevronView* _chevronView;
}

- (instancetype)initWithStyle:(LNPopupCloseButtonStyle)style
{
	self = [self init];
	
	if(self)
	{
		_style = style;
		
		if(_style == LNPopupCloseButtonStyleRound)
		{
			[self _setupForCircularButton];
		}
		else
		{
			[self _setupForChevronButton];
		}
		
		self.accessibilityLabel = NSLocalizedString(@"Close", @"");
		
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		return self;
	}
	
	return self;
}

- (UIVisualEffectView*)backgroundView
{
	return _effectView;
}

- (void)_setupForChevronButton
{
	_chevronView = [[LNChevronView alloc] initWithFrame:CGRectMake(0, 0, 42, 15)];
	_chevronView.width = 5.5;
	[_chevronView setState:LNChevronViewStateUp animated:NO];
	[self addSubview:_chevronView];
}

- (void)_setupForCircularButton
{
	_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
	_effectView.userInteractionEnabled = NO;
	[self addSubview:_effectView];
	
	UIVisualEffectView* highlightEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect*)_effectView.effect]];
	highlightEffectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	highlightEffectView.frame = _effectView.contentView.bounds;
	_highlightView = [[UIView alloc] initWithFrame:highlightEffectView.contentView.bounds];
	_highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
	_highlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_highlightView.alpha = 0.0;
	[highlightEffectView.contentView addSubview:_highlightView];
	[_effectView.contentView addSubview:highlightEffectView];
	
	[self addTarget:self action:@selector(_didTouchDown) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(_didTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
	[self addTarget:self action:@selector(_didTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
	[self addTarget:self action:@selector(_didTouchUp) forControlEvents:UIControlEventTouchUpInside];
	[self addTarget:self action:@selector(_didTouchUp) forControlEvents:UIControlEventTouchUpOutside];
	[self addTarget:self action:@selector(_didTouchCancel) forControlEvents:UIControlEventTouchCancel];
	
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.1;
	self.layer.shadowRadius = 3.0;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.masksToBounds = NO;
	
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[self setImage:[UIImage imageNamed:@"DismissChevron" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

- (void)_didTouchDown
{
	[self _setHighlighted:YES animated:NO];
}

- (void)_didTouchDragExit
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_didTouchDragEnter
{
	[self _setHighlighted:YES animated:YES];
}

- (void)_didTouchUp
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_didTouchCancel
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	dispatch_block_t alphaBlock = ^{
		_highlightView.alpha = highlighted ? 1.0 : 0.0;
		_highlightView.alpha = highlighted ? 1.0 : 0.0;
	};
	
	if (animated) {
		[UIView animateWithDuration:0.47 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
			alphaBlock();
		} completion:nil];
	} else {
		alphaBlock();
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self sendSubviewToBack:_effectView];
	
	CGFloat minSideSize = MIN(self.bounds.size.width, self.bounds.size.height);
	
	_effectView.frame = self.bounds;
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	maskLayer.rasterizationScale = [UIScreen mainScreen].nativeScale;
	maskLayer.shouldRasterize = YES;
	
	CGPathRef path = CGPathCreateWithRoundedRect(self.bounds, minSideSize / 2, minSideSize / 2, NULL);
	maskLayer.path = path;
	CGPathRelease(path);
	
	_effectView.layer.mask = maskLayer;
	
	CGRect imageFrame = self.imageView.frame;
	imageFrame.origin.y += 0.5;
	self.imageView.frame = imageFrame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return CGSizeMake(24, 24);
	}
	else
	{
		return CGSizeMake(42, 25);
	}
}

- (CGSize)intrinsicContentSize
{
	return [self sizeThatFits:CGSizeZero];
}

- (void)_setButtonContainerStationary
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return;
	}
	
	[_chevronView setState:LNChevronViewStateUp animated:YES];
}

- (void)_setButtonContainerTransitioning
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return;
	}
	
	[_chevronView setState:LNChevronViewStateFlat animated:YES];
}

@end
