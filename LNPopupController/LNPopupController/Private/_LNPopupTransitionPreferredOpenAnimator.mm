//
//  _LNPopupTransitionPreferredOpenAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionPreferredOpenAnimator.h"

@implementation _LNPopupTransitionPreferredOpenAnimator
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
	
	self.view.cornerRadius = self.scaledBarImageViewCornerRadius;
	if(_supportsShadow)
	{
		self.view.shadow = self.scaledBarImageViewShadow;
	}
	else
	{
		self.transitionView.shadow = self.popupBar.imageView.shadow.copy;
	}
}

- (void)performAdditionalAnimations
{
	[super performAdditionalAnimations];
	
	self.view.cornerRadius = _originalCornerRadius;
	self.view.shadow = _originalShadow;
	
	if(_supportsShadow)
	{
		self.view.shadow = _originalShadow;
	}
	else
	{
		self.transitionView.shadow = _originalShadow;
	}
	
	self.crossfadeView.cornerRadius = self.view.cornerRadius;
}

@end
