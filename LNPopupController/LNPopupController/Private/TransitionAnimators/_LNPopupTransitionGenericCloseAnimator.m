//
//  _LNPopupTransitionGenericCloseAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionGenericCloseAnimator.h"

@implementation _LNPopupTransitionGenericCloseAnimator
{
	NSShadow* _targetShadow;
}

- (void)animateWithAnimator:(UIViewPropertyAnimator *)animator otherAnimations:(void (^)(void))otherAnimations
{
	[super animateWithAnimator:animator otherAnimations:otherAnimations];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((animator.duration * 0.38) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[animator addAnimations:^{
			self.transitionView.cornerRadius = self.popupBar.imageView.cornerRadius;
		}];
	});
}

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	_targetShadow = self.popupBar.imageView.shadow.copy;
	
	NSShadow* hiddenShadow = [_targetShadow copy];
	hiddenShadow.shadowColor = [_targetShadow.shadowColor colorWithAlphaComponent:0.0];
	self.transitionView.shadow = hiddenShadow;
}

- (void)performAdditionalAnimations
{
	[super performAdditionalAnimations];
	
	self.transitionView.shadow = _targetShadow;
}

@end
