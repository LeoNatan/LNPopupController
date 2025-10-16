//
//  LNPopupController.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupControllerImpl.h"
#import "LNPopupCloseButton+Private.h"
#import "LNPopupItem+Private.h"
#import "LNPopupOpenTapGestureRecognizer.h"
#import "LNPopupLongPressGestureRecognizer.h"
#import "LNPopupInteractionPanGestureRecognizer.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "UIView+LNPopupSupportPrivate.h"
#import "LNPopupCustomBarViewController+Private.h"
#import "_LNPopupTransitionView.h"
#import "_LNPopupTransitionPreferredOpenAnimator.h"
#import "_LNPopupTransitionGenericOpenAnimator.h"
#import "_LNPopupTransitionGenericCloseAnimator.h"
#import "_LNPopupTransitionPreferredCloseAnimator.h"
#import "LNPopupPresentationContainerSupport.h"
#import "UITabBar+LNPopupMinimizationSupport.h"

#import <objc/runtime.h>
#import <os/log.h>

#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif

#ifdef DEBUG
#import "LNPopupDebug.h"

static BOOL _LNEnableSlowTransitionsDebug(void)
{
	return [__LNDebugUserDefaults() boolForKey:@"__LNPopupEnableSlowTransitionsDebug"];
}
#endif

CF_EXTERN_C_BEGIN

static const NSTimeInterval LNPopupBarTransitionDuration = 0.5;

static const CGFloat LNPopupBarGestureHeightPercentThreshold = 0.2;

LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style)
{
	LNPopupInteractionStyle rv = style;
	if(rv == LNPopupInteractionStyleDefault)
	{
		if([LNPopupBar isCatalystApp])
		{
			rv = LNPopupInteractionStyleScroll;
		}
		else
		{
			rv = LNPopupInteractionStyleSnap;
		}
	}
	return rv;
}

OS_ALWAYS_INLINE
static BOOL _LNCallDelegateObjectObjectBool(UIViewController* controller, UIViewController* content, SEL selector, BOOL animated)
{
	if([controller.popupPresentationDelegate respondsToSelector:selector])
	{
		void (*msgSendObjectObjectBool)(id, SEL, id, id, BOOL) = reinterpret_cast<decltype(msgSendObjectObjectBool)>(objc_msgSend);
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
		void (*msgSendObjectBool)(id, SEL, id, BOOL) = reinterpret_cast<decltype(msgSendObjectBool)>(objc_msgSend);
		msgSendObjectBool(controller.popupPresentationDelegate, selector, controller, animated);
		return YES;
	}
	return NO;
}

#pragma mark Popup Controller

@interface LNPopupController () <_LNPopupItemDelegate, _LNPopupTabBarMinimizationDelegate>

- (void)_applicationDidEnterBackground;
- (void)_applicationWillEnterForeground;
- (void)_popupBarTapGestureRecognized:(UITapGestureRecognizer*)tgr;
- (void)_popupBarLongPressGestureRecognized:(UILongPressGestureRecognizer*)lpgr;
- (void)_closePopupContent;
- (void)_popupBarPresentationByUserPanGestureHandler:(UIPanGestureRecognizer*)pgr;
- (void)_120HzTick;

@end

@interface _LNPopupControllerEvent: NSObject

@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSSet<NSString*>* coalescedOperations;
@property (nonatomic, strong, readonly) dispatch_block_t operation;

@end

@implementation _LNPopupControllerEvent

+ (instancetype)_eventWithName:(NSString*)name coalescedOperations:(NSArray<NSString*>*)coalescedOperations operation:(dispatch_block_t)operation
{
	_LNPopupControllerEvent* rv = [_LNPopupControllerEvent new];
	rv->_name = name;
	rv->_operation = operation;
	rv->_coalescedOperations = [NSSet setWithArray:coalescedOperations];
	return rv;
}

+ (instancetype)presentEventWithOperation:(dispatch_block_t)operation
{
	return [self _eventWithName:@"present" coalescedOperations:@[@"present", @"dismiss"] operation:operation];
}

+ (instancetype)dismissEventWithOperation:(dispatch_block_t)operation
{
	return [self _eventWithName:@"dismiss" coalescedOperations:@[@"present", @"open", @"close", @"dismiss"] operation:operation];
}

+ (instancetype)openEventWithOperation:(dispatch_block_t)operation
{
	return [self _eventWithName:@"open" coalescedOperations:@[@"open", @"close"] operation:operation];
}

+ (instancetype)closeEventWithOperation:(dispatch_block_t)operation
{
	return [self _eventWithName:@"close" coalescedOperations:@[@"close", @"open"] operation:operation];
}

@end

__attribute__((objc_direct_members))
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
	
	UIImpactFeedbackGenerator* _softFeedbackGenerator;
	UIImpactFeedbackGenerator* _rigidFeedbackGenerator;
	
	NSArray<_LNPopupControllerEvent*>* _eventQueue;
	
	UIViewPropertyAnimator* _runningBarAnimation;
	UIViewPropertyAnimator* _runningBarSidecarAnimation;
	
	UIViewPropertyAnimator* _runningPopupAnimation;
	
	UIWindow* _lockedRotationWindow;
}

@synthesize popupContentView=_popupContentView;

- (instancetype)initWithContainerViewController:(__kindof UIViewController*)containerController
{
	self = [super init];
	
	if(self)
	{
		_containerController = containerController;
		
		LNDynamicSubclass(_containerController, LNPopupPresentationContainerSupport.class);
		
		_popupControllerInternalState = LNPopupPresentationStateBarHidden;
		_popupControllerTargetState = LNPopupPresentationStateBarHidden;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
		
		_wantsFeedbackGeneration = YES;
		_softFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSoft];
		_rigidFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleRigid];
	}
	
	return self;
}

- (void)setContainerController:(__kindof UIViewController *)containerController
{
	_containerController = containerController;
}

