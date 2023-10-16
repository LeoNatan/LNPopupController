//
//  LNPopupController.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupController.h"
#import "LNPopupCloseButton+Private.h"
#import "LNPopupItem+Private.h"
#import "LNPopupOpenTapGestureRecognizer.h"
#import "LNPopupLongPressGestureRecognizer.h"
#import "LNPopupInteractionPanGestureRecognizer.h"
#import "_LNPopupSwizzlingUtils.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "LNPopupCustomBarViewController+Private.h"
@import ObjectiveC;
@import os.log;

#ifndef LNPopupControllerEnforceStrictClean
//visualProvider.toolbarIsSmall
static NSString* const _vPTIS = @"dmlzdWFsUHJvdmlkZXIudG9vbGJhcklzU21hbGw=";
#endif

#if TARGET_OS_MACCATALYST
@import AppKit;
#endif

const NSUInteger _LNPopupPresentationStateTransitioning = 2;

static const CGFloat LNPopupBarGestureHeightPercentThreshold = 0.2;
static const CGFloat LNPopupBarDeveloperPanGestureThreshold = 0;

LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style)
{
	LNPopupInteractionStyle rv = style;
	if(rv == LNPopupInteractionStyleDefault)
	{
#if TARGET_OS_MACCATALYST
		rv = LNPopupInteractionStyleScroll;
#else
		rv = LNPopupInteractionStyleSnap;
#endif
	}
	return rv;
}

OS_ALWAYS_INLINE
static BOOL _LNCallDelegateObjectObjectBool(UIViewController* controller, UIViewController* content, SEL selector, BOOL animated)
{
	if([controller.popupPresentationDelegate respondsToSelector:selector])
	{
		void (*msgSendObjectObjectBool)(id, SEL, id, id, BOOL) = (void*)objc_msgSend;
		msgSendObjectObjectBool(controller.popupPresentationDelegate, selector, controller, content, animated);
		return YES;
	}
	return NO;
}

OS_ALWAYS_INLINE
static BOOL _LNCallDelegateObjectBool(UIViewController* controller, SEL selector, BOOL animated)
{
	if([controller.popupPresentationDelegate respondsToSelector:selector])
	{
		void (*msgSendObjectBool)(id, SEL, id, BOOL) = (void*)objc_msgSend;
		msgSendObjectBool(controller.popupPresentationDelegate, selector, controller, animated);
		return YES;
	}
	return NO;
}

#pragma mark Popup Controller

@interface LNPopupController () <_LNPopupItemDelegate, _LNPopupBarDelegate> @end

@implementation LNPopupController
{
	__weak LNPopupItem* _currentPopupItem;
	
	BOOL _dismissGestureStarted;
	CGFloat _dismissStartingOffset;
	CGFloat _dismissScrollViewStartingContentOffset;
	LNPopupPresentationState _stateBeforeDismissStarted;
	
	BOOL _dismissalOverride;
	
	//Cached for performance during panning the popup content
	CGRect _cachedDefaultFrame;
	UIEdgeInsets _cachedInsets;
	CGRect _cachedOpenPopupFrame;
	
	CGFloat _statusBarThresholdDir;
	
	CGFloat _bottomBarOffset;
	
	CADisplayLink* _displayLinkFor120Hz;
}

- (instancetype)initWithContainerViewController:(__kindof UIViewController*)containerController
{
	self = [super init];
	
	if(self)
	{
		_containerController = containerController;
		
		_popupControllerInternalState = LNPopupPresentationStateBarHidden;
		_popupControllerTargetState = LNPopupPresentationStateBarHidden;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	}
	
	return self;
}

- (CGRect)_frameForOpenPopupBar
{
//	CGRect defaultFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
	return CGRectMake(0, - self.popupBar.frame.size.height, _containerController.view.bounds.size.width, self.popupBar.frame.size.height);
}

- (CGRect)_frameForClosedPopupBar
{
	CGRect defaultFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
	UIEdgeInsets insets = [_containerController insetsForBottomDockingView];
	return CGRectMake(0, defaultFrame.origin.y - self.popupBar.frame.size.height - insets.bottom, _containerController.view.bounds.size.width, self.popupBar.frame.size.height);
}

- (void)_repositionPopupContentMovingBottomBar:(BOOL)bottomBar animated:(BOOL)animated
{
	CGFloat percent = [self _percentFromPopupBarForBottomBarDisplacement];
	
	CGFloat barHeight = (_bottomBar.isHidden ? 0 : _bottomBar.bounds.size.height) + _cachedInsets.bottom;
	CGFloat heightForContent = _containerController.view.bounds.size.height - (1.0 - percent) * barHeight;
	
	if(bottomBar)
	{
		CGRect bottomBarFrame = _cachedDefaultFrame;
		bottomBarFrame.origin.y -= _cachedInsets.bottom;
		bottomBarFrame.origin.y += (percent * (bottomBarFrame.size.height + _cachedInsets.bottom));
		_bottomBar.frame = bottomBarFrame;
	}
	
	[self.popupBar layoutIfNeeded];
	self.popupBar.contentView.contentView.alpha = 1.0 - percent;
	
	CGRect contentFrame = _containerController.view.bounds;
	contentFrame.origin.x = self.popupBar.frame.origin.x;
	contentFrame.origin.y = self.popupBar.frame.origin.y + self.popupBar.frame.size.height;
	
	CGFloat fractionalHeight = MAX(heightForContent - (self.popupBar.frame.origin.y + self.popupBar.frame.size.height), 0);
	contentFrame.size.height = ceil(fractionalHeight);
	
	self.popupContentView.frame = contentFrame;
	
	_containerController.popupContentViewController.view.frame = _containerController.view.bounds;
	
	[self.popupContentView _repositionPopupCloseButtonAnimated:animated];
}

static CGFloat __saturate(CGFloat x)
{
	return MAX(0, MIN(1, x));
}

static CGFloat __smoothstep(CGFloat a, CGFloat b, CGFloat x)
{
	float t = __saturate((x - a)/(b - a));
	return t * t * (3.0 - (2.0 * t));
}

- (CGFloat)_percentFromPopupBar
{
	return 1 - (CGRectGetMaxY(self.popupBar.frame) / (_cachedDefaultFrame.origin.y - _cachedInsets.bottom));
}

- (CGFloat)_percentFromPopupBarForBottomBarDisplacement
{
	CGFloat percent = [self _percentFromPopupBar];
	
	return __smoothstep(0.00, 1.0, percent);
}

- (void)_setContentToState:(LNPopupPresentationState)state
{
	[self _setContentToState:state animated:YES];
}

