//
//  LNPopupBarAppearanceChainProxy.m
//  LNPopupBarAppearanceChainProxy
//
//  Created by Leo Natan on 8/7/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "LNPopupBarAppearanceChainProxy.h"

@implementation LNPopupBarAppearanceChainProxy

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p chain: %@>", self.class, self, _chain];
}

- (instancetype)initWithAppearanceChain:(NSArray<UIBarAppearance*>*)chain
{
	self = [super init];
	
	if(self)
	{
		_chain = chain;
	}
	
	return self;
}

- (id)objectForKey:(NSString*)key
{
	__block id rv = nil;
	
	[_chain enumerateObjectsUsingBlock:^(UIBarAppearance * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		id candidateRV;
		if([obj respondsToSelector:NSSelectorFromString(key)])
		{
			candidateRV = [obj valueForKey:key];
			rv = candidateRV;
			*stop = YES;
		}
	}];
	
	return rv;
}

- (BOOL)boolForKey:(NSString*)key
{
	return [[self objectForKey:key] boolValue];
}

- (NSUInteger)unsignedIntegerForKey:(NSString*)key
{
	return [[self objectForKey:key] unsignedIntegerValue];
}

- (double)doubleForKey:(NSString*)key
{
	return [[self objectForKey:key] doubleValue];
}

- (void)setChainDelegate:(id<_LNPopupBarAppearanceDelegate>)delegate
{
	for (LNPopupBarAppearance* appearance in _chain) {
		if([appearance isKindOfClass:LNPopupBarAppearance.class])
		{
			appearance.delegate = delegate;
		}
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [LNPopupBarAppearance instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(void), 1) == 0)
	{
		//Ignore setters or methods
		return;
	}
	
	NSString* key = NSStringFromSelector(anInvocation.selector);
	
	if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(id), 1) == 0)
	{
		//id
		id rv = [self objectForKey:key];
		[anInvocation setReturnValue:&rv];
	}
	else if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(NSInteger), 1) == 0 || strncmp(anInvocation.methodSignature.methodReturnType, @encode(NSUInteger), 1) == 0)
	{
		//Integers
		NSUInteger rv = [self unsignedIntegerForKey:key];
		[anInvocation setReturnValue:&rv];
	}
	else if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(BOOL), 1) == 0)
	{
		//Boolean
		BOOL rv = [self boolForKey:key];
		[anInvocation setReturnValue:&rv];
	}
	else if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(double), 1) == 0)
	{
		//Double
		double rv = [self doubleForKey:key];
		[anInvocation setReturnValue:&rv];
	}
	else if(strncmp(anInvocation.methodSignature.methodReturnType, @encode(float), 1) == 0)
	{
		//Float
		float rv = [self doubleForKey:key];
		[anInvocation setReturnValue:&rv];
	}
	else
	{
		[NSException raise:NSInvalidArgumentException format:@"%@ is unsupported", NSStringFromSelector(anInvocation.selector)];
	}
}

@end
