//
//  SplitViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan (Wix) on 8/21/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import "SplitViewController.h"

@interface SplitViewController ()

@end

@implementation SplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

@end

@interface SceneSplitViewController : UISplitViewController <UISplitViewControllerDelegate> @end
@implementation SceneSplitViewController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
	}
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
	if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		return YES;
	}
	
	return splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

@end
