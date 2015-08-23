//
//  _LNPopupBarSupportObject.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupController.h"
#import "LNPopupItem+Private.h"
@import ObjectiveC;

static NSString* const _mcvc = @"bXV0YWJsZUNoaWxkVmlld0NvbnRyb2xsZXJz";

static const CFTimeInterval LNPopupBarGesturePanThreshold = 0.1;
static const CFTimeInterval LNPopupBarGestureHeightPercentThreshold = 0.2;

@interface _LNPopupTransitionCoordinator : NSObject <UIViewControllerTransitionCoordinator> @end
@implementation _LNPopupTransitionCoordinator

- (BOOL)isAnimated
{
	return NO;
}

- (UIModalPresentationStyle)presentationStyle
{
	return UIModalPresentationNone;
}

- (BOOL)initiallyInteractive
{
	return NO;
}

- (BOOL)isInteractive
{
	return NO;
}

- (BOOL)isCancelled
{
	return NO;
}

- (NSTimeInterval)transitionDuration
{
	return 0.0;
}

- (CGFloat)percentComplete;
{
	return 1.0;
}

- (CGFloat)completionVelocity
{
	return 1.0;
}

- (UIViewAnimationCurve)completionCurve
{
	return UIViewAnimationCurveEaseInOut;
}

- (nullable LNObjectOfKind(UIViewController *))viewControllerForKey:(NSString *)key
{
	if([key isEqualToString:UITransitionContextFromViewControllerKey])
	{
		
	}
	else if([key isEqualToString:UITransitionContextToViewControllerKey])
	{
		
	}
	
	return nil;
}

- (nullable LNObjectOfKind(UIView *))viewForKey:(NSString *)key
{
	return nil;
}

- (UIView *)containerView
{
	return nil;
}

- (CGAffineTransform)targetTransform
{
	return CGAffineTransformIdentity;
}

- (BOOL)animateAlongsideTransition:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
						completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
	if(animation)
	{
		animation(self);
	}
	
	if(completion)
	{
		completion(self);
	}
	
	return YES;
}

- (BOOL)animateAlongsideTransitionInView:(nullable UIView *)view
							   animation:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
							  completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
	return [self animateAlongsideTransition:animation completion:completion];
}

- (void)notifyWhenInteractionEndsUsingBlock: (void (^)(id <UIViewControllerTransitionCoordinatorContext>context))handler
{ }

@end

@implementation LNPopupContentContainerView

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame popupBarStyle:UIBarStyleDefault];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame popupBarStyle:(UIBarStyle)popupBarStyle
{
	self = [super initWithEffect:nil];
	if(self) { self.frame = frame; }
	return self;
}

@end


@interface LNPopupController () <_LNPopupItemDelegate> @end

@implementation LNPopupController
{
	__weak LNObjectOfKind(UIViewController*) _containerController;
	__weak LNPopupItem* _currentPopupItem;
	__weak LNObjectOfKind(UIViewController*) _currentContentController;
	
	BOOL _dismissalOverride;
	
	//Cached for performance during panning the popup content
	CGRect _cachedDefaultFrame;
	CGRect _cachedOpenPopupFrame;
	
	CGFloat _tresholdToPassForStatusBarUpdate;
	CGFloat _statusBarTresholdDir;
	
	CGFloat _bottomBarOffset;
}

- (instancetype)initWithContainerViewController:(LNObjectOfKind(UIViewController*))containerController
{
	self = [super init];
	
	if(self)
	{
		_containerController = containerController;
		
		_popupControllerState = LNPopupPresentationStateHidden;
		_popupControllerTargetState = LNPopupPresentationStateHidden;
	}
	
	return self;
}

- (CGRect)_frameForOpenPopupBar
{
	return CGRectMake([_containerController defaultFrameForBottomDockingView].origin.x, - _popupBar.frame.size.height, _containerController.view.bounds.size.width, _popupBar.frame.size.height);
}

