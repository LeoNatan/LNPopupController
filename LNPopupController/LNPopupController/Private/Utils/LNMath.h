//
//  LNMath.h
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-06.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#ifndef C__Math_h
#define C__Math_h

#import <CoreFoundation/CoreFoundation.h>

CF_EXTERN_C_BEGIN

extern CGFloat _ln_clamp(CGFloat v, CGFloat lo, CGFloat hi);
extern CGFloat _ln_smoothstep(CGFloat a, CGFloat b, CGFloat x);
extern CGFloat _ln_lerp(CGFloat a, CGFloat b, CGFloat x);

CF_EXTERN_C_END

#endif /* C__Math_h */
