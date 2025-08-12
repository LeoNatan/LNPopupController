//
//  _LNPopupGlassUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 13/8/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupGlassUtils.h"

BOOL __LN_HAS_OS26_GLASS(void)
{
	static BOOL rv;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
		if(@available(iOS 26.0, *))
		{
			rv = ![[NSBundle.mainBundle objectForInfoDictionaryKey:@"UIDesignRequiresCompatibility"] boolValue];
		}
		else
		{
			rv = NO;
		}
#else
		rv = NO;
#endif
	});
	
	return rv;
}