- (void)setBottomBar:(UIView *)bottomBar
{
	if(@available(iOS 17.0, *))
	{
		[_bottomBar.traitOverrides setObject:nil forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
	}
	
	_bottomBar = bottomBar;
	
	if(LNPopupBar.isCatalystApp == YES)
	{
		return;
	}
	
	if(@available(iOS 17.0, *))
	{
		[_bottomBar.traitOverrides setObject:self.popupBar.effectGroupingIdentifier forTrait:_LNPopupBarBackgroundGroupNameOverride.class];
	}
}

- (CGRect)_frameForOpenPopupBar
{
	return CGRectMake(0, - self.popupBar.frame.size.height, _containerController.view.bounds.size.width, self.popupBar.frame.size.height);
}

- (CGRect)_frameForClosedPopupBar
{
	return [self _frameForClosedPopupBarForBarHeight:self.popupBar.frame.size.height];
}

- (CGRect)_frameForClosedPopupBarForBarHeight:(CGFloat)barHeight
{
	CGRect defaultFrame = [_containerController _defaultFrameForBottomDockingViewForPopupBar:_popupBar];
	UIEdgeInsets insets = UIEdgeInsetsZero;
	if(!LNPopupEnvironmentHasGlass())
	{
		insets = [_containerController insetsForBottomDockingView];
	}
	CGFloat offset = [_containerController _ln_popupOffsetForPopupBar:_popupBar];
	return CGRectMake(0, defaultFrame.origin.y - barHeight - insets.bottom + offset, _containerController.view.bounds.size.width, barHeight);
}

- (void)_repositionPopupContentMovingBottomBar:(BOOL)bottomBar animated:(BOOL)animated
{
	CGFloat percent = [self _percentFromPopupBarForBottomBarDisplacement];
	
	CGFloat barHeight = (_bottomBar.isHidden ? 0 : _bottomBar.bounds.size.height) + _cachedInsets.bottom;
	CGFloat heightForContent = _containerController.view.bounds.size.height - (1.0 - percent) * barHeight;
	
	if(bottomBar && _containerController.bottomDockingViewForPopupBar == nil && !LNPopupEnvironmentHasGlass())
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
	
	if(self.popupControllerTargetState <= LNPopupPresentationStateBarPresented)
	{
		CGFloat offset = [_containerController _ln_popupOffsetForPopupBar:self.popupBar];
		contentFrame.size.height = 0;
		contentFrame.origin.y -= offset;
	}
	
	self.popupContentView.frame = contentFrame;
	
	_containerController.popupContentViewController.view.frame = _containerController.view.bounds;
	
	[self.popupContentView _repositionPopupCloseButtonAnimated:animated];
}

static CGFloat __clamp(CGFloat x)
{
	return MAX(0, MIN(1, x));
}

static CGFloat __smoothstep(CGFloat a, CGFloat b, CGFloat x)
{
	float t = __clamp((x - a)/(b - a));
	return t * t * (3.0 - (2.0 * t));
}

- (CGFloat)_percentFromPopupBar
{
	return 1 - (CGRectGetMaxY(self.popupBar.frame) / (_cachedDefaultFrame.origin.y - _cachedInsets.bottom));
}

- (CGFloat)_percentFromPopupBarForBottomBarDisplacement
{
	CGFloat percent = [self _percentFromPopupBar];
	
	return __smoothstep(0.0, 1.0, percent);
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
	
	_cachedDefaultFrame = [_containerController _defaultFrameForBottomDockingViewForPopupBar:_popupBar];
	if(LNPopupEnvironmentHasGlass())
	{
		_cachedInsets = UIEdgeInsetsZero;
	}
	else
	{
		_cachedInsets = [_containerController insetsForBottomDockingView];
	}
	CGFloat offset = [_containerController _ln_popupOffsetForPopupBar:_popupBar];
	_cachedInsets.bottom -= offset;
	
	self.popupBar.frame = targetFrame;
	
	if(state != _LNPopupPresentationStateTransitioning)
	{
		[_containerController setNeedsStatusBarAppearanceUpdate];
		[_containerController setNeedsUpdateOfHomeIndicatorAutoHidden];
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
	currentContentController.view.translatesAutoresizingMaskIntoConstraints = YES;
	currentContentController.view.autoresizingMask = UIViewAutoresizingNone;
	currentContentController.view.frame = self.popupContentView.contentView.bounds;
	[self.popupContentView.contentView addSubview:currentContentController.view];
	currentContentController.popupPresentationContainerViewController = self.containerController;
	[currentContentController viewDidMoveToPopupContainerContentView:self.popupContentView];
}

- (void)_removeContentControllerFromContentView:(UIViewController*)oldContentController
{
	if(oldContentController == nil)
	{
		return;
	}
	
	[oldContentController viewWillMoveToPopupContainerContentView:nil];
	[oldContentController.view removeFromSuperview];
	if(@available(iOS 17.0, *))
	{
		[oldContentController.traitOverrides removeTrait:LNPopupBarEnvironmentTrait.class];
	}
	oldContentController.popupPresentationContainerViewController = nil;
	[oldContentController viewDidMoveToPopupContainerContentView:nil];
}

- (void)_generateSoftFeedbackWithIntensity:(CGFloat)intensity
{
	if(_wantsFeedbackGeneration == NO)
	{
		return;
	}
	
	[_softFeedbackGenerator prepare];
	[_softFeedbackGenerator impactOccurredWithIntensity:intensity];
}

- (void)_generateRigidFeedbackWithIntensity:(CGFloat)intensity
{
	if(_wantsFeedbackGeneration == NO)
	{
		return;
	}
	
	[_rigidFeedbackGenerator prepare];
	[_rigidFeedbackGenerator impactOccurredWithIntensity:intensity];
}

- (BOOL)_validateViewForTransition:(UIView*)viewToValidate
{
	if(viewToValidate == nil)
	{
		return NO;
	}
	
	if(viewToValidate == self.popupContentView || [viewToValidate isDescendantOfView:self.popupContentView] == NO)
	{
		return NO;
	}
	
	return YES;
}

- (_LNPopupTransitionView*)_customTransitionViewForTransitionFromState:(LNPopupPresentationState)fromState toState:(LNPopupPresentationState)state userView:(out id<LNPopupTransitionView> _Nonnull __strong * _Nonnull)userView
{
	//Normally, only LNPopupUI should provide a custom transition view
	_LNPopupTransitionView* userTransitionView = (id)[self.currentContentController _ln_transitionViewForPopupTransitionFromPresentationState:fromState toPresentationState:state view:userView];
	
	if(userTransitionView == nil || [userTransitionView isKindOfClass:_LNPopupTransitionView.class] == NO)
	{
		return nil;
	}
	
	return userTransitionView;
}

- (UIView*)_supportedUserViewForTransitionFromState:(LNPopupPresentationState)fromState toState:(LNPopupPresentationState)state
{
	UIView* userView = [self.currentContentController viewForPopupTransitionFromPresentationState:fromState toPresentationState:state];
	
	if([self _validateViewForTransition:userView] == NO)
	{
		return nil;
	}
	
	return userView;
}

- (void)animateOpenTransitionIfNeededWithAnimator:(UIViewPropertyAnimator*)animator customTransitionView:(_LNPopupTransitionView*)customTransitionView userViewForTransition:(UIView*)userView otherAnimations:(void(^)(void))otherAnimations
{
	_LNPopupTransitionOpenAnimator* handler;
	if([userView conformsToProtocol:@protocol(LNPopupTransitionView)])
	{
		handler = [[_LNPopupTransitionPreferredOpenAnimator alloc] initWithTransitionView:customTransitionView userView:userView popupBar:self.popupBar popupContentView:self.popupContentView];
	}
	else
	{
		handler = [[_LNPopupTransitionGenericOpenAnimator alloc] initWithTransitionView:customTransitionView userView:userView popupBar:self.popupBar popupContentView:self.popupContentView];
	}
	
	[handler animateWithAnimator:animator otherAnimations:otherAnimations];
}

- (void)animateCloseTransitionIfNeededWithAnimator:(UIViewPropertyAnimator*)animator customTransitionView:(_LNPopupTransitionView*)userTransitionView userViewForTransition:(UIView*)userView otherAnimations:(void(^)(void))otherAnimations
{
	_LNPopupTransitionCloseAnimator* handler;
	
	if([userView conformsToProtocol:@protocol(LNPopupTransitionView)])
	{
		handler = [[_LNPopupTransitionPreferredCloseAnimator alloc] initWithTransitionView:userTransitionView userView:userView popupBar:self.popupBar popupContentView:self.popupContentView currentContentController:self.currentContentController containerController:self.containerController];
	}
	else
	{
		handler = [[_LNPopupTransitionGenericCloseAnimator alloc] initWithTransitionView:userTransitionView userView:userView popupBar:self.popupBar popupContentView:self.popupContentView currentContentController:self.currentContentController containerController:self.containerController];
	}
	
	[handler animateWithAnimator:animator otherAnimations:otherAnimations];
}

- (void)_transitionToState:(LNPopupPresentationState)state notifyDelegate:(BOOL)notifyDelegate animated:(BOOL)animated useSpringAnimation:(BOOL)spring allowPopupBarAlphaModification:(BOOL)allowBarAlpha allowFeedbackGeneration:(BOOL)allowFeedbackGeneration forceFeedbackGenerationAtStart:(BOOL)forceFeedbackAtStart completion:(void(^)(void))completion
{
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
			
			[self.popupContentView _applyBackgroundEffectWithContentViewController:_currentContentController activeAppearance:self.popupBar.activeAppearance];
			
			self.popupContentView.currentPopupContentViewController = _currentContentController;
			[self.popupContentView.contentView sendSubviewToBack:_currentContentController.view];
			
			[self.popupContentView.contentView setNeedsLayout];
			[self.popupContentView.contentView layoutIfNeeded];
			if(notifyDelegate == YES && state == _LNPopupPresentationStateTransitioning)
			{
				[_currentContentController _userFacing_viewIsAppearing:NO];
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
	if(notifyDelegate && (_popupControllerPublicState == LNPopupPresentationStateBarPresented || _popupControllerPublicState == LNPopupPresentationStateBarHidden) && state == LNPopupPresentationStateOpen)
	{
		shouldNotifyDelegateWillOpen = YES;
	}
	
	if(state != _LNPopupPresentationStateTransitioning)
	{
		[self _start120HzHack];
	}
	
	LNPopupPresentationState stateAtStart = _popupControllerInternalState;
	LNPopupPresentationState publicStateAtStart = _popupControllerPublicState;
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
			if(allowFeedbackGeneration == YES && (forceFeedbackAtStart || resolvedStyle == LNPopupInteractionStyleSnap))
			{
				[self _generateSoftFeedbackWithIntensity:0.9];
			}
			
			if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:willOpenPopupWithContentController:animated:), animated) == NO)
			{
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
			}
		}
		
		if(shouldNotifyDelegateWillClose == YES)
		{
			if(allowFeedbackGeneration == YES && (forceFeedbackAtStart || resolvedStyle == LNPopupInteractionStyleSnap))
			{
				[self _generateRigidFeedbackWithIntensity:0.9];
			}
			
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
			[UIView performWithoutAnimation:^{
				_popupContentView.hidden = NO;
			}];
			[_currentContentController _userFacing_viewWillAppear:animated];
		}
		
		if(state == LNPopupPresentationStateBarPresented)
		{
			[_currentContentController beginAppearanceTransition:NO animated:animated];
			[_currentContentController _userFacing_viewWillDisappear:animated];
		}
		
		[self _setContentToState:state animated:animated];
		[_containerController.view layoutIfNeeded];
		
		if(state == LNPopupPresentationStateOpen && stateAtStart == LNPopupPresentationStateBarPresented)
		{
			[_currentContentController _userFacing_viewIsAppearing:animated];
		}
	};
	
	void (^completionBlock)(UIViewAnimatingPosition) = ^(UIViewAnimatingPosition position) {
		if(position != UIViewAnimatingPositionEnd)
		{
			return;
		}
		
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
			[self.popupBar.contentView addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			
			[self.popupBar _setTitleViewMarqueesPaused:NO];
			
			_popupContentView.accessibilityViewIsModal = NO;
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
			
//			if(allowFeedbackGeneration == YES && (forceFeedbackAtStart == false && resolvedStyle != LNPopupInteractionStyleSnap))
//			{
//				[self _generateSoftFeedbackWithIntensity:0.8];
//			}
		}
		
		_popupControllerInternalState = state;
		if(state != _LNPopupPresentationStateTransitioning)
		{
			[_containerController _ln_setPopupPresentationState:state];
			[self _end120HzHack];
		}
		
		if(state == LNPopupPresentationStateBarPresented && _popupControllerPublicState == LNPopupPresentationStateBarPresented && publicStateAtStart != _popupControllerPublicState)
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
			
//			if(allowFeedbackGeneration == YES && (forceFeedbackAtStart == false && resolvedStyle != LNPopupInteractionStyleSnap))
//			{
//				[self _generateSoftFeedbackWithIntensity:0.8];
//			}
			
			if(_popupControllerPublicState == LNPopupPresentationStateOpen && publicStateAtStart != _popupControllerPublicState)
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
	
//	[self _clearRunningPopupAnimators];
	
	_LNPopupTransitionView* transitionView;
	UIView<LNPopupTransitionView>* userView;
	if((self.popupBar.resolvedIsCompact == NO || self.popupBar.resolvedIsFloating) &&
	   resolvedStyle == LNPopupInteractionStyleSnap &&
	   ((stateAtStart == LNPopupPresentationStateBarPresented && state == LNPopupPresentationStateOpen) ||
		(state == LNPopupPresentationStateBarPresented)))
	{
		//Normally, only LNPopupUI should provide a custom transition view
		transitionView = [self _customTransitionViewForTransitionFromState:publicStateAtStart toState:state userView:&userView];
		
		if(transitionView == nil)
		{
			userView = (id)[self _supportedUserViewForTransitionFromState:publicStateAtStart toState:state];
		}
	}
	
	CGFloat animationDuration = resolvedStyle == LNPopupInteractionStyleSnap ? 0.5 : 0.5;
#if DEBUG
	if(_LNEnableSlowTransitionsDebug())
	{
		animationDuration = 4.0;
	}
#endif

	_runningPopupAnimation = [[UIViewPropertyAnimator alloc] initWithDuration:animationDuration dampingRatio:spring ? 0.85 : 1.0 animations:nil];
	_runningPopupAnimation.userInteractionEnabled = state == LNPopupPresentationStateOpen;
	
	if(stateAtStart == LNPopupPresentationStateBarPresented)
	{
		[self animateOpenTransitionIfNeededWithAnimator:_runningPopupAnimation customTransitionView:transitionView userViewForTransition:userView otherAnimations:animationBlock];
	}
	else if(state == LNPopupPresentationStateBarPresented)
	{
		[self animateCloseTransitionIfNeededWithAnimator:_runningPopupAnimation customTransitionView:transitionView userViewForTransition:userView otherAnimations:animationBlock];
	}
	else
	{
		[_runningPopupAnimation addAnimations:animationBlock];
	}
	
	[_runningPopupAnimation addCompletion:completionBlock];
	[_runningPopupAnimation addCompletion:^(UIViewAnimatingPosition finalPosition) {
		_runningPopupAnimation = nil;
		if(animated)
		{
			[self _endTransitioningLock];
		}
	}];
	[self _addEventQueueResumptionStep:_runningPopupAnimation];
	
	if(animated)
	{
		[self _beginTransitionLockWithUserInteractionEnabled:state == LNPopupPresentationStateOpen];
	}
	
	[_runningPopupAnimation startAnimation];
	
	if(animated == NO)
	{
		UIViewPropertyAnimator* retained = _runningPopupAnimation;
		[retained stopAnimation:NO];
		[retained finishAnimationAtPosition:UIViewAnimatingPositionEnd];
	}
}

