//
//  _LNPopupTransitionPreferredCloseAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionPreferredCloseAnimator.h"

@implementation _LNPopupTransitionPreferredCloseAnimator
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
}

- (void)performAdditionalAnimations
{
	self.view.cornerRadius = self.scaledBarImageViewCornerRadius;
	self.view.shadow = self.scaledBarImageViewShadow;
	
	[super performAdditionalAnimations];
}

- (void)performAdditionalCompletion
{
	self.view.cornerRadius = _originalCornerRadius;
	self.view.shadow = _originalShadow;
	
	[super performAdditionalCompletion];
}

@end
