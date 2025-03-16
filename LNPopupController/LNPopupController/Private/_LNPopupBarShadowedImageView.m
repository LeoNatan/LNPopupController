//
//  _LNPopupBarShadowedImageView.m
//  LNPopupController
//
//  Created by Léo Natan on 2023-10-16.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "_LNPopupBarShadowedImageView.h"
#import "_LNPopupBackgroundShadowView.h"

@implementation _LNPopupBarShadowedImageView
{
	_LNPopupBackgroundShadowView* _shadowView;
	__weak LNPopupBar* _containingBar;
}

- (instancetype)initWithContainingPopupBar:(LNPopupBar *)popupBar
{
	self = [super initWithFrame:CGRectZero];
	
	if(self)
	{
		super.contentMode = UIViewContentModeScaleAspectFit;
		_containingBar = popupBar;
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

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	
	_shadowView.hidden = hidden;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
	if(self.contentMode != contentMode)
	{
		[super setContentMode:contentMode];
		
		[_containingBar setNeedsLayout];
	}
}

- (void)setImage:(UIImage *)image
{
	if(self.image != image && [self.image isEqual:image] == NO)
	{
		[super setImage:image];
		
		[_containingBar setNeedsLayout];
	}
}

@end