- (void)_popupBarLongPressGestureRecognized:(UILongPressGestureRecognizer*)lpgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultHighlightGestureRecognizer == NO)
	{
		return;
	}
	
	switch(lpgr.state)
	{
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

- (void)_beginTransitionLockWithUserInteractionEnabled:(BOOL)userInteractionEnabled
{
	[UIViewController _ln_beginTransitioningLockWithWindow:_containerController.view.window userInteractionsEnabled:userInteractionEnabled allowedViews:@[self.popupBar, self.popupContentView] lockRotation:_lockedRotationWindow == nil];
	_lockedRotationWindow = _containerController.view.window;
}

- (void)_endTransitioningLock
{
//	NSLog(@"_endTransitioningLock %@", _lockedRotationWindow);
	if(_lockedRotationWindow)
	{
		[UIViewController _ln_endTransitioningLockWithWindow:_lockedRotationWindow unlockingRotation:YES];
		_lockedRotationWindow = nil;
	}
}

- (void)_popupBarTapGestureRecognized:(UITapGestureRecognizer*)tgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultTapGestureRecognizer == NO)
	{
		return;
	}
	
	switch(tgr.state)
	{
		case UIGestureRecognizerStateEnded:
		{
			[_containerController.view setNeedsLayout];
			[_containerController.view layoutIfNeeded];
			[self openPopupAnimated:YES completion:nil];
		}	break;
		default:
			break;
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_began:(UIPanGestureRecognizer*)pgr
{
	if(LNPopupBar.isCatalystApp)
	{
		UIEvent* event = self.popupBar.window._ln_currentEvent;
		if(event != nil && event.type == 22 /*NSEventTypeScrollWheel*/)
		{
			return;
		}
	}
	
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
	
	[self _start120HzHack];
	[self _beginTransitionLockWithUserInteractionEnabled:YES];
	
	CGPoint velocity = [pgr velocityInView:self.popupBar];
	BOOL isVertical = fabs(velocity.y) > fabs(velocity.x);
	
	if(resolvedStyle == LNPopupInteractionStyleSnap)
	{
		if((_popupControllerInternalState == LNPopupPresentationStateBarPresented && isVertical && velocity.y < 0))
		{
			[self _end120HzHack];
			
			pgr.enabled = NO;
			pgr.enabled = YES;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self openPopupAnimated:YES completion:nil];
			});
		}
		else if((_popupControllerInternalState == LNPopupPresentationStateBarPresented && [pgr velocityInView:self.popupBar].y > 0))
		{
			[self _end120HzHack];
			[self _endTransitioningLock];
			
			pgr.enabled = NO;
			pgr.enabled = YES;
		}
		else
		{
			[self _end120HzHack];
			[self _endTransitioningLock];
		}
	}
	
	if(resolvedStyle == LNPopupInteractionStyleDrag && _popupControllerInternalState == LNPopupPresentationStateBarPresented && (isVertical == NO || [pgr velocityInView:self.popupBar].y > 0))
	{
		[self _end120HzHack];
		[self _endTransitioningLock];
		
		pgr.enabled = NO;
		pgr.enabled = YES;
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
	if(LNPopupBar.isCatalystApp && self.popupBar.window._ln_currentEvent.type == 22 /*NSEventTypeScrollWheel*/)
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
	
	CGPoint translation = [pgr translationInView:pgr.view];
	BOOL isVerticalPan = fabs(translation.y) > fabs(translation.x);
	
	if(CGPointEqualToPoint(translation, CGPointZero))
	{
		return;
	}
	
	if(pgr != _popupContentView.popupInteractionGestureRecognizer)
	{
		UIScrollView* possibleScrollView = (id)pgr.view;
		if([possibleScrollView isKindOfClass:[UIScrollView class]] && [NSStringFromClass(pgr.class) hasPrefix:@"UIScrollView"])
		{
			//If not scrolling only vertically, ignore the scroll view's pan gesture recognizer.
			if(possibleScrollView._ln_scrollingOnlyVertically == NO)
			{
				if(isVerticalPan == NO)
				{
					_popupContentView.popupInteractionGestureRecognizer.enabled = NO;
					_popupContentView.popupInteractionGestureRecognizer.enabled = YES;
				}
				else if(_dismissGestureStarted == YES)
				{
					pgr.enabled = NO;
					pgr.enabled = YES;
				}
				
				return;
			}
			
			id<UIGestureRecognizerDelegate> delegate = _popupContentView.popupInteractionGestureRecognizer.delegate;
			
			if(([delegate respondsToSelector:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)] && [delegate gestureRecognizer:_popupContentView.popupInteractionGestureRecognizer shouldRequireFailureOfGestureRecognizer:pgr] == YES) ||
			   ([delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] && [delegate gestureRecognizer:_popupContentView.popupInteractionGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:pgr] == NO) ||
			   (_dismissGestureStarted == NO && (possibleScrollView._ln_isAtTop == NO || translation.y < 0)))
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
		BOOL allowFeedback = (_popupControllerInternalState == LNPopupPresentationStateOpen && translation.y > 0) || (_popupControllerInternalState == LNPopupPresentationStateBarPresented && translation.y < 0);
		
		if(resolvedStyle != LNPopupInteractionStyleSnap && allowFeedback)
		{
			[self _generateSoftFeedbackWithIntensity:0.8];
		}
		
		_lastSeenMovement = CACurrentMediaTime();
		BOOL prevState = self.popupBar.barHighlightGestureRecognizer.enabled;
		self.popupBar.barHighlightGestureRecognizer.enabled = NO;
		self.popupBar.barHighlightGestureRecognizer.enabled = prevState;
		_lastPopupBarLocation = self.popupBar.center;
		
		_statusBarThresholdDir = _popupControllerInternalState == LNPopupPresentationStateOpen ? 1 : -1;
		
		_stateBeforeDismissStarted = _popupControllerInternalState;
		
		[self _transitionToState:_LNPopupPresentationStateTransitioning notifyDelegate:YES animated:NO useSpringAnimation:NO allowPopupBarAlphaModification:YES allowFeedbackGeneration:NO forceFeedbackGenerationAtStart:NO completion:nil];
		
		_cachedDefaultFrame = [_containerController _defaultFrameForBottomDockingViewForPopupBar:_popupBar];
		if(LNPopupEnvironmentHasGlass())
		{
			_cachedInsets = UIEdgeInsetsZero;
		}
		else
		{
			_cachedInsets = [_containerController insetsForBottomDockingView];
		}
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
			
			_popupContentView.popupInteractionGestureRecognizer.enabled = NO;
			_popupContentView.popupInteractionGestureRecognizer.enabled = YES;
			
			[self closePopupAnimated:YES completion:^ {
				[_popupContentView.popupCloseButton _setButtonContainerStationary];
			}];
		}
		
		CGFloat statusBarHeightThreshold = [LNPopupController _statusBarHeightForView:_containerController.view] / 2.0;
		
		if((_statusBarThresholdDir == 1 && currentCenterY < targetCenterY && _popupContentView.frame.origin.y >= statusBarHeightThreshold)
		   || (_statusBarThresholdDir == -1 && currentCenterY > targetCenterY && _popupContentView.frame.origin.y < statusBarHeightThreshold))
		{
			_statusBarThresholdDir = -_statusBarThresholdDir;
			
			[UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:0 animations:^{
				[_containerController setNeedsStatusBarAppearanceUpdate];
				[_containerController setNeedsUpdateOfHomeIndicatorAutoHidden];
			} completion:nil];
		}
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_endedOrCancelled:(UIPanGestureRecognizer*)pgr
{
	if(_dismissGestureStarted == NO)
	{
		[self _end120HzHack];
		[self _endTransitioningLock];
	}
	else
	{
		LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
		
		LNPopupPresentationState targetState;
		if(resolvedStyle == LNPopupInteractionStyleSnap)
		{
			targetState = _popupControllerPublicState;
		}
		else
		{
			targetState = _stateBeforeDismissStarted;
		}
		
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
		if(targetState == LNPopupPresentationStateOpen)
		{
			[self openPopupAnimated:YES allowFeedbackGeneration:targetState != _stateBeforeDismissStarted forceFeedbackGenerationAtStart:resolvedStyle == LNPopupInteractionStyleSnap trollState:resolvedStyle == LNPopupInteractionStyleSnap completion:nil];
		}
		else
		{
			[self closePopupAnimated:YES allowFeedbackGeneration:targetState != _stateBeforeDismissStarted forceFeedbackGenerationAtStart:resolvedStyle == LNPopupInteractionStyleSnap completion:nil];
		}
	}
	
	_dismissGestureStarted = NO;
}

- (void)_popupBarPresentationByUserPanGestureHandler:(UIPanGestureRecognizer*)pgr
{
	if(_dismissalOverride)
	{
		return;
	}
	
	switch(pgr.state)
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

- (void)_reconfigureBarItems
{
	[self.popupBarStorage setLeadingBarButtonItems:_currentPopupItem.leadingBarButtonItems];
	[self.popupBarStorage setTrailingBarButtonItems:_currentPopupItem.trailingBarButtonItems];
}

- (void)_popupItem:(LNPopupItem*)popupItem didChangeToValue:(id)value forKey:(NSString*)key
{
	if(self.popupBarStorage.customBarViewController)
	{
		[self.popupBarStorage.customBarViewController popupItemDidUpdate];
	}
	else
	{
		NSString* reconfigureSelector = [NSString stringWithFormat:@"_popupItem_update_%@", key];
		
		if([self respondsToSelector:NSSelectorFromString(reconfigureSelector)])
		{
			void (*configureDispatcher)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
			configureDispatcher(self, NSSelectorFromString(reconfigureSelector));
		}
		else
		{
			[self.popupBarStorage setValue:value forKey:key];
		}
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
	
	[self _addContentControllerSubview:newContentController];
	
	if(oldContentController != nil)
	{
		[self.popupContentView.contentView insertSubview:newContentController.view belowSubview:oldContentController.view];
	}
	else
	{
		[self.popupContentView.contentView sendSubviewToBack:newContentController.view];
	}
	
	[self _removeContentControllerFromContentView:oldContentController];
	
	if(_popupControllerInternalState > LNPopupPresentationStateBarPresented)
	{
		[newContentController _userFacing_viewIsAppearing:NO];
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
		for(NSString* key in __LNPopupItemObservedKeys)
		{
			[self _popupItem:_currentPopupItem didChangeToValue:[_currentPopupItem valueForKey:key] forKey:key];
		}
	}
}

- (void)_configurePopupBarFromBottomBar
{
	[self _configurePopupBarFromBottomBarModifyingGroupingIdentifier:YES];
}

- (void)_configurePopupBarFromBottomBarModifyingGroupingIdentifier:(BOOL)modifyingGroupingIdentifier
{
	if(ln_unavailable(iOS 17.0, *))
	{
		if(modifyingGroupingIdentifier == YES)
		{
			self.popupBar.effectGroupingIdentifier = _bottomBar._ln_effectGroupingIdentifierIfAvailable;
			//Schedule one more effect identifier refresh, in case it's not yet ready at this point.
			dispatch_async(dispatch_get_main_queue(), ^{
				self.popupBar.effectGroupingIdentifier = _bottomBar._ln_effectGroupingIdentifierIfAvailable;
			});
		}
	}
	
	if(self.popupBar.inheritsAppearanceFromDockingView == NO)
	{
		return;
	}
	
	UIBarAppearance* appearanceToUse = nil;
	
#ifndef LNPopupControllerEnforceStrictClean
	static NSString* vPTIS = LNPopupHiddenString("visualProvider.toolbarIsSmall");
	
	//visualProvider.toolbarIsSmall
	if([_bottomBar isKindOfClass:UIToolbar.class] &&  [[_bottomBar valueForKeyPath:vPTIS] boolValue] == YES)
	{
		UIToolbar* toolbar = (UIToolbar*)_bottomBar;
		appearanceToUse = toolbar.compactAppearance;
	}
	
	if(appearanceToUse == nil && [_bottomBar isKindOfClass:UITabBar.class])
	{
		UITabBar* tabBar = (UITabBar*)_bottomBar;
		appearanceToUse = tabBar.selectedItem.standardAppearance ?: tabBar.standardAppearance;
	}
	
#endif
	
	if(appearanceToUse == nil && [_bottomBar respondsToSelector:@selector(standardAppearance)])
	{
		appearanceToUse = [(id<_LNPopupBarSupport>)_bottomBar standardAppearance];
	}
	
	UIColor* bottomBarTintColor = _bottomBar.tintColor;
	if(_bottomBar.window != nil || [_bottomBar.superview.tintColor isEqual:bottomBarTintColor] == NO)
	{
		self.popupBar.systemTintColor = bottomBarTintColor;
	}
	else
	{
		self.popupBar.systemTintColor = nil;
	}
	
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

- (LNPopupBar*)popupBarStorage
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
	[_popupBar.contentView addGestureRecognizer:_popupBar.popupOpenGestureRecognizer];
	
	_popupBar.barHighlightGestureRecognizer = [[LNPopupLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarLongPressGestureRecognized:)];
	_popupBar.barHighlightGestureRecognizer.minimumPressDuration = 0;
	_popupBar.barHighlightGestureRecognizer.cancelsTouchesInView = NO;
	_popupBar.barHighlightGestureRecognizer.delaysTouchesBegan = NO;
	_popupBar.barHighlightGestureRecognizer.delaysTouchesEnded = NO;
	[_popupBar.contentView addGestureRecognizer:_popupBar.barHighlightGestureRecognizer];
	
	
	if(@available(iOS 17.0, *))
	{
		[_popupBar.traitOverrides setNSIntegerValue:LNPopupBarEnvironmentRegular forTrait:LNPopupBarEnvironmentTrait.class];
	}
	
	return _popupBar;
}

- (LNPopupBar*)popupBarNoCreate
{
	return _popupBar;
}

- (LNPopupBar*)popupBar
{
	if(_popupControllerInternalState == LNPopupPresentationStateBarHidden)
	{
		return nil;
	}
	
	return self.popupBarStorage;
}

- (LNPopupContentView*)popupContentView
{
	if(_popupContentView)
	{
		return _popupContentView;
	}
	
	_popupContentView = [[LNPopupContentView alloc] initWithFrame:_containerController.view.bounds];
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
	
	if(_lockedRotationWindow)
	{
		[UIViewController _ln_endTransitioningLockWithWindow:_lockedRotationWindow unlockingRotation:YES];
	}
}

static void __LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(UIView* view, void (^block)(UIView* view))
{
	block(view);
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		__LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(obj, block);
	}];
}

- (void)_fixupGestureRecognizer:(UIGestureRecognizer*)obj
{
	if([obj isKindOfClass:[UIPanGestureRecognizer class]] && [obj.view isDescendantOfView:_currentContentController.viewForPopupInteractionGestureRecognizer] && obj != _popupContentView.popupInteractionGestureRecognizer)
	{
		[obj addTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:)];
	}
}

