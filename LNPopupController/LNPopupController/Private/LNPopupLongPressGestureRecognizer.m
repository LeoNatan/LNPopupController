//
//  LNPopupLongPressGestureRecognizer.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupLongPressGestureRecognizer.h"
#import "LNForwardingDelegate.h"

@interface LNPopupControllerLongPressGestureDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>
@end

@implementation LNPopupControllerLongPressGestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
#if ! TARGET_OS_MACCATALYST
	if (@available(iOS 13.4, *))
	{
		if(touch.type == UITouchTypeIndirectPointer)
		{
			return NO;
		}
	}
#endif
	
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if([NSStringFromClass(otherGestureRecognizer.class) containsString:@"SwiftUI"])
	{
		return YES;
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
	}
	
	return NO;
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


@implementation LNPopupLongPressGestureRecognizer
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
