//
//  LNEventQueueDemoSceneController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 24/12/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

#import "LNEventQueueDemoSceneController.h"
#import "RandomColors.h"

@import LNPopupController;

extern CGFloat UIAnimationDragCoefficient(void);

@implementation LNEventQueueDemoSceneController
{
	UIViewController* _contentController;
}

- (BOOL)_isSlow
{
	return UIAnimationDragCoefficient() != 1.0;
}

- (void)_presentBarAndOpen
{
	[self presentPopupBarWithContentViewController:_contentController openPopup:YES animated:YES completion:^{
		NSLog(@"Presented and Opened");
	}];
}

- (void)_presentBar
{
	[self presentPopupBarWithContentViewController:_contentController animated:YES completion:^{
		NSLog(@"Presented");
	}];
}

- (void)_dismissBar
{
	[self _dismissBarCompletionHandler:nil];
}

- (void)_dismissBarCompletionHandler:(dispatch_block_t)completion
{
	[self dismissPopupBarAnimated:YES completion:^{
		NSLog(@"Dismissed");
		
		if(completion)
		{
			completion();
		}
	}];
}

- (void)_openPopup
{
	[self openPopupAnimated:YES completion:^{
		NSLog(@"Opened");
	}];
}

- (void)_closePopup
{
	[self closePopupAnimated:YES completion:^{
		NSLog(@"Closed");
	}];
}

- (void)_afterShort:(dispatch_block_t)perform 
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), perform);
}

- (void)_afterSecond:(dispatch_block_t)perform
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), perform);
}

- (void)_start
{
	__weak __typeof(self) weakSelf = self;
	
	[self _firstContentController];
	[self _presentBar];
	[self _dismissBar];
	[self _presentBar];
	[self _dismissBar];
	[self _presentBar];
	[self _openPopup];
	[self _secondContentController];
	[self _presentBar];
	[self _dismissBar];
	[self _presentBarAndOpen];
	[self _closePopup];
	[self _openPopup];
	[self _dismissBarCompletionHandler:^{
		[weakSelf _afterSecond:^{
			[weakSelf _start];
		}];
	}];
}

- (void)_firstContentController
{
	_contentController = [UIViewController new];
	_contentController.view.backgroundColor = LNSeedAdaptiveColor(@"EventQueueInner");
	_contentController.popupItem.title = @"Title";
	_contentController.popupItem.subtitle = @"Subtitle";
	_contentController.popupItem.image = [UIImage imageNamed:@"genre18"];
}

- (void)_secondContentController
{
	_contentController = [UIViewController new];
	_contentController.view.backgroundColor = LNSeedAdaptiveColor(@"EventQueueInner2");
	_contentController.popupItem.title = @"Another Title";
	_contentController.popupItem.subtitle = @"Another Subtitle";
	_contentController.popupItem.image = [UIImage imageNamed:@"genre19"];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = LNSeedAdaptiveColor(@"EventQueue_");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _start];
}

@end