- (void)_fixupGestureRecognizersForController:(UIViewController*)vc
{
	__LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(vc.viewForPopupInteractionGestureRecognizer, ^(UIView *view) {
		[view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self _fixupGestureRecognizer:obj];
		}];
	});
}

- (void)_unfixupGestureRecognizer:(UIGestureRecognizer*)obj
{
	if([obj isKindOfClass:[UIPanGestureRecognizer class]] && [obj.view isDescendantOfView:_currentContentController.viewForPopupInteractionGestureRecognizer] && obj != _popupContentView.popupInteractionGestureRecognizer)
	{
		[obj removeTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:)];
	}
}

- (void)_cleanupGestureRecognizersForController:(UIViewController*)vc
{
	__LNPopupControllerDeeplyEnumerateSubviewsUsingBlock(vc.viewForPopupInteractionGestureRecognizer, ^(UIView *view) {
		[view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self _unfixupGestureRecognizer:obj];
		}];
	});
}

- (BOOL)_hasRunningAnimators
{
	return _runningBarAnimation != nil || _runningBarSidecarAnimation != nil || _runningPopupAnimation != nil;
}

- (void)_resumeEventQueue
{
	if(self._hasRunningAnimators)
	{
		return;
	}
	
	if(_eventQueue.count == 0)
	{
		return;
	}
	
	_LNPopupControllerEvent* event = _eventQueue[0];
	_eventQueue = [_eventQueue subarrayWithRange:NSMakeRange(1, _eventQueue.count - 1)];
	
	event.isRunning = YES;
	event.operation();
}

