//
//  _LNPopupTransitionView.mm
//  LNPopupController
//
//  Created by Léo Natan on 22/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionView.h"
#import "_LNPopupBase64Utils.hh"

@implementation _LNPopupTransitionView
{
	UIView* _portalView;
	UIView* _radiusContainerView;
}

- (instancetype)initWithFrame:(CGRect)frame sourceView:(UIView*)sourceView
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_portalView = [[NSClassFromString(LNPopupHiddenString("_UIPortalView")) alloc] initWithFrame:(CGRect){0, 0, frame.size}];
		_portalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_portalView setValue:sourceView forKey:LNPopupHiddenString("sourceView")];
		[_portalView setValue:@YES forKey:LNPopupHiddenString("hidesSourceView")];
		[_portalView setValue:@YES forKey:LNPopupHiddenString("matchesTransform")];
		_portalView.layer.contentsGravity = kCAGravityCenter;
		
		_radiusContainerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, frame.size}];
		_radiusContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_radiusContainerView.layer.cornerCurve = kCACornerCurveContinuous;
		self.cornerRadius = 0.0;
		
		[_radiusContainerView addSubview:_portalView];
		[self addSubview:_radiusContainerView];
		
		self.layer.masksToBounds = NO;
	}
	
	return self;
}

- (CGFloat)cornerRadius
{
	return _radiusContainerView.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	_radiusContainerView.layer.cornerRadius = cornerRadius;
	_radiusContainerView.layer.masksToBounds = cornerRadius != 0.0;
}

- (void)setTargetFrameUpdatingTransform:(CGRect)targetFrame
{
	CGRect sourceFrame = self.frame;
	
	[super setFrame:targetFrame];
	
	CGFloat ratioX = targetFrame.size.width / sourceFrame.size.width;
	CGFloat ratioY = targetFrame.size.height / sourceFrame.size.height;
	[self setSourceViewTransform: CGAffineTransformMakeScale(ratioX, ratioY)];
}

- (void)setShadow:(NSShadow *)shadow
{
	_shadow = shadow;
	
	self.layer.shadowOffset = _shadow.shadowOffset;
	self.layer.shadowRadius = _shadow.shadowBlurRadius;
	
	[self _updateShadowColor];
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

- (CGAffineTransform)sourceViewTransform
{
	return _portalView.transform;
}

- (void)setSourceViewTransform:(CGAffineTransform)sourceViewTransform
{
	_portalView.transform = sourceViewTransform;
}

@end
