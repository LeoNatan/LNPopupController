//
//  _LNPopupTransitionCloseAnimator.m
//  LNPopupController
//
//  Created by Léo Natan on 24/3/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionCloseAnimator.h"
#import "UIViewController+LNPopupSupportPrivate.h"

@implementation _LNPopupTransitionCloseAnimator

- (instancetype)initWithUserView:(UIView*)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView currentContentController:(UIViewController*)currentContentController containerController:(UIViewController*)containerController
{
	self = [super initWithUserView:view popupBar:popupBar popupContentView:popupContentView];
	
	if(self)
	{
		self.currentContentController = currentContentController;
		self.containerController = containerController;
	}
	
	return self;
}

- (CGRect)sourceFrame
{
	return [self.popupContentView.window convertRect:self.view.bounds fromView:self.view];
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

- (void)performAdditionalAnimations
{
	[self.transitionView setTargetFrameUpdatingTransform:self.targetFrame];
	
	if(self.containerController._ln_shouldPopupContentViewFadeForTransition)
	{
		self.popupContentView.alpha = 0.0;
	}
	else
	{
		self.currentContentController.view.alpha = 0.0;
	}
}

- (void)performAdditionalCompletion
{
	self.popupContentView.alpha = 1.0;
	self.currentContentController.view.alpha = 1.0;
}

@end
