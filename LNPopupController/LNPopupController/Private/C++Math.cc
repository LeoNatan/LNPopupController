//
//  C++Math.c
//  C++Math
//
//  Created by Leo Natan on 8/6/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

extern "C" {
#include "C++Math.h"
}
#include <algorithm>

double _ln_clamp(double v, double lo, double hi)
{
	return std::clamp(v, lo, hi);
}
