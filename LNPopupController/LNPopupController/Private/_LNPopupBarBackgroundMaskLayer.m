//
//  _LNPopupBarBackgroundMaskLayer.m
//  LNPopupController
//
//  Created by Leo Natan on 27/09/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

#import "_LNPopupBarBackgroundMaskLayer.h"

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

@implementation _LNPopupBarBackgroundMaskLayer
{
	CGGradientRef _gradient;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_gradient = _LNGradientCreateWithEaseFunction(_LNEaseInOutSine, UIColor.clearColor, UIColor.whiteColor);
	}
	
	return self;
}

- (void)dealloc
{
	CGGradientRelease(_gradient);
	_gradient = NULL;
}

- (void)drawInContext:(CGContextRef)ctx
{
	UIGraphicsPushContext(ctx);
	
	CGContextDrawLinearGradient(ctx, _gradient, CGPointMake(self.bounds.size.width / 2, 0), CGPointMake(self.bounds.size.width / 2, self.bounds.size.height), 0);
	
	if(self.wantsCutout)
	{
		CGContextSetBlendMode(ctx, kCGBlendModeClear);
		
		[UIColor.blackColor setFill];
		[[UIBezierPath bezierPathWithRoundedRect:self.floatingFrame cornerRadius:self.floatingCornerRadius] fill];
	}
	
	UIGraphicsPopContext();
}

@end