- (void)_enqueueEvent:(_LNPopupControllerEvent*)event
{
//	NSArray* before = [_eventQueue copy];
	
	_eventQueue = [[_eventQueue ?: @[] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(_LNPopupControllerEvent* evaluatedObject, id bindings) {
		return evaluatedObject.isRunning == YES || [event.coalescedOperations containsObject:evaluatedObject.name] == NO;
	}]] arrayByAddingObject:event];
	
//	NSLog(@"_eventQueue before: %@\n_eventQueue after: %@", before, _eventQueue);
	
	[self _resumeEventQueue];
}

- (void)_addEventQueueResumptionStep:(UIViewPropertyAnimator*)animator
{
	[animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
		[self _resumeEventQueue];
	}];
}

//- (void)_clearRunningBarAnimators
//{
//	if(_runningBarAnimation != nil)
//	{
//		UIViewPropertyAnimator* retained = _runningBarAnimation;
//		[retained stopAnimation:NO];
//		[retained finishAnimationAtPosition:UIViewAnimatingPositionCurrent];
//		_runningBarAnimation = nil;
//	}
//	
//	if(_runningBarSidecarAnimation != nil)
//	{
//		UIViewPropertyAnimator* retained = _runningBarSidecarAnimation;
//		[retained stopAnimation:NO];
//		[retained finishAnimationAtPosition:UIViewAnimatingPositionCurrent];
//		_runningBarSidecarAnimation = nil;
//	}
//}
//
//- (void)_clearRunningPopupAnimators
//{
//	if(_runningPopupAnimation != nil)
//	{
//		UIViewPropertyAnimator* retained = _runningPopupAnimation;
//		[retained stopAnimation:NO];
//		[retained finishAnimationAtPosition:UIViewAnimatingPositionCurrent];
//		_runningPopupAnimation = nil;
//	}
//}

- (void)presentPopupBarWithContentViewController:(UIViewController*)contentViewController openPopup:(BOOL)open animated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _enqueueEvent:[_LNPopupControllerEvent presentEventWithOperation:^{
		[self _presentPopupBarWithContentViewController:contentViewController openPopup:open animated:animated completion:completionBlock];
	}]];
}

