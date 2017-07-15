//
//  LNForwardingDelegate.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 15/07/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "LNForwardingDelegate.h"

@implementation LNForwardingDelegate

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if([super respondsToSelector:aSelector])
	{
		return YES;
	}
	
	return [self.forwardedDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return self.forwardedDelegate;
}

@end