- (void)_setContentToState:(LNPopupPresentationState)state animated:(BOOL)animated
{
	CGRect targetFrame = self.popupBar.frame;
	if(state == LNPopupPresentationStateOpen)
	{
		targetFrame = [self _frameForOpenPopupBar];
	}
	else if(state == LNPopupPresentationStateBarPresented || (state == _LNPopupPresentationStateTransitioning && (_popupControllerTargetState == LNPopupPresentationStateBarHidden || _popupControllerTargetState == LNPopupPresentationStateBarPresented)))
	{
		targetFrame = [self _frameForClosedPopupBar];
	}
	else
	{
		CGRect closedFrame = [self _frameForClosedPopupBar];
		targetFrame.size = closedFrame.size;
	}
	
	_cachedDefaultFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
	_cachedInsets = [_containerController insetsForBottomDockingView];
	
	self.popupBar.frame = targetFrame;
	
	if(state != _LNPopupPresentationStateTransitioning)
	{
		[_containerController setNeedsStatusBarAppearanceUpdate];
	}
	
	[self _repositionPopupContentMovingBottomBar:_containerController._ignoringLayoutDuringTransition == NO animated:animated];
}

- (void)_addContentControllerSubview:(UIViewController*)currentContentController
{
	if(currentContentController == nil)
	{
		return;
	}
	
	[currentContentController viewWillMoveToPopupContainerContentView:self.popupContentView];
	[self.popupContentView setControllerOverrideUserInterfaceStyle:currentContentController.overrideUserInterfaceStyle];
	currentContentController.view.translatesAutoresizingMaskIntoConstraints = YES;
	currentContentController.view.autoresizingMask = UIViewAutoresizingNone;
	currentContentController.view.frame = self.popupContentView.contentView.bounds;
	[self.popupContentView.contentView addSubview:currentContentController.view];
	[currentContentController viewDidMoveToPopupContainerContentView:self.popupContentView];
}

- (void)_removeContentControllerFromContentView:(UIViewController*)currentContentController
{
	if(currentContentController == nil)
	{
		return;
	}
	
	[currentContentController viewWillMoveToPopupContainerContentView:nil];
	[currentContentController.view removeFromSuperview];
	[currentContentController viewDidMoveToPopupContainerContentView:nil];
}

- (void)_transitionToState:(LNPopupPresentationState)state notifyDelegate:(BOOL)notifyDelegate animated:(BOOL)animated useSpringAnimation:(BOOL)spring allowPopupBarAlphaModification:(BOOL)allowBarAlpha completion:(void(^)(void))completion transitionOriginatedByUser:(BOOL)transitionOriginatedByUser
{
	if(transitionOriginatedByUser == YES && _popupControllerInternalState == _LNPopupPresentationStateTransitioning)
	{
		NSLog(@"LNPopupController: The popup controller is already in transition. Will ignore this transition request.");
		return;
	}
	
	if(state == _popupControllerInternalState)
	{
		return;
	}
	
	if(_popupControllerInternalState == LNPopupPresentationStateBarPresented)
	{
		[_currentContentController beginAppearanceTransition:YES animated:NO];
		[UIView performWithoutAnimation:^{
			if(notifyDelegate == YES && state == _LNPopupPresentationStateTransitioning)
			{
				_popupContentView.hidden = NO;
				[_currentContentController _userFacing_viewWillAppear:NO];
			}
//			_currentContentController.view.frame = _containerController.view.bounds;
			
			[self.popupContentView _applyBackgroundEffectWithContentViewController:_currentContentController barEffect:(id)self.popupBar.backgroundView.effect];
			
			self.popupContentView.currentPopupContentViewController = _currentContentController;
			[self.popupContentView.contentView sendSubviewToBack:_currentContentController.view];
			
			[self.popupContentView.contentView setNeedsLayout];
			[self.popupContentView.contentView layoutIfNeeded];
			if(notifyDelegate == YES && state == _LNPopupPresentationStateTransitioning)
			{
				[_currentContentController _userFacing_viewDidAppear:NO];
			}
		}];
		[_currentContentController endAppearanceTransition];
	};
	
	BOOL shouldNotifyDelegateWillClose = NO;
	if(_popupControllerPublicState == LNPopupPresentationStateOpen && state == LNPopupPresentationStateBarPresented)
	{
		[_currentContentController.view endEditing:YES];
		
		if(notifyDelegate)
		{
			shouldNotifyDelegateWillClose = YES;
		}
	}
	
	BOOL shouldNotifyDelegateWillOpen = NO;
	if(notifyDelegate && _popupControllerPublicState == LNPopupPresentationStateBarPresented && state == LNPopupPresentationStateOpen)
	{
		shouldNotifyDelegateWillOpen = YES;
	}
	
	if(state != _LNPopupPresentationStateTransitioning)
	{
		[self _start120HzHack];
	}
	
	__unused LNPopupPresentationState stateAtStart = _popupControllerInternalState;
	_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
	_popupControllerTargetState = state;
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	void (^updatePopupBarAlpha)(void) = ^ {
		if(allowBarAlpha && resolvedStyle == LNPopupInteractionStyleSnap)
		{
			CGRect frame = self.popupBar.frame;
			frame.size.height = state < _LNPopupPresentationStateTransitioning ? _LNPopupBarHeightForPopupBar(self.popupBar) : 0.0;
			self.popupBar.frame = frame;
			self.popupBar.alpha = state < _LNPopupPresentationStateTransitioning;
		}
		else
		{
			self.popupBar.alpha = 1.0;
		}
	};
	
	void (^animationBlock)(void) = ^
	{
		if(shouldNotifyDelegateWillOpen == YES)
		{
			if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:willOpenPopupWithContentController:animated:), animated) == NO)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
			}
		}
		
		if(shouldNotifyDelegateWillClose == YES)
		{
			if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:willClosePopupWithContentController:animated:), animated) == NO)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillClosePopup:animated:), animated);
			}
		}
		
		if(state != _LNPopupPresentationStateTransitioning)
		{
			updatePopupBarAlpha();
		}
		
		if(state == LNPopupPresentationStateOpen && stateAtStart == LNPopupPresentationStateBarPresented)
		{
			_popupContentView.hidden = NO;
			[_currentContentController _userFacing_viewWillAppear:animated];
		}
		
		if(state == LNPopupPresentationStateBarPresented)
		{
			[_currentContentController beginAppearanceTransition:NO animated:animated];
			[_currentContentController _userFacing_viewWillDisappear:animated];
		}
		
		[self _setContentToState:state animated:animated];
		[_containerController.view layoutIfNeeded];
	};
	
	void (^completionBlock)(BOOL) = ^(BOOL finished)
	{
		if(state != _LNPopupPresentationStateTransitioning)
		{
			updatePopupBarAlpha();
		}
		
		if(state == LNPopupPresentationStateBarPresented)
		{
			[_currentContentController endAppearanceTransition];
			[_currentContentController _userFacing_viewDidDisappear:animated];
			
			_popupContentView.hidden = YES;
			
			[self _cleanupGestureRecognizersForController:_currentContentController];
			
			[_currentContentController.viewForPopupInteractionGestureRecognizer removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			
			[self.popupBar _setTitleViewMarqueesPaused:NO];
			
			_popupContentView.accessibilityViewIsModal = NO;
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		}
		
		_popupControllerInternalState = state;
		if(state != _LNPopupPresentationStateTransitioning)
		{
			[_containerController _ln_setPopupPresentationState:state];
			[self _end120HzHack];
		}
		
		if(state == LNPopupPresentationStateBarPresented && _popupControllerPublicState == LNPopupPresentationStateBarPresented)
		{
			if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:didClosePopupWithContentController:animated:), animated) == NO)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidClosePopup:animated:), animated);
			}
		}
		
		if(state == LNPopupPresentationStateOpen)
		{
			if(stateAtStart == LNPopupPresentationStateBarPresented)
			{
				[_currentContentController _userFacing_viewDidAppear:animated];
			}
			
			[self.popupBar _setTitleViewMarqueesPaused:YES];
			
			[self.popupBar removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[_currentContentController.viewForPopupInteractionGestureRecognizer addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[self _fixupGestureRecognizersForController:_currentContentController];
			
			_popupContentView.accessibilityViewIsModal = YES;
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, _popupContentView.popupCloseButton);
			
			if(_popupControllerPublicState == LNPopupPresentationStateOpen)
			{
				if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:didOpenPopupWithContentController:animated:), animated) == NO)
				{
					_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidOpenPopup:animated:), animated);
				}
			}
		}
		
		if(completion)
		{
			completion();
		}
	};
	
	if(animated == NO)
	{
		[UIView performWithoutAnimation:^{
			animationBlock();
			completionBlock(YES);
			[_currentContentController.view layoutIfNeeded];
		}];
		return;
	}
	
	[UIView animateWithDuration:resolvedStyle == LNPopupInteractionStyleSnap ? 0.4 : 0.5 delay:0.0 usingSpringWithDamping:spring ? 0.85 : 1.0 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:animationBlock completion:completionBlock];
}

