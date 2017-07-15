//
//  LNPopupOpenTapGesutreRecognizer.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 15/07/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "LNPopupOpenTapGesutreRecognizer.h"
#import "LNForwardingDelegate.h"

@interface LNPopupOpenTapGesutreRecognizerForwardingDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>

@end

@implementation LNPopupOpenTapGesutreRecognizerForwardingDelegate

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

@implementation LNPopupOpenTapGesutreRecognizer
{
	LNPopupOpenTapGesutreRecognizerForwardingDelegate* _actualDelegate;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	
	if(self)
	{
		_actualDelegate = [LNPopupOpenTapGesutreRecognizerForwardingDelegate new];
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
	_actualDelegate.forwardedDelegate = delegate;
}

@end
