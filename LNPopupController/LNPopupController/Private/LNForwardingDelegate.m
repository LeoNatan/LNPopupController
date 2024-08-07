//
//  LNForwardingDelegate.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
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