- (void)_popupBarLongPressGestureRecognized:(UILongPressGestureRecognizer*)lpgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultHighlightGestureRecognizer == NO)
	{
		return;
	}
	
	switch (lpgr.state) {
		case UIGestureRecognizerStateBegan:
			[self.popupBar setHighlighted:YES animated:YES];
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			[self.popupBar setHighlighted:NO animated:YES];
			break;
		default:
			break;
	}
}

- (void)_popupBarTapGestureRecognized:(UITapGestureRecognizer*)tgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultTapGestureRecognizer == NO)
	{
		return;
	}
	
	switch (tgr.state) {
		case UIGestureRecognizerStateEnded:
		{
			[_containerController.view setNeedsLayout];
			[_containerController.view layoutIfNeeded];
			[self _transitionToState:LNPopupPresentationStateOpen notifyDelegate:YES animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
		}	break;
		default:
			break;
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_began:(UIPanGestureRecognizer*)pgr
{
#if TARGET_OS_MACCATALYST
	UIEvent* event = self.popupBar.window._ln_currentEvent;
	if(event.type == 22 /*NSEventTypeScrollWheel*/)
	{
		return;
	}
	
	if(event != nil && event.type == 22)
	{
		return;
	}
#endif
	
	[self _start120HzHack];
	
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultPanGestureRecognizer == NO)
	{
		return;
	}
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	if(resolvedStyle == LNPopupInteractionStyleNone)
	{
		//Ignore all events.
		return;
	}
	
	if(resolvedStyle == LNPopupInteractionStyleScroll && [pgr.view isKindOfClass:UIScrollView.class] == NO)
	{
		//Ignore non-scroll events.
		return;
	}
	
	if(resolvedStyle == LNPopupInteractionStyleSnap)
	{
		if((_popupControllerInternalState == LNPopupPresentationStateBarPresented && [pgr velocityInView:self.popupBar].y < 0))
		{
			pgr.enabled = NO;
			pgr.enabled = YES;
			
			_popupControllerTargetState = LNPopupPresentationStateOpen;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self _transitionToState:_popupControllerTargetState notifyDelegate:YES animated:YES useSpringAnimation:_popupControllerTargetState == LNPopupPresentationStateBarPresented ? YES : NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
			});
		}
		else if((_popupControllerInternalState == LNPopupPresentationStateBarPresented && [pgr velocityInView:self.popupBar].y > 0))
		{
			pgr.enabled = NO;
			pgr.enabled = YES;
		}
	}
}

- (CGFloat)rubberbandFromHeight:(CGFloat)height
{
	/*
	 f(x, d, c) = (x * d * c) / (d + c * x)
	 
	 where,
	 x – distance from the edge
	 c – constant (UIScrollView uses 0.55)
	 d – dimension, either width or height
	 */
	CGFloat c = _containerController.popupSnapPercent, x = height, d = self.popupBar.superview.bounds.size.height;
	
	return (x * d * c) / (d + c * x);
}

