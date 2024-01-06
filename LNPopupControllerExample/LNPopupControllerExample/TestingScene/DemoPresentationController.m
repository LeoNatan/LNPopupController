//
//  DemoPresentationController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 06/01/2024.
//  Copyright © 2024 Leo Natan. All rights reserved.
//

#import "DemoPresentationController.h"

@interface DemoPresentationController ()

@property (nonatomic, setter=_setWantsFullScreen:) BOOL _wantsFullScreen;
@property (nonatomic, setter=_setAllowsInteractiveDismissWhenFullScreen:) BOOL _allowsInteractiveDismissWhenFullScreen;

@end

@implementation DemoPresentationController

@dynamic _wantsFullScreen, _allowsInteractiveDismissWhenFullScreen;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
	self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
	
	if(self)
	{
		self._wantsFullScreen = YES;
		self._allowsInteractiveDismissWhenFullScreen = NO;
		self.prefersGrabberVisible = NO;
	}
	
	return self;
}

@end
