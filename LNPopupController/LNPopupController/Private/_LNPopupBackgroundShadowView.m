//
//  _LNPopupBackgroundShadowView.m
//  LNPopupController
//
//  Created by Leo Natan on 24/09/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

#import "_LNPopupBackgroundShadowView.h"

@implementation _LNPopupBackgroundShadowView
{
	CAShapeLayer* _maskLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		self.layer.shadowColor = UIColor.blackColor.CGColor;
		self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
		self.layer.shadowOpacity = 0.15;
		self.layer.shadowRadius = 8.0;
		
		_maskLayer = [CAShapeLayer layer];
		_maskLayer.fillRule = kCAFillRuleEvenOdd;
		self.layer.mask = _maskLayer;
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath;
	_maskLayer.frame = CGRectInset(self.bounds, -20, -20);
	
	UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:_maskLayer.bounds];
	[maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(_maskLayer.bounds, 20, 20) cornerRadius:_cornerRadius]];
	maskPath.usesEvenOddFillRule = YES;
	
	_maskLayer.path = maskPath.CGPath;
}

@end
