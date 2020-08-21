//
//  LNPopupInteractionPanGestureRecognizer.m
//  LNPopupController
//
//  Created by Leo Natan on 15/07/2017.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import "LNPopupInteractionPanGestureRecognizer.h"
#import "LNForwardingDelegate.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"

extern LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style);

@interface LNPopupInteractionPanGestureRecognizerDelegate : LNForwardingDelegate <UIGestureRecognizerDelegate>
@end

@implementation LNPopupInteractionPanGestureRecognizerDelegate
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_popupController.containerController.popupInteractionStyle);
	
	BOOL rv = resolvedStyle != LNPopupInteractionStyleNone;
	
	if(rv && [self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizerShouldBegin:gestureRecognizer];
	}
	
	return rv;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if([NSStringFromClass(otherGestureRecognizer.view.class) containsString:@"DropShadow"])
	{
		otherGestureRecognizer.state = UIGestureRecognizerStateFailed;
		return YES;
	}
	
	if([NSStringFromClass(otherGestureRecognizer.class) containsString:@"Reveal"])
	{
		return NO;
	}
	
	if(_popupController.popupControllerInternalState != LNPopupPresentationStateOpen)
	{
		if([self.forwardedDelegate respondsToSelector:_cmd])
		{
			return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
		}
		
		return YES;
	}
	
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	//This is to disable gesture recognizers in the superview while dragging the popup bar. This is mostly to fix issues when the bar is part of a scroll view scene, such as `UITableViewController` / `UITableView`.
	if([_popupController.popupBar.superview.gestureRecognizers containsObject:otherGestureRecognizer])
	{
		return YES;
	}
	
	if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]])
	{
		if(otherGestureRecognizer.view == gestureRecognizer.view)
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
	}
	
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if(_popupController.popupControllerInternalState != LNPopupPresentationStateOpen)
	{
		return NO;
	}
	
	if(_popupController.popupBar._applySwiftUILayoutFixes)
	{
		if([otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class])
		{
			return YES;
		}
		
		return NO;
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
	}
	
	if (@available(iOS 13.0, *))
	{
		if([otherGestureRecognizer.name hasPrefix:@"undointeraction"])
		{
			return NO;
		}
	}
	
	return YES;
}

@end

@implementation LNPopupInteractionPanGestureRecognizer
{
	LNPopupInteractionPanGestureRecognizerDelegate* _actualDelegate;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action popupController:(LNPopupController*)popupController
{
	self = [super initWithTarget:target action:action];
	
	if(self)
	{
		_actualDelegate = [[LNPopupInteractionPanGestureRecognizerDelegate alloc] initWithPopupController:popupController];
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
	_actualDelegate = [[LNPopupInteractionPanGestureRecognizerDelegate alloc] initWithPopupController:[_actualDelegate valueForKey:@"popupController"]];
	_actualDelegate.forwardedDelegate = delegate;
	[super setDelegate:_actualDelegate];
}

@end
