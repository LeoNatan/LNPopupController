//
//  LNPopupContentView.m
//  LNPopupController
//
//  Created by Leo Natan on 8/4/20.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import "LNPopupContentView+Private.h"

@implementation LNPopupContentView
{
	NSInteger _userOverrideUserInterfaceStyle;
	NSInteger _controllerOverrideUserInterfaceStyle;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_effectView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_effectView.frame = self.bounds;
		_effectView.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:_effectView];
		
		_popupCloseButtonAutomaticallyUnobstructsTopBars = YES;
		
		_translucent = YES;
		_backgroundStyle = LNBackgroundStyleInherit;
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_effectView.frame = self.bounds;
}

- (UIView *)contentView
{
	return _effectView.contentView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(scrollView.contentOffset.y > 0)
	{
		scrollView.contentOffset = CGPointZero;
	}
}

- (void)safeAreaInsetsDidChange
{
	[super safeAreaInsetsDidChange];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle
{
	return _userOverrideUserInterfaceStyle != UIUserInterfaceStyleUnspecified ? _userOverrideUserInterfaceStyle : _controllerOverrideUserInterfaceStyle;
}

- (void)setOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle
{
	_userOverrideUserInterfaceStyle = overrideUserInterfaceStyle;
	
	[super setOverrideUserInterfaceStyle:self.overrideUserInterfaceStyle];
}

- (void)setControllerOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle
{
	_controllerOverrideUserInterfaceStyle = overrideUserInterfaceStyle;
	
	[super setOverrideUserInterfaceStyle:self.overrideUserInterfaceStyle];
}

- (void)_applyBackgroundEffectWithContentViewController:(UIViewController*)vc barEffect:(UIBlurEffect*)barEffect
{
	__block BOOL alphaLessThanZero;
	void (^block)(void) = ^ {
		alphaLessThanZero = CGColorGetAlpha(vc.view.backgroundColor.CGColor) < 1.0;
	};
	
	if (@available(iOS 13.0, *)) {
		[vc.traitCollection performAsCurrentTraitCollection:block];
	} else {
		block();
	}
	
	if(alphaLessThanZero)
	{
		if(self.translucent == NO)
		{
			_effectView.effect = nil;
		}
		else if(self.backgroundStyle == LNBackgroundStyleInherit)
		{
			_effectView.effect = barEffect;
		}
		else
		{
			_effectView.effect = [UIBlurEffect effectWithStyle:self.backgroundStyle];
		}
		
		if(self.popupCloseButton.style == LNPopupCloseButtonStyleRound)
		{
			self.popupCloseButton.layer.shadowOpacity = 0.2;
		}
	}
	else
	{
		_effectView.effect = nil;
		if(self.popupCloseButton.style == LNPopupCloseButtonStyleRound)
		{
			self.popupCloseButton.layer.shadowOpacity = 0.1;
		}
	}
}

@end

#pragma mark Popup Transition Coordinator

@implementation _LNPopupTransitionCoordinator

- (BOOL)isInterruptible
{
	return NO;
}

- (BOOL)isAnimated
{
	return NO;
}

- (UIModalPresentationStyle)presentationStyle
{
	return UIModalPresentationNone;
}

- (BOOL)initiallyInteractive
{
	return NO;
}

- (BOOL)isInteractive
{
	return NO;
}

- (BOOL)isCancelled
{
	return NO;
}

- (NSTimeInterval)transitionDuration
{
	return 0.0;
}

- (CGFloat)percentComplete;
{
	return 1.0;
}

- (CGFloat)completionVelocity
{
	return 1.0;
}

- (UIViewAnimationCurve)completionCurve
{
	return UIViewAnimationCurveEaseInOut;
}

- (nullable __kindof UIViewController *)viewControllerForKey:(NSString *)key
{
	if([key isEqualToString:UITransitionContextFromViewControllerKey])
	{
		
	}
	else if([key isEqualToString:UITransitionContextToViewControllerKey])
	{
		
	}
	
	return nil;
}

- (nullable __kindof UIView *)viewForKey:(NSString *)key
{
	return nil;
}

- (UIView *)containerView
{
	return nil;
}

- (CGAffineTransform)targetTransform
{
	return CGAffineTransformIdentity;
}

- (BOOL)animateAlongsideTransition:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
						completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
	if(animation)
	{
		animation(self);
	}
	
	if(completion)
	{
		completion(self);
	}
	
	return YES;
}

- (BOOL)animateAlongsideTransitionInView:(nullable UIView *)view
							   animation:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
							  completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
	return [self animateAlongsideTransition:animation completion:completion];
}

- (void)notifyWhenInteractionEndsUsingBlock: (void (^)(id <UIViewControllerTransitionCoordinatorContext>context))handler
{ }

- (void) notifyWhenInteractionChangesUsingBlock:(nonnull void (^)(id<UIViewControllerTransitionCoordinatorContext> _Nonnull))handler
{ }

@end
