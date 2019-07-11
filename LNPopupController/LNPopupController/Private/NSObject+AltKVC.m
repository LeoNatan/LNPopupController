//
//  NSObject+AltKVC.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 6/8/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import "NSObject+AltKVC.h"
@import ObjectiveC;

@implementation NSObject (AltKVC)

- (id)__ln_valueForKey:(NSString *)key
{
	unsigned int count = 0;
	Ivar* ivarList = class_copyIvarList(self.class, &count);
	id rv = nil;
	
	NSString* uKey = [NSString stringWithFormat:@"_%@", key];
	
	for(NSUInteger idx = 0; idx < count; idx++)
	{		
		NSString* name = [NSString stringWithUTF8String:ivar_getName(ivarList[idx])];
		
		if([name isEqualToString:key] || [name isEqualToString:uKey])
		{
			rv = object_getIvar(self, ivarList[idx]);
			break;
		}
	}
	
	if(ivarList != NULL)
	{
		free(ivarList);
	}
	
	return rv;
}

@end
