//
//  _LNPopupTransitionCloseAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionCloseAnimator.h"
#import "UIViewController+LNPopupSupportPrivate.h"

@implementation _LNPopupTransitionCloseAnimator

- (instancetype)initWithTransitionView:(_LNPopupTransitionView *)transitionView userView:(UIView *)view popupBar:(LNPopupBar *)popupBar popupContentView:(LNPopupContentView *)popupContentView currentContentController:(UIViewController *)currentContentController containerController:(UIViewController *)containerController
{
	self = [super initWithTransitionView:transitionView userView:view popupBar:popupBar popupContentView:popupContentView];
	
	if(self)
	{
		self.currentContentController = currentContentController;
		self.containerController = containerController;
	}
	
	return self;
}

- (CGRect)sourceFrame
{
	return [self.popupContentView.window convertRect:self.transitionView.sourceView.bounds fromView:self.transitionView.sourceView];
}

- (CGRect)targetFrame
{
	return [self.popupBar.imageView.window convertRect:self.popupBar.imageView.bounds fromView:self.popupBar.imageView];
}

- (CGFloat)scaledBarImageViewCornerRadius
{
	return self.popupBar.imageView.cornerRadius * self.sourceFrame.size.width / self.popupBar.imageView.bounds.size.width;
}

- (NSShadow *)scaledBarImageViewShadow
{
	NSShadow* scaled = self.popupBar.imageView.shadow.copy;
	scaled.shadowBlurRadius = scaled.shadowBlurRadius * self.sourceFrame.size.width / self.popupBar.imageView.bounds.size.width;
	return scaled;
}

- (LNPopupPresentationState)targetState
{
	return LNPopupPresentationStateBarPresented;
}

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	self.crossfadeImageView.alpha = 0.0;
	self.crossfadeImageView.layer.cornerRadius = self.transitionView.cornerRadius;
}

- (void)performAdditionalAnimations
{
	[self.transitionView setTargetFrameUpdatingTransform:self.targetFrame];
	
	self.crossfadeImageView.layer.cornerRadius = self.popupBar.imageView.cornerRadius;
	
	[super performAdditionalAnimations];
}

- (void)performAdditionalDelayed015Animations
{
	[super performAdditionalDelayed015Animations];
	
	if(self.containerController._ln_shouldPopupContentViewFadeForTransition)
	{
		self.popupContentView.alpha = 0.0;
	}
	else
	{
		self.currentContentController.view.alpha = 0.0;
	}
	
	self.crossfadeImageView.alpha = 1.0;
}

- (void)performAdditionalCompletion
{
	[super performAdditionalCompletion];
	
	self.popupContentView.alpha = 1.0;
	self.currentContentController.view.alpha = 1.0;
}

@end
