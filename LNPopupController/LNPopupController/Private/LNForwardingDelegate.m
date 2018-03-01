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

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:self.forwardedDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature* ms = [super methodSignatureForSelector:aSelector];
	
	if(ms)
	{
		return ms;
	}
	
	return [self.forwardedDelegate methodSignatureForSelector:aSelector];
}

@end
