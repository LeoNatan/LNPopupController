//
//  LNPopupControllerExampleSupport.m
//  LNPopupControllerExampleSupport
//
//  Created by Léo Natan on 2021-08-31.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "LNPopupControllerExampleSupport.h"

#define WANTS_SIDEBAR_TABS 0

@interface DemoGalleryControllerTableView : UITableView @end
@implementation DemoGalleryControllerTableView

- (BOOL)canBecomeFocused
{
	return NO;
}

@end

@interface DemoTabBarController : UITabBarController @end

@implementation DemoTabBarController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(@available(iOS 18.0, *))
	{
		NSMutableArray<UITab*>* tabs = [NSMutableArray new];
		
		NSUInteger idx = 0;
		for(UIViewController* vc in self.viewControllers)
		{
			NSString* title = vc.tabBarItem.title;
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				title = [NSString stringWithFormat:@"%@ %@", title, @(idx + 1)];
			}
			
			UITab* tab = [[UITab alloc] initWithTitle:title image:vc.tabBarItem.image identifier:[NSString stringWithFormat:@"%@_%@", vc.tabBarItem.title, @(idx)] viewControllerProvider:^UIViewController * _Nonnull(__kindof UITab * _Nonnull tab) {
				return vc;
			}];
			[tabs addObject:tab];
			idx++;
		}
		
#if WANTS_SIDEBAR_TABS
		self.compactTabIdentifiers = [tabs valueForKey:@"identifier"];
		
		if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			BOOL wantsNav = [tabs.firstObject.viewController isKindOfClass:UINavigationController.class];
			
			for(NSUInteger jdx = 0; jdx < 3; jdx++)
			{
				UIViewController* vc;
				if(wantsNav)
				{
					vc = [self.storyboard instantiateViewControllerWithIdentifier:@"navDemoView"];
				}
				else
				{
					vc = [self.storyboard instantiateViewControllerWithIdentifier:@"demoVC"];
				}
				
				UITab* sidebarOnly = [[UITab alloc] initWithTitle:[NSString stringWithFormat:@"Sidebar Tab %@", @(idx + 1)] image:[UIImage systemImageNamed:[NSString stringWithFormat:@"%@.square.fill", @(idx + 1)]] identifier:[NSString stringWithFormat:@"sidebar_%@", @(idx)] viewControllerProvider:^UIViewController * _Nonnull(__kindof UITab * _Nonnull tab) {
					return vc;
				}];
				sidebarOnly.preferredPlacement = UITabPlacementSidebarOnly;
				[tabs addObject:sidebarOnly];
				idx++;
			}
		}
#endif
		
		self.tabs = tabs;
#if WANTS_SIDEBAR_TABS
		self.mode = UITabBarControllerModeTabSidebar;
		self.sidebar.preferredLayout = UITabBarControllerSidebarLayoutOverlap;
		self.sidebar.hidden = YES;
		self.customizableViewControllers = @[];
#else
		self.mode = UITabBarControllerModeTabBar;
#endif
	}
}

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
