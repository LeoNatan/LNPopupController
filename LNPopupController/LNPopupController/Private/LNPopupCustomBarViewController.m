//
//  LNPopupBarContentViewController.m
//  LNPopupController
//
//  Created by Leo Natan on 15/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import "LNPopupCustomBarViewController+Private.h"

@interface LNPopupCustomBarViewController ()

@end

@implementation LNPopupCustomBarViewController

@dynamic preferredContentSize;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if([self isMemberOfClass:[LNPopupCustomBarViewController class]])
	{
		[NSException raise:NSInternalInconsistencyException format:@"Do not initialize instances of LNPopupCustomBarViewController directly. You should subclass LNPopupCustomBarViewController and use instances of that subclass."];
		return nil;
	}
	
	return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.preservesSuperviewLayoutMargins = YES;
}

- (BOOL)wantsDefaultTapGestureRecognizer
{
	return YES;
}

- (BOOL)wantsDefaultPanGestureRecognizer
{
	return YES;
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize
{
	[super setPreferredContentSize:preferredContentSize];
}

- (void)popupItemDidUpdate
{
}

@end