- (CGRect)_frameForClosedPopupBar
{
	return CGRectMake([_containerController defaultFrameForBottomDockingView].origin.x, [_containerController defaultFrameForBottomDockingView].origin.y - _popupBar.frame.size.height, _containerController.view.bounds.size.width, _popupBar.frame.size.height);
}

- (void)_repositionPopupContent
{
	UIView* relativeViewForContentView = _bottomBar;
	
	CGFloat percent = [self _percentFromPopupBarForBottomBarDisplacement];
	CGRect bottomBarFrame = _cachedDefaultFrame;
	bottomBarFrame.origin.y += (percent * bottomBarFrame.size.height);
	_bottomBar.frame = bottomBarFrame;
	
	[_popupBar.toolbar setAlpha:1.0 - percent];
	[_popupBar.progressView setAlpha:1.0 - percent];
	
	CGRect contentFrame = _containerController.view.bounds;
	contentFrame.origin.x = _popupBar.frame.origin.x;
	contentFrame.origin.y = _popupBar.frame.origin.y + _popupBar.frame.size.height;
	contentFrame.size.height = relativeViewForContentView.frame.origin.y - (_popupBar.frame.origin.y + _popupBar.frame.size.height);
	
	_popupContentView.frame = contentFrame;
	_containerController.popupContentViewController.view.frame = _containerController.view.bounds;
	
	CGRect popupCloseButtonFrame = _popupCloseButton.frame;
	popupCloseButtonFrame.origin.y = 12 + ([UIApplication sharedApplication].isStatusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height);
	
	if(! CGRectEqualToRect(_popupCloseButton.frame, popupCloseButtonFrame))
	{
		[UIView animateWithDuration:0.2 animations:^{
			_popupCloseButton.frame = popupCloseButtonFrame;
		}];
	}
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
	return 1 - (_popupBar.center.y / _cachedDefaultFrame.origin.y);
}

- (CGFloat)_percentFromPopupBarForBottomBarDisplacement
{
	CGFloat percent = [self _percentFromPopupBar];
	
	return __smoothstep(0.05, 1.0, percent);
}

- (void)_setContentToState:(LNPopupPresentationState)state
{
	CGRect targetFrame = _popupBar.frame;
	if(state == LNPopupPresentationStateOpen)
	{
		targetFrame = [self _frameForOpenPopupBar];
	}
	else if(state == LNPopupPresentationStateClosed)
	{
		targetFrame = [self _frameForClosedPopupBar];
	}
	
	_cachedDefaultFrame = [_containerController defaultFrameForBottomDockingView];
	
	_popupBar.frame = targetFrame;
	
	if(state != LNPopupPresentationStateTransitioning)
	{
		[_containerController setNeedsStatusBarAppearanceUpdate];
	}
	
	[self _repositionPopupContent];
}

