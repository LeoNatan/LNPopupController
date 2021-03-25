//
//  LNPopupOpenTapGestureRecognizer.m
//  LNPopupController
//
//  Created by Leo Natan on 15/07/2017.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import "LNPopupOpenTapGestureRecognizer.h"
#import "LNForwardingDelegate.h"

@interface LNPopupOpenTapGestureRecognizerForwardingDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>

@end

@implementation LNPopupOpenTapGestureRecognizerForwardingDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if([touch.view isKindOfClass:[UIControl class]])
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
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	
	if(self)
	{
		_actualDelegate = [LNPopupOpenTapGestureRecognizerForwardingDelegate new];
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
	_actualDelegate = [LNPopupOpenTapGestureRecognizerForwardingDelegate new];
	_actualDelegate.forwardedDelegate = delegate;
	[super setDelegate:_actualDelegate];
}

@end
