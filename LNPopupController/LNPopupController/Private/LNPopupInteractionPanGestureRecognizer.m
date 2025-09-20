//
//  LNPopupInteractionPanGestureRecognizer.m
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupInteractionPanGestureRecognizer.h"
#import "LNForwardingDelegate.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "UIView+LNPopupSupportPrivate.h"

extern LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style);

@interface UIViewController ()

- (CGRect)_ln_interactionLimitRect;

@end

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
	
	if(rv && gestureRecognizer.view == _popupController.currentContentController.view && [_popupController.currentContentController respondsToSelector:@selector(_ln_interactionLimitRect)])
	{
		CGRect limit = [_popupController.currentContentController _ln_interactionLimitRect];
		CGPoint interactionPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
		
		if(CGRectContainsPoint(limit, interactionPoint) == NO)
		{
			return NO;
		}
	}
	
	if(rv && [self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizerShouldBegin:gestureRecognizer];
	}
	
	return rv;
}

//- (BOOL)_panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldTryToBeginHorizontallyWithEvent:(UIEvent*)event
//{
//	return NO;
//}

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
	
	if([NSStringFromClass(otherGestureRecognizer.view.class) containsString:@"SwiftUI"])
	{
		return YES;
	}
	
	//View hierarchy might add more and more views with gesture recognizers. Let's try to "import" them for our system.
	[_popupController _fixupGestureRecognizer:otherGestureRecognizer];
	
	if([otherGestureRecognizer.view isKindOfClass:UIScrollView.class] && [(UIScrollView*)otherGestureRecognizer.view _ln_hasVerticalContent] == NO && [(UIScrollView*)otherGestureRecognizer.view _ln_hasHorizontalContent] == NO)
	{
		return YES;
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
		if(@available(iOS 26.0, *))
		{
			return NO;
		}
		
		if(otherGestureRecognizer.view == gestureRecognizer.view)
		{
			return NO;
		}
		else
		{
			return [(UIScrollView*)otherGestureRecognizer.view _ln_hasVerticalContent] == YES;
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
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
	}
	
	if([otherGestureRecognizer.name hasPrefix:@"undointeraction"])
	{
		return NO;
	}
	
	if([otherGestureRecognizer.view isKindOfClass:UIScrollView.class] && [(UIScrollView*)otherGestureRecognizer.view _ln_hasVerticalContent] == NO)
	{
		return NO;
	}

	if([NSStringFromClass(otherGestureRecognizer.view.class) containsString:@"SwiftUI"])
	{
		return YES;
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
	if([LNForwardingDelegate isCallerUIKit:NSThread.callStackReturnAddresses])
	{
		return _actualDelegate;
	}
	
	return _actualDelegate.forwardedDelegate;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
	_actualDelegate = [[LNPopupInteractionPanGestureRecognizerDelegate alloc] initWithPopupController:[_actualDelegate valueForKey:@"popupController"]];
	_actualDelegate.forwardedDelegate = delegate;
	[super setDelegate:_actualDelegate];
}

@end
