//
//  LNForwardingDelegate.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNForwardingDelegate.h"
#import "_LNPopupAddressInfo.h"

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

+ (BOOL)isCallerUIKit:(NSArray *)callStackReturnAddresses
{
	NSUInteger addr = [callStackReturnAddresses[1] unsignedIntegerValue];
	_LNPopupAddressInfo* addrInfo = [[_LNPopupAddressInfo alloc] initWithAddress:addr];
	
	return [addrInfo.image hasPrefix:@"UIKit"];
}

@end
