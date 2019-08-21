//
//  main.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@import ObjectiveC;

#if TARGET_OS_MACCATALYST
@interface NSObject (ZZZ) @end
@implementation NSObject (ZZZ)

+ (void)load
{
	Class cls = NSClassFromString(@"UIFocusRingManager");
	Method m1 = class_getClassMethod(cls, NSSelectorFromString(@"moveRingToFocusItem:"));
	Method m2 = class_getClassMethod(NSObject.class, @selector(__ln_moveRingToFocusItem:));
	method_exchangeImplementations(m1, m2);
}

+ (void)__ln_moveRingToFocusItem:(id)arg1
{
	
}

@end
#endif

int main(int argc, char * argv[]) {
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
