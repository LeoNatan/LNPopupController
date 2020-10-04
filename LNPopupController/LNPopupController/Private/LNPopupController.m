//
//  _LNPopupBarSupportObject.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import "LNPopupController.h"
#import "LNPopupCloseButton+Private.h"
#import "LNPopupItem+Private.h"
#import "LNPopupOpenTapGesutreRecognizer.h"
#import "LNPopupLongPressGesutreRecognizer.h"
#import "LNPopupInteractionPanGestureRecognizer.h"
#import "_LNPopupSwizzlingUtils.h"
#import "NSObject+AltKVC.h"
#import "UIView+LNPopupSupportPrivate.h"
@import ObjectiveC;

const NSUInteger _LNPopupPresentationStateTransitioning = 2;

static const CGFloat LNPopupBarGestureHeightPercentThreshold = 0.2;
static const CGFloat LNPopupBarDeveloperPanGestureThreshold = 0;

LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style)
{
	LNPopupInteractionStyle rv = style;
	if(rv == LNPopupInteractionStyleDefault)
	{
		rv = LNPopupInteractionStyleSnap;
	}
	return rv;
}

OS_ALWAYS_INLINE
static void _LNCallDelegateObjectBool(UIViewController* controller, SEL selector, BOOL animated)
{
	if([controller.popupPresentationDelegate respondsToSelector:selector])
	{
		void (*msgSendObjectBool)(id, SEL, id, BOOL) = (void*)objc_msgSend;
		msgSendObjectBool(controller.popupPresentationDelegate, selector, controller, animated);
	}
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

- (void)_repositionPopupContentMovingBottomBar:(BOOL)bottomBar
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
	[self.popupBar.contentView setAlpha:1.0 - percent];
	
	CGRect contentFrame = _containerController.view.bounds;
	contentFrame.origin.x = self.popupBar.frame.origin.x;
	contentFrame.origin.y = self.popupBar.frame.origin.y + self.popupBar.frame.size.height;
	
	CGFloat fractionalHeight = MAX(heightForContent - (self.popupBar.frame.origin.y + self.popupBar.frame.size.height), 0);
	contentFrame.size.height = ceil(fractionalHeight);
	
	self.popupContentView.frame = contentFrame;
	
	_containerController.popupContentViewController.view.frame = _containerController.view.bounds;
	
	[self.popupContentView _repositionPopupCloseButton];
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
	
	[self _repositionPopupContentMovingBottomBar:_containerController._ignoringLayoutDuringTransition == NO];
}

- (void)_addContentControllerSubview:(UIViewController*)currentContentController
{
	if(currentContentController == nil)
	{
		return;
	}
	
	if (@available(iOS 13.0, *))
	{
		[self.popupContentView setControllerOverrideUserInterfaceStyle:currentContentController.overrideUserInterfaceStyle];
	}
	currentContentController.view.translatesAutoresizingMaskIntoConstraints = YES;
	_currentContentController.view.autoresizingMask = UIViewAutoresizingNone;
	currentContentController.view.frame = self.popupContentView.contentView.bounds;
	[self.popupContentView.contentView addSubview:currentContentController.view];
}

