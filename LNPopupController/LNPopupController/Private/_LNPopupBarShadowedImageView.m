//
//  _LNPopupBarShadowedImageView.m
//  LNPopupController
//
//  Created by Leo Natan on 15/10/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

#import "_LNPopupBarShadowedImageView.h"
#import "_LNPopupBackgroundShadowView.h"

@implementation _LNPopupBarShadowedImageView
{
	_LNPopupBackgroundShadowView* _shadowView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_shadowView = [_LNPopupBackgroundShadowView new];
	}
	
	return self;
}

- (void)setShadow:(NSShadow *)shadow
{
	_shadow = [shadow copy];
	
	_shadowView.shadow = shadow;
}

- (void)didMoveToSuperview
{
	if(self.superview)
	{
		[self _updateShadowViewFrame];
	}
	else
	{
		[_shadowView removeFromSuperview];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self _updateShadowViewFrame];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	[self _updateShadowViewFrame];
}

- (void)setCenter:(CGPoint)center
{
	[super setCenter:center];
	[self _updateShadowViewFrame];
}

- (void)_updateShadowViewFrame
{
	[self.superview insertSubview:_shadowView aboveSubview:self];
	_shadowView.frame = self.frame;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	_cornerRadius = cornerRadius;
	self.layer.cornerRadius = cornerRadius;
	_shadowView.cornerRadius = cornerRadius;
}

@end
