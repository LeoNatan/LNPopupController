//
//  NSObject+XcodeBugs.m
//  LNPopupControllerExample
//
//  Created by Leo Natan (Wix) on 7/11/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import "NSObject+XcodeBugs.h"

@implementation NSObject (XcodeBugs)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	//Ignore Xcode 11 IB bugs on iOS 10 🤦‍♂️
}

@end