- (void)_removeContentControllerFromContentView:(UIViewController*)currentContentController
{
	if(currentContentController == nil)
	{
		return;
	}
	
	[_currentContentController.view removeFromSuperview];
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
		[_currentContentController _ln_beginAppearanceTransition:YES animated:NO];
		[UIView performWithoutAnimation:^{
//			_currentContentController.view.frame = _containerController.view.bounds;
			
			[self.popupContentView _applyBackgroundEffectWithContentViewController:_currentContentController barEffect:(id)self.popupBar.backgroundView.effect];
			
			self.popupContentView.currentPopupContentViewController = _currentContentController;
			[self.popupContentView.contentView sendSubviewToBack:_currentContentController.view];
			
			[self.popupContentView.contentView setNeedsLayout];
			[self.popupContentView.contentView layoutIfNeeded];
		}];
		[_currentContentController _ln_endAppearanceTransition];
	};
	
	if(notifyDelegate && _popupControllerPublicState == LNPopupPresentationStateOpen && state == LNPopupPresentationStateBarPresented)
	{
		_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillClosePopup:animated:), animated);
	}
	
	if(notifyDelegate && _popupControllerPublicState == LNPopupPresentationStateBarPresented && state == LNPopupPresentationStateOpen)
	{
		_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
	}
	
	_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
	_popupControllerTargetState = state;
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	void (^updatePopupBarAlpha)(void) = ^ {
		if(allowBarAlpha && resolvedStyle == LNPopupInteractionStyleSnap)
		{
			CGRect frame = self.popupBar.frame;
			frame.size.height = state < _LNPopupPresentationStateTransitioning ? _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController) : 0.0;
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
		if(state != _LNPopupPresentationStateTransitioning)
		{
			updatePopupBarAlpha();
		}
		
		if(state == LNPopupPresentationStateBarPresented)
		{
			[_currentContentController _ln_beginAppearanceTransition:NO animated:YES];
		}
		
		[self _setContentToState:state];
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
			[_currentContentController _ln_endAppearanceTransition];
			
			[self _cleanupGestureRecognizersForController:_currentContentController];
			
			[_currentContentController.viewForPopupInteractionGestureRecognizer removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			
			[self.popupBar _setTitleViewMarqueesPaused:NO];
			
			_popupContentView.accessibilityViewIsModal = NO;
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
			
			if(_popupControllerPublicState == LNPopupPresentationStateOpen)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidClosePopup:animated:), animated);
			}
		}
		else if(state == LNPopupPresentationStateOpen)
		{
			[self.popupBar _setTitleViewMarqueesPaused:YES];
			
			[self.popupBar removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[_currentContentController.viewForPopupInteractionGestureRecognizer addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			[self _fixupGestureRecognizersForController:_currentContentController];
			
			_popupContentView.accessibilityViewIsModal = YES;
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, _popupContentView.popupCloseButton);
			
			if(_popupControllerPublicState == LNPopupPresentationStateBarPresented)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidOpenPopup:animated:), animated);
			}
		}
		
		_popupControllerInternalState = state;
		if(state != _LNPopupPresentationStateTransitioning)
		{
			[_containerController _ln_setPopupPresentationState:state];
		}
		
		if(completion)
		{
			completion();
		}
	};
	
	if(animated == NO)
	{
		animationBlock();
		completionBlock(YES);
		return;
	}
	
	[UIView animateWithDuration:resolvedStyle == LNPopupInteractionStyleSnap ? 0.65 : 0.5 delay:0.0 usingSpringWithDamping:spring ? 0.8 : 1.0 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:animationBlock completion:completionBlock];
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
			[self _transitionToState:_LNPopupPresentationStateTransitioning notifyDelegate:NO animated:NO useSpringAnimation:NO allowPopupBarAlphaModification:NO completion:^{
				[_containerController.view setNeedsLayout];
				[_containerController.view layoutIfNeeded];
				[self _transitionToState:LNPopupPresentationStateOpen notifyDelegate:YES animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
			} transitionOriginatedByUser:NO];
		}	break;
		default:
			break;
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_began:(UIPanGestureRecognizer*)pgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultPanGestureRecognizer == NO)
	{
		return;
	}
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
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
	CGFloat c = 0.55, x = height, d = self.popupBar.superview.bounds.size.height / 5;
	return (1.0 - (1.0 / ((x * c / d) + 1.0))) * d;
}

