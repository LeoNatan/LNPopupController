//
//  _LNPopupTransitionAnimatorOpen.m
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionAnimator.h"
#import <objc/runtime.h>

static const void* _LNPopupOpenCloseTransitionViewKey = &_LNPopupOpenCloseTransitionViewKey;

@implementation _LNPopupTransitionAnimator

 - (instancetype)initWithUserView:(UIView *)view popupBar:(LNPopupBar*)popupBar popupContentView:(LNPopupContentView*)popupContentView
{
	self = [super init];
	
	if(self)
	{
		_view = view;
		_popupBar = popupBar;
		_popupContentView = popupContentView;
	}
	
	return self;
}

- (void)animateWithAnimator:(UIViewPropertyAnimator *)animator otherAnimations:(void (^)(void))otherAnimations
{
	[UIView performWithoutAnimation:^{
		[self.popupContentView layoutIfNeeded];
		self.popupBar.imageView.alpha = 0.0;
		
		_transitionView = [[_LNPopupTransitionView alloc] initWithFrame:self.sourceFrame sourceView:self.view];
		
		[self beforeAnyAnimation];
		
		objc_setAssociatedObject(self.view, _LNPopupOpenCloseTransitionViewKey, _transitionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}];
	
	[animator addAnimations:otherAnimations];
	
	[animator addAnimations:^{
		[UIView performWithoutAnimation:^{
			[self.popupContentView.window addSubview:_transitionView];
			[self performBeforeAdditionalAnimations];
		}];
		
		[self performAdditionalAnimations];
	}];
	
	[animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
		[self completeTransition];
	}];
}

- (CGRect)sourceFrame
{
	return CGRectZero;
}

- (CGRect)targetFrame
{
	return CGRectZero;
}

- (CGAffineTransform)transform
{
	return CGAffineTransformIdentity;
}

- (CGFloat)scaledBarImageViewCornerRadius
{
	return 0.0;
}

- (NSShadow *)scaledBarImageViewShadow
{
	return nil;
}

- (void)beforeAnyAnimation {}
- (void)performBeforeAdditionalAnimations {}
- (void)performAdditionalAnimations {}
- (void)performAdditionalCompletion {}

- (void)completeTransition
{
	[UIView performWithoutAnimation:^{
		UIView* transitionView = objc_getAssociatedObject(self.view, _LNPopupOpenCloseTransitionViewKey);
		[transitionView removeFromSuperview];
		objc_setAssociatedObject(self.view, _LNPopupOpenCloseTransitionViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		self.popupBar.imageView.alpha = 1.0;
		[self performAdditionalCompletion];
	}];
}

@end
