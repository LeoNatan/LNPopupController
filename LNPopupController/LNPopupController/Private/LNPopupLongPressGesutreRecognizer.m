//
//  LNPopupLongPressGesutreRecognizer.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 15/07/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "LNPopupLongPressGesutreRecognizer.h"
#import "LNForwardingDelegate.h"

@interface LNPopupControllerLongPressGestureDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>
@end

@implementation LNPopupControllerLongPressGestureDelegate

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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
	}
	
	return YES;
}

@end


@implementation LNPopupLongPressGesutreRecognizer
{
	LNPopupControllerLongPressGestureDelegate* _actualDelegate;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	
	if(self)
	{
		_actualDelegate = [LNPopupControllerLongPressGestureDelegate new];
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
	_actualDelegate = [LNPopupControllerLongPressGestureDelegate new];
	_actualDelegate.forwardedDelegate = delegate;
	[super setDelegate:_actualDelegate];
}

@end
