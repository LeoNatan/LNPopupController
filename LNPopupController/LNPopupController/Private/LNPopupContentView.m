//
//  LNPopupContentView.m
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-04.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
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
		if([LNPopupBar isCatalystApp])
		{
			rv =  LNPopupCloseButtonStyleRound;
		}
		else
		{
			rv = LNPopupCloseButtonStyleGrabber;
		}
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
		
		__weak __typeof(self) weakSelf = self;
		if(@available(iOS 13.4, *))
		{
			_popupCloseButton.pointerInteractionEnabled = YES;
			_popupCloseButton.pointerStyleProvider = ^ UIPointerStyle* (UIButton *button, UIPointerEffect *proposedEffect, UIPointerShape *proposedShape) {
				LNPopupCloseButtonStyle resolvedStyle = _LNPopupResolveCloseButtonStyleFromCloseButtonStyle(weakSelf.popupCloseButtonStyle);
				
				if(resolvedStyle == LNPopupCloseButtonStyleRound)
				{
					CGRect frame = CGRectInset(weakSelf.popupCloseButton.frame, 5, 5);
					
					return [UIPointerStyle styleWithEffect:proposedEffect shape:[UIPointerShape shapeWithPath:[UIBezierPath bezierPathWithOvalInRect:frame]]];
				}
				
				NSValue* rectValue = [proposedShape valueForKey:@"rect"];
				if(rectValue == nil)
				{
					return [UIPointerStyle styleWithEffect:proposedEffect shape:proposedShape];
				}
				
				CGRect rect = CGRectInset(rectValue.CGRectValue, -5, -5);
				
				return [UIPointerStyle styleWithEffect:proposedEffect shape:[UIPointerShape shapeWithRoundedRect:rect]];
			};
		}
		
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
	
	if(self.currentPopupContentViewController == nil)
	{
		return;
	}
	
	CGRect layoutFrame = [self convertRect:_currentPopupContentViewController.view.layoutMarginsGuide.layoutFrame fromView:_currentPopupContentViewController.view];
	
	CGFloat topConstant = self.popupCloseButton.style == LNPopupCloseButtonStyleRound ? 0 : 1.0;
	topConstant += layoutFrame.origin.y;
	topConstant = MAX(self.popupCloseButton.style == LNPopupCloseButtonStyleRound ? 12 : 0, topConstant);
	
#if TARGET_OS_MACCATALYST
	topConstant += 20;
#endif
	
	CGFloat leadingConstant = layoutFrame.origin.x;
	
	if(topConstant != _popupCloseButtonTopConstraint.constant || leadingConstant != _popupCloseButtonLeadingConstraint.constant)
	{
		_popupCloseButtonTopConstraint.constant = topConstant;
		_popupCloseButtonLeadingConstraint.constant = leadingConstant;
		
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