- (void)_transitionToState:(LNPopupPresentationState)state animated:(BOOL)animated completion:(void(^)())completion userOriginatedTransition:(BOOL)userOriginatedTransition
{
	if(state == _popupControllerState)
	{
		return;
	}
	
	if(userOriginatedTransition == YES && _popupControllerState == LNPopupPresentationStateTransitioning)
	{
		NSLog(@"The popup controller is already in transition. Will ignore this transition request.");
		return;
	}
	
	UIViewController* contentController = _containerController.popupContentViewController;
	
	if(_popupControllerState == LNPopupPresentationStateClosed)
	{
		[contentController beginAppearanceTransition:YES animated:NO];
		contentController.view.frame = _containerController.view.bounds;
		contentController.view.clipsToBounds = NO;
		contentController.view.autoresizingMask = UIViewAutoresizingNone;
		if(CGColorGetAlpha(contentController.view.backgroundColor.CGColor) < 1.0)
		{
			//Support for iOS8, where this property was exposed as readonly.
			[_popupContentView setValue:[UIBlurEffect effectWithStyle:_popupBar.barStyle == UIBarStyleDefault ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark] forKey:@"effect"];
		}
		else
		{
			[_popupContentView setValue:nil forKey:@"effect"];
		}
		
		[_popupContentView.contentView addSubview:contentController.view];
		[_popupContentView.contentView sendSubviewToBack:contentController.view];
		[contentController endAppearanceTransition];
		
		[_popupBar removeGestureRecognizer:_popupBarUserPresentPanGestureRecognizer];
		[contentController.view addGestureRecognizer:_popupBarUserPresentPanGestureRecognizer];
	}
	
	_popupControllerState = LNPopupPresentationStateTransitioning;
	_popupControllerTargetState = state;
	
	[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent animations:^
	{
		if(state == LNPopupPresentationStateClosed)
		{
			[contentController beginAppearanceTransition:NO animated:YES];
		}
		
		[self _setContentToState:state];
	} completion:^(BOOL finished)
	 {
		 if(state == LNPopupPresentationStateClosed)
		 {
			 [contentController.view removeFromSuperview];
			 [contentController endAppearanceTransition];
			 
			 [contentController.view removeGestureRecognizer:_popupBarUserPresentPanGestureRecognizer];
			 [_popupBar addGestureRecognizer:_popupBarUserPresentPanGestureRecognizer];
			 
			 [_popupBar _setTitleViewMarqueesPaused:NO];
		 }
		 else if(state == LNPopupPresentationStateOpen)
		 {
			 [_popupBar _setTitleViewMarqueesPaused:YES];
		 }
		 
		 _popupControllerState = state;
		 
		 if(completion)
		 {
			 completion();
		 }
	 }];
}

- (void)_popupBarLongPressGestureRecognized:(UILongPressGestureRecognizer*)lpgr
{
	switch (lpgr.state) {
		case UIGestureRecognizerStateBegan:
			[_popupBar setHighlighted:YES];
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			[_popupBar setHighlighted:NO];
			break;
		default:
			break;
	}
}

