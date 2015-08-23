//
//  LNPopupCloseButton.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupCloseButton.h"
@import ObjectiveC;

@implementation LNPopupCloseButton
{
	UIVisualEffectView* _effectView;
	UIView* _highlightView;
	UIImageView* _chevronImageView;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
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
		
		_chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DismissChevron" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
		_chevronImageView.contentMode = UIViewContentModeCenter;
		CGRect frame = self.bounds;
		frame.origin.y += 1;
		_chevronImageView.frame = frame;
		_chevronImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:_chevronImageView];
	}
	
	return self;
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

- (void)_setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
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
	_effectView.frame = self.bounds;
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	maskLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].nativeScale;
	maskLayer.shouldRasterize = YES;
	
	CGPathRef path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
	maskLayer.path = path;
	CGPathRelease(path);
	
	_effectView.layer.mask = maskLayer;
}

@end