- (void)_popupBarPresentationByUserPanGestureHandler_changed:(UIPanGestureRecognizer*)pgr
{
#if TARGET_OS_MACCATALYST
	if(self.popupBar.window._ln_currentEvent.type == 22 /*NSEventTypeScrollWheel*/)
	{
		return;
	}
#endif
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	if(resolvedStyle == LNPopupInteractionStyleNone)
	{
		//Ignore all events.
		return;
	}
	
	if(resolvedStyle == LNPopupInteractionStyleScroll && [pgr.view isKindOfClass:UIScrollView.class] == NO)
	{
		//Ignore non-scroll events.
		return;
	}
	
	if(pgr != _popupContentView.popupInteractionGestureRecognizer)
	{
		UIScrollView* possibleScrollView = (id)pgr.view;
		if([possibleScrollView isKindOfClass:[UIScrollView class]])
		{
			//If the scroll view has horizontal scroll, ignore the scroll view's pan gesture recognizer.
			if(possibleScrollView.contentSize.width > possibleScrollView.bounds.size.width)
			{
				return;
			}
			
			id<UIGestureRecognizerDelegate> delegate = _popupContentView.popupInteractionGestureRecognizer.delegate;
			
			if(([delegate respondsToSelector:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)] && [delegate gestureRecognizer:_popupContentView.popupInteractionGestureRecognizer shouldRequireFailureOfGestureRecognizer:pgr] == YES) ||
			   ([delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] && [delegate gestureRecognizer:_popupContentView.popupInteractionGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:pgr] == NO) ||
			   (_dismissGestureStarted == NO && possibleScrollView.contentOffset.y > - (possibleScrollView.contentInset.top + LNPopupBarDeveloperPanGestureThreshold)))
			{
				return;
			}
			
			if(_dismissGestureStarted == NO)
			{
				_dismissScrollViewStartingContentOffset = possibleScrollView.contentOffset.y;
			}
			
			if(_popupBar.frame.origin.y > _cachedOpenPopupFrame.origin.y)
			{
				possibleScrollView.contentOffset = CGPointMake(possibleScrollView.contentOffset.x, _dismissScrollViewStartingContentOffset);
			}
		}
		else
		{
			return;
		}
	}
	
	if(_dismissGestureStarted == NO && (resolvedStyle == LNPopupInteractionStyleDrag || resolvedStyle == LNPopupInteractionStyleScroll || _popupControllerInternalState > LNPopupPresentationStateBarPresented))
	{
		_lastSeenMovement = CACurrentMediaTime();
		BOOL prevState = self.popupBar.barHighlightGestureRecognizer.enabled;
		self.popupBar.barHighlightGestureRecognizer.enabled = NO;
		self.popupBar.barHighlightGestureRecognizer.enabled = prevState;
		_lastPopupBarLocation = self.popupBar.center;
		
		_statusBarThresholdDir = _popupControllerInternalState == LNPopupPresentationStateOpen ? 1 : -1;
		
		_stateBeforeDismissStarted = _popupControllerInternalState;
		
		[self _transitionToState:_LNPopupPresentationStateTransitioning notifyDelegate:YES animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
		
		_cachedDefaultFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
		_cachedInsets = [_containerController insetsForBottomDockingView];
		_cachedOpenPopupFrame = [self _frameForOpenPopupBar];
		
		_dismissGestureStarted = YES;
		
		if(pgr != _popupContentView.popupInteractionGestureRecognizer)
		{
			_dismissStartingOffset = [pgr translationInView:self.popupBar.superview].y;
		}
		else
		{
			_dismissStartingOffset = 0;
		}
	}
	
	if(_dismissGestureStarted == YES)
	{
		CGFloat targetCenterY = MIN(_lastPopupBarLocation.y + [pgr translationInView:self.popupBar.superview].y, _cachedDefaultFrame.origin.y - self.popupBar.frame.size.height / 2 - _cachedInsets.bottom) - _dismissStartingOffset;
		targetCenterY = MAX(targetCenterY, _cachedOpenPopupFrame.origin.y + self.popupBar.frame.size.height / 2);
		
		CGFloat realTargetCenterY = targetCenterY;
		
		if(resolvedStyle == LNPopupInteractionStyleSnap)
		{
			//Rubberband the pull gesture in snap mode.
			targetCenterY = [self rubberbandFromHeight:targetCenterY];
			
			//Offset the rubberband pull so that it starts where it should.
			targetCenterY -= (self.popupBar.frame.size.height / 2) + [self rubberbandFromHeight:self.popupBar.frame.size.height / -2];
		}
		
		CGFloat currentCenterY = self.popupBar.center.y;
		
		self.popupBar.center = CGPointMake(self.popupBar.center.x, targetCenterY);
		[self _repositionPopupContentMovingBottomBar:(resolvedStyle == LNPopupInteractionStyleDrag || resolvedStyle == LNPopupInteractionStyleScroll) animated:YES];
		_lastSeenMovement = CACurrentMediaTime();
		
		[_popupContentView.popupCloseButton _setButtonContainerTransitioning];
		
		if(resolvedStyle == LNPopupInteractionStyleSnap && realTargetCenterY / self.popupBar.superview.bounds.size.height > _containerController.popupSnapPercent)
		{
			_dismissGestureStarted = NO;
			
			pgr.enabled = NO;
			pgr.enabled = YES;
			
			_popupControllerTargetState = LNPopupPresentationStateBarPresented;
			[self _transitionToState:_popupControllerTargetState notifyDelegate:YES animated:YES useSpringAnimation:_popupControllerTargetState == LNPopupPresentationStateBarPresented ? YES : NO allowPopupBarAlphaModification:YES completion:^ {
				[_popupContentView.popupCloseButton _setButtonContainerStationary];
			} transitionOriginatedByUser:NO];
		}
		
		CGFloat statusBarHeightThreshold = [LNPopupController _statusBarHeightForView:_containerController.view] / 2.0;
		
		if((_statusBarThresholdDir == 1 && currentCenterY < targetCenterY && _popupContentView.frame.origin.y >= statusBarHeightThreshold)
		   || (_statusBarThresholdDir == -1 && currentCenterY > targetCenterY && _popupContentView.frame.origin.y < statusBarHeightThreshold))
		{
			_statusBarThresholdDir = -_statusBarThresholdDir;
			
			[UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:0 animations:^{
				[_containerController setNeedsStatusBarAppearanceUpdate];
			} completion:nil];
		}
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_endedOrCancelled:(UIPanGestureRecognizer*)pgr
{
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	if(_dismissGestureStarted == YES)
	{
		LNPopupPresentationState targetState = _stateBeforeDismissStarted;
		
		if(resolvedStyle == LNPopupInteractionStyleDrag || resolvedStyle == LNPopupInteractionStyleScroll)
		{
			CGFloat barTransitionPercent = [self _percentFromPopupBar];
			BOOL hasPassedHeighThreshold = _stateBeforeDismissStarted == LNPopupPresentationStateBarPresented ? barTransitionPercent > LNPopupBarGestureHeightPercentThreshold : barTransitionPercent < (1.0 - LNPopupBarGestureHeightPercentThreshold);
			CGFloat panVelocity = [pgr velocityInView:_containerController.view].y;
			
			if(panVelocity < 0)
			{
				targetState = LNPopupPresentationStateOpen;
			}
			else if(panVelocity > 0)
			{
				targetState = LNPopupPresentationStateBarPresented;
			}
			else if(hasPassedHeighThreshold == YES)
			{
				targetState = _stateBeforeDismissStarted == LNPopupPresentationStateBarPresented ? LNPopupPresentationStateOpen : LNPopupPresentationStateBarPresented;
			}
		}
		
		[_popupContentView.popupCloseButton _setButtonContainerStationary];
		[self _transitionToState:targetState notifyDelegate:YES animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
	}
	
	_dismissGestureStarted = NO;
}

- (void)_popupBarPresentationByUserPanGestureHandler:(UIPanGestureRecognizer*)pgr
{
	if(_dismissalOverride)
	{
		return;
	}
	
	switch (pgr.state)
	{
		case UIGestureRecognizerStateBegan:
			[self _popupBarPresentationByUserPanGestureHandler_began:pgr];
			break;
		case UIGestureRecognizerStateChanged:
			[self _popupBarPresentationByUserPanGestureHandler_changed:pgr];
			break;
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			[self _popupBarPresentationByUserPanGestureHandler_endedOrCancelled:pgr];
			break;
		default:
			break;
	}
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
	return UIBarPositionAny;
}

- (void)_closePopupContent
{
	[self closePopupAnimated:YES completion:nil];
}

- (void)_reconfigure_title
{
	self.popupBarStorage.attributedTitle = _currentPopupItem.attributedTitle;
}

- (void)_reconfigure_subtitle
{
	self.popupBarStorage.attributedSubtitle = _currentPopupItem.attributedSubtitle;
}

- (void)_reconfigure_attributedTitle
{
	self.popupBarStorage.attributedTitle = _currentPopupItem.attributedTitle;
}

- (void)_reconfigure_attributedSubtitle
{
	self.popupBarStorage.attributedSubtitle = _currentPopupItem.attributedSubtitle;
}

- (void)_reconfigure_image
{
	self.popupBarStorage.image = _currentPopupItem.image;
	
	if(_currentPopupItem.image != nil && _currentPopupItem.swiftuiImageController != nil)
	{
		_currentPopupItem.swiftuiImageController = nil;
	}
}

- (void)_reconfigure_progress
{
	[UIView performWithoutAnimation:^{
		[self.popupBarStorage.progressView setProgress:_currentPopupItem.progress animated:NO];
	}];
}

- (void)_reconfigure_accessibilityLabel
{
	self.popupBarStorage.accessibilityCenterLabel = _currentPopupItem.accessibilityLabel;
}

- (void)_reconfigure_accessibilityHint
{
	self.popupBarStorage.accessibilityCenterHint = _currentPopupItem.accessibilityHint;
}

- (void)_reconfigure_accessibilityImageLabel
{
	self.popupBarStorage.accessibilityImageLabel = _currentPopupItem.accessibilityImageLabel;
}

- (void)_reconfigure_accessibilityProgressLabel
{
	self.popupBarStorage.accessibilityProgressLabel = _currentPopupItem.accessibilityProgressLabel;
}

- (void)_reconfigure_accessibilityProgressValue
{
	self.popupBarStorage.accessibilityProgressValue = _currentPopupItem.accessibilityProgressValue;
}

- (void)_reconfigureBarItems
{
	[self.popupBarStorage _delayBarButtonLayout];
	[self.popupBarStorage setLeadingBarButtonItems:_currentPopupItem.leadingBarButtonItems];
	[self.popupBarStorage setTrailingBarButtonItems:_currentPopupItem.trailingBarButtonItems];
	[self.popupBarStorage _layoutBarButtonItems];
}

- (void)_reconfigure_leadingBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_reconfigure_trailingBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_reconfigure_swiftuiImageController
{
	if(_currentPopupItem.swiftuiImageController != nil)
	{
		self.popupBarStorage.swiftuiImageController = _currentPopupItem.swiftuiImageController;
	}
	
	if(_currentPopupItem.swiftuiImageController != nil && _currentPopupItem.image != nil)
	{
		_currentPopupItem.image = nil;
	}
}

- (void)_reconfigure_swiftuiTitleContentView
{
	if(_currentPopupItem.swiftuiTitleContentView != nil)
	{
		self.popupBarStorage.swiftuiTitleContentView = _currentPopupItem.swiftuiTitleContentView;
		_currentPopupItem.title = nil;
	}
}

- (void)_reconfigure_swiftuiHiddenLeadingController
{
	self.popupBarStorage.swiftuiHiddenLeadingController = _currentPopupItem.swiftuiHiddenLeadingController;
}

- (void)_reconfigure_swiftuiHiddenTrailingController
{
	self.popupBarStorage.swiftuiHiddenTrailingController = _currentPopupItem.swiftuiHiddenTrailingController;
}

- (void)_reconfigure_standardAppearance
{
	[self.popupBarStorage _recalcActiveAppearanceChain];
}

- (void)_popupItem:(LNPopupItem*)popupItem didChangeValueForKey:(NSString*)key
{
	if(self.popupBarStorage.customBarViewController)
	{
		[self.popupBarStorage.customBarViewController popupItemDidUpdate];
	}
	else
	{
		NSString* reconfigureSelector = [NSString stringWithFormat:@"_reconfigure_%@", key];
		
		void (*configureDispatcher)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
		configureDispatcher(self, NSSelectorFromString(reconfigureSelector));
	}
}

- (void)_reconfigureContentWithOldContentController:(__kindof UIViewController*)oldContentController newContentController:(__kindof UIViewController*)newContentController
{
	if(oldContentController == newContentController)
	{
		return;
	}
	
	_currentPopupItem.itemDelegate = nil;
	_currentPopupItem = newContentController.popupItem;
	_currentPopupItem.itemDelegate = self;
	
	self.popupBarStorage.popupItem = _currentPopupItem;
	
	if(_popupControllerInternalState > LNPopupPresentationStateBarPresented)
	{
		[oldContentController beginAppearanceTransition:NO animated:NO];
		[oldContentController _userFacing_viewWillDisappear:NO];
		[newContentController beginAppearanceTransition:YES animated:NO];
		[newContentController _userFacing_viewWillAppear:NO];
	}
	
	_LNPopupTransitionCoordinator* coordinator = [_LNPopupTransitionCoordinator new];
	[newContentController willTransitionToTraitCollection:_containerController.traitCollection withTransitionCoordinator:coordinator];
	[newContentController viewWillTransitionToSize:_containerController.view.bounds.size withTransitionCoordinator:coordinator];
	newContentController.view.translatesAutoresizingMaskIntoConstraints = YES;
	newContentController.view.autoresizingMask = UIViewAutoresizingNone;
	newContentController.view.frame = _containerController.view.bounds;
	newContentController.view.clipsToBounds = NO;
	
	self.popupContentView.currentPopupContentViewController = newContentController;
	
//	if(_popupControllerInternalState > LNPopupPresentationStateBarPresented)
//	{
		if(oldContentController != nil)
		{
			[self.popupContentView.contentView insertSubview:newContentController.view belowSubview:oldContentController.view];
		}
		else
		{
			[self _addContentControllerSubview:newContentController];
			[self.popupContentView.contentView sendSubviewToBack:newContentController.view];
		}
//	}
	
	[self _removeContentControllerFromContentView:oldContentController];
	
	if(_popupControllerInternalState > LNPopupPresentationStateBarPresented)
	{
		[newContentController _userFacing_viewDidAppear:NO];
		[newContentController endAppearanceTransition];
		[oldContentController _userFacing_viewDidDisappear:NO];
		[oldContentController endAppearanceTransition];
		
		UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		
		[self _cleanupGestureRecognizersForController:oldContentController];
		[self _fixupGestureRecognizersForController:newContentController];
	}
	
	if(_popupControllerPublicState == LNPopupPresentationStateOpen)
	{
		[newContentController.viewForPopupInteractionGestureRecognizer addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
	}
	
	_currentContentController = newContentController;
	
	if(self.popupBarStorage.customBarViewController != nil)
	{
		[self.popupBarStorage.customBarViewController popupItemDidUpdate];
	}
	else
	{
		[__LNPopupItemObservedKeys enumerateObjectsUsingBlock:^(NSString * __nonnull key, NSUInteger idx, BOOL * __nonnull stop) {
			[self _popupItem:_currentPopupItem didChangeValueForKey:key];
		}];
	}
}

- (void)_configurePopupBarFromBottomBar
{
	self.popupBar.effectGroupingIdentifier = _bottomBar._ln_effectGroupingIdentifierIfAvailable;
	//Schedule one more effect identifier refresh, in case it's not yet ready at this point.
	dispatch_async(dispatch_get_main_queue(), ^{
		self.popupBar.effectGroupingIdentifier = _bottomBar._ln_effectGroupingIdentifierIfAvailable;
	});
	
	if(self.popupBar.inheritsAppearanceFromDockingView == NO)
	{
		return;
	}
	
	UIBarAppearance* appearanceToUse = nil;
	
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* vPTIS = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		vPTIS = _LNPopupDecodeBase64String(_vPTIS);
	});
	
	//visualProvider.toolbarIsSmall
	if([_bottomBar isKindOfClass:UIToolbar.class] &&  [[_bottomBar valueForKeyPath:vPTIS] boolValue] == YES)
	{
		appearanceToUse = [(UIToolbar*)_bottomBar compactAppearance];
	}
	
#endif
	
	if(appearanceToUse == nil && [_bottomBar respondsToSelector:@selector(standardAppearance)])
	{
		appearanceToUse = [(id<_LNPopupBarSupport>)_bottomBar standardAppearance];
	}
	
	self.popupBar.systemTintColor = _bottomBar.tintColor;
	
	self.popupBar.systemAppearance = appearanceToUse;
}

- (void)_updateBarExtensionStyleFromPopupBar
{
	if(_containerController._ln_bottomBarExtension_nocreate == nil)
	{
		return;
	}
	
	_containerController._ln_bottomBarExtension_nocreate.effect = _containerController.popupBar.backgroundView.effect;
	[_containerController.popupBar _applyGroupingIdentifierToVisualEffectView:_containerController._ln_bottomBarExtension_nocreate.effectView];
	
	_containerController._ln_bottomBarExtension_nocreate.foregroundColor = _containerController.popupBar.backgroundView.foregroundColor;
	_containerController._ln_bottomBarExtension_nocreate.foregroundImage = _containerController.popupBar.backgroundView.foregroundImage;
	_containerController._ln_bottomBarExtension_nocreate.foregroundImageContentMode = _containerController.popupBar.backgroundView.foregroundImageContentMode;
	[_containerController._ln_bottomBarExtension_nocreate hideOrShowImageViewIfNecessary];
}

- (void)_movePopupBarAndContentToBottomBarSuperview
{
	[self.popupBar removeFromSuperview];
	[self.popupContentView removeFromSuperview];
	
	if([_bottomBar.superview isKindOfClass:[UIScrollView class]])
	{
		NSLog(@"LNPopupController: Attempted to present popup bar %@ on top of a UIScrollView subclass %@. This is unsupported and may result in unexpected behavior.", self.popupBar, _bottomBar.superview);
	}
	
	[self.popupBar layoutIfNeeded];
	
	if(_bottomBar.superview != nil)
	{
		[_bottomBar.superview insertSubview:self.popupBar belowSubview:_bottomBar];
		[self.popupBar.superview bringSubviewToFront:self.popupBar];
		[self.popupBar.superview bringSubviewToFront:_bottomBar];
		[self.popupBar.superview insertSubview:self.popupContentView belowSubview:self.popupBar];
	}
	else
	{
		[_containerController.view addSubview:self.popupBar];
		[_containerController.view bringSubviewToFront:self.popupBar];
		[_containerController.view insertSubview:self.popupContentView belowSubview:self.popupBar];
	}
}

- (LNPopupBar *)popupBarStorage
{
	if(_popupBar)
	{
		return _popupBar;
	}
	
	_popupBar = [[LNPopupBar alloc] initWithFrame:[self _frameForClosedPopupBar]];
	_popupBar.hidden = YES;
	_popupBar.barContainingController = _containerController;
	_popupBar._barDelegate = self;
	_popupBar.popupOpenGestureRecognizer = [[LNPopupOpenTapGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarTapGestureRecognized:)];
	[_popupBar addGestureRecognizer:_popupBar.popupOpenGestureRecognizer];
	
	_popupBar.barHighlightGestureRecognizer = [[LNPopupLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarLongPressGestureRecognized:)];
	_popupBar.barHighlightGestureRecognizer.minimumPressDuration = 0;
	_popupBar.barHighlightGestureRecognizer.cancelsTouchesInView = NO;
	_popupBar.barHighlightGestureRecognizer.delaysTouchesBegan = NO;
	_popupBar.barHighlightGestureRecognizer.delaysTouchesEnded = NO;
	[_popupBar addGestureRecognizer:_popupBar.barHighlightGestureRecognizer];
	
	return _popupBar;
}

- (LNPopupBar *)popupBar
{
	if(_popupControllerInternalState == LNPopupPresentationStateBarHidden)
	{
		return nil;
	}
	
	return self.popupBarStorage;
}

- (LNPopupContentView *)popupContentView
{
	if(_popupContentView)
	{
		return _popupContentView;
	}
	
	self.popupContentView = [[LNPopupContentView alloc] initWithFrame:_containerController.view.bounds];
	_popupContentView.clipsToBounds = YES;
	[_popupContentView.popupCloseButton addTarget:self action:@selector(_closePopupContent) forControlEvents:UIControlEventTouchUpInside];
	
	_popupContentView.preservesSuperviewLayoutMargins = YES;
	_popupContentView.contentView.preservesSuperviewLayoutMargins = YES;
	
	_popupContentView.popupInteractionGestureRecognizer = [[LNPopupInteractionPanGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:) popupController:self];
	
	return _popupContentView;
}

- (void)dealloc
{
	//Cannot use self.popupBar in this method because it returns nil when the popup state is LNPopupPresentationStateBarHidden.
	if(_popupBar)
	{
		[_popupBar removeFromSuperview];
	}
}

static void __LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(UIView* view, void (^block)(UIView* view))
{
	block(view);
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		__LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(obj, block);
	}];
}

