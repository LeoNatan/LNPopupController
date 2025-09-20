//
//  _LNPopupTransitionView.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionView.h"
#import "_LNPopupBase64Utils.hh"

@implementation _LNPopupTransitionView
{
	UIView* _portalView;
	UIView* _radiusContainerView;
}

+ (instancetype)transitionViewWithSourceView:(UIView*)sourceView
{
	return [[self alloc] initWithSourceView:sourceView];
}

+ (instancetype)transitionViewWithSourceLayer:(CALayer *)sourceLayer
{
	return [[self alloc] initWithSourceLayer:sourceLayer];
}

- (instancetype)initWithSourceView:(UIView*)sourceView
{
	self = [self initWithSourceLayer:sourceView.layer];
	if(self)
	{
		_sourceView = sourceView;
	}
	return self;
}

- (instancetype)initWithSourceLayer:(CALayer *)sourceLayer
{
	self = [super initWithFrame:CGRectZero];
	
	if(self)
	{
		_sourceLayer = sourceLayer;
		
		_portalView = [[NSClassFromString(LNPopupHiddenString("_UIPortalView")) alloc] initWithFrame:CGRectZero];
		_portalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_portalView.layer setValue:sourceLayer forKey:LNPopupHiddenString("sourceLayer")];
		[_portalView setValue:@YES forKey:LNPopupHiddenString("hidesSourceView")];
		[_portalView setValue:@YES forKey:LNPopupHiddenString("matchesTransform")];
		if(@available(iOS 26.0, *))
		{
			[_portalView setValue:@NO forKey:LNPopupHiddenString("hidesSourceLayerInOtherPortals")];
		}
		_portalView.layer.contentsGravity = kCAGravityResize;
		
		_radiusContainerView = [[UIView alloc] initWithFrame:CGRectZero];
		_radiusContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_radiusContainerView.layer.cornerCurve = kCACornerCurveContinuous;
		self.cornerRadius = 0.0;
		
		[_radiusContainerView addSubview:_portalView];
		[self addSubview:_radiusContainerView];
		
		_layerAlwaysMasksToBounds = NO;
		
		self.layer.masksToBounds = NO;
	}
	
	return self;
}

- (BOOL)matchesAlpha
{
	return [[_portalView valueForKey:LNPopupHiddenString("matchesAlpha")] boolValue];
}

- (void)setMatchesAlpha:(BOOL)matchesAlpha
{
	[_portalView setValue:@(matchesAlpha) forKey:LNPopupHiddenString("matchesAlpha")];
}

- (BOOL)matchesTransform
{
	return [[_portalView valueForKey:LNPopupHiddenString("matchesTransform")] boolValue];
}

- (void)setMatchesTransform:(BOOL)matchesTransform
{
	[_portalView setValue:@(matchesTransform) forKey:LNPopupHiddenString("matchesTransform")];
}

- (BOOL)matchesPosition
{
	return [[_portalView valueForKey:LNPopupHiddenString("matchesPosition")] boolValue];
}

- (void)setMatchesPosition:(BOOL)matchesPosition
{
	[_portalView setValue:@(matchesPosition) forKey:LNPopupHiddenString("matchesPosition")];
}

- (CGFloat)cornerRadius
{
	return _radiusContainerView.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	_radiusContainerView.layer.cornerRadius = cornerRadius;
	_radiusContainerView.layer.masksToBounds = _layerAlwaysMasksToBounds || cornerRadius != 0.0;
}

- (void)setLayerAlwaysMasksToBounds:(BOOL)layerAlwaysMasksToBounds
{
	_layerAlwaysMasksToBounds = layerAlwaysMasksToBounds;
	self.cornerRadius = self.cornerRadius;
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
