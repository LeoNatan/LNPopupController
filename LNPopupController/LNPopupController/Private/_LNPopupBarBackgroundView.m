//
//  _LNPopupBarBackgroundView.m
//  LNPopupController
//
//  Created by Léo Natan on 2021-06-20.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupBarBackgroundView.h"

@interface _LNPopupBarBackgroundImageView : UIImageView @end
@implementation _LNPopupBarBackgroundImageView @end

@interface _LNPopupBarBackgroundEffectView : UIVisualEffectView @end
@implementation _LNPopupBarBackgroundEffectView @end

@implementation _LNPopupBarBackgroundView
{
	UIImageView* _imageView;
	UIView* _transitionShadingView;
	
	UIViewContentMode _cachedImageMode;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect
{
	self = [super init];
	
	if(self)
	{
		_effectView = [[_LNPopupBarBackgroundEffectView alloc] initWithEffect:effect];
		_effectView.clipsToBounds = YES;
		
		self.cornerRadius = 0;
		self.layer.masksToBounds = NO;
		
		[self addSubview:_effectView];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
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

- (UIImageView *)imageView
{
	if(_imageView == nil)
	{
		_imageView = [_LNPopupBarBackgroundImageView new];
		_imageView.contentMode = _cachedImageMode;
		[_effectView.contentView addSubview:_imageView];
	}
	
	return _imageView;
}

- (UIColor *)foregroundColor
{
	return _imageView.backgroundColor;
}

- (void)setForegroundColor:(nullable UIColor*)foregroundColor
{
	if(_imageView == nil && foregroundColor == nil && foregroundColor != UIColor.clearColor)
	{
		return;
	}
	
	self.imageView.backgroundColor = foregroundColor;
}

- (UIImage *)foregroundImage
{
	return _imageView.image;
}

- (void)setForegroundImage:(nullable UIImage*)foregroundImage
{
	if(_imageView == nil && foregroundImage == nil)
	{
		return;
	}
	
	self.imageView.image = foregroundImage;
}

- (UIViewContentMode)foregroundImageContentMode
{
	return _imageView == nil ? _cachedImageMode : _imageView.contentMode;
}

- (void)setForegroundImageContentMode:(UIViewContentMode)foregroundImageContentMode
{
	if(_imageView == nil)
	{
		_cachedImageMode = foregroundImageContentMode;
		
		return;
	}
	
	_imageView.contentMode = foregroundImageContentMode;
}

- (void)hideOrShowImageViewIfNecessary
{
	if(_imageView == nil)
	{
		return;
	}
	
	_imageView.hidden = _imageView.backgroundColor == nil && _imageView.image == nil;
}

- (UIView *)transitionShadingView
{
	if(_transitionShadingView == nil)
	{
		_transitionShadingView = [UIView new];
		_transitionShadingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
		_transitionShadingView.alpha = 0.0;
		_transitionShadingView.hidden = YES;
		
		[self addSubview:_transitionShadingView];
	}
	
	return _transitionShadingView;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	if(_imageView != nil)
	{
		[_effectView.contentView sendSubviewToBack:_imageView];
	}
	
	if(_transitionShadingView)
	{
		[self bringSubviewToFront:_transitionShadingView];
	}
	
	_effectView.frame = self.bounds;
	_imageView.frame = self.bounds;
	_transitionShadingView.frame = self.bounds;
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
