//
//  LNPopupBarExtras.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-04-07.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"

#ifndef LNPopupControllerEnforceStrictClean
static SEL _effectWithStyle_tintColor_invertAutomaticStyle_SEL;
static id(*_effectWithStyle_tintColor_invertAutomaticStyle)(id, SEL, NSUInteger, UIColor*, BOOL);

__attribute__((constructor))
static void __setupFunction(void)
{
	_effectWithStyle_tintColor_invertAutomaticStyle_SEL = NSSelectorFromString(LNPopupHiddenString("_effectWithStyle:tintColor:invertAutomaticStyle:"));
	Method m = class_getClassMethod(UIBlurEffect.class, _effectWithStyle_tintColor_invertAutomaticStyle_SEL);
	_effectWithStyle_tintColor_invertAutomaticStyle = reinterpret_cast<decltype(_effectWithStyle_tintColor_invertAutomaticStyle)>(method_getImplementation(m));
}
#endif

@implementation _LNPopupBarContentView @end

@implementation _LNPopupBarTitlesView @end

@implementation _LNPopupTitleLabelWrapper

+ (instancetype)wrapperForLabel:(UILabel*)wrapped
{
	_LNPopupTitleLabelWrapper* rv = [[_LNPopupTitleLabelWrapper alloc] initWithFrame:wrapped.frame];
	rv.wrapped = wrapped;
	
	rv.translatesAutoresizingMaskIntoConstraints = wrapped.translatesAutoresizingMaskIntoConstraints;
	[rv addSubview:wrapped];
	
	rv.wrappedWidthConstraint = [wrapped.widthAnchor constraintEqualToConstant:rv.bounds.size.width];
	
	[NSLayoutConstraint activateConstraints:@[
		[rv.leadingAnchor constraintEqualToAnchor:wrapped.leadingAnchor],
		[rv.heightAnchor constraintEqualToAnchor:wrapped.heightAnchor],
		rv->_wrappedWidthConstraint
	]];
	
	return rv;
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	
	if(_wrappedWidthConstraint.constant == bounds.size.width)
	{
		return;
	}
	
	if(UIView.inheritedAnimationDuration == 0.0)
	{
		_wrappedWidthConstraint.constant = bounds.size.width;
		[_wrapped layoutSubviews];
	}
	else
	{
		[UIView transitionWithView:_wrapped
						  duration:UIView.inheritedAnimationDuration / 2.0
						   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseOut
						animations:^{
			_wrappedWidthConstraint.constant = bounds.size.width;
			[_wrapped layoutSubviews];
		} completion:nil];
	}
}

@end

@implementation _LNPopupBarShadowView

#if DEBUG

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

#endif

@end

@implementation _LNPopupToolbar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* rv = [super hitTest:point withEvent:event];
	
	if(rv != nil && [rv isKindOfClass:UIControl.class] == NO && [NSStringFromClass(rv.class) containsString:@"BarItemView"] == NO)
	{
		rv = nil;
	}
	
	return rv;
}

- (void)layoutSubviews
{
	if(unavailable(iOS 13.0, *))
	{
		[UIView performWithoutAnimation:^{
			[super layoutSubviews];
			[(UIView*)[self valueForKey:LNPopupHiddenString("backgroundView")] setBackgroundColor:UIColor.clearColor];
		}];
	}
	
	//On iOS 11 and above reset the semantic content attribute to make sure it propagades to all subviews.
	[self setSemanticContentAttribute:self.semanticContentAttribute];
	
	[self._layoutDelegate _toolbarDidLayoutSubviews];
}

- (void)_deepSetSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute toView:(UIView*)view startingFromView:(UIView*)staringView;
{
	if(view == staringView)
	{
		[super setSemanticContentAttribute:semanticContentAttribute];
	}
	else
	{
		[view setSemanticContentAttribute:semanticContentAttribute];
	}
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:obj startingFromView:staringView];
	}];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute
{
	//On iOS 11, due to a bug in UIKit, the semantic content attribute must be propagaded recursively to all subviews, so that the system behaves correctly.
	[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:self startingFromView:self];
}

@end

@implementation LNNonMarqueeLabel

- (void)resetLabel {}
- (void)unpauseLabel {}
- (void)pauseLabel {}
- (void)restartLabel {}
- (void)shutdownLabel {}
- (BOOL)isPaused { return YES; }
- (NSTimeInterval)animationDuration { return 0.0; }

@synthesize rate=_rate, animationDelay=_animationDelay, synchronizedLabel=_synchronizedLabel, holdScrolling=_holdScrolling;

@end
