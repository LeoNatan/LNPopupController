//
//  _LNPopupTransitionOpenAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionOpenAnimator.h"
#import <objc/runtime.h>

@implementation _LNPopupTransitionOpenAnimator

- (CGRect)sourceFrame
{
	return [self.popupBar.imageView.window convertRect:self.popupBar.imageView.bounds fromView:self.popupBar.imageView];
}

- (CGRect)targetFrame
{
	return [self.popupContentView.window convertRect:self.transitionView.sourceView.bounds fromView:self.transitionView.sourceView];;
}

- (CGAffineTransform)transform
{
	CGFloat ratioX = self.sourceFrame.size.width / self.targetFrame.size.width;
	CGFloat ratioY = self.sourceFrame.size.height / self.targetFrame.size.height;
	return CGAffineTransformMakeScale(ratioX, ratioY);
}

- (CGFloat)scaledBarImageViewCornerRadius
{
	return self.popupBar.imageView.cornerRadius * self.targetFrame.size.width / self.popupBar.imageView.bounds.size.width;
}

- (NSShadow *)scaledBarImageViewShadow
{
	NSShadow* scaled = self.popupBar.imageView.shadow.copy;
	scaled.shadowBlurRadius = scaled.shadowBlurRadius * self.targetFrame.size.width / self.popupBar.imageView.bounds.size.width;
	return scaled;
}

- (LNPopupPresentationState)targetState
{
	return LNPopupPresentationStateOpen;
}

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	self.crossfadeView.alpha = 1.0;
	self.crossfadeView.cornerRadius = self.popupBar.imageView.cornerRadius;
}

- (void)performBeforeAdditionalAnimations
{
	[super performBeforeAdditionalAnimations];
	
	self.transitionView.sourceViewTransform = self.transform;
}

- (void)performAdditionalAnimations
{
	[super performAdditionalAnimations];
	
	self.transitionView.frame = self.targetFrame;
	self.transitionView.sourceViewTransform = CGAffineTransformIdentity;
	self.crossfadeView.cornerRadius = self.transitionView.cornerRadius;
}

- (void)performAdditional01Animations
{
	[super performAdditional01Animations];
	
	self.crossfadeView.alpha = 0.0;
}

@end
