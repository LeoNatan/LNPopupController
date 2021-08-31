//
//  LNPopupControllerExampleSupport.m
//  LNPopupControllerExampleSupport
//
//  Created by Leo Natan on 8/20/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "LNPopupControllerExampleSupport.h"

@interface DemoGalleryControllerTableView : UITableView @end
@implementation DemoGalleryControllerTableView

- (BOOL)canBecomeFocused
{
	return NO;
}

@end

@interface DemoTabBarController : UITabBarController @end

@implementation DemoTabBarController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

@end

@interface DemoTabBar : UITabBar @end
@implementation DemoTabBar

- (void)setFrame:(CGRect)frame
{
	//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);
	
	[super setFrame:frame];
}

@end

@interface DemoToolbar : UIToolbar @end
@implementation DemoToolbar

- (void)setFrame:(CGRect)frame
{
	//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);
	
	[super setFrame:frame];
}

@end
