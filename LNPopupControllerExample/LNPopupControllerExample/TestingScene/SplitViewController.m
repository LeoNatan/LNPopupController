//
//  SplitViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/21/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import "SplitViewController.h"

@implementation UIViewController (LNSplitViewController)

- (LNSplitViewController *)ln_splitViewController
{
	return (id)self.splitViewController;
}

@end

@implementation LNSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if(@available(iOS 14.0, *))
	{
		self.minimumPrimaryColumnWidth = 400;
		self.maximumPrimaryColumnWidth = 400;
		
		if(self.style == UISplitViewControllerStyleTripleColumn)
		{
			self.minimumSupplementaryColumnWidth = 400;
			self.maximumSupplementaryColumnWidth = 400;
		}
	}
	else
	{
		self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
	}
}

- (nullable __kindof UIViewController *)viewControllerForColumn:(LNSplitViewControllerColumn)column
{
	if(@available(iOS 14.0, *))
	{
		return [super viewControllerForColumn:(NSInteger)column];
	}
	
	return column == LNSplitViewControllerColumnSecondary ? self.viewControllers.lastObject : self.viewControllers.firstObject;
}

@end

@implementation SplitViewControllerPrimaryPopup @end
@implementation SplitViewControllerSecondaryPopup @end
@implementation SplitViewControllerGlobalPopup @end
