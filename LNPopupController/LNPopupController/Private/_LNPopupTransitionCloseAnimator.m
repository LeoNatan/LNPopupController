//
//  _LNPopupTransitionCloseAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionCloseAnimator.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupBar+Private.h"
#import "LNPopupContentView+Private.h"

@implementation _LNPopupTransitionCloseAnimator
{
	BOOL _wasGlass;
}

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
	return [self.popupContentView.window.layer convertRect:self.transitionView.sourceLayer.bounds fromLayer:self.transitionView.sourceLayer];
}

- (CGRect)targetFrame
{
	return [self.popupBar.imageView.window convertRect:self.popupBar.imageView.bounds fromView:self.popupBar.imageView];
}

- (CGFloat)scaledBarImageViewCornerRadius
{
	return MAX(self.popupBar.imageView.cornerRadius * self.sourceFrame.size.width / self.popupBar.imageView.bounds.size.width, self.popupBar.imageView.cornerRadius * self.sourceFrame.size.height / self.popupBar.imageView.bounds.size.height);
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
	
	self.crossfadeView.alpha = 0.0;
	self.crossfadeView.cornerRadius = self.transitionView.cornerRadius;
}

- (void)performAdditionalAnimations
{
	[super performAdditionalAnimations];
	
	[self.transitionView setTargetFrameUpdatingTransform:self.targetFrame];
	self.crossfadeView.cornerRadius = self.popupBar.imageView.cornerRadius;
	
	if(self.popupContentView.effectView.effect.ln_isGlass)
	{
		_wasGlass = YES;
	}
}

- (void)performAdditionalDelayed015Animations
{
	[super performAdditionalDelayed015Animations];
}

- (void)performAdditional04Delayed015Animations
{
	[super performAdditional04Delayed015Animations];
	
	self.crossfadeView.alpha = 1.0;
	
	if(self.containerController._ln_shouldPopupContentAnyFadeForTransition)
	{
		if(self.containerController._ln_shouldPopupContentViewFadeForTransition)
		{
			if(_wasGlass)
			{
				self.currentContentController.view.alpha = 0.0;
				//An effect view with glass effect has its layer contained in a _UIMultiLayer
				self.popupContentView.effectView.layer.superlayer.opacity = 0.0;
			}
			else
			{
				self.popupContentView.alpha = 0.0;
			}
		}
		else
		{
			self.currentContentController.view.alpha = 0.0;
		}
	}
}

- (void)performAdditionalCompletion
{
	[super performAdditionalCompletion];
	
	self.popupContentView.alpha = 1.0;
	self.currentContentController.view.alpha = 1.0;
	if(_wasGlass)
	{
		self.popupContentView.effectView.layer.superlayer.opacity = 1.0;
	}
}

@end
