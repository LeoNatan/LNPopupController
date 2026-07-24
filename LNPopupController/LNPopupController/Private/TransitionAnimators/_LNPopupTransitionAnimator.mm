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
#import "LNPopupContentView+Private.h"
#import "LNPopupControllerImpl.h"

static const void* _LNPopupOpenCloseTransitionViewKey = &_LNPopupOpenCloseTransitionViewKey;

@implementation _LNPopupTransitionAnimator
{
	CGFloat _alphaBefore;
}

- (instancetype)initWithTransitionView:(_LNPopupTransitionView *)transitionView userView:(UIView *)view popupBar:(LNPopupBar *)popupBar popupContentView:(LNPopupContentView *)popupContentView effectiveInteractionStyle:(LNPopupInteractionStyle)interactionStyle
{
	self = [super init];
	
	if(self)
	{
		if(popupBar.customBarViewController != nil || popupBar.imageView.isHidden)
		{
			transitionView = nil;
			view = nil;
		}
		
		_transitionView = transitionView;
		_view = view;
		_popupBar = popupBar;
		_popupContentView = popupContentView;
		
		if(@available(iOS 26.0, *))
		{
			_wantsContentTransition = LNPopupEnvironmentHasGlass() && popupContentView.allowsContentTransition && interactionStyle == LNPopupInteractionStyleSnap;
			
			if(_wantsContentTransition)
			{
				_contentViewTransitionView = [_LNPopupTransitionView transitionViewWithSourceView:popupContentView.contentView];
				_contentViewTransitionView.matchesAlpha = NO;
				_contentViewTransitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
				
				_contentTransitionEffectView = [[UIVisualEffectView alloc] initWithEffect:self.sourceContentTransitionEffect];
				_contentTransitionEffectView.frame = popupContentView.frame;
				[_contentTransitionEffectView.contentView addSubview:_contentViewTransitionView];
				_contentViewTransitionView.frame = self.popupContentView.currentPopupContentViewController.view.bounds;
				_contentTransitionEffectView.clipsToBounds = YES;
				_contentTransitionEffectView.layer.cornerCurve = kCACornerCurveCircular;
				
				_popupBarTransitionView = [_LNPopupTransitionView transitionViewWithSourceView:popupBar.contentView.effectView];
				_popupBarTransitionView.matchesAlpha = NO;
				_popupBarTransitionView.allowsEffects = YES;
				_popupBarTransitionView.matchesPosition = NO;
				_popupBarTransitionView.frame = popupBar.contentView.frame;
				_popupBarTransitionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
				
				_contentTransitionWrapperView = [[UIView alloc] initWithFrame:popupContentView.frame];
				_contentTransitionEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				[_contentTransitionWrapperView addSubview:_contentTransitionEffectView];
				_contentTransitionEffectView.frame = _contentTransitionWrapperView.bounds;
				[_contentTransitionWrapperView addSubview:_popupBarTransitionView];
				
				self.popupContentView.transitionView = _contentTransitionWrapperView;
			}
		}
	}
	
	return self;
}

