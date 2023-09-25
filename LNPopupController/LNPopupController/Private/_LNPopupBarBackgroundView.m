//
//  _LNPopupBarBackgroundView.m
//  LNPopupController
//
//  Created by Leo Natan on 6/26/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "_LNPopupBarBackgroundView.h"

@interface _LNPopupBarBackgroundColorView : UIView @end
@implementation _LNPopupBarBackgroundColorView @end

@interface _LNPopupBarBackgroundImageView : UIImageView @end
@implementation _LNPopupBarBackgroundImageView @end

@interface _LNPopupBarBackgroundEffectView : UIVisualEffectView @end
@implementation _LNPopupBarBackgroundEffectView @end

@implementation _LNPopupBarBackgroundView
{
	UIView* _colorView;
	UIImageView* _imageView;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect
{
	self = [super init];
	
	if(self)
	{
		_effectView = [[_LNPopupBarBackgroundEffectView alloc] initWithEffect:effect];
		_effectView.clipsToBounds = YES;
		
		_colorView = [_LNPopupBarBackgroundColorView new];
		_imageView = [_LNPopupBarBackgroundImageView new];
		
		self.cornerRadius = 0;
		self.layer.masksToBounds = NO;
		
		[self addSubview:_colorView];
		[self addSubview:_imageView];
		
		[self addSubview:_effectView];
	}
	
	return self;
}

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

- (UIVisualEffect *)effect
{
	return _effectView.effect;
}

- (void)setEffect:(UIVisualEffect *)effect
{
	_effectView.effect = effect;
}

- (UIView *)contentView
{
	return _effectView.contentView;
}

- (UIView *)colorView
{
	return _colorView;
}

- (UIImageView *)imageView
{
	return _imageView;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self sendSubviewToBack:_colorView];
	[self insertSubview:_imageView aboveSubview:_colorView];
	[self insertSubview:_effectView aboveSubview:_imageView];
	
	_effectView.frame = self.bounds;
	_imageView.frame = self.bounds;
	_colorView.frame = self.bounds;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	_cornerRadius = cornerRadius;
	
	self.layer.cornerRadius = cornerRadius;
	self.layer.cornerCurve = kCACornerCurveContinuous;
	
	_effectView.layer.cornerRadius = cornerRadius;
	_effectView.layer.cornerCurve = kCACornerCurveContinuous;
}

@end