- (void)_fixupGestureRecognizersForController:(UIViewController*)vc
{
	__LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(vc.viewForPopupInteractionGestureRecognizer, ^(UIView *view) {
		[view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if([obj isKindOfClass:[UIPanGestureRecognizer class]] && obj != _popupContentView.popupInteractionGestureRecognizer)
			{
				[obj addTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:)];
			}
		}];
	});
}

- (void)_cleanupGestureRecognizersForController:(UIViewController*)vc
{
	[vc.viewForPopupInteractionGestureRecognizer.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if([obj isKindOfClass:[UIPanGestureRecognizer class]] && obj != _popupContentView.popupInteractionGestureRecognizer)
		{
			[obj removeTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:)];
		}
	}];
}

#if TARGET_IPHONE_SIMULATOR
extern float UIAnimationDragCoefficient(void);
#endif

- (void)presentPopupBarAnimated:(BOOL)animated openPopup:(BOOL)open completion:(void(^)(void))completionBlock
{
	[self _start120HzHack];
	
	UIViewController* old = _currentContentController;
	[self _reconfigureContentWithOldContentController:old newContentController:_containerController.popupContentViewController];
	
	if(_popupControllerTargetState == LNPopupPresentationStateBarHidden)
	{
		_dismissalOverride = NO;
		
		if(open)
		{
			_popupControllerInternalState = LNPopupPresentationStateBarPresented;
		}
		else
		{
			_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
		}
		_popupControllerTargetState = LNPopupPresentationStateBarPresented;
		
		_bottomBar = _containerController.bottomDockingViewForPopup_internalOrDeveloper;
		_bottomBar.attachedPopupController = self;
		
		self.popupBarStorage.hidden = NO;
		
		[self _movePopupBarAndContentToBottomBarSuperview];
		[self _configurePopupBarFromBottomBar];
		
		[self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
		
		[self _setContentToState:LNPopupPresentationStateBarPresented animated:animated];
		
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		
		self.popupBar.clipsToBounds = NO;
		
		dispatch_block_t animations = ^{
			_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillPresentPopupBar:animated:), animated);
			[self.popupBar.customBarViewController _userFacing_viewWillAppear:animated];
			
			[_bottomBar _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
			_containerController._ln_bottomBarExtension_nocreate.alpha = 1.0;
			
			CGRect barFrame = self.popupBar.frame;
			barFrame.size.height = _LNPopupBarHeightForPopupBar(self.popupBar);
			self.popupBar.frame = barFrame;
			
			self.popupBar.frame = [self _frameForClosedPopupBar];
			
			[self.popupBar setNeedsLayout];
			[self.popupBar layoutIfNeeded];
			
			_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsMake(0, 0, barFrame.size.height, 0));
			
			if(open)
			{
				if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:willOpenPopupWithContentController:animated:), animated) == NO)
				{
					_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
				}
				[self openPopupAnimated:animated completion:completionBlock];
			}
		};
		
		dispatch_block_t middle = ^{
			self.popupBar.floatingBackgroundShadowView.alpha = 1.0;
		};
		
		void (^completion)(BOOL) = ^(BOOL finished) {
			if(!open)
			{
				_popupControllerInternalState = LNPopupPresentationStateBarPresented;
				
				if(_popupContentView.frame.size.height == 0)
				{
					_popupContentView.hidden = YES;
				}
				
				[_containerController _ln_setPopupPresentationState:LNPopupPresentationStateBarPresented];
				
				[self _end120HzHack];
			}
			
			[self.popupBar.customBarViewController _userFacing_viewDidAppear:animated];
			_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidPresentPopupBar:animated:), animated);
			
			self.popupBar.acceptsSizing = YES;
			
			if(completionBlock != nil && !open)
			{
				completionBlock();
			}
		};
		
		_containerController._ln_bottomBarExtension_nocreate.alpha = 0.0;
		
		if(animated == NO)
		{
			[UIView performWithoutAnimation:^{
				animations();
				middle();
				completion(YES);
			}];
			return;
		}
		
		[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:0 animations:animations completion:completion];
		[UIView animateWithDuration:0.3 delay:0.2 usingSpringWithDamping:500 initialSpringVelocity:0 options:0 animations:middle completion:completion];
	}
	else
	{
		if(open)
		{
			[self openPopupAnimated:animated completion:completionBlock];
		}
		else
		{
			[self _end120HzHack];
			
			if(completionBlock != nil)
			{
				completionBlock();
			}
		}
	}
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _start120HzHack];
	
	if(_popupControllerTargetState == LNPopupPresentationStateBarPresented)
	{
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		[self _transitionToState:LNPopupPresentationStateOpen notifyDelegate:YES animated:animated useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:NO];
	}
	else if(completionBlock != nil)
	{
		completionBlock();
	}
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(_popupControllerTargetState == LNPopupPresentationStateOpen)
	{
		LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
		
		[self _transitionToState:LNPopupPresentationStateBarPresented notifyDelegate:YES animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap ? YES : NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:YES];
	}
	else if(completionBlock != nil)
	{
		completionBlock();
	}
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _start120HzHack];
	
	if(_dismissalOverride == YES)
	{
		if(completionBlock != nil) { completionBlock(); }
		return;
	}
	
	if(_popupControllerInternalState != LNPopupPresentationStateBarHidden)
	{
		self.popupBar.acceptsSizing = NO;
		self.popupBar.clipsToBounds = YES;
		
		void (^dismissalAnimationCompletionBlock)(void) = ^
		{
			_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
			_popupControllerTargetState = LNPopupPresentationStateBarHidden;
			
			[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillDismissPopupBar:animated:), animated);
				[self.popupBar.customBarViewController _userFacing_viewWillDisappear:animated];
				
				CGRect barFrame = self.popupBar.frame;
				barFrame.size.height = 0;
				self.popupBar.frame = barFrame;
				
				self.popupBar.floatingBackgroundShadowView.alpha = 0.0;
				
				self.popupBar.shadowView.alpha = 0.0;
				_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
				
				[_bottomBar _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
				
				CGFloat currentBarAlpha = self.popupBarStorage.alpha;
				[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{					
					if(_containerController.shouldFadePopupBarOnDismiss)
					{
						self.popupBar.alpha = 0.0;
					}
					_containerController._ln_bottomBarExtension_nocreate.alpha = 0.0;
				} completion:^(BOOL finished) {
					self.popupBarStorage.alpha = currentBarAlpha;
				}];
			} completion:^(BOOL finished) {
				self.popupBar.shadowView.alpha = 1.0;
				
				[self.popupBar.customBarViewController _userFacing_viewDidDisappear:animated];
				
				_popupControllerInternalState = LNPopupPresentationStateBarHidden;
				
				[self _removeContentControllerFromContentView:_currentContentController];
				
				CGRect bottomBarFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
				bottomBarFrame.origin.y -= _cachedInsets.bottom;
				_bottomBar.frame = bottomBarFrame;
				
				self.popupBar.hidden = YES;
				[self.popupBar removeFromSuperview];
				
				[self.popupContentView removeFromSuperview];
				self.popupContentView.popupInteractionGestureRecognizer = nil;
				self.popupContentView = nil;
				
				_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
				
				_currentContentController = nil;
				
				_effectiveStatusBarUpdateController = nil;
				
				[_containerController _ln_setPopupPresentationState:LNPopupPresentationStateBarHidden];
				
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidDismissPopupBar:animated:), animated);
				
				_bottomBar.attachedPopupController = nil;
				_bottomBar = nil;
				
				[self _end120HzHack];
				
				if(completionBlock != nil) { completionBlock(); }
			}];
		};
		
		_dismissalOverride = YES;
		
		if(_popupControllerTargetState != LNPopupPresentationStateBarPresented)
		{
			self.popupContentView.popupInteractionGestureRecognizer.enabled = NO;
			self.popupContentView.popupInteractionGestureRecognizer.enabled = YES;
			
			LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
			
			[self _transitionToState:LNPopupPresentationStateBarPresented notifyDelegate:YES animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap allowPopupBarAlphaModification:YES completion:dismissalAnimationCompletionBlock transitionOriginatedByUser:NO];
		}
		else
		{
			dismissalAnimationCompletionBlock();
		}
	}
}

