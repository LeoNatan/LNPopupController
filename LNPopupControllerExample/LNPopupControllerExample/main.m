//
//  main.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void HandleExceptions(NSException *exception)
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:exception.name message:exception.reason preferredStyle:UIAlertControllerStyleAlert];
	
	[UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
	
	[[NSRunLoop currentRunLoop] runUntilDate:NSDate.distantFuture];
}

int main(int argc, char * argv[]) {
	@autoreleasepool {
		NSSetUncaughtExceptionHandler(&HandleExceptions);
		
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