- (void)_presentPopupBarWithContentViewController:(UIViewController*)contentViewController openPopup:(BOOL)open animated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	_containerController.popupContentViewController = contentViewController;
	
	NSInteger value = LNPopupBarEnvironmentRegular;
	
	if(@available(iOS 26.0, *))
	{
		__weak decltype(self) weakSelf = self;
		
		if([_containerController isKindOfClass:UITabBarController.class] && _containerController.bottomDockingViewForPopupBar == nil)
		{
			UITabBar* bar = [_containerController tabBar];
			bar.minimizationDelegate = self;
			
			value = self.popupBarStorage.supportsMinimization && bar._ln_wantsMinimizedPopupBar ? LNPopupBarEnvironmentInline : LNPopupBarEnvironmentRegular;
		}
	}

	if(@available(iOS 17.0, *))
	{
		[contentViewController.traitOverrides setNSIntegerValue:value forTrait:LNPopupBarEnvironmentTrait.class];
		[self.popupBarStorage.traitOverrides setNSIntegerValue:value forTrait:LNPopupBarEnvironmentTrait.class];
	}
	
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
		
		self.bottomBar = _containerController.bottomDockingViewForPopup_internalOrDeveloper;
		_bottomBar.attachedPopupController = self;
		
		self.popupBarStorage.hidden = NO;
		
		if([_containerController.view isKindOfClass:[UIScrollView class]])
		{
			os_log_t customLog = __LNPopupFrameworkLogger("UnsupportedPresentation");
			os_log_with_type(customLog, OS_LOG_TYPE_DEBUG, "%{public}@: Attempted to present popup bar with content view controller %{public}@ on %{public}@ whose view %{public}@ is a scroll view. This is unsupported and may result in unexpected behavior.", __LNPopupFrameworkName(), contentViewController, _containerController, _containerController.view);
		}
		
		[self _configurePopupBarFromBottomBar];
		
		[self.popupBar.contentView addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
		
		[self _setContentToState:LNPopupPresentationStateBarPresented animated:animated];
		
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		
		self.popupBar.clipsToBounds = NO;
		
		if(animated)
		{
			[UIView performWithoutAnimation:^{
				self.popupBar.floatingBackgroundShadowView.alpha = 0.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
				if(@available(iOS 26.0, *))
				if(LNPopupEnvironmentHasGlass())
				{
					CGRect frame = [self _frameForClosedPopupBarForBarHeight:_LNPopupBarHeightForPopupBar(self.popupBar)];
					self.popupBar.contentView.effect = [_LNPopupGlassEffect effectWithStyle:UIGlassEffectStyleClear];
					self.popupBar.contentView.contentView.alpha = 0.0;
#ifndef LNPopupControllerEnforceStrictClean
					self.popupBar.contentView.contentView.layer.filters = @[__LNPopupEmptyBlurFilter()];
					[self.popupBar.contentView.contentView.layer setValue:@5 forKeyPath:__LNPopupBlurFilterUpdateKey];
#endif
					
					UIView* target;
					if(self.popupBar.activeAppearance.floatingBackgroundEffect.ln_isGlass)
					{
						target = self.popupBar.layoutContainer;
					}
					else
					{
						target = self.popupBar;
					}
					self.popupBar.os26TransitionView = [_LNPopupTransitionView transitionViewWithSourceView:target];
					self.popupBar.os26TransitionView.matchesTransform = NO;
					self.popupBar.os26TransitionView.matchesPosition = NO;
					self.popupBar.os26TransitionView.frame = frame;
					self.popupBar.os26TransitionView.transform = CGAffineTransformMakeScale(1.05, 1.05);
					self.popupBar.os26TransitionView.alpha = 0.0;
				}
#endif
			}];
		}
		
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
			
			if(animated && LNPopupEnvironmentHasGlass())
			{
				self.popupBar.os26TransitionView.transform = CGAffineTransformIdentity;
				self.popupBar.os26TransitionView.alpha = 1.0;
				self.popupBar.floatingBackgroundShadowView.alpha = 1.0;
#ifndef LNPopupControllerEnforceStrictClean
				[self.popupBar.contentView.contentView.layer setValue:@0 forKeyPath:__LNPopupBlurFilterUpdateKey];
#endif
			}
			
			[self.popupBar.customBarViewController _userFacing_viewIsAppearing:animated];
			
			_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsMake(0, 0, barFrame.size.height - [_containerController _ln_popupOffsetForPopupBar:self.popupBar], 0));
			
			if(open)
			{
				[self _generateSoftFeedbackWithIntensity:0.9];
				
				if(_LNCallDelegateObjectObjectBool(_containerController, _currentContentController, @selector(popupPresentationController:willOpenPopupWithContentController:animated:), animated) == NO)
				{
					_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillOpenPopup:animated:), animated);
				}
				
				[self _openPopupAnimated:animated allowFeedbackGeneration:YES forceFeedbackGenerationAtStart:YES completion:completionBlock];
			}
		};
		
		CGFloat animationDuration = LNPopupBarTransitionDuration;
#if DEBUG
		if(_LNEnableSlowTransitionsDebug())
		{
			animationDuration = 4.0;
		}
#endif
		
		if(animated && LNPopupEnvironmentHasGlass())
		{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * 0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:animationDuration * 0.25 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
					self.popupBar.contentView.effectView.contentView.alpha = 1.0;
				} completion:nil];
			});
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
					self.popupBar.contentView.effect = [self.popupBar.activeAppearance floatingBackgroundEffectForPopupBar:self.popupBar containerController:self.containerController traitCollection:self.popupBar.traitCollection];
				} completion:nil];
			});
		}
		
		dispatch_block_t middle = nil;
		if(!LNPopupEnvironmentHasGlass())
		{
			middle = ^{
				self.popupBar.floatingBackgroundShadowView.alpha = 1.0;
			};
		}
		
		void (^completion)(UIViewAnimatingPosition) = ^(UIViewAnimatingPosition finalPosition) {
			if(finalPosition != UIViewAnimatingPositionEnd)
			{
				return;
			}
			
			if(animated && LNPopupEnvironmentHasGlass())
			{
				[self.popupBar.os26TransitionView removeFromSuperview];
				self.popupBar.os26TransitionView = nil;
				
				[self.containerController _layoutPopupBarOrderForUse];
			}
			
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
		
//		[self _clearRunningBarAnimators];
//		[self _clearRunningPopupAnimators];
		
		_runningBarAnimation = [[UIViewPropertyAnimator alloc] initWithDuration:animationDuration dampingRatio:500 animations:animations];
		[_runningBarAnimation addCompletion:completion];
		[_runningBarAnimation addCompletion:^(UIViewAnimatingPosition finalPosition) {
			_runningBarAnimation = nil;
		}];
		[self _addEventQueueResumptionStep:_runningBarAnimation];

		[_runningBarAnimation startAnimation];
		
		if(middle != nil)
		{
			_runningBarSidecarAnimation = [[UIViewPropertyAnimator alloc] initWithDuration:animationDuration * 0.6 dampingRatio:500 animations:middle];
			[_runningBarSidecarAnimation addCompletion:^(UIViewAnimatingPosition finalPosition) {
				_runningBarSidecarAnimation = nil;
			}];
			[self _addEventQueueResumptionStep:_runningBarSidecarAnimation];
		}
		if(animated == NO)
		{
			[_runningBarSidecarAnimation startAnimation];
			
			UIViewPropertyAnimator* retained1 = _runningBarAnimation;
			UIViewPropertyAnimator* retained2 = _runningBarSidecarAnimation;
			
			[retained1 stopAnimation:NO];
			[retained1 finishAnimationAtPosition:UIViewAnimatingPositionEnd];
			
			[retained2 stopAnimation:NO];
			[retained2 finishAnimationAtPosition:UIViewAnimatingPositionEnd];
		}
		else
		{
			[_runningBarSidecarAnimation startAnimationAfterDelay:0.2];
		}
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
			
			[self _resumeEventQueue];
		}
	}
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self openPopupAnimated:animated allowFeedbackGeneration:YES forceFeedbackGenerationAtStart:YES trollState:NO completion:completionBlock];
}

