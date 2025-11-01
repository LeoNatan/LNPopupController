//
//  _LNPopupTitleLabelWrapper.m
//  LNPopupController
//
//  Created by Léo Natan on 25/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTitleLabelWrapper.h"
#include "LNMath.h"

@implementation _LNPopupTitleLabelWrapper
{
	double _percent;
	CGFloat _step;
	CGFloat _start;
	CGFloat _target;
	CADisplayLink* _displayLink;
}

+ (instancetype)wrapperForLabel:(UILabel*)wrapped
{
	_LNPopupTitleLabelWrapper* rv = [[_LNPopupTitleLabelWrapper alloc] initWithFrame:wrapped.bounds];
	wrapped.translatesAutoresizingMaskIntoConstraints = NO;
	
	rv.wrapped = wrapped;
	
	rv.translatesAutoresizingMaskIntoConstraints = YES;
	rv.autoresizingMask = UIViewAutoresizingNone;
	
	[rv addSubview:wrapped];
	
	rv.wrappedWidthConstraint = [wrapped.widthAnchor constraintEqualToConstant:rv.bounds.size.width];
	rv.wrappedWidthConstraint.constant = rv.bounds.size.width;
	
	[NSLayoutConstraint activateConstraints:@[
		[rv.leadingAnchor constraintEqualToAnchor:wrapped.leadingAnchor],
		[rv.heightAnchor constraintEqualToAnchor:wrapped.heightAnchor],
		rv.wrappedWidthConstraint
	]];
	
	return rv;
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	
	if(_wrappedWidthConstraint.constant == bounds.size.width || _target == bounds.size.width)
	{
		return;
	}
	
	[_displayLink invalidate];
	_displayLink = nil;
	
	if(UIView.inheritedAnimationDuration == 0.0 || UIView.areAnimationsEnabled == NO)
	{
		_wrappedWidthConstraint.constant = bounds.size.width;
		[self layoutSubviews];
	}
	else
	{
		_percent = 0.0;
		_start = _wrappedWidthConstraint.constant;
		_target = bounds.size.width;
		_step = 1 / (0.5 * UIView.inheritedAnimationDuration * 60);
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_tick)];
		if(@available(iOS 15.0, *))
		{
			_displayLink.preferredFrameRateRange = CAFrameRateRangeMake(60, 60, 60);
		}
		else
		{
			_displayLink.preferredFramesPerSecond = 60;
		}
		[_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
	}
}

- (void)_tick
{
	_percent += _step;
	
	_wrappedWidthConstraint.constant = _ln_lerp(_start, _target, _ln_smoothstep(0.0, 1.0, _percent));
	
	[self layoutSubviews];
	
	if(_percent > 1.0)
	{
		[_displayLink invalidate];
		_displayLink = nil;
		
		return;
	}
}

@end
