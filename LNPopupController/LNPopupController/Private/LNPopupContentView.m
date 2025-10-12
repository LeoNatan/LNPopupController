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
#import "UIView+LNPopupSupportPrivate.h"
#import "_LNUITraitOverridesWrapper.h"

@implementation LNPopupContentView
{
	NSLayoutConstraint* _popupCloseButtonTopConstraint;

	NSLayoutConstraint* _popupCloseButtonCenterConstraint;
	NSLayoutConstraint* _popupCloseButtonLeadingConstraint;
	NSLayoutConstraint* _popupCloseButtonTrailingConstraint;
}

- (id<UITraitOverrides>)traitOverrides
{
	return [[_LNUITraitOverridesWrapper alloc] initWithTraitOverrides:super.traitOverrides contentView:self];
}

- (void)setUserUserInterfaceStyleTraitModifier:(UIUserInterfaceStyle)userUserInterfaceStyleTraitModifier
{
	_userUserInterfaceStyleTraitModifier = userUserInterfaceStyleTraitModifier;
	
	[self _updateTraitOverrides];
}

- (void)setSystemUserInterfaceStyleTraitModifier:(UIUserInterfaceStyle)systemUserInterfaceStyleTraitModifier
{
	_systemUserInterfaceStyleTraitModifier = systemUserInterfaceStyleTraitModifier;
	
	[self _updateTraitOverrides];
}