- (void)openPopupAnimated:(BOOL)animated allowFeedbackGeneration:(BOOL)allowFeedbackGeneration forceFeedbackGenerationAtStart:(BOOL)forceFeedbackAtStart trollState:(BOOL)trollState completion:(void(^)(void))completionBlock
{
	[self _enqueueEvent:[_LNPopupControllerEvent openEventWithOperation:^{
		if(trollState)
		{
			_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
			_popupControllerTargetState = _LNPopupPresentationStateTransitioning;
		}
		[self _openPopupAnimated:animated allowFeedbackGeneration:allowFeedbackGeneration forceFeedbackGenerationAtStart:forceFeedbackAtStart completion:completionBlock];
	}]];
}

- (void)_openPopupAnimated:(BOOL)animated allowFeedbackGeneration:(BOOL)allowFeedbackGeneration forceFeedbackGenerationAtStart:(BOOL)forceFeedbackAtStart completion:(void(^)(void))completionBlock
{
	[self _start120HzHack];
	
	if(_popupControllerTargetState != LNPopupPresentationStateOpen)
	{
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		[self _transitionToState:LNPopupPresentationStateOpen notifyDelegate:YES animated:animated useSpringAnimation:NO allowPopupBarAlphaModification:YES allowFeedbackGeneration:allowFeedbackGeneration forceFeedbackGenerationAtStart:forceFeedbackAtStart completion:completionBlock];
	}
	else if(completionBlock != nil)
	{
		completionBlock();
	}
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self closePopupAnimated:animated allowFeedbackGeneration:YES forceFeedbackGenerationAtStart:YES completion:completionBlock];
}

- (void)closePopupAnimated:(BOOL)animated allowFeedbackGeneration:(BOOL)allowFeedbackGeneration forceFeedbackGenerationAtStart:(BOOL)forceFeedbackAtStart completion:(void(^)(void))completionBlock
{
	[self _enqueueEvent:[_LNPopupControllerEvent closeEventWithOperation:^{
		[self _closePopupAnimated:animated allowFeedbackGeneration:allowFeedbackGeneration forceFeedbackGenerationAtStart:forceFeedbackAtStart completion:completionBlock];
	}]];
}

- (void)_closePopupAnimated:(BOOL)animated allowFeedbackGeneration:(BOOL)allowFeedbackGeneration forceFeedbackGenerationAtStart:(BOOL)forceFeedbackAtStart completion:(void(^)(void))completionBlock
{
	if(_popupControllerTargetState != LNPopupPresentationStateBarPresented)
	{
		LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
		
		[self _transitionToState:LNPopupPresentationStateBarPresented notifyDelegate:YES animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap ? YES : NO allowPopupBarAlphaModification:YES allowFeedbackGeneration:allowFeedbackGeneration forceFeedbackGenerationAtStart:forceFeedbackAtStart completion:completionBlock];
	}
	else if(completionBlock != nil)
	{
		completionBlock();
	}
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _enqueueEvent:[_LNPopupControllerEvent dismissEventWithOperation:^{
		[self _dismissPopupBarAnimated:animated completion:completionBlock];
	}]];
}

#ifndef LNPopupControllerEnforceStrictClean
static NSString* __LNPopupBlurFilterInputRadius = LNPopupHiddenString("inputRadius");
static NSString* __LNPopupBlurFilterName = LNPopupHiddenString("gaussianBlur");
static NSString* __LNPopupBlurFilterUpdateKey = [NSString stringWithFormat:@"filters.%@.%@", __LNPopupBlurFilterName, __LNPopupBlurFilterInputRadius];

id __LNPopupEmptyBlurFilter(void)
{
	static Class cls = NSClassFromString(LNPopupHiddenString("CAFilter"));
	static SEL sel = NSSelectorFromString(LNPopupHiddenString("filterWithName:"));
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	id rv = [cls performSelector:sel withObject:__LNPopupBlurFilterName];
#pragma clang diagnostic pop
	[rv setValue:@0 forKey:__LNPopupBlurFilterInputRadius];
	
	return rv;
}
#endif

- (void)_dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
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
		if(!LNPopupEnvironmentHasGlass())
		{
			self.popupBar.clipsToBounds = YES;
		}
		
		void (^dismissalAnimationCompletionBlock)(void) = ^
		{
			_popupControllerInternalState = _LNPopupPresentationStateTransitioning;
			_popupControllerTargetState = LNPopupPresentationStateBarHidden;
			
//			[self _clearRunningBarAnimators];
//			[self _clearRunningPopupAnimators];
			
			__weak decltype(self) weakSelf = self;
			
			if(animated && LNPopupEnvironmentHasGlass())
			{
				[UIView performWithoutAnimation:^{
					CGRect frame = [self _frameForClosedPopupBarForBarHeight:_LNPopupBarHeightForPopupBar(self.popupBar)];
					
					UIView* target;
					if(self.popupBar.activeAppearance.floatingBackgroundEffect.ln_isGlass)
					{
						target = self.popupBar.contentView;
					}
					else
					{
						target = self.popupBar;
					}
					self.popupBar.os26TransitionView = [_LNPopupTransitionView transitionViewWithSourceView:target];
					self.popupBar.os26TransitionView.matchesTransform = NO;
					self.popupBar.os26TransitionView.frame = frame;
#ifndef LNPopupControllerEnforceStrictClean
					self.popupBar.contentView.contentView.layer.filters = @[__LNPopupEmptyBlurFilter()];
#endif
				}];
			}
			
			CGFloat animationDuration = LNPopupBarTransitionDuration;
#if DEBUG
			if(_LNEnableSlowTransitionsDebug())
			{
				animationDuration = 4.0;
			}
#endif
			
			__block CGRect newBarFrame;
			_runningBarAnimation = [[UIViewPropertyAnimator alloc] initWithDuration:animationDuration dampingRatio:500 animations:^{
				__strong decltype(weakSelf) self = weakSelf;
				if(self == nil)
				{
					return;
				}
				
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerWillDismissPopupBar:animated:), animated);
				[self.popupBar.customBarViewController _userFacing_viewWillDisappear:animated];
				
				[_bottomBar _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
				
				newBarFrame = self.popupBar.frame;
				newBarFrame.size.height = 0;
				self.popupBar.frame = newBarFrame;
				
				self.popupBar.floatingBackgroundShadowView.alpha = 0.0;
				
				self.popupBar.shadowView.alpha = 0.0;
				_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
				
				CGFloat currentBarAlpha = self.popupBarStorage.alpha;
				if(animated)
				{
					[UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
						if(_containerController.shouldFadePopupBarOnDismiss && !LNPopupEnvironmentHasGlass())
						{
							self.popupBar.alpha = 0.0;
						}
						_containerController._ln_bottomBarExtension_nocreate.alpha = 0.0;
					} completion:^(BOOL finished) {
						self.popupBarStorage.alpha = currentBarAlpha;
					}];
				}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
				if(@available(iOS 26, *))
				if(animated && LNPopupEnvironmentHasGlass())
				{
					self.popupBar.contentView.effect = [_LNPopupGlassEffect effectWithStyle:UIGlassEffectStyleClear];
					self.popupBar.os26TransitionView.transform = CGAffineTransformMakeScale(1.05, 1.05);
					self.popupBar.os26TransitionView.alpha = 0.0;
					
#ifndef LNPopupControllerEnforceStrictClean
					[self.popupBar.contentView.contentView.layer setValue:@20 forKeyPath:__LNPopupBlurFilterUpdateKey];
#endif
				}
#endif
			}];
			
			if(animated && LNPopupEnvironmentHasGlass())
			{
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * 0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[UIView animateWithDuration:animationDuration * 0.4 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
						self.popupBar.contentView.contentView.alpha = 0.0;
					} completion:nil];
				});
			}
			
			[_runningBarAnimation addCompletion:^(UIViewAnimatingPosition finalPosition) {
				__strong decltype(weakSelf) self = weakSelf;
				if(self == nil)
				{
					return;
				}
				
				if(finalPosition != UIViewAnimatingPositionEnd)
				{
					return;
				}
				
				if(animated && LNPopupEnvironmentHasGlass())
				{
					[self.popupBar.os26TransitionView removeFromSuperview];
					self.popupBar.os26TransitionView = nil;
					
					self.popupBar.contentView.contentView.alpha = 1.0;
					self.popupBar.contentView.contentView.layer.filters = nil;
					[self.popupBar.contentView clearEffect];
					self.popupBar.contentView.effect = [self.popupBar.activeAppearance floatingBackgroundEffectForPopupBar:self.popupBar containerController:self.containerController traitCollection:self.popupBar.traitCollection];
					
					[self.containerController _layoutPopupBarOrderForUse];
				}
				
				self.popupBar.shadowView.alpha = 1.0;
				
				[self.popupBar.customBarViewController _userFacing_viewDidDisappear:animated];
				
				[self _removeContentControllerFromContentView:_currentContentController];
				
				CGRect bottomBarFrame = [_containerController _defaultFrameForBottomDockingViewForPopupBar:_popupBar];
				bottomBarFrame.origin.y -= _cachedInsets.bottom;
				_bottomBar.frame = bottomBarFrame;
				
				self.popupBar.hidden = YES;
				[self.popupBar removeFromSuperview];
				
				[self.popupContentView removeFromSuperview];
				self.popupContentView.popupInteractionGestureRecognizer = nil;
				_popupContentView = nil;
				
				_LNPopupSupportSetPopupInsetsForViewController(_containerController, YES, UIEdgeInsetsZero);
				
				_currentContentController = nil;
				
				_effectiveStatusBarUpdateController = nil;
				
				[_containerController _ln_setPopupPresentationState:LNPopupPresentationStateBarHidden];
				
				_LNCallDelegateObjectBool(_containerController, @selector(popupPresentationControllerDidDismissPopupBar:animated:), animated);
				
				_bottomBar.attachedPopupController = nil;
				self.bottomBar = nil;
				
				[self _end120HzHack];
				
				_popupControllerInternalState = LNPopupPresentationStateBarHidden;
				
				if(completionBlock != nil) { completionBlock(); }
			}];
			[_runningBarAnimation addCompletion:^(UIViewAnimatingPosition finalPosition) {
				_runningBarAnimation = nil;
			}];
			[self _addEventQueueResumptionStep:_runningBarAnimation];
			
			[_runningBarAnimation startAnimation];
			
			if(animated == NO)
			{
				UIViewPropertyAnimator* retained = _runningBarAnimation;
				[retained stopAnimation:NO];
				[retained finishAnimationAtPosition:UIViewAnimatingPositionEnd];
			}
		};
		
		_dismissalOverride = YES;
		
		if(_popupControllerTargetState != LNPopupPresentationStateBarPresented)
		{
			self.popupContentView.popupInteractionGestureRecognizer.enabled = NO;
			self.popupContentView.popupInteractionGestureRecognizer.enabled = YES;
			
			LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
			
			[self _transitionToState:LNPopupPresentationStateBarPresented notifyDelegate:YES animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap allowPopupBarAlphaModification:YES allowFeedbackGeneration:YES forceFeedbackGenerationAtStart:YES completion:dismissalAnimationCompletionBlock];
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
	[self _popupBarMetricsDidChange:bar shouldLayout:YES];
}

