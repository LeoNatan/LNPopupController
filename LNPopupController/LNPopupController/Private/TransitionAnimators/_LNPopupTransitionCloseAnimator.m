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
{
	BOOL _wasGlass;
}

- (instancetype)initWithTransitionView:(_LNPopupTransitionView *)transitionView userView:(UIView *)view popupBar:(LNPopupBar *)popupBar popupContentView:(LNPopupContentView *)popupContentView currentContentController:(UIViewController *)currentContentController containerController:(UIViewController *)containerController
{
	self = [super initWithTransitionView:transitionView userView:view popupBar:popupBar popupContentView:popupContentView effectiveInteractionStyle:containerController.effectivePopupInteractionStyle];
	
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

- (UIVisualEffect *)sourceContentTransitionEffect
{
	return self.popupContentView.effectView.effect;
}

- (UIVisualEffect *)targetContentTransitionEffect
{
	return self.popupBarEffect;
}

- (CGRect)sourceContentFrame
{
	return [self.popupContentView.superview convertRect:self.popupContentView.bounds fromView:self.popupContentView];
}

- (CGRect)targetContentFrame
{
	return [self.popupContentView.superview convertRect:self.popupBar.contentView.bounds fromView:self.popupBar.contentView];
}

- (LNPopupViewCorners)sourceContentCornerRadius
{
	return [LNPopupContentView cornersForContentView:self.popupContentView];
}

- (LNPopupViewCorners)targetContentCornerRadius
{
	return self.popupBar.contentView.effectView.corners;
}

- (CGFloat)sourceContentAlpha
{
	return 1.0;
}

- (CGFloat)targetContentAlpha
{
	return 0.0;
}

- (void)beforeAnyAnimation
{
	[super beforeAnyAnimation];
	
	self.crossfadeView.alpha = 0.0;
	self.crossfadeView.cornerRadius = self.transitionView.cornerRadius;
	
	if(@available(iOS 26.0, *))
	{
		self.popupBarTransitionView.alpha = 0.0;
	}
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
	if(@available(iOS 26.0, *))
	{
		self.contentViewTransitionView.alpha = self.targetContentAlpha;
	}
	else
	{
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
}

- (void)performAdditional075Delayed015Animations
{
	[super performAdditional075Delayed015Animations];
	
	if(@available(iOS 26.0, *))
	{
		self.popupBarTransitionView.alpha = 1.0;
	}
}

- (void)performAdditional025Delayed060Animations
{
	[super performAdditional025Delayed060Animations];
	
	if(@available(iOS 26.0, *))
	{
		self.contentTransitionEffectView.effect = nil;
	}
}

- (void)performAdditionalCompletion
{
	[super performAdditionalCompletion];
	
	if(ln_unavailable(iOS 26.0, *))
	{
		self.popupContentView.alpha = 1.0;
		self.currentContentController.view.alpha = 1.0;
		if(_wasGlass)
		{
			self.popupContentView.effectView.layer.superlayer.opacity = 1.0;
		}
	}
}

@end
