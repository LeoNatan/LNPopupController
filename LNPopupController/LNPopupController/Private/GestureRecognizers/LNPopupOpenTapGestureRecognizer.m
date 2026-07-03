//
//  LNPopupOpenTapGestureRecognizer.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupOpenTapGestureRecognizer.h"
#import "LNForwardingDelegate.h"
#import "LNPopupControllerImpl.h"

@interface LNPopupOpenTapGestureRecognizerForwardingDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>

@end

@implementation LNPopupOpenTapGestureRecognizerForwardingDelegate
{
	__weak LNPopupController* _popupController;
}

- (instancetype)initWithPopupController:(LNPopupController*)popupController
{
	self = [super init];
	if(self)
	{
		_popupController = popupController;
	}
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if([_popupController.popupBar.toolbar _isViewDescendantOfToolbarItem:touch.view])
	{
		return NO;
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
	}
	
	return YES;
}

@end

@implementation LNPopupOpenTapGestureRecognizer
{
	LNPopupOpenTapGestureRecognizerForwardingDelegate* _actualDelegate;
	__weak LNPopupController* _popupController;
}

- (instancetype)initWithPopupController:(LNPopupController*)popupController action:(SEL)action
{
	self = [super initWithTarget:popupController action:action];
	
	if(self)
	{
		_popupController = popupController;
		_actualDelegate = [[LNPopupOpenTapGestureRecognizerForwardingDelegate alloc] initWithPopupController:popupController];
		[super setDelegate:_actualDelegate];
	}
	
	return self;
}

- (id<UIGestureRecognizerDelegate>)delegate
{
	return _actualDelegate.forwardedDelegate;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
	_actualDelegate = [[LNPopupOpenTapGestureRecognizerForwardingDelegate alloc] initWithPopupController:_popupController];
	_actualDelegate.forwardedDelegate = delegate;
	[super setDelegate:_actualDelegate];
}

@end