- (void)_popupBarMetricsDidChange:(LNPopupBar*)bar shouldLayout:(BOOL)layout
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
	
	[_containerController _ln_updatePopupBarContainerInsets];
}

- (void)_popupBarStyleDidChange:(LNPopupBar*)bar
{
	[self _updateBarExtensionStyleFromPopupBar];
	if(LNPopupBar.isCatalystApp == NO)
	{
		[_containerController.popupBar _applyGroupingIdentifierToVisualEffectView:self.popupContentView.effectView];
	}
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

#pragma mark _LNPopupTabBarMinimizationDelegate

- (void)tabBar:(UITabBar *)tabBar didMinimize:(BOOL)wasMinimized API_AVAILABLE(ios(26.0))
{
	NSInteger newValue = self.popupBar.supportsMinimization && wasMinimized ? LNPopupBarEnvironmentInline : LNPopupBarEnvironmentRegular;
	
	void (^updateMargins)(void) = ^{
		[_containerController.popupContentViewController.traitOverrides setNSIntegerValue:newValue forTrait:LNPopupBarEnvironmentTrait.class];
		[self.popupBar.traitOverrides setNSIntegerValue:newValue forTrait:LNPopupBarEnvironmentTrait.class];
		self.popupBar._hackyMargins = [self.containerController _ln_popupBarMarginsForPopupBar:self.popupBar];
		[self.popupBar layoutIfNeeded];
	};
	void (^layoutVerticalBarPosition)(void) = ^{
		[self.containerController _ln_layoutPopupBarAndContent];
	};
	
	if(self.popupBar.traitCollection.popupBarEnvironment == newValue)
	{
		[UIView _ln_animatedUsingSwiftUIWithDuration:0.4 animations:^{
			updateMargins();
			layoutVerticalBarPosition();
		} completion:nil];
	}
	else
	{
		auto animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.4 dampingRatio:1.0 animations:nil];
		
		[animator addAnimations:updateMargins delayFactor: wasMinimized ? 0.0 : 0.2];
		[animator ln_addAnimations:layoutVerticalBarPosition delayFactor:wasMinimized ? 0.2 : 0.0 durationFactor:wasMinimized ? 0.8 : 0.35];
		[animator startAnimation];
	}
}

#pragma mark Utils

static NSString* __LNPopupFrameworkName(void)
{
	static NSString* frameworkName;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		frameworkName = NSClassFromString(@"__LNPopupUI") ? @"LNPopupUI" : @"LNPopupController";
	});
	return frameworkName;
}

static os_log_t __LNPopupFrameworkLogger(const char* category)
{
	static NSString* subsystem;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		subsystem = [NSString stringWithFormat:@"com.LeoNatan.%@", __LNPopupFrameworkName()];
	});
	return os_log_create(subsystem.UTF8String, category);
}

- (void)_check120HzHackAndNotifyIfNeeded
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(@available(iOS 15.0, *))
		{
			if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.maximumFramesPerSecond > 60 && [[NSBundle.mainBundle objectForInfoDictionaryKey:@"CADisableMinimumFrameDurationOnPhone"] boolValue] == NO)
			{
				os_log_t customLog = __LNPopupFrameworkLogger("ProMotion");
				os_log_with_type(customLog, OS_LOG_TYPE_DEBUG, "%{public}@: This device supports ProMotion, but %{public}s does not enable the full range of refresh rates by setting the “CADisableMinimumFrameDurationOnPhone” Info.plist key to “true”. See https://developer.apple.com/documentation/quartzcore/optimizing_promotion_refresh_rates_for_iphone_13_pro_and_ipad_pro", __LNPopupFrameworkName(), NSBundle.mainBundle.bundleURL.lastPathComponent.UTF8String);
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
	if(LNPopupBar.isCatalystApp)
	{
		return 0;
	}

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
}

- (void)_120HzTick {}

@end

@interface LNPopupController (PopupItemUpdateSupport) @end
@implementation LNPopupController (PopupItemUpdateSupport)

- (void)_popupItem_update_title
{
	self.popupBarStorage.attributedTitle = _currentPopupItem.attributedTitle;
}

- (void)_popupItem_update_subtitle
{
	self.popupBarStorage.attributedSubtitle = _currentPopupItem.attributedSubtitle;
}

- (void)_popupItem_update_progress
{
	[UIView performWithoutAnimation:^{
		[self.popupBarStorage.progressView setProgress:_currentPopupItem.progress animated:NO];
	}];
}

- (void)_popupItem_update_accessibilityLabel
{
	self.popupBarStorage.accessibilityCenterLabel = _currentPopupItem.accessibilityLabel;
}

- (void)_popupItem_update_accessibilityHint
{
	self.popupBarStorage.accessibilityCenterHint = _currentPopupItem.accessibilityHint;
}

- (void)_popupItem_update_leadingBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_popupItem_update_trailingBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_popupItem_update_standardAppearance
{
	[self.popupBarStorage _setNeedsRecalcActiveAppearanceChain];
}

- (void)_popupItem_update_inlineAppearance
{
	[self.popupBarStorage _setNeedsRecalcActiveAppearanceChain];
}

@end

CF_EXTERN_C_END