- (void)_popupBarTapGestureRecognized:(UITapGestureRecognizer*)tgr
{
	switch (tgr.state) {
		case UIGestureRecognizerStateEnded:
		{
			[self _transitionToState:LNPopupPresentationStateOpen animated:YES completion:nil userOriginatedTransition:NO];
		}	break;
		default:
			break;
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler:(UIPanGestureRecognizer*)pgr
{
	if(_dismissalOverride)
	{
		return;
	}
	
	switch (pgr.state) {
		case UIGestureRecognizerStateBegan:
		{
			_lastSeenMovement = CACurrentMediaTime();
			_popupBarLongPressGestureRecognizer.enabled = NO;
			_popupBarLongPressGestureRecognizer.enabled = YES;
			_lastPopupBarLocation = _popupBar.center;
			
			_statusBarTresholdDir = _popupControllerState == LNPopupPresentationStateOpen ? 1 : -1;
			_tresholdToPassForStatusBarUpdate = -10;
			
			[self _transitionToState:LNPopupPresentationStateTransitioning animated:YES completion:nil userOriginatedTransition:NO];
			
			_cachedDefaultFrame = [_containerController defaultFrameForBottomDockingView];
			_cachedOpenPopupFrame = [self _frameForOpenPopupBar];
			
		}	break;
		case UIGestureRecognizerStateChanged:
		{
			CGFloat targetCenterY = MIN(_lastPopupBarLocation.y + [pgr translationInView:_popupBar.superview].y, _cachedDefaultFrame.origin.y - _popupBar.frame.size.height / 2);
			targetCenterY = MAX(targetCenterY, _cachedOpenPopupFrame.origin.y + _popupBar.frame.size.height / 2);
			
			CGFloat currentCenterY = _popupBar.center.y;
			
			_popupBar.center = CGPointMake(_popupBar.center.x, targetCenterY);
			[self _repositionPopupContent];
			_lastSeenMovement = CACurrentMediaTime();
			
			if((_statusBarTresholdDir == 1 && currentCenterY < targetCenterY && targetCenterY >= _tresholdToPassForStatusBarUpdate)
			   || (_statusBarTresholdDir == -1 && currentCenterY > targetCenterY && targetCenterY < _tresholdToPassForStatusBarUpdate))
			{
				_statusBarTresholdDir = -_statusBarTresholdDir;
				
				[_containerController setNeedsStatusBarAppearanceUpdate];
			}
 			
		}	break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
		{
			BOOL panThreshold = CACurrentMediaTime() - _lastSeenMovement <= LNPopupBarGesturePanThreshold;
			BOOL heightTreshold = [self _percentFromPopupBar] > LNPopupBarGestureHeightPercentThreshold;
			BOOL isPanUp = [pgr velocityInView:_containerController.view].y < 0;
			
			if((panThreshold || heightTreshold) && isPanUp)
			{
				[self _transitionToState:LNPopupPresentationStateOpen animated:YES completion:nil userOriginatedTransition:NO];
			}
			else
			{
				[self _transitionToState:LNPopupPresentationStateClosed animated:YES completion:nil userOriginatedTransition:NO];
			}
		}	break;
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
	_popupBar.title = _currentPopupItem.title;
}

- (void)_reconfigure_subtitle
{
	_popupBar.subtitle = _currentPopupItem.subtitle;
}

- (void)_reconfigure_progress
{
	[UIView performWithoutAnimation:^{
		[_popupBar.progressView setProgress:_currentPopupItem.progress animated:NO];
	}];
}

- (void)_reconfigureBarItems
{
	[_popupBar _delayBarButtonLayout];
	[_popupBar setLeftBarButtonItems:_currentPopupItem.leftBarButtonItems];
	[_popupBar setRightBarButtonItems:_currentPopupItem.rightBarButtonItems];
	[_popupBar _layoutBarButtonItems];
}

- (void)_reconfigure_leftBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_reconfigure_rightBarButtonItems
{
	[self _reconfigureBarItems];
}

- (void)_popupItem:(LNPopupItem*)popupItem didChangeValueForKey:(NSString*)key
{
	NSString* reconfigureSelector = [NSString stringWithFormat:@"_reconfigure_%@", key];
	
	void (*configureDispatcher)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
	configureDispatcher(self, NSSelectorFromString(reconfigureSelector));
}

- (void)_reconfigureContent
{
	_currentPopupItem.itemDelegate = nil;
	_currentPopupItem = _containerController.popupContentViewController.popupItem;
	_currentPopupItem.itemDelegate = self;
	
	if(_currentContentController)
	{
		LNObjectOfKind(UIViewController*) newContentController = _containerController.popupContentViewController;
		
		CGRect oldContentViewFrame = _currentContentController.view.frame;
		
		[newContentController beginAppearanceTransition:YES animated:NO];
		_LNPopupTransitionCoordinator* coordinator = [_LNPopupTransitionCoordinator new];
		[newContentController willTransitionToTraitCollection:_containerController.traitCollection withTransitionCoordinator:coordinator];
		[newContentController viewWillTransitionToSize:_containerController.view.bounds.size withTransitionCoordinator:coordinator];
		newContentController.view.frame = oldContentViewFrame;
		newContentController.view.clipsToBounds = NO;
		[_popupContentView.contentView insertSubview:newContentController.view belowSubview:_currentContentController.view];
		[newContentController endAppearanceTransition];
		
		[_currentContentController beginAppearanceTransition:NO animated:NO];
		[_currentContentController willMoveToParentViewController:nil];
		[_currentContentController.view removeFromSuperview];
		[_currentContentController endAppearanceTransition];
		[_currentContentController removeFromParentViewController];
		
		_currentContentController = newContentController;
	}
	
	LNArrayOfType(NSString*)* keys = @[@"title", @"subtitle", @"progress", @"leftBarButtonItems"];
	[keys enumerateObjectsUsingBlock:^(NSString * __nonnull key, NSUInteger idx, BOOL * __nonnull stop) {
		[self _popupItem:_currentPopupItem didChangeValueForKey:key];
	}];
}

- (void)_configurePopupBarFromBottomBar
{
	if([_bottomBar respondsToSelector:@selector(barStyle)])
	{
		[_popupBar setBarStyle:[(id<_LNPopupBarSupport>)_bottomBar barStyle]];
	}
	_popupBar.tintColor = _bottomBar.tintColor;
	if([_bottomBar respondsToSelector:@selector(barTintColor)])
	{
		[_popupBar setBarTintColor:[(id<_LNPopupBarSupport>)_bottomBar barTintColor]];
	}
	_popupBar.backgroundColor = _bottomBar.backgroundColor;
}

- (void)_movePopupBarAndContentToBottomBarSuperview
{
	[_popupBar removeFromSuperview];
	[_bottomBar.superview insertSubview:_popupBar belowSubview:_bottomBar];
	
	[_popupBar.superview insertSubview:_popupContentView belowSubview:_popupBar];
}

- (void)_fixChildControllersHierarchyIfNeeded
{
	if([_containerController isKindOfClass:[UINavigationController class]])
	{
		NSMutableArray* arr = [_containerController valueForKey:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:_mcvc options:0] encoding:NSUTF8StringEncoding]];
		[arr removeObject:_containerController.popupContentViewController];
		[arr insertObject:_containerController.popupContentViewController atIndex:0];
	}
}

- (void)presentPopupBarAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	[_containerController addChildViewController:_containerController.popupContentViewController];
	[_containerController.popupContentViewController didMoveToParentViewController:_containerController];
	
	[self _fixChildControllersHierarchyIfNeeded];
	
	_LNPopupTransitionCoordinator* coordinator = [_LNPopupTransitionCoordinator new];
	[_containerController.popupContentViewController willTransitionToTraitCollection:_containerController.traitCollection withTransitionCoordinator:coordinator];
	[_containerController.popupContentViewController viewWillTransitionToSize:_containerController.view.bounds.size withTransitionCoordinator:coordinator];
	
	if(_popupControllerTargetState == LNPopupPresentationStateHidden)
	{
		_dismissalOverride = NO;
		
		_popupControllerState = LNPopupPresentationStateClosed;
		_popupControllerTargetState = LNPopupPresentationStateClosed;
		
		_bottomBar = _containerController.bottomDockingViewForPopup;
		
		_popupBar = [[LNPopupBar alloc] initWithFrame:CGRectZero];
		_popupBar.hidden = NO;
		[self _configurePopupBarFromBottomBar];
		
		_popupContentView = [[LNPopupContentContainerView alloc] initWithFrame:_containerController.view.bounds popupBarStyle:_popupBar.barStyle];
		_popupContentView.layer.masksToBounds = YES;
		
		_popupContentView.preservesSuperviewLayoutMargins = YES;
		_popupContentView.contentView.preservesSuperviewLayoutMargins = YES;
		
		_popupCloseButton = [[LNPopupCloseButton alloc] initWithFrame: CGRectMake(12, 12, 24, 24)];
		[_popupCloseButton addTarget:self action:@selector(_closePopupContent) forControlEvents:UIControlEventTouchUpInside];
		[_popupContentView.contentView addSubview:_popupCloseButton];
		
		[self _movePopupBarAndContentToBottomBarSuperview];
		
		_popupBarLongPressGestureRecognizerDelegate = [LNPopupControllerLongPressGestureDelegate new];
		_popupBarLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarLongPressGestureRecognized:)];
		_popupBarLongPressGestureRecognizer.minimumPressDuration = 0;
		_popupBarLongPressGestureRecognizer.cancelsTouchesInView = NO;
		_popupBarLongPressGestureRecognizer.delaysTouchesBegan = NO;
		_popupBarLongPressGestureRecognizer.delaysTouchesEnded = NO;
		_popupBarLongPressGestureRecognizer.delegate = _popupBarLongPressGestureRecognizerDelegate;
		[_popupBar addGestureRecognizer:_popupBarLongPressGestureRecognizer];
		
		_popupBarTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarTapGestureRecognized:)];
		[_popupBar addGestureRecognizer:_popupBarTapGestureRecognizer];
		
		_popupBarUserPresentPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:)];
		[_popupBar addGestureRecognizer:_popupBarUserPresentPanGestureRecognizer];
		
		[self _setContentToState:LNPopupPresentationStateClosed];
		[_containerController.view layoutIfNeeded];
		
		[self _reconfigureContent];
		
		[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
		{
			CGRect barFrame = _popupBar.frame;
			barFrame.size.height = LNPopupBarHeight;
			_popupBar.frame = barFrame;
			
			_LNPopupSupportFixInsetsForViewController(_containerController, YES);
		} completion:^(BOOL finished)
		{
			
			if(completionBlock != nil)
			{
				completionBlock();
			}
		}];
	}
	else
	{
		[self _reconfigureContent];
		
		if(completionBlock != nil)
		{
			completionBlock();
		}
	}
	
	_currentContentController = _containerController.popupContentViewController;
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[self _transitionToState:LNPopupPresentationStateOpen animated:animated completion:completionBlock userOriginatedTransition:YES];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[self _transitionToState:LNPopupPresentationStateClosed animated:animated completion:completionBlock userOriginatedTransition:YES];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	if(_popupControllerState != LNPopupPresentationStateHidden)
	{
		void (^dismissalAnimationCompletionBlock)() = ^
		{
			[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
			{
				CGRect barFrame = _popupBar.frame;
				barFrame.size.height = 0;
				_popupBar.frame = barFrame;
				
				_LNPopupSupportFixInsetsForViewController(_containerController, YES);
			} completion:^(BOOL finished)
			{
				_popupControllerTargetState = LNPopupPresentationStateHidden;
				_popupControllerState = LNPopupPresentationStateHidden;
				
				_bottomBar.frame = [_containerController defaultFrameForBottomDockingView];
				_bottomBar = nil;
				
				[_popupBar removeFromSuperview];
				_popupBar = nil;
				
				[_popupContentView removeFromSuperview];
				_popupContentView = nil;
				
				_popupBarLongPressGestureRecognizerDelegate = nil;
				_popupBarLongPressGestureRecognizer = nil;
				_popupBarTapGestureRecognizer = nil;
				_popupBarUserPresentPanGestureRecognizer = nil;
				
				_LNPopupSupportFixInsetsForViewController(_containerController, YES);
				
				[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
				[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
				
				[_currentContentController willMoveToParentViewController:nil];
				[_currentContentController removeFromParentViewController];
				_currentContentController = nil;
				
				_effectiveStatusBarUpdateController = nil;
				
				if(completionBlock != nil)
				{
					completionBlock();
				}
			}];
		};
		
		if(_popupControllerTargetState != LNPopupPresentationStateClosed)
		{
			_popupBar.hidden = YES;
			_dismissalOverride = YES;
			_popupBarUserPresentPanGestureRecognizer.enabled = NO;
			_popupBarUserPresentPanGestureRecognizer.enabled = YES;
			[self _transitionToState:LNPopupPresentationStateClosed animated:animated completion:dismissalAnimationCompletionBlock userOriginatedTransition:NO];
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
	[_popupBar _setTitleViewMarqueesPaused:YES];
}

- (void)_applicationWillEnterForeground
{
	[_popupBar _setTitleViewMarqueesPaused:NO];
}

@end