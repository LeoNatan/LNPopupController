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
	NSMutableDictionary<NSString*, NSMethodSignature*>* _forwardedDelegateLookupTable;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_forwardedDelegateLookupTable = [NSMutableDictionary new];
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
	
	//Use lookup table in all cases. If we've seen the signature before in the forwarded delegate, but it was released in the meantime, this will ensure we don't crash. If an unseen method is attempted, the runtime will go to respondsToSelector: first, and that will fail since the forwarded delegate is no more.
	NSMethodSignature* hit = [_forwardedDelegateLookupTable objectForKey:NSStringFromSelector(aSelector)];
	if(hit != nil)
	{
		return hit;
	}

	if([self.forwardedDelegate respondsToSelector:aSelector] == NO)
	{
		return nil;
	}
	
	if([self.forwardedDelegate respondsToSelector:@selector(methodSignatureForSelector:)])
	{
		NSMethodSignature* rv = [self.forwardedDelegate methodSignatureForSelector:aSelector];
		_forwardedDelegateLookupTable[NSStringFromSelector(aSelector)] = rv;
		return rv;
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
			_forwardedDelegateLookupTable[NSStringFromSelector(aSelector)] = rv;
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
