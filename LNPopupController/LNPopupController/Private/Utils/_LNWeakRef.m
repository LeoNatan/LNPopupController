//
//  _LNWeakRef.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNWeakRef.h"

@implementation _LNWeakRef

+ (instancetype)refWithObject:(id)object
{
	if(object == nil)
	{
		return nil;
	}
	
	_LNWeakRef* rv = [self new];
	rv->_object = object;
	
	return rv;
}

@end
