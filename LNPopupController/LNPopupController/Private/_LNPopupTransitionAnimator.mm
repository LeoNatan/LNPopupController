//
//  _LNPopupTransitionAnimatorOpen.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionAnimator.h"
#import <LNPopupController/UIViewController+LNPopupSupport.h>
#import <objc/runtime.h>

static const void* _LNPopupOpenCloseTransitionViewKey = &_LNPopupOpenCloseTransitionViewKey;

@implementation _LNPopupTransitionAnimator

- (instancetype)initWithTransitionView:(_LNPopupTransitionView *)transitionView userView:(UIView *)view popupBar:(LNPopupBar *)popupBar popupContentView:(LNPopupContentView *)popupContentView
{
	self = [super init];
	
	if(self)
	{
		_transitionView = transitionView;
		_view = view;
		_popupBar = popupBar;
		_popupContentView = popupContentView;
	}
	
	return self;
}

- (void)animateWithAnimator:(UIViewPropertyAnimator *)animator otherAnimations:(void (^)(void))otherAnimations
{
	static SEL transitionWillBegin = NSSelectorFromString(@"_transitionWillBeginToState:");
	static SEL transitionDidEnd = NSSelectorFromString(@"_transitionDidEnd");
	
	[UIView performWithoutAnimation:^{
		[self.popupContentView layoutIfNeeded];
		self.popupBar.imageView.alpha = 0.0;
		
		if(self.transitionView == nil)
		{
			_transitionView = [[_LNPopupTransitionView alloc] initWithSourceView:self.view];
		}
		
		_crossfadeImageView = [[UIImageView alloc] initWithImage:self.popupBar.imageView.image];
		_crossfadeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_crossfadeImageView.contentMode = self.popupBar.imageView.contentMode;
		_crossfadeImageView.frame = _transitionView.bounds;
		_crossfadeImageView.layer.masksToBounds = YES;
		[_transitionView addSubview:_crossfadeImageView];
		
		_transitionView.frame = self.sourceFrame;
		[self beforeAnyAnimation];
		
		_crossfadeImageView.layer.cornerCurve = kCACornerCurveContinuous;
		
		objc_setAssociatedObject(self.transitionView.sourceView, _LNPopupOpenCloseTransitionViewKey, _transitionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}];
	
	[animator addAnimations:otherAnimations];
	
	[animator addAnimations:^{
		[UIView performWithoutAnimation:^{
			[self.popupContentView.window addSubview:_transitionView];
			[self performBeforeAdditionalAnimations];
		}];
		
		[self performAdditionalAnimations];
		
		if([self.view respondsToSelector:transitionWillBegin])
		{
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self.view methodSignatureForSelector:transitionWillBegin]];
			invocation.target = self.view;
			LNPopupPresentationState targetState = self.targetState;
			invocation.selector = transitionWillBegin;
			[invocation setArgument:&targetState atIndex:2];
			[invocation invoke];
		}
	}];
	
	[animator addAnimations:^{
		[self performAdditionalDelayed015Animations];
	} delayFactor:0.15];
	
	[animator addAnimations:^{
		[self performAdditionalDelayed05Animations];
	} delayFactor:0.5];
	
	[animator addAnimations:^{
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.75 animations:^{
				[self performAdditional075Animations];
			}];
		} completion:nil];
	} delayFactor:0.0];
	
	[animator addAnimations:^{
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
				[self performAdditional01Animations];
			}];
		} completion:nil];
	} delayFactor:0.0];
	
	[animator addAnimations:^{
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.75 animations:^{
				[self performAdditional075Delayed015Animations];
			}];
		} completion:nil];
	} delayFactor:0.0];
	
	[animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
		if([self.view respondsToSelector:transitionDidEnd])
		{
			[self.view performSelector:transitionDidEnd];
		}
		
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

- (LNPopupPresentationState)targetState
{
	return (LNPopupPresentationState)-1;
}

- (void)beforeAnyAnimation {}
- (void)performBeforeAdditionalAnimations {}
- (void)performAdditionalAnimations {}
- (void)performAdditionalDelayed015Animations {}
- (void)performAdditionalDelayed05Animations {}
- (void)performAdditional01Animations {}
- (void)performAdditional075Animations {}
- (void)performAdditional075Delayed015Animations {}
- (void)performAdditionalCompletion {}

- (void)completeTransition
{
	[UIView performWithoutAnimation:^{
		UIView* transitionView = objc_getAssociatedObject(self.transitionView.sourceView, _LNPopupOpenCloseTransitionViewKey);
		[transitionView removeFromSuperview];
		objc_setAssociatedObject(self.transitionView.sourceView, _LNPopupOpenCloseTransitionViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		self.popupBar.imageView.alpha = 1.0;
		[self performAdditionalCompletion];
	}];
}

@end
