//
//  LNPopupDebug.m
//  LNPopupController
//
//  Created by Léo Natan on 4/4/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "LNPopupDebug.h"

#ifdef DEBUG
NSUserDefaults* __LNDebugUserDefaults(void)
{
	static NSUserDefaults* rv = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SEL sel = NSSelectorFromString(@"settingDefaults");
		if([NSUserDefaults respondsToSelector:sel])
		{
			rv = [NSUserDefaults valueForKey:@"settingDefaults"];
		}
		else
		{
			rv = NSUserDefaults.standardUserDefaults;
		}
	});
	
	return rv;
}
#endif
