//
//  _LNPopupBackgroundShadowView.m
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-25.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "_LNPopupBackgroundShadowView.h"

@implementation _LNPopupBackgroundShadowView
{
	CAShapeLayer* _maskLayer;
	UIColor* _color;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_maskLayer = [CAShapeLayer layer];
		_maskLayer.fillRule = kCAFillRuleEvenOdd;
		self.layer.mask = _maskLayer;
		self.layer.shouldRasterize = YES;
	}
	
	return self;
}

- (void)setShadow:(NSShadow *)shadow
{
	_shadow = shadow;
	
	self.layer.shadowOffset = _shadow.shadowOffset;
	self.layer.shadowRadius = _shadow.shadowBlurRadius;
	
	[self _updateShadowColor];
	[self setNeedsLayout];
}

- (void)_updateShadowColor
{
	self.layer.shadowColor = [(UIColor*)_shadow.shadowColor colorWithAlphaComponent:1.0].CGColor;
	self.layer.shadowOpacity = CGColorGetAlpha([_shadow.shadowColor CGColor]);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	self.layer.rasterizationScale = self.traitCollection.displayScale;
	[self _updateShadowColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat dx = 2 * _shadow.shadowBlurRadius + fabs(_shadow.shadowOffset.width);
	CGFloat dy = 2 * _shadow.shadowBlurRadius + fabs(_shadow.shadowOffset.height);
	
	self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath;
	_maskLayer.frame = CGRectInset(self.bounds, -dx, -dy);
	
	UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:_maskLayer.bounds];
	[maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(_maskLayer.bounds, dx, dy) cornerRadius:_cornerRadius]];
	maskPath.usesEvenOddFillRule = YES;
	
	_maskLayer.path = maskPath.CGPath;
}

@end