#pragma mark Application Events

- (void)_applicationDidEnterBackground
{
	[self.popupBar _setTitleViewMarqueesPaused:YES];
}

- (void)_applicationWillEnterForeground
{
	[self.popupBar _setTitleViewMarqueesPaused:_popupControllerInternalState != LNPopupPresentationStateBarPresented];
}

#pragma mark _LNPopupBarDelegate

- (void)_removeInteractionGestureForPopupBar:(LNPopupBar*)bar
{
	BOOL oldVal = _popupContentView.popupInteractionGestureRecognizer.enabled;
	_popupContentView.popupInteractionGestureRecognizer.enabled = NO;
	_popupContentView.popupInteractionGestureRecognizer.enabled = oldVal;
}

- (void)_traitCollectionForPopupBarDidChange:(LNPopupBar*)bar
{
	[self _configurePopupBarFromBottomBar];
}

- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar
{
	if(self.popupBar.acceptsSizing == NO)
	{
		//Ignore frame changes before a bar is fully presented.
		return;
	}
	
	CGRect barFrame = self.popupBar.frame;
	CGFloat currentHeight = barFrame.size.height;
	barFrame.size.height = _LNPopupBarHeightForPopupBar(self.popupBar);
	barFrame.origin.y -= (barFrame.size.height - currentHeight);
	self.popupBar.frame = barFrame;
	
	_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsMake(0, 0, self.popupBar.frame.size.height, 0));
}

