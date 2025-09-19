//
//  UIScreen+LNPopupSupportPrivate.mm
//  LNPopupController
//
//  Created by Léo Natan on 19/9/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "UIScreen+LNPopupSupportPrivate.h"
#import "_LNPopupBase64Utils.hh"

@implementation UIScreen (LNPopupSupportPrivate)

- (CGFloat)_ln_cornerRadius
{
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* const key = LNPopupHiddenString("_displayCornerRadius");
	if([self respondsToSelector:NSSelectorFromString(key)])
	{
		return [[self valueForKey:key] doubleValue];
	}
#endif
	
	return 0;
}

@end
