//
//  LNPopupContentView.mm
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-04.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupControllerImpl.h"
#import "LNPopupContentView+Private.h"
#import "LNPopupCloseButton+Private.h"
#import <LNPopupController/UIViewController+LNPopupSupport.h>
#import "UIScreen+LNPopupSupportPrivate.h"
#import "_LNPopupBase64Utils.hh"
#import "_LNPopupCatalystHelper.h"

#if !TARGET_OS_MACCATALYST
@implementation _LNPopupContentViewLayoutController @end
#endif

@implementation LNPopupContentView
{
	NSLayoutConstraint* _popupCloseButtonTopConstraint;

	NSLayoutConstraint* _popupCloseButtonCenterConstraint;
	NSLayoutConstraint* _popupCloseButtonLeadingConstraint;
	NSLayoutConstraint* _popupCloseButtonTrailingConstraint;
	
#if !TARGET_OS_MACCATALYST
	UIView* _leadingLayoutView;
	UIView* _trailingLayoutView;
#endif
}

+ (LNPopupViewCorners)cornersForContentView:(LNPopupContentView*)contentView
{
	if(contentView.window != nil)
	{
		CGRect frameInWindow = [contentView.window convertRect:contentView.bounds fromView:contentView];
		CGRect superFrameInWindow = [contentView.window convertRect:contentView.superview.bounds fromView:contentView.superview];
		
		LNPopupViewCorners corners = {};
		CGSize corner = CGSizeMake(contentView.window.screen._ln_cornerRadius, contentView.window.screen._ln_cornerRadius);
		if(frameInWindow.origin.x == 0)
		{
			if(superFrameInWindow.origin.y == 0)
			{
				corners.leftTop = corner;
			}
			if(superFrameInWindow.origin.y + superFrameInWindow.size.height == contentView.window.bounds.size.height)
			{
				corners.leftBottom = corner;
			}
		}
		
		if(frameInWindow.origin.x + frameInWindow.size.width == contentView.window.bounds.size.width)
		{
			if(superFrameInWindow.origin.y == 0)
			{
				corners.rightTop = corner;
			}
			if(superFrameInWindow.origin.y + superFrameInWindow.size.height == contentView.window.bounds.size.height)
			{
				corners.rightBottom = corner;
			}
		}
		
		return corners;
	}
	
	return {};
}

+ (void)load
{
	@autoreleasepool
	{
		Method m = LNSwizzleClassGetInstanceMethod(self, @selector(safeAreaInsetsDidChange));
		class_addMethod(self, NSSelectorFromString(LNPopupHiddenString("_updateSafeAreaInsets")), imp_implementationWithBlock(^{}), method_getTypeEncoding(m));
	}
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
		_allowsContentTransition = YES;
		
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
		
		if(@available(iOS 17.0, *))
		{
			self.traitOverrides.userInterfaceLevel = UIUserInterfaceLevelElevated;
		}
		
#if !TARGET_OS_MACCATALYST
		if(LNPopupEnvironmentHasGlass())
		{
			auto vc = [UIViewController new];
			_leadingLayoutView = [UIView new];
			_leadingLayoutView.frame = CGRectMake(0, 0, 44, 44);
			vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leadingLayoutView];
			_trailingLayoutView = [UIView new];
			_trailingLayoutView.frame = CGRectMake(0, 0, 44, 44);
			vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_trailingLayoutView];
			
			_layoutController = [[_LNPopupContentViewLayoutController alloc] initWithRootViewController:vc];
			_layoutController.view.userInteractionEnabled = NO;
//			_layoutController.view.alpha = 0.3;
			_layoutController.view.hidden = YES;
			[self addSubview:_layoutController.view];
		}
#endif
	}
	
	return self;
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event
{
	[super pressesEnded:presses withEvent:event];
}