- (void)_updateTraitOverrides API_AVAILABLE(ios(17.0))
{
	super.traitOverrides.userInterfaceStyle = self.userUserInterfaceStyleTraitModifier != UIUserInterfaceStyleUnspecified ? self.userUserInterfaceStyleTraitModifier : self.systemUserInterfaceStyleTraitModifier;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_effectView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_effectView.frame = self.bounds;
		_effectView.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:_effectView];
		
		_contentView = [UIView new];
		_contentView.frame = self.bounds;
		_contentView.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:_contentView];
		
		_translucent = YES;
		_backgroundEffect = nil;
		
		_popupCloseButton = [[LNPopupCloseButton alloc] initWithContainingContentView:self];
		[self _setStyle:LNPopupCloseButtonStyleDefault positioning:LNPopupCloseButtonPositioningDefault];
		
		__weak __typeof(self) weakSelf = self;
		if(@available(iOS 13.4, *))
		{
			_popupCloseButton.pointerInteractionEnabled = YES;
			_popupCloseButton.pointerStyleProvider = ^ UIPointerStyle* (UIButton *button, UIPointerEffect *proposedEffect, UIPointerShape *proposedShape) {
				LNPopupCloseButtonStyle resolvedStyle = weakSelf.effectivePopupCloseButtonStyle;
				
				if(resolvedStyle == LNPopupCloseButtonStyleRound || _LNPopupCloseButtonStyleIsGlass(resolvedStyle))
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
	_contentView.frame = self.bounds;
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
	[self _setStyle:popupCloseButtonStyle positioning:_popupCloseButtonPositioning];
}

- (void)setPopupCloseButtonPositioning:(LNPopupCloseButtonPositioning)popupCloseButtonPositioning
{
	[self _setStyle:_popupCloseButtonStyle positioning:popupCloseButtonPositioning];
}

- (void)_setStyle:(LNPopupCloseButtonStyle)popupCloseButtonStyle positioning:(LNPopupCloseButtonPositioning)popupCloseButtonPositioning
{
	_popupCloseButtonStyle = popupCloseButtonStyle;
	_popupCloseButtonPositioning = popupCloseButtonPositioning;
	
	_LNPopupResolveCloseButtonStyleAndPositioning(_popupCloseButtonStyle, _popupCloseButtonPositioning, &_effectivePopupCloseButtonStyle, &_effectivePopupCloseButtonPositioning);

	[self _configureButton];
}

- (void)_configureButton
{
	[UIView performWithoutAnimation:^{
		[self.popupCloseButton _setStyle:_popupCloseButtonStyle];
		[self.popupCloseButton _setPositioning:_popupCloseButtonPositioning];
		
		if([_currentPopupContentViewController positionPopupCloseButton:self.popupCloseButton] == YES)
		{
			_popupCloseButtonTopConstraint.active = NO;
			_popupCloseButtonLeadingConstraint.active = NO;
			_popupCloseButtonTrailingConstraint.active = NO;
			_popupCloseButtonCenterConstraint.active = NO;
			return;
		}
		else
		{
			if(self.popupCloseButton.superview != self.contentView)
			{
				[self.contentView addSubview:self.popupCloseButton];
			}
		}
		
		if(self.effectivePopupCloseButtonStyle != LNPopupCloseButtonStyleNone)
		{
			self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
			
			if(_popupCloseButtonTopConstraint == nil)
			{
				_popupCloseButtonTopConstraint = [self.popupCloseButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor];
				
				[NSLayoutConstraint activateConstraints:@[_popupCloseButtonTopConstraint]];
			}
			
			if(_popupCloseButtonLeadingConstraint == nil)
			{
				_popupCloseButtonLeadingConstraint = [self.popupCloseButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor];
			}
			
			if(_popupCloseButtonTrailingConstraint == nil)
			{
				_popupCloseButtonTrailingConstraint = [self.popupCloseButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor];
			}
			
			if(_popupCloseButtonCenterConstraint == nil)
			{
				_popupCloseButtonCenterConstraint = [self.popupCloseButton.centerXAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.centerXAnchor];
			}
			
			[self _repositionPopupCloseButtonAnimated:NO];
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
	
	_popupCloseButtonTopConstraint.constant = _LNPopupCloseButtonStyleIsGlass(self.effectivePopupCloseButtonStyle) ? 20 : self.effectivePopupCloseButtonStyle == LNPopupCloseButtonStyleRound ? 12 : 8;
	_popupCloseButtonLeadingConstraint.constant = _LNPopupCloseButtonStyleIsGlass(self.effectivePopupCloseButtonStyle) ? 20 : 12;
	_popupCloseButtonTrailingConstraint.constant = _LNPopupCloseButtonStyleIsGlass(self.effectivePopupCloseButtonStyle) ? -20 : -12;
	
	switch(self.effectivePopupCloseButtonPositioning)
	{
		default:
		case LNPopupCloseButtonPositioningLeading:
			_popupCloseButtonLeadingConstraint.active = YES;
			_popupCloseButtonCenterConstraint.active = NO;
			_popupCloseButtonTrailingConstraint.active = NO;
			break;
		case LNPopupCloseButtonPositioningCenter:
			_popupCloseButtonLeadingConstraint.active = NO;
			_popupCloseButtonCenterConstraint.active = YES;
			_popupCloseButtonTrailingConstraint.active = NO;
			break;
		case LNPopupCloseButtonPositioningTrailing:
			_popupCloseButtonLeadingConstraint.active = NO;
			_popupCloseButtonCenterConstraint.active = NO;
			_popupCloseButtonTrailingConstraint.active = YES;
			break;
	}
	
	if(self.currentPopupContentViewController == nil)
	{
		return;
	}
	
	UIEdgeInsets layoutMargins = LNPopupEnvironmentLayoutInsets(self.currentPopupContentViewController.view, false);
	
	CGFloat topConstant = layoutMargins.top;
	
	topConstant = MAX(self.effectivePopupCloseButtonStyle == LNPopupCloseButtonStyleRound ? 12 : 0, topConstant);
	
#if TARGET_OS_MACCATALYST
	topConstant += 20;
#endif
	
	if(topConstant != _popupCloseButtonTopConstraint.constant || layoutMargins.left != _popupCloseButtonLeadingConstraint.constant || -layoutMargins.right != _popupCloseButtonTrailingConstraint.constant)
	{
		_popupCloseButtonTopConstraint.constant = topConstant;
		_popupCloseButtonLeadingConstraint.constant = layoutMargins.left;
		_popupCloseButtonTrailingConstraint.constant = -layoutMargins.right;
		
		if(self.window == nil)
		{
			return;
		}
		
		if(animated == NO || UIView.inheritedAnimationDuration > 0.0)
		{
			[self layoutIfNeeded];
		}
		else
		{
			[UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
				[self layoutIfNeeded];
			} completion:nil];
		}
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
}

- (void)safeAreaInsetsDidChange
{
	[super safeAreaInsetsDidChange];
	
	[self _repositionPopupCloseButtonAnimated:NO];
}

- (void)_applyBackgroundEffectWithContentViewController:(UIViewController*)vc activeAppearance:(LNPopupBarAppearance*)appearance
{
	if(self.translucent == NO)
	{
		//This is so glass effect get's really removed. 🤦‍♂️
		_effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		_effectView.effect = nil;
		_effectView.backgroundColor = UIColor.systemBackgroundColor;
	}
	else
	{
		UIVisualEffect* effectToUse;
		if(_backgroundEffect != nil)
		{
			effectToUse = _backgroundEffect;
		}
		else
		{
			effectToUse = [appearance floatingBackgroundEffectForPopupBar:nil containerController:nil traitCollection:vc.traitCollection];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		if(effectToUse.ln_isGlass)
		{
			_LNPopupGlassWrapperEffect* wrapper = [_LNPopupGlassWrapperEffect wrapperWithEffect:effectToUse];
			wrapper.disableForeground = YES;
			wrapper.disableInteractive = _backgroundEffect == nil;
			effectToUse = wrapper;
		}
#endif
		
		_effectView.effect = effectToUse;
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
