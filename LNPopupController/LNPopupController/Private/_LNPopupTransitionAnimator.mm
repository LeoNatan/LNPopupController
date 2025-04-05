//
//  _LNPopupTransitionAnimatorOpen.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-03-24.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTransitionAnimator.h"
#import "LNPopupBar+Private.h"
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
		
		UIImage* image;
		if(@available(iOS 13, *))
		{
			if(self.popupBar.swiftuiImageController != nil)
			{
				id contents = self.popupBar.swiftuiImageController.view.subviews.firstObject.layer.contents;
				if(contents != nil && CFGetTypeID((__bridge CFTypeRef)contents) == CGImageGetTypeID())
				{
					image = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)contents];
				}
				else
				{
					image = [[[UIGraphicsImageRenderer alloc] initWithSize:self.popupBar.imageView.bounds.size] imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
						[self.popupBar.imageView drawViewHierarchyInRect:self.popupBar.imageView.bounds afterScreenUpdates:NO];
					}];
				}
			}
			else
			{
				image = self.popupBar.imageView.image;
			}
		}
		else
		{
			image = self.popupBar.imageView.image;
		}
		
		_crossfadeView = [[LNPopupImageView alloc] initWithImage:image];
		_crossfadeView.contentMode = self.popupBar.imageView.contentMode;
		_crossfadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_crossfadeView.frame = _transitionView.bounds;
		[_transitionView addSubview:_crossfadeView];
		
		_transitionView.frame = self.sourceFrame;
		[self beforeAnyAnimation];
		
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
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.85 animations:^{
				[self performAdditionalDelayed015Animations];
			}];
		} completion:nil];
	}];
	
	[animator addAnimations:^{
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.4 animations:^{
				[self performAdditional04Delayed015Animations];
			}];
		} completion:nil];
	}];
	
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
- (void)performAdditional04Delayed015Animations {}
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
