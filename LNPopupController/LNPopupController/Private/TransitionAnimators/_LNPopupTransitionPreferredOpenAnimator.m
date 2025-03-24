//
//  _LNPopupTransitionPreferredOpenAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionPreferredOpenAnimator.h"

@implementation _LNPopupTransitionPreferredOpenAnimator
{
	CGFloat _originalCornerRadius;
	NSShadow* _originalShadow;
}

@dynamic view;

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	_originalCornerRadius = self.view.cornerRadius;
	_originalShadow = self.view.shadow.copy;
	
	self.view.cornerRadius = self.scaledBarImageViewCornerRadius;
	self.view.shadow = self.scaledBarImageViewShadow;
}

- (void)performAdditionalAnimations
{
	self.view.cornerRadius = _originalCornerRadius;
	self.view.shadow = _originalShadow;
	
	[super performAdditionalAnimations];
}

@end