- (void)_popupBarPresentationByUserPanGestureHandler_changed:(UIPanGestureRecognizer*)pgr
{
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	if(pgr != _popupContentView.popupInteractionGestureRecognizer)
	{
		UIScrollView* possibleScrollView = (id)pgr.view;
		if([possibleScrollView isKindOfClass:[UIScrollView class]])
		{
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
	
	if(_dismissGestureStarted == NO && (resolvedStyle == LNPopupInteractionStyleDrag || _popupControllerInternalState > LNPopupPresentationStateBarPresented))
	{
		_lastSeenMovement = CACurrentMediaTime();
		BOOL prevState = self.popupBar.barHighlightGestureRecognizer.enabled;
		self.popupBar.barHighlightGestureRecognizer.enabled = NO;
		self.popupBar.barHighlightGestureRecognizer.enabled = prevState;
		_lastPopupBarLocation = self.popupBar.center;
		
		_statusBarThresholdDir = _popupControllerInternalState == LNPopupPresentationStateOpen ? 1 : -1;
		
		_stateBeforeDismissStarted = _popupControllerInternalState;
		
		[self _transitionToState:_LNPopupPresentationStateTransitioning notifyDelegate:NO animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
		
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
		[self _repositionPopupContentMovingBottomBar:resolvedStyle == LNPopupInteractionStyleDrag];
		_lastSeenMovement = CACurrentMediaTime();
		
		[_popupContentView.popupCloseButton _setButtonContainerTransitioning];
		
		if(resolvedStyle == LNPopupInteractionStyleSnap && realTargetCenterY / self.popupBar.superview.bounds.size.height > 0.275)
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
		
		if(resolvedStyle == LNPopupInteractionStyleDrag)
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
	self.popupBarStorage.title = _currentPopupItem.title;
}

- (void)_reconfigure_subtitle
{
	self.popupBarStorage.subtitle = _currentPopupItem.subtitle;
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

- (void)_reconfigure_accessibilityLavel
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
		[oldContentController _ln_beginAppearanceTransition:NO animated:NO];
		[newContentController _ln_beginAppearanceTransition:YES animated:NO];
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
		[oldContentController _ln_endAppearanceTransition];
		[newContentController _ln_endAppearanceTransition];
		
		UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		
		[self _cleanupGestureRecognizersForController:oldContentController];
		[self _fixupGestureRecognizersForController:newContentController];
	}
	
	if(_popupControllerPublicState == LNPopupPresentationStateOpen)
	{
		[newContentController.viewForPopupInteractionGestureRecognizer addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
	}
	
	_currentContentController = newContentController;
	
	if(self.popupBar.customBarViewController != nil)
	{
		[self.popupBar.customBarViewController popupItemDidUpdate];
	}
	else
	{
		NSArray<NSString*>* keys = @[@"title", @"subtitle", @"image", @"progress", @"leadingBarButtonItems", @"trailingBarButtonItems", @"accessibilityLavel", @"accessibilityHint", @"accessibilityImageLabel", @"accessibilityProgressLabel", @"accessibilityProgressValue"];
		[keys enumerateObjectsUsingBlock:^(NSString * __nonnull key, NSUInteger idx, BOOL * __nonnull stop) {
			[self _popupItem:_currentPopupItem didChangeValueForKey:key];
		}];
	}
}

- (void)_configurePopupBarFromBottomBar
{
	if(self.popupBar.inheritsVisualStyleFromDockingView == NO)
	{
		return;
	}
	
	self.popupBar.effectGroupingIdentifier = _bottomBar._effectGroupingIdentifierIfAvailable;
	
	if([_bottomBar respondsToSelector:@selector(barStyle)])
	{
		[self.popupBar setSystemBarStyle:[(id<_LNPopupBarSupport>)_bottomBar barStyle]];
	}
	self.popupBar.systemTintColor = _bottomBar.tintColor;
	if([_bottomBar respondsToSelector:@selector(barTintColor)])
	{
		[self.popupBar setSystemBarTintColor:[(id<_LNPopupBarSupport>)_bottomBar barTintColor]];
	}
	self.popupBar.systemBackgroundColor = _bottomBar.backgroundColor;
	
	if([_bottomBar respondsToSelector:@selector(isTranslucent)])
	{
		self.popupBar.translucent = [(id<_LNPopupBarSupport>)_bottomBar isTranslucent];
	}
	
	static UIColor* systemShadowColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(@available(iOS 13.0, *))
		{
			UIToolbarAppearance* appearance = [UIToolbarAppearance new];
			[appearance configureWithDefaultBackground];
			systemShadowColor = appearance.shadowColor;
		}
		else
		{
			systemShadowColor = [UIColor lightGrayColor];
		}
	});
	
	UIColor* shadowColorToUse = systemShadowColor;
	if(@available(iOS 13.0, *))
	{
		UIBarAppearance* appearanceToUse = nil;
		if([_bottomBar respondsToSelector:@selector(standardAppearance)])
		{
			appearanceToUse = [(id<_LNPopupBarSupport>)_bottomBar standardAppearance];
		}
		
		if(appearanceToUse != nil)
		{
			shadowColorToUse = appearanceToUse.shadowColor;
		}
	}
	self.popupBar.systemShadowColor = shadowColorToUse;
}

- (void)_updateBarExtensionStyleFromPopupBar
{
	_containerController._ln_bottomBarExtension_nocreate.backgroundColor = _containerController.popupBar.backgroundColor;
	_containerController._ln_bottomBarExtension_nocreate.effectView.backgroundColor = _containerController.popupBar.backgroundView.backgroundColor;
	_containerController._ln_bottomBarExtension_nocreate.effectView.alpha = _containerController.popupBar.backgroundView.alpha;
	_containerController._ln_bottomBarExtension_nocreate.effectView.effect = _containerController.popupBar.backgroundView.effect;
	[_containerController.popupBar _applyGroupingIdentifierToVisualEffectView:_containerController._ln_bottomBarExtension_nocreate.effectView];
	_popupContentView.clipsToBounds = YES;
}

- (void)_movePopupBarAndContentToBottomBarSuperview
{
	[self.popupBar removeFromSuperview];
	[self.popupContentView removeFromSuperview];
	
	if([_bottomBar.superview isKindOfClass:[UIScrollView class]])
	{
		NSLog(@"Attempted to present popup bar %@ on top of a UIScrollView subclass %@. This is unsupported and may result in unexpected behavior.", self.popupBar, _bottomBar.superview);
	}
	
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
	_popupBar._barDelegate = self;
	_popupBar.popupOpenGestureRecognizer = [[LNPopupOpenTapGesutreRecognizer alloc] initWithTarget:self action:@selector(_popupBarTapGestureRecognized:)];
	[_popupBar addGestureRecognizer:_popupBar.popupOpenGestureRecognizer];
	
	_popupBar.barHighlightGestureRecognizer = [[LNPopupLongPressGesutreRecognizer alloc] initWithTarget:self action:@selector(_popupBarLongPressGestureRecognized:)];
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

- (void)presentPopupBarAnimated:(BOOL)animated openPopup:(BOOL)open completion:(void(^)(void))completionBlock
{
	UIViewController* old = _currentContentController;
	[self _reconfigureContentWithOldContentController:old newContentController:_containerController.popupContentViewController];
	
	if(_popupControllerTargetState == LNPopupPresentationStateBarHidden)
	{
		_dismissalOverride = NO;
		
		_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillPresentPopupBar:animated:), animated);
		
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
		
		self.popupBarStorage.hidden = NO;
		
		[self _movePopupBarAndContentToBottomBarSuperview];
		[self _configurePopupBarFromBottomBar];
		
		[self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
		
		[self _setContentToState:LNPopupPresentationStateBarPresented];
		
		[_containerController.view layoutIfNeeded];
		
		[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
			CGRect barFrame = self.popupBar.frame;
			barFrame.size.height = _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController);
			self.popupBar.frame = barFrame;
			
			self.popupBar.frame = [self _frameForClosedPopupBar];
			
			[self.popupBar setNeedsLayout];
			[self.popupBar layoutIfNeeded];
			
			_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsMake(0, 0, barFrame.size.height, 0));
			
			if(open)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
				[self openPopupAnimated:animated completion:completionBlock];
			}
		} completion:^(BOOL finished) {
			if(!open)
			{
				_popupControllerInternalState = LNPopupPresentationStateBarPresented;
				[_containerController _ln_setPopupPresentationState:LNPopupPresentationStateBarPresented];
			}
			
			_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidPresentPopupBar:animated:), animated);
			
			if(open)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidOpenPopup:animated:), animated);
			}
			
			if(completionBlock != nil && !open)
			{
				completionBlock();
			}
		}];
	}
	else
	{
		if(open)
		{
			[self openPopupAnimated:animated completion:completionBlock];
		}
		else if(completionBlock != nil)
		{
			completionBlock();
		}
	}
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _transitionToState:_LNPopupPresentationStateTransitioning notifyDelegate:NO animated:NO useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:^{
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		[self _transitionToState:LNPopupPresentationStateOpen notifyDelegate:YES animated:animated useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:NO];
	} transitionOriginatedByUser:YES];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	[self _transitionToState:LNPopupPresentationStateBarPresented notifyDelegate:YES animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap ? YES : NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:YES];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(_dismissalOverride == YES)
	{
		if(completionBlock != nil) { completionBlock(); }
		return;
	}
	
	if(_popupControllerInternalState != LNPopupPresentationStateBarHidden)
	{
		void (^dismissalAnimationCompletionBlock)(void) = ^
		{
			_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
			_popupControllerTargetState = LNPopupPresentationStateBarHidden;
			
			_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillDismissPopupBar:animated:), animated);
			
			[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
			 {
				 CGRect barFrame = self.popupBar.frame;
				 barFrame.size.height = 0;
				 self.popupBar.frame = barFrame;
				 
				 _LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
			 } completion:^(BOOL finished) {
				 _popupControllerInternalState = LNPopupPresentationStateBarHidden;
				 
				 [self _removeContentControllerFromContentView:_currentContentController];
				 
				 CGRect bottomBarFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
				 bottomBarFrame.origin.y -= _cachedInsets.bottom;
				 _bottomBar.frame = bottomBarFrame;
				 _bottomBar = nil;
				 
				 self.popupBarStorage.hidden = YES;
				 [self.popupBar removeFromSuperview];
				 
				 [self.popupContentView removeFromSuperview];
				 self.popupContentView.popupInteractionGestureRecognizer = nil;
				 self.popupContentView = nil;
				 
				 _LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
				 
				 _currentContentController = nil;
				 
				 _effectiveStatusBarUpdateController = nil;
				 
				 _LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidDismissPopupBar:animated:), animated);
				 
				 [_containerController _ln_setPopupPresentationState:LNPopupPresentationStateBarHidden];
				 
				 if(completionBlock != nil) { completionBlock(); }
			 }];
		};
		
		_dismissalOverride = YES;
		
		if(_popupControllerTargetState != LNPopupPresentationStateBarPresented)
		{
//			self.popupBarStorage.hidden = YES;
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

- (void)_traitCollectionForPopupBarDidChange:(LNPopupBar*)bar
{
	[self _configurePopupBarFromBottomBar];
}

- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar
{
	CGRect barFrame = self.popupBar.frame;
	CGFloat currentHeight = barFrame.size.height;
	barFrame.size.height = _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController);
	barFrame.origin.y -= (barFrame.size.height - currentHeight);
	self.popupBar.frame = barFrame;
	
	_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsMake(0, 0, self.popupBar.frame.size.height, 0));
}

- (void)_popupBarStyleDidChange:(LNPopupBar*)bar
{
	[self _updateBarExtensionStyleFromPopupBar];
	[_containerController.popupBar _applyGroupingIdentifierToVisualEffectView:self.popupContentView.effectView];
}

#pragma mark Utils

+ (CGFloat)_statusBarHeightForView:(UIView*)view
{
#if TARGET_OS_MACCATALYST
	return 0;
#else
	if(view == nil || view.window == nil)
	{
		return 0;
	}
	
	if (@available(iOS 13.0, *))
	{
		if(view.window.safeAreaInsets.top == 0)
		{
			//Probably 🤷‍♂️ an old iPhone
			return view.window.windowScene.statusBarManager.statusBarHidden ? 0 : 20;
		}
		
		return view.window.safeAreaInsets.top;
	}
	
	return UIApplication.sharedApplication.statusBarFrame.size.height;
#endif
}

@end
