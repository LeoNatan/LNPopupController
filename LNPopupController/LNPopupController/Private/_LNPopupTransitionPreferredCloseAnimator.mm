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
	BOOL _supportsShadow;
}

@dynamic view;

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	if([self.view respondsToSelector:@selector(supportsShadow)])
	{
		_supportsShadow = self.view.supportsShadow;
	}
	else
	{
		_supportsShadow = YES;
	}
	
	_originalCornerRadius = self.view.cornerRadius;
	if(_supportsShadow)
	{
		_originalShadow = self.view.shadow.copy;
	}
	else
	{
		_originalShadow = nil;
	}
}

- (void)performAdditionalAnimations
{
	self.view.cornerRadius = self.scaledBarImageViewCornerRadius;
	if(_supportsShadow)
	{
		self.view.shadow = self.scaledBarImageViewShadow;
	}
	else
	{
		self.transitionView.shadow = self.popupBar.imageView.shadow.copy;
	}
	
	[super performAdditionalAnimations];
}

- (void)performAdditionalCompletion
{
	self.view.cornerRadius = _originalCornerRadius;
	if(_supportsShadow)
	{
		self.view.shadow = _originalShadow;
	}
	else
	{
		self.transitionView.shadow = _originalShadow;
	}
	
	[super performAdditionalCompletion];
}

@end