- (void)animateWithAnimator:(UIViewPropertyAnimator *)animator otherAnimations:(void (^)(void))otherAnimations
{
	//LNPopupUI support
	static SEL transitionWillBegin = NSSelectorFromString(@"_transitionWillBeginToState:");
	static SEL transitionDidEnd = NSSelectorFromString(@"_transitionDidEnd");
	
	[UIView performWithoutAnimation:^{
		[self.popupContentView layoutIfNeeded];
		if(self.transitionView == nil && self.view != nil)
		{
			_transitionView = [[_LNPopupTransitionView alloc] initWithSourceView:self.view];
		}
		
		if(@available(iOS 26.0, *))
		if(_wantsContentTransition)
		{
			_transitionView.matchesAlpha = NO;
			_transitionView.alpha = self.view.alpha;
			_alphaBefore = self.view.alpha;
			self.view.alpha = 0.0;
			
			_popupBarEffect = self.popupBar.contentView.effectView.effect;
		}
		
		_popupBarImageAlphaBeforeAnimation = self.popupBar.imageView.alpha;
		
		if(_transitionView != nil)
		{
			self.popupBar.imageView.alpha = 0.0;
			
			UIImage* image;
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
			
			_crossfadeView = [[LNPopupImageView alloc] initWithImage:image];
			_crossfadeView.contentMode = self.popupBar.imageView.contentMode;
			_crossfadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_crossfadeView.frame = _transitionView.bounds;
			[_transitionView addSubview:_crossfadeView];
			
			_transitionView.frame = self.sourceFrame;
			_transitionView.alpha = self.sourceImageAlpha;
		}
		
		if(@available(iOS 26.0, *))
		if(_wantsContentTransition)
		{
			self.popupContentView.effectView.alpha = 0.0;
			_contentTransitionWrapperView.frame = self.sourceContentFrame;
			_contentTransitionEffectView.corners = self.sourceContentCornerRadius;
			_contentViewTransitionView.alpha = self.sourceContentAlpha;
			_contentTransitionEffectView.effect = self.targetContentTransitionEffect;
		}
		
		[self beforeAnyAnimation];
		
		if(_transitionView != nil)
		{
			objc_setAssociatedObject(self.transitionView.sourceLayer, _LNPopupOpenCloseTransitionViewKey, _transitionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
		
		if(@available(iOS 26.0, *))
		if(_wantsContentTransition)
		{
			[self.popupContentView.superview addSubview:_contentTransitionWrapperView];
		}
		if(_transitionView != nil)
		{
			[self.popupContentView.window addSubview:_transitionView];
		}
		[self performBeforeAdditionalAnimations];
	}];
	
	[animator addAnimations:otherAnimations];
	
	[animator addAnimations:^{
		if(@available(iOS 26.0, *))
		if(_wantsContentTransition)
		{
			_contentTransitionWrapperView.frame = self.targetContentFrame;
			_contentTransitionEffectView.corners = self.targetContentCornerRadius;
		}
		
		_transitionView.alpha = self.targetImageAlpha;
		
		[self performAdditionalAnimations];
		
		if([self.view respondsToSelector:transitionWillBegin])
		{
			//LNPopupUI support
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
	
	[animator addAnimations:^{
		[UIView animateKeyframesWithDuration:0.0 delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.55 relativeDuration:0.35 animations:^{
				[self performAdditional025Delayed060Animations];
			}];
		} completion:nil];
	} delayFactor:0.0];
	
	[animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
		if([self.view respondsToSelector:transitionDidEnd])
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self.view performSelector:transitionDidEnd];
#pragma clang diagnostic pop
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

- (UIVisualEffect *)sourceContentTransitionEffect
{
	return nil;
}

- (UIVisualEffect *)targetContentTransitionEffect
{
	return nil;
}

- (CGRect)sourceContentFrame
{
	return CGRectZero;
}

- (CGRect)targetContentFrame
{
	return CGRectZero;
}

- (LNPopupViewCorners)sourceContentCornerRadius
{
	return {0};
}

- (LNPopupViewCorners)targetContentCornerRadius
{
	return {0};
}

- (CGFloat)sourceContentAlpha
{
	return 1.0;
}

- (CGFloat)targetContentAlpha
{
	return 1.0;
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
- (void)performAdditional025Delayed060Animations {}
- (void)performAdditionalCompletion {}

- (void)completeTransition
{
	[UIView performWithoutAnimation:^{
		if(@available(iOS 26.0, *))
		if(_wantsContentTransition)
		{
			self.view.alpha = _alphaBefore;
			self.popupContentView.effectView.alpha = 1.0;
			self.popupBar.contentView.effectView.effect = _popupBarEffect;
			[_contentTransitionWrapperView removeFromSuperview];
			self.popupContentView.transitionView = nil;
		}
		UIView* transitionView = objc_getAssociatedObject(self.transitionView.sourceLayer, _LNPopupOpenCloseTransitionViewKey);
		[transitionView removeFromSuperview];
		objc_setAssociatedObject(self.transitionView.sourceLayer, _LNPopupOpenCloseTransitionViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		self.popupBar.imageView.alpha = _popupBarImageAlphaBeforeAnimation;
		[self performAdditionalCompletion];
	}];
}

@end
