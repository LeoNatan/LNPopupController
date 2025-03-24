//
//  _LNPopupTransitionGenericOpenAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
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
	
	_targetShadow = [self.transitionView.shadow copy];
	_targetShadow.shadowColor = [_targetShadow.shadowColor colorWithAlphaComponent:0.0];
}

- (void)performAdditionalAnimations
{
	self.transitionView.shadow = _targetShadow;
	
	[super performAdditionalAnimations];
}

@end