- (void)_setApplyScreenCorners:(BOOL)applyScreenCorners
{
	if(_applyScreenCorners == applyScreenCorners)
	{
		return;
	}
	
	_applyScreenCorners = applyScreenCorners;
	
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	if(LNPopupEnvironmentHasGlass())
	{
		self.layer.masksToBounds = YES;
		self.layer.cornerCurve = kCACornerCurveCircular;
	
		if(_applyScreenCorners)
		{
			self.corners = [LNPopupContentView cornersForContentView:self];
		}
		else
		{
			self.corners = {};
		}
	}
	
	[super layoutSubviews];
	
	_effectView.frame = self.bounds;
	
#if !TARGET_OS_MACCATALYST
	if(LNPopupEnvironmentHasGlass())
	{
		_layoutController.view.frame = self.bounds;
		[_layoutController.navigationBar _ln_removeInteractionsFromSubviewTree];
	}
#endif
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
		
		if(self.effectivePopupCloseButtonStyle != LNPopupCloseButtonStyleNone)
		{
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
				_popupCloseButtonTrailingConstraint = [self.contentView.trailingAnchor constraintEqualToAnchor:self.popupCloseButton.trailingAnchor];
			}
			
			if(_popupCloseButtonCenterConstraint == nil)
			{
				_popupCloseButtonCenterConstraint = [self.popupCloseButton.centerXAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.centerXAnchor];
			}
			
			[self _repositionPopupCloseButtonAnimated:NO];
		}
		else
		{
			[self.popupCloseButton removeFromSuperview];
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
		
	NSDirectionalEdgeInsets layoutMargins = self.currentPopupContentViewController.view.directionalLayoutMargins;
	CGFloat topConstant = 0.0;
	CGFloat leadingConstant = 0.0;
	CGFloat trailingConstant = 0.0;
#if TARGET_OS_MACCATALYST
	_LNPopupCatalystMetrics* metrics = [_LNPopupCatalystHelper metricsForScene:self.window.windowScene];
	topConstant = metrics.topConstant;
	leadingConstant = metrics.leadingConstant;
	trailingConstant = metrics.trailingConstant;
#else
	if(LNPopupEnvironmentHasGlass())
	{
		[UIView performWithoutAnimation:^{
			[_layoutController.view layoutIfNeeded];
		}];
		
		CGRect leadingFrame = [self convertRect:_leadingLayoutView.bounds fromView:_leadingLayoutView];
		CGRect trailingFrame = [self convertRect:_trailingLayoutView.bounds fromView:_trailingLayoutView];
	
		NSDirectionalEdgeInsets cornerAdaptionMargin = NSDirectionalEdgeInsetsZero;
		if(@available(iOS 26.0, *))
		{
			UIEdgeInsets insets = [self.window edgeInsetsForLayoutRegion:[UIViewLayoutRegion marginsLayoutRegionWithCornerAdaptation:UIViewLayoutRegionAdaptivityAxisHorizontal]];
			
			BOOL hasWindowControls = insets.left != insets.right;
			if(insets.left > 30 && hasWindowControls)
			{
				insets.left += 10;
			}
			else
			{
				insets.left = 0;
			}
			
			if(insets.right > 30 && hasWindowControls)
			{
				insets.right += 10;
			}
			else
			{
				insets.right = 0;
			}
			
			CGRect frameInWindow = [self.window convertRect:self.bounds fromView:self];
			
			insets.left -= frameInWindow.origin.x;
			
			cornerAdaptionMargin = _LNDirectionalEdgeInsetsFromEdgeInsets(self, insets);
		}
		
		if(leadingFrame.origin.x < trailingFrame.origin.x)
		{
			//LTR
			leadingConstant = MAX(cornerAdaptionMargin.leading, leadingFrame.origin.x - 4);
			trailingConstant = MAX(cornerAdaptionMargin.trailing, self.bounds.size.width - trailingFrame.origin.x - trailingFrame.size.width - 4);
		}
		else
		{
			//RTL
			trailingConstant = MAX(cornerAdaptionMargin.trailing, trailingFrame.origin.x - 4);
			leadingConstant = MAX(cornerAdaptionMargin.leading, self.bounds.size.width - leadingFrame.origin.x - leadingFrame.size.width - 4);
		}
		
		topConstant = leadingFrame.origin.y - 4;
	}
	else
	{
		topConstant = MAX(12, layoutMargins.top);
		leadingConstant = layoutMargins.leading;
		trailingConstant = layoutMargins.trailing;
	}
#endif
	
	if(topConstant != _popupCloseButtonTopConstraint.constant || leadingConstant != _popupCloseButtonLeadingConstraint.constant || trailingConstant != _popupCloseButtonTrailingConstraint.constant)
	{
		_popupCloseButtonTopConstraint.constant = topConstant;
		_popupCloseButtonLeadingConstraint.constant = leadingConstant;
		_popupCloseButtonTrailingConstraint.constant = trailingConstant;
		
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

#if DEBUG

- (void)setFrame:(CGRect)frame
{
	if(CGRectEqualToRect(frame, super.frame))
	{
		return;
	}
	
	[super setFrame:frame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
}

#endif

- (void)safeAreaInsetsDidChange
{
	[super safeAreaInsetsDidChange];
	
	[self _repositionPopupCloseButtonAnimated:NO];
}

- (UIVisualEffect*)_currentEffect
{
	return self.translucent && _backgroundEffect != nil ? _backgroundEffect : _effectView.effect;
}

- (void)_applyBackgroundEffectWithContentViewController:(UIViewController*)vc popupBar:(LNPopupBar*)popupBar
{
	if(self.translucent == NO)
	{
		if(@available(iOS 26.1, *))
		{
			_effectView.effect = [UIColorEffect effectWithColor:UIColor.systemBackgroundColor];
		}
		else
		{
			//This is so glass effect get's really removed. 🤦‍♂️
			_effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
			_effectView.effect = nil;
			_effectView.backgroundColor = UIColor.systemBackgroundColor;
		}
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
			if(LNPopupEnvironmentHasGlass())
			{
				effectToUse = popupBar.contentView.effect;
			}
			else
			{
				effectToUse = popupBar.backgroundView.effect;
			}
		}
		
		if(@available(iOS 26.0, *))
		if(effectToUse.ln_isGlass)
		{
			_LNPopupGlassWrapperEffect* wrapper = [_LNPopupGlassWrapperEffect wrapperWithEffect:effectToUse];
			wrapper.disableForeground = YES;
			wrapper.disableInteractive = _backgroundEffect == nil;
			effectToUse = wrapper;
		}
		
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
