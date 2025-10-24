//
// 	LNMath.
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-11.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#include "LNMath.h"
#import <Foundation/Foundation.h>

CGFloat _ln_clamp(CGFloat v, CGFloat lo, CGFloat hi)
{
	return MAX(lo, MIN(hi, v));
}

CGFloat _ln_smoothstep(CGFloat a, CGFloat b, CGFloat x)
{
	float t = _ln_clamp((x - a)/(b - a), 0, 1);
	return t * t * (3.0 - (2.0 * t));
}

CGFloat _ln_lerp(CGFloat a, CGFloat b, CGFloat x)
{
	x = _ln_clamp(x, 0.0, 1.0);
	return a * (1 - x) + b * x;
}
