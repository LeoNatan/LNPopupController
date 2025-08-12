//
//  _LNPopupBarBackgroundMaskView.mm
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-27.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupBarBackgroundMaskView.h"

//https://github.com/janselv/smooth-gradient

typedef CGFloat(*EASE_FUNC)(CGFloat, CGFloat, CGFloat, CGFloat);

__unused static CGFloat _LNEaseInQuad(CGFloat _t, CGFloat b, CGFloat c, CGFloat d)
{
	CGFloat t = _t/d;
	return c * t * t + b;
}

__unused static CGFloat _LNEaseInOutCubic(CGFloat _t, CGFloat b, CGFloat c, CGFloat d)
{
	CGFloat t = _t/(d/2);
	if(t < 1)
	{
		return c/2*t*t*t + b;
	}
	t -= 2;
	return c/2*(t*t*t + 2) + b;
}

static CGFloat _LNEaseInOutSine(CGFloat _t, CGFloat b, CGFloat c, CGFloat d)
{
	return -c/2 * (cos(M_PI*_t/d) - 1) + b;
}

static CGFloat _LNBezierCurve(CGFloat t, CGFloat p0, CGFloat p1)
{
	return (1.0 - t) * p0 + t * p1;
}

static UIColor* _LNInterpolateColor(CGFloat p, UIColor* start, UIColor* end)
{
	CGFloat r1, g1, b1, a1;
	CGFloat r2, g2, b2, a2;
	
	if(CGColorGetNumberOfComponents(start.CGColor) == 4)
	{
		[start getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
		
	}
	else
	{
		[start getWhite:&r1 alpha:&a1];
		b1 = r1;
		g1 = r1;
	}
	
	if(CGColorGetNumberOfComponents(end.CGColor) == 4)
	{
		[end getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
		
	}
	else
	{
		[end getWhite:&r2 alpha:&a2];
		b2 = r2;
		g2 = r2;
	}
	
	CGFloat r = _LNBezierCurve(p, r1, r2);
	CGFloat g = _LNBezierCurve(p, g1, g2);
	CGFloat b = _LNBezierCurve(p, b1, b2);
	CGFloat a = _LNBezierCurve(p, a1, a2);
	
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

static CGGradientRef _LNGradientCreateWithEaseFunction(EASE_FUNC func, UIColor* start, UIColor* end)
{
	const NSUInteger sampleCount = 24;
	CFMutableArrayRef colors = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
	CGFloat locations[sampleCount] = {0};
	
	for(NSUInteger idx = 0; idx < sampleCount; idx++)
	{
		CGFloat tt = idx / (CGFloat)sampleCount;
		CGFloat t = func(tt, 0.0, 1.0, 1.0);
		
		locations[idx] = tt;
		CFArrayAppendValue(colors, _LNInterpolateColor(t, start, end).CGColor);
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
	
	CGColorSpaceRelease(colorSpace);
	CFRelease(colors);
	
	return gradient;
}

@implementation _LNPopupBarBackgroundMaskView
{
	CGGradientRef _gradient;
	CADisplayLink* _displayLink;
	
	CGFloat _targetAlpha;
	CGFloat _currentAlpha;
	CGFloat _step;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_gradient = _LNGradientCreateWithEaseFunction(_LNEaseInOutSine, UIColor.clearColor, UIColor.whiteColor);
		self.backgroundColor = UIColor.clearColor;
	}
	
	return self;
}

- (void)dealloc
{
	CGGradientRelease(_gradient);
	_gradient = NULL;
}

- (void)setWantsCutout:(BOOL)wantsCutout animated:(BOOL)animated
{
	if(_wantsCutout == wantsCutout)
	{
		return;
	}
	
	_wantsCutout = wantsCutout;
	
	_targetAlpha = _wantsCutout ? 0.0 : 1.0;
	if(animated == NO || self.superview.alpha == 0.0 || self.superview.isHidden)
	{
		[_displayLink invalidate];
		_displayLink = nil;
		
		_currentAlpha = _targetAlpha;
		
		[self setNeedsDisplay];
	}
	else
	{
		_step = 0.02 * (_targetAlpha < _currentAlpha ? -1.0 : 1.0);
		
		if(_displayLink == nil)
		{
			_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_animationTick)];
			_displayLink.preferredFramesPerSecond = 30;
			[_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
		}
	}
}

- (void)_animationTick
{
	_currentAlpha += _step;
	if((_step < 0 && _currentAlpha < _targetAlpha) ||
	   (_step > 0 && _currentAlpha > _targetAlpha))
	{
		_currentAlpha = _targetAlpha;
		
		[_displayLink invalidate];
		_displayLink = nil;
	}
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIGraphicsPushContext(ctx);
	
	CGContextDrawLinearGradient(ctx, _gradient, CGPointMake(self.bounds.size.width / 2, 0), CGPointMake(self.bounds.size.width / 2, self.bounds.size.height), 0);
	
	CGContextSetBlendMode(ctx, kCGBlendModeDestinationIn);
	
	[[UIColor.blackColor colorWithAlphaComponent:_currentAlpha] setFill];
	[[UIBezierPath bezierPathWithRoundedRect:self.floatingFrame cornerRadius:self.floatingCornerRadius] fill];
	
	UIGraphicsPopContext();
}

@end
