//
//  _LNPopupBackgroundShadowView.mm
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupBackgroundShadowView.h"
#import "_LNPopupGlassUtils.h"
#import "_LNPopupBase64Utils.hh"
#import <objc/message.h>
#import "UIView+LNPopupSupportPrivate.h"
#import "_LNPopupSwizzlingUtils.h"

typedef struct {
	CGSize x1;
	CGSize x2;
	CGSize x3;
	CGSize x4;
} LNPopupCorners;

@interface _LNPopupBackgroundShadowLayer: CALayer @end
@implementation _LNPopupBackgroundShadowLayer

+ (void)load
{
	@autoreleasepool
	{
		Class cls = self;
		SEL sel = NSSelectorFromString(LNPopupHiddenString("setCornerRadii:"));
		Method from = LNSwizzleClassGetInstanceMethod(cls, @selector(_ln_setCorners:));
		class_addMethod(cls, sel, method_getImplementation(from), method_getTypeEncoding(from));
	}
}

- (void)_ln_setCorners:(LNPopupCorners)corners
{
	struct objc_super super = {
		.receiver = self,
		.super_class = self.class.superclass
	};
	static void (*superFunc)(struct objc_super*, SEL, LNPopupCorners) = reinterpret_cast<decltype(superFunc)>(objc_msgSendSuper);
	
	superFunc(&super, _cmd, corners);
	
	UIView* view = (id)self.delegate;
	if(view.isHidden == NO)
	{
		[view setNeedsLayout];
	}
}

@end

@implementation _LNPopupBackgroundShadowView
{
	CAShapeLayer* _maskLayer;
	CALayer* _maskLayer2;
}

+ (Class)layerClass
{
	return _LNPopupBackgroundShadowLayer.class;
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
		
		if(LNPopupEnvironmentHasGlass())
		{
			_maskLayer.backgroundColor = UIColor.blackColor.CGColor;
			
			_maskLayer2 = [CALayer layer];
			_maskLayer2.backgroundColor = UIColor.whiteColor.CGColor;
			_maskLayer2.compositingFilter = @"xor";
			_maskLayer2.masksToBounds = true;
			[_maskLayer addSublayer:_maskLayer2];
		}
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
	
	if(self.isHidden)
	{
		return;
	}
	
	CGFloat dx = 3 * _shadow.shadowBlurRadius + fabs(_shadow.shadowOffset.width);
	CGFloat dy = 3 * _shadow.shadowBlurRadius + fabs(_shadow.shadowOffset.height);
	
	_maskLayer.frame = CGRectInset(self.bounds, -dx, -dy);
	
	if(LNPopupEnvironmentHasGlass())
	{
		static NSString* cornersName = LNPopupHiddenString("cornerRadii");
		CGFloat radius = self._ln_simulatedCornerRadiusFromCorners;
		
		self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius].CGPath;
		
		_maskLayer2.frame = CGRectOffset(self.bounds, dx, dy);
		[_maskLayer2 setValue:[self.layer valueForKey:cornersName] forKey:cornersName];
	}
	else
	{
		self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath;
		
		UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:_maskLayer.bounds];
		[maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(_maskLayer.bounds, dx, dy) cornerRadius:_cornerRadius]];
		maskPath.usesEvenOddFillRule = YES;
		
		_maskLayer.path = maskPath.CGPath;
	}
}

@end
