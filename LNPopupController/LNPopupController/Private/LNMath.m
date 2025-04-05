//
// 	LNMath.
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-11.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#include "LNMath.h"
#import <Foundation/Foundation.h>

double _ln_clamp(double v, double lo, double hi)
{
	return MIN(hi, MAX(v, lo));
}
