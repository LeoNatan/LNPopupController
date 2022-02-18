//
// 	LNMath.
//  LNPopupController
//
//  Created by Leo Natan on 8/6/21.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#include "LNMath.h"
#import <Foundation/Foundation.h>

double _ln_clamp(double v, double lo, double hi)
{
	return MIN(hi, MAX(v, lo));
}