- (void)_popupBarStyleDidChange:(LNPopupBar*)bar
{
	[self _updateBarExtensionStyleFromPopupBar];
	[_containerController.popupBar _applyGroupingIdentifierToVisualEffectView:self.popupContentView.effectView];
}

- (void)_popupBar:(LNPopupBar *)bar updateCustomBarController:(LNPopupCustomBarViewController *)customController cleanup:(BOOL)cleanup
{
	if(cleanup)
	{
		customController.popupController = nil;
	}
	else
	{
		customController.popupController = self;
	}
}

#pragma mark Utils

- (void)_check120HzHackAndNotifyIfNeeded
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (@available(iOS 15.0, *))
		{
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.maximumFramesPerSecond > 60 && [[NSBundle.mainBundle objectForInfoDictionaryKey:@"CADisableMinimumFrameDurationOnPhone"] boolValue] == NO)
			{
				NSString* frameworkName = NSClassFromString(@"__LNPopupUI") ? @"LNPopupUI" : @"LNPopupController";
				NSString* subsystem = [NSString stringWithFormat:@"com.LeoNatan.%@", frameworkName];
				os_log_t customLog = os_log_create(subsystem.UTF8String, frameworkName.UTF8String);
				os_log_with_type(customLog, OS_LOG_TYPE_DEBUG, "This device supports ProMotion, but %s does not enable the full range of refresh rates by setting the “CADisableMinimumFrameDurationOnPhone” Info.plist key to “true”. See https://developer.apple.com/documentation/quartzcore/optimizing_promotion_refresh_rates_for_iphone_13_pro_and_ipad_pro", NSBundle.mainBundle.bundleURL.lastPathComponent.UTF8String);
			}
		}
	});
}

