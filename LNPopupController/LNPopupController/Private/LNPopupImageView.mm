//
//  LNPopupImageView.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupImageView+Private.h"
#import "_LNPopupBase64Utils.hh"
#import "UIViewController+LNPopupSupportPrivate.h"
#import <LNPopupController/UIViewController+LNPopupSupport.h>

@interface _LNPopupBarShadowedImageViewLayer : CALayer @end
@implementation _LNPopupBarShadowedImageViewLayer
{
	@public
	__weak CALayer* _imageContentsLayer;
}

- (void)setMasksToBounds:(BOOL)masksToBounds
{
	[super setMasksToBounds:NO];
}

- (void)addSublayer:(CALayer *)layer
{
	layer.masksToBounds = YES;
	if(@available(iOS 13.0, *))
	{
		layer.cornerCurve = kCACornerCurveContinuous;
	}
	layer.cornerRadius = _imageContentsLayer.cornerRadius;
	[super addSublayer:layer];
}

- (void)layoutSublayers
{
	[super layoutSublayers];
	_imageContentsLayer.frame = self.bounds;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	[(LNPopupImageView*)self.delegate setCornerRadius:cornerRadius];
}

- (void)setSuperCornerRadius:(CGFloat)cornerRadius
{
	_imageContentsLayer.cornerRadius = cornerRadius;
	for(CALayer* sublayer in self.sublayers)
	{
		if(sublayer != _imageContentsLayer)
		{
			sublayer.cornerRadius = cornerRadius;
		}
	}
}

- (void)setContents:(id)contents
{
	[_imageContentsLayer setContents:contents];
}

- (void)setContentsRect:(CGRect)contentsRect
{
	[_imageContentsLayer setContentsRect:contentsRect];
}

- (void)setContentsScale:(CGFloat)contentsScale
{
	[_imageContentsLayer setContentsScale:contentsScale];
}

- (void)setContentsCenter:(CGRect)contentsCenter
{
	[_imageContentsLayer setContentsCenter:contentsCenter];
}

- (void)setContentsFormat:(CALayerContentsFormat)contentsFormat
{
	[_imageContentsLayer setContentsFormat:contentsFormat];
}

- (void)setContentsGravity:(CALayerContentsGravity)contentsGravity
{
	[_imageContentsLayer setContentsGravity:contentsGravity];
}

- (void)setWantsExtendedDynamicRangeContent:(BOOL)wantsExtendedDynamicRangeContent
{
	[super setWantsExtendedDynamicRangeContent:wantsExtendedDynamicRangeContent];
	[_imageContentsLayer setWantsExtendedDynamicRangeContent:wantsExtendedDynamicRangeContent];
}

- (void)setImageContentsLayer:(CALayer*)layer
{
	_imageContentsLayer = layer;
}

@end

@implementation LNPopupImageView
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
	
	UIView* imageContentsLayerView = [[UIView alloc] initWithFrame:self.bounds];
	imageContentsLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:imageContentsLayerView];
	[(_LNPopupBarShadowedImageViewLayer*)self.layer setImageContentsLayer:imageContentsLayerView.layer];
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
	if([_shadow.shadowColor isKindOfClass:UIColor.class])
	{
		self.layer.shadowColor = [_shadow.shadowColor CGColor];
	}
	else
	{
		self.layer.shadowColor = (__bridge CGColorRef)_shadow.shadowColor;
	}
	self.layer.shadowOpacity = _shadow != nil ? 1.0 : 0.0;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	self.layer.rasterizationScale = self.traitCollection.displayScale;
	[self _updateShadowColor];
}

#if DEBUG

- (void)layoutSubviews
{
	[super layoutSubviews];
}

#endif

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

- (void)didMoveToWindow
{
	if(self.window == nil || _containingBar != nil)
	{
		return;
	}
	
	static NSString* vCFA = LNPopupHiddenString("_viewControllerForAncestor");
	
	UIViewController* candidate = [self valueForKey:vCFA];
	candidate.ln_discoveredTransitionView = self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ cornerRadius: %@ shadow: %@", super.description, @(self.cornerRadius), self.shadow];
}

@end

@implementation LNPopupImageView (TransitionSupport) @end
