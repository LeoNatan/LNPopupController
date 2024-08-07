//
//  LNPopupOpenTapGestureRecognizer.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
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