- (void)_start120HzHack
{
	[self _check120HzHackAndNotifyIfNeeded];
	
	if(_displayLinkFor120Hz != nil)
	{
		return;
	}
	
	_displayLinkFor120Hz = [CADisplayLink displayLinkWithTarget:self selector:@selector(_120HzTick)];
	CGFloat max = UIScreen.mainScreen.maximumFramesPerSecond;
	if(@available(iOS 15.0, *))
	{
		_displayLinkFor120Hz.preferredFrameRateRange = CAFrameRateRangeMake(max, max, max);
	}
	else
	{
		_displayLinkFor120Hz.preferredFramesPerSecond = max;
	}
	[_displayLinkFor120Hz addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
}

- (void)_end120HzHack
{
	[_displayLinkFor120Hz invalidate];
	_displayLinkFor120Hz = nil;
}

+ (CGFloat)_statusBarHeightForView:(UIView*)view
{
#if TARGET_OS_MACCATALYST
	return 0;
#else
	if(view == nil || view.window == nil)
	{
		return 0;
	}
	
	if(view.window.safeAreaInsets.top == 0)
	{
		//Probably 🤷‍♂️ an old iPhone
		return view.window.windowScene.statusBarManager.statusBarHidden ? 0 : 20;
	}
	
	return view.window.safeAreaInsets.top;
#endif
}

- (void)_120HzTick {}

@end
