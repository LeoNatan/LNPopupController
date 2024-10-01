//
//  LNSplitViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-10-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "LNSplitViewController.h"

@implementation LNSplitViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.minimumPrimaryColumnWidth = 400;
	self.maximumPrimaryColumnWidth = 400;
	
	if(self.style == UISplitViewControllerStyleTripleColumn)
	{
		self.minimumSupplementaryColumnWidth = 400;
		self.maximumSupplementaryColumnWidth = 400;
	}
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	if(newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
	{
		[self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
	}
}

@end

@implementation LNSplitViewControllerPrimaryPopup @end
@implementation LNSplitViewControllerSecondaryPopup @end
@implementation LNSplitViewControllerGlobalPopup @end
