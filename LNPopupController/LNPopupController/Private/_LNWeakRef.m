//
//  _LNWeakRef.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "_LNWeakRef.h"

@implementation _LNWeakRef

+ (instancetype)refWithObject:(id)object
{
	_LNWeakRef* rv = [self new];
	rv.object = object;
	
	return rv;
}

@end
