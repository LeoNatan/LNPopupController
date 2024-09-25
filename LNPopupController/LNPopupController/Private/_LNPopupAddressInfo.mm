//
//  _LNPopupAddressInfo.mm
//  LNPopupController
//
//  Created by Léo Natan on 9/8/24.
//  Copyright © 2024 Léo Natan. All rights reserved.
//

#import "_LNPopupAddressInfo.h"
#include <dlfcn.h>
#include <cxxabi.h>

@implementation _LNPopupAddressInfo
{
	Dl_info _info;
}

@synthesize image, symbol, offset, address;

- (instancetype)initWithAddress:(NSUInteger)_address
{
	self = [super init];
	
	if(self)
	{
		address = _address;
		dladdr((void*)address, &_info);
	}
	
	return self;
}

- (NSString *)image
{
	if(_info.dli_fname != NULL)
	{
		NSString* potentialImage = [NSString stringWithUTF8String:_info.dli_fname];
		
		if([potentialImage containsString:@"/"])
		{
			return potentialImage.lastPathComponent;
		}
	}
	
	return @"???";
}

- (NSString *)symbol
{
	if(_info.dli_sname != NULL)
	{
		return [NSString stringWithUTF8String:_info.dli_sname];
	}
	else if(_info.dli_fname != NULL)
	{
		return self.image;
	}
	
	return [NSString stringWithFormat:@"0x%1lx", (unsigned long)_info.dli_saddr];
}

- (NSUInteger)offset
{
	NSString* str = nil;
	if(_info.dli_sname != NULL && (str = [NSString stringWithUTF8String:_info.dli_sname]) != nil)
	{
		return address - (NSUInteger)_info.dli_saddr;
	}
	else if(_info.dli_fname != NULL && (str = [NSString stringWithUTF8String:_info.dli_fname]) != nil)
	{
		return address - (NSUInteger)_info.dli_fbase;
	}
	
	return address - (NSUInteger)_info.dli_saddr;
}

- (NSString*)description
{
#if __LP64__
	return [NSString stringWithFormat:@"%-35s 0x%016llx %@ + %ld", self.image.UTF8String, (uint64_t)address, self.symbol, self.offset];
#else
	return [NSString stringWithFormat:@"%-35s 0x%08lx %@ + %d", self.image.UTF8String, (unsigned long)address, self.symbol, self.offset];
#endif
}

@end
