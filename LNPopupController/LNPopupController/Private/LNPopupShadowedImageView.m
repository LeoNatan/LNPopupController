//
//  LNPopupShadowedImageView.m
//  LNPopupController
//
//  Created by Léo Natan on 2023-10-16.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "LNPopupShadowedImageView+Private.h"

@interface _LNPopupBarImageContentLayer: CALayer @end
@implementation _LNPopupBarImageContentLayer

- (id<CAAction>)actionForKey:(NSString *)event
{
	id rv = [self.superlayer.delegate actionForLayer:self forKey:event];
	
	return rv;
}

@end

@interface _LNPopupBarShadowedImageViewLayer : CALayer @end
@implementation _LNPopupBarShadowedImageViewLayer
{
	@public
	CALayer* _imageContentsLayer;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_imageContentsLayer = [_LNPopupBarImageContentLayer layer];
		_imageContentsLayer.masksToBounds = YES;
		_imageContentsLayer.cornerCurve = kCACornerCurveContinuous;
		[self addSublayer:_imageContentsLayer];
	}
	
	return self;
}

- (void)layoutSublayers
{
	[super layoutSublayers];
	_imageContentsLayer.frame = self.bounds;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	[(LNPopupShadowedImageView*)self.delegate setCornerRadius:cornerRadius];
}

- (void)setSuperCornerRadius:(CGFloat)cornerRadius
{
//	super.cornerRadius = cornerRadius;
	_imageContentsLayer.cornerRadius = cornerRadius;
}

- (void)setContents:(id)contents
{
	[_imageContentsLayer setContents:contents];
}

//- (void)setMasksToBounds:(BOOL)masksToBounds
//{
//	NSLog(@"Fuck off!");
//}

@end

@implementation LNPopupShadowedImageView
{
	__weak LNPopupBar* _containingBar;
}

+ (Class)layerClass
{
	return [_LNPopupBarShadowedImageViewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		[self _commonInit];
	}
	
	return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
	return [self initWithImage:image highlightedImage:nil];
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
	self = [super initWithImage:image highlightedImage:highlightedImage];
	
	if(self)
	{
		[self _commonInit];
	}
	
	return self;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	id<CAAction> rv = [super actionForLayer:layer forKey:event];
	
	return rv;
}

- (instancetype)initWithContainingPopupBar:(LNPopupBar *)popupBar
{
	self = [self initWithFrame:CGRectZero];
	
	if(self)
	{
		_containingBar = popupBar;
	}
	
	return self;
}

- (void)_commonInit
{
	super.contentMode = UIViewContentModeScaleAspectFit;
	self.clipsToBounds = NO;
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
	
//	CGFloat dx = _shadow.shadowOffset.width;
//	CGFloat dy = _shadow.shadowOffset.height;
//	
//	UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
//	[maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, dx, dy) cornerRadius:_cornerRadius]];
//	maskPath.usesEvenOddFillRule = YES;
//	
//	self.layer.shadowPath = maskPath.CGPath;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	_cornerRadius = cornerRadius;
	[(_LNPopupBarShadowedImageViewLayer*)self.layer setSuperCornerRadius:cornerRadius];
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
