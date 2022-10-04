//
//  LNPopupContentView.m
//  LNPopupController
//
//  Created by Leo Natan on 8/4/20.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupController.h"
#import "LNPopupContentView+Private.h"
#import "LNPopupCloseButton+Private.h"
#import <LNPopupController/UIViewController+LNPopupSupport.h>

LNPopupCloseButtonStyle _LNPopupResolveCloseButtonStyleFromCloseButtonStyle(LNPopupCloseButtonStyle style)
{
	LNPopupCloseButtonStyle rv = style;
	if(rv == LNPopupCloseButtonStyleDefault)
	{
#if TARGET_OS_MACCATALYST
		rv = LNPopupCloseButtonStyleRound;
#else
		rv = LNPopupCloseButtonStyleChevron;
#endif
	}
	return rv;
}

@implementation LNPopupContentView
{
	NSInteger _userOverrideUserInterfaceStyle;
	NSInteger _controllerOverrideUserInterfaceStyle;
	
	NSLayoutConstraint* _popupCloseButtonTopConstraint;

	NSLayoutConstraint* _popupCloseButtonCenterConstraint;
	NSLayoutConstraint* _popupCloseButtonLeadingConstraint;
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
		
		_translucent = YES;
		_backgroundEffect = nil;
		
		_popupCloseButton = [[LNPopupCloseButton alloc] initWithContainingContentView:self];
		_popupCloseButton.popupContentView = self;
		
		[_popupCloseButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		[_popupCloseButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[_popupCloseButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		[_popupCloseButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
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

- (void)setCurrentPopupContentViewController:(UIViewController *)currentPopupContentViewController
{
	if(_currentPopupContentViewController == currentPopupContentViewController)
	{
		return;
	}
	
	_currentPopupContentViewController = currentPopupContentViewController;
	
	self.popupCloseButtonStyle = self.popupCloseButtonStyle;
}

- (void)setPopupCloseButtonStyle:(LNPopupCloseButtonStyle)popupCloseButtonStyle
{
	_popupCloseButtonStyle = popupCloseButtonStyle;
	
	LNPopupCloseButtonStyle buttonStyle = _LNPopupResolveCloseButtonStyleFromCloseButtonStyle(self.popupCloseButtonStyle);
	
	[UIView performWithoutAnimation:^{
		[self.popupCloseButton _setStyle:buttonStyle];
		
		if(buttonStyle == LNPopupCloseButtonStyleRound)
		{
			self.popupCloseButton.tintColor = [UIColor labelColor];
		}
		else
		{
				self.popupCloseButton.tintColor = [UIColor systemGray2Color];
		}
		
		if([_currentPopupContentViewController positionPopupCloseButton:self.popupCloseButton] == YES)
		{
			return;
		}
		else
		{
			if(self.popupCloseButton.superview != self.contentView)
			{
				[self.contentView addSubview:self.popupCloseButton];
			}
		}
		
		if(buttonStyle != LNPopupCloseButtonStyleNone)
		{
			self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
			
			if(_popupCloseButtonTopConstraint == nil)
			{
				_popupCloseButtonTopConstraint = [self.popupCloseButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:buttonStyle == LNPopupCloseButtonStyleRound ? 12 : 8];
				
				[NSLayoutConstraint activateConstraints:@[_popupCloseButtonTopConstraint]];
			}
			
			if(_popupCloseButtonLeadingConstraint == nil)
			{
				_popupCloseButtonLeadingConstraint = [self.popupCloseButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12];
			}
			
			if(_popupCloseButtonCenterConstraint == nil)
			{
				_popupCloseButtonCenterConstraint = [self.popupCloseButton.centerXAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.centerXAnchor];
			}
			
			if(buttonStyle == LNPopupCloseButtonStyleRound)
			{
				_popupCloseButtonLeadingConstraint.active = YES;
				_popupCloseButtonCenterConstraint.active = NO;
			}
			else
			{
				_popupCloseButtonLeadingConstraint.active = NO;
				_popupCloseButtonCenterConstraint.active = YES;
			}
			
			[self _repositionPopupCloseButtonAnimated:YES];
		}
		else
		{
			self.popupCloseButton.hidden = YES;
		}
	}];
}

- (UIView*)_view:(UIView*)view selfOrSuperviewKindOfClass:(Class)aClass
{
	if([view isKindOfClass:aClass])
	{
		return view;
	}
	
	UIView* superview = view.superview;
	
	while(superview != nil)
	{
		if([superview isKindOfClass:aClass])
		{
			return superview;
		}
		
		superview = superview.superview;
	}
	
	return nil;
}

- (void)_repositionPopupCloseButton
{
	[self _repositionPopupCloseButtonAnimated:YES];
}

- (void)_repositionPopupCloseButtonAnimated:(BOOL)animated
{
	if(self.popupCloseButton.superview != self.contentView)
	{
		return;
	}
	
	CGFloat startingTopConstant = _popupCloseButtonTopConstraint.constant;

	_popupCloseButtonTopConstraint.constant = self.popupCloseButton.style == LNPopupCloseButtonStyleRound ? 12 : 4;

	CGFloat windowTopSafeAreaInset = 0;

	if([NSStringFromClass(_currentPopupContentViewController.popupPresentationContainerViewController.nonMemoryLeakingPresentationController.class) containsString:@"Fullscreen"])
	{
		windowTopSafeAreaInset += self.window.safeAreaInsets.top;
	}
	else
	{
		UIView* viewToUse = _currentPopupContentViewController.popupPresentationContainerViewController.presentingViewController.presentedViewController.view;
		if(viewToUse == nil)
		{
			viewToUse = self.superview;
		}
		windowTopSafeAreaInset += viewToUse.safeAreaInsets.top + 5;
	}

	_popupCloseButtonTopConstraint.constant += windowTopSafeAreaInset;

	if(startingTopConstant != _popupCloseButtonTopConstraint.constant)
	{
		if(animated == NO)
		{
			[UIView performWithoutAnimation:^{
				[self layoutIfNeeded];
			}];
		}
		else
		{
			[UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
				[self layoutIfNeeded];
			} completion:nil];
		}
	}
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
	if(self.translucent == NO)
	{
		_effectView.effect = nil;
	}
	else if(_backgroundEffect == nil)
	{
		_effectView.effect = barEffect;
	}
	else
	{
		_effectView.effect = _backgroundEffect;
	}
}

@end

#pragma mark Deprecations

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation LNPopupContentView (Deprecations)

- (void)setBackgroundStyle:(UIBlurEffectStyle)backgroundStyle
{
	_backgroundEffect = backgroundStyle == LNBackgroundStyleInherit ? nil : [UIBlurEffect effectWithStyle:backgroundStyle];
}

- (UIBlurEffectStyle)backgroundStyle
{
	return _backgroundEffect == nil ? LNBackgroundStyleInherit : [[_backgroundEffect valueForKey:@"style"] unsignedIntegerValue];
}

@end

#pragma clang diagnostic pop

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
