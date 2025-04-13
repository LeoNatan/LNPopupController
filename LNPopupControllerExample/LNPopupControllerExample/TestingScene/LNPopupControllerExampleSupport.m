//
//  LNPopupControllerExampleSupport.m
//  LNPopupControllerExampleSupport
//
//  Created by Léo Natan on 2021-08-31.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupControllerExampleSupport.h"
#import "SettingKeys.h"

@interface DemoGalleryControllerTableView : UITableView @end
@implementation DemoGalleryControllerTableView

- (BOOL)canBecomeFocused
{
	return NO;
}

@end

@interface DemoNavigationController : UINavigationController @end
@implementation DemoNavigationController

- (UITabBarItem *)tabBarItem
{
	return self.viewControllers.firstObject.tabBarItem;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
	return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
	return self.topViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
	return self.topViewController;
}

@end

@interface DemoTabBarController : UITabBarController @end

@implementation DemoTabBarController
{
	NSMutableArray<UITab*>* _tabs API_AVAILABLE(ios(18.0));
	NSMutableArray<UITab*>* _sidebarTabs API_AVAILABLE(ios(18.0));
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
	return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
	return self.selectedViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
	return self.selectedViewController;
}

- (void)awakeFromNib
{
	if(@available(iOS 18.0, *))
	{
		_tabs = [NSMutableArray new];
		
		NSUInteger idx = 0;
		for(UIViewController* vc in self.viewControllers)
		{
			NSString* title = vc.tabBarItem.title;
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				title = [NSString stringWithFormat:@"%@ %@", title, @(idx + 1)];
			}
			
			UITab* tab = [[UITab alloc] initWithTitle:title image:[UIImage systemImageNamed:[NSString stringWithFormat:@"%@.square", @(idx + 1)]] identifier:[NSString stringWithFormat:@"%@_%@", vc.tabBarItem.title, @(idx)] viewControllerProvider:^UIViewController * _Nonnull(__kindof UITab * _Nonnull tab) {
				return vc;
			}];
			[_tabs addObject:tab];
			idx++;
		}
		
		_sidebarTabs = [NSMutableArray new];
		if([NSUserDefaults.settingDefaults boolForKey:PopupSettingTabBarHasSidebar])
		{
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				BOOL wantsNav = [_tabs.firstObject.viewController isKindOfClass:UINavigationController.class];
				
				for(NSUInteger jdx = 0; jdx <= 3; jdx++)
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
					
					UITab* sidebarOnly = [[UITab alloc] initWithTitle:[NSString stringWithFormat:@"Sidebar Tab %@", @(idx + 1)] image:[UIImage systemImageNamed:[NSString stringWithFormat:@"%@.square", @(idx + 1)]] identifier:[NSString stringWithFormat:@"sidebar_%@", @(idx)] viewControllerProvider:^UIViewController * _Nonnull(__kindof UITab * _Nonnull tab) {
						return vc;
					}];
					sidebarOnly.preferredPlacement = UITabPlacementSidebarOnly;
					[_sidebarTabs addObject:sidebarOnly];
					idx++;
				}
			}
		}
		
		self.viewControllers = nil;
	}
	
	[super awakeFromNib];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(@available(iOS 18.0, *))
	{
		[self updateTabsForTraitCollection:self.traitCollection];
	}
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		if(@available(iOS 18.0, *))
		{
			[self updateTabsForTraitCollection:newCollection];
		}
	} completion:nil];
}

- (void)updateTabsForTraitCollection:(UITraitCollection*)collection API_AVAILABLE(ios(18.0))
{
	if(collection.userInterfaceIdiom == UIUserInterfaceIdiomPad && collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && _sidebarTabs.count > 0 && self.splitViewController == nil)
	{
		self.tabs = [_tabs arrayByAddingObjectsFromArray:_sidebarTabs];
		self.compactTabIdentifiers = [_tabs valueForKey:@"identifier"];
		
		self.mode = UITabBarControllerModeTabSidebar;
		self.sidebar.preferredLayout = UITabBarControllerSidebarLayoutAutomatic;
		self.sidebar.hidden = YES;
		self.customizableViewControllers = @[];
	}
	else
	{
		self.tabs = _tabs;
		self.mode = UITabBarControllerModeTabBar;
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

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
}

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
