//
//  LNForwardingDelegate.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNForwardingDelegate.h"
#import "_LNPopupAddressInfo.h"
@import ObjectiveC;

@implementation LNForwardingDelegate
{
	NSMutableDictionary<NSString*, NSMethodSignature*>* _lookupTable;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_lookupTable = [NSMutableDictionary new];
	}
	
	return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if([super respondsToSelector:aSelector])
	{
		return YES;
	}
	
	BOOL rv = [self.forwardedDelegate respondsToSelector:aSelector];
	
#if DEBUG
	if(rv)
	{
		return YES;
	}
#endif
	
	return rv;
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
	
	if([self.forwardedDelegate respondsToSelector:aSelector] == NO)
	{
		return nil;
	}
	
	if([self.forwardedDelegate respondsToSelector:@selector(methodSignatureForSelector:)])
	{
		return [self.forwardedDelegate methodSignatureForSelector:aSelector];
	}
	
	NSMethodSignature* hit = [_lookupTable objectForKey:NSStringFromSelector(aSelector)];
	if(hit != nil)
	{
		return hit;
	}
	
	//Swift retarded bullshit
	IMP imp = [self.forwardedDelegate methodForSelector:aSelector];
	
	unsigned int methodCount = 0;
	Method* methods = class_copyMethodList(object_getClass(self.forwardedDelegate), &methodCount);
	if(methods == NULL)
	{
		return nil;
	}
	
	for(NSUInteger idx = 0; idx < methodCount; idx++)
	{
		Method m = methods[idx];
		if(method_getImplementation(m) == imp)
		{
			const char* encoding = method_getTypeEncoding(m);
			NSMethodSignature* rv = [NSMethodSignature signatureWithObjCTypes:encoding];
			_lookupTable[NSStringFromSelector(aSelector)] = rv;
			return rv;
		}
	}
	
	return nil;
}

+ (BOOL)isCallerUIKit:(NSArray *)callStackReturnAddresses
{
	NSUInteger addr = [callStackReturnAddresses[1] unsignedIntegerValue];
	_LNPopupAddressInfo* addrInfo = [[_LNPopupAddressInfo alloc] initWithAddress:addr];
	
	return [addrInfo.image hasPrefix:@"UIKit"];
}

@end
