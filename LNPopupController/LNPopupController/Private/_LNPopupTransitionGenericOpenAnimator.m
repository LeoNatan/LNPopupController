//
//  _LNPopupTransitionGenericOpenAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionGenericOpenAnimator.h"

@implementation _LNPopupTransitionGenericOpenAnimator
{
	NSShadow* _targetShadow;
}

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	self.transitionView.shadow = self.popupBar.imageView.shadow.copy;
	self.transitionView.cornerRadius = self.scaledBarImageViewCornerRadius;
	
	_targetShadow = [self.transitionView.shadow copy];
	_targetShadow.shadowColor = [_targetShadow.shadowColor colorWithAlphaComponent:0.0];
}

- (void)performAdditionalAnimations
{
	[super performAdditionalAnimations];
	
	self.transitionView.shadow = _targetShadow;
	self.transitionView.cornerRadius = 0.000001;
}

@end
