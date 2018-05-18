//
//  _LNPopupBarSupportObject.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupController.h"
#import "LNPopupItem+Private.h"
#import "LNPopupCloseButton+Private.h"
#import "LNPopupOpenTapGesutreRecognizer.h"
#import "LNPopupLongPressGesutreRecognizer.h"
#import "LNPopupInteractionPanGestureRecognizer.h"
#import "_LNPopupBase64Utils.h"
@import ObjectiveC;

void __LNPopupControllerOutOfWindowHierarchy()
{
}

static const CGFloat LNPopupBarGestureHeightPercentThreshold = 0.2;
static const CGFloat LNPopupBarDeveloperPanGestureThreshold = 0;

#pragma mark Popup Transition Coordinator

@interface _LNPopupTransitionCoordinator : NSObject <UIViewControllerTransitionCoordinator> @end
@implementation _LNPopupTransitionCoordinator

- (BOOL)isInterruptible
{
	return NO;
}

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

- (nullable __kindof UIViewController *)viewControllerForKey:(NSString *)key
{
	if([key isEqualToString:UITransitionContextFromViewControllerKey])
	{
		
	}
	else if([key isEqualToString:UITransitionContextToViewControllerKey])
	{
		
	}
	
	return nil;
}

- (nullable __kindof UIView *)viewForKey:(NSString *)key
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

- (void) notifyWhenInteractionChangesUsingBlock:(nonnull void (^)(id<UIViewControllerTransitionCoordinatorContext> _Nonnull))handler
{ }


@end

#pragma mark Popup Content View

@interface LNPopupContentView ()

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* popupInteractionGestureRecognizer;
@property (nonatomic, strong, readwrite) LNPopupCloseButton* popupCloseButton;
@property (nonatomic, strong) UIVisualEffectView* effectView;

@end

@implementation LNPopupContentView

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_effectView = [[UIVisualEffectView alloc] initWithEffect:nil];
		_effectView.frame = self.bounds;
		_effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_effectView];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_effectView.frame = self.bounds;
}

- (UIView *)contentView
{
	return _effectView.contentView;
}

- (void)setEffect:(UIVisualEffect*)effect
{
	[_effectView setEffect:effect];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(scrollView.contentOffset.y > 0)
	{
		scrollView.contentOffset = CGPointZero;
	}
}

@end

LNPopupInteractionStyle _LNPopupResolveInteractionStyleFromInteractionStyle(LNPopupInteractionStyle style)
{
	LNPopupInteractionStyle rv = style;
	if(rv == LNPopupInteractionStyleDefault)
	{
		rv = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9 ? LNPopupInteractionStyleSnap : LNPopupInteractionStyleDrag;
	}
	return rv;
}

LNPopupCloseButtonStyle _LNPopupResolveCloseButtonStyleFromCloseButtonStyle(LNPopupCloseButtonStyle style)
{
	LNPopupCloseButtonStyle rv = style;
	if(rv == LNPopupCloseButtonStyleDefault)
	{
		rv = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9 ? LNPopupCloseButtonStyleChevron : LNPopupCloseButtonStyleRound;
	}
	return rv;
}

#pragma mark Popup Controller

@interface LNPopupController () <_LNPopupItemDelegate, UIViewControllerPreviewingDelegate, _LNPopupBarDelegate> @end

@implementation LNPopupController
{
	__weak LNPopupItem* _currentPopupItem;
	__weak __kindof UIViewController* _currentContentController;
	
	BOOL _dismissGestureStarted;
	CGFloat _dismissStartingOffset;
	CGFloat _dismissScrollViewStartingContentOffset;
	LNPopupPresentationState _stateBeforeDismissStarted;
	
	BOOL _dismissalOverride;
	BOOL _forceTouchOverride;
	
	//Cached for performance during panning the popup content
	CGRect _cachedDefaultFrame;
	UIEdgeInsets _cachedInsets;
	CGRect _cachedOpenPopupFrame;
	
	CGFloat _statusBarThresholdDir;
	
	CGFloat _bottomBarOffset;
	
	NSLayoutConstraint* _popupCloseButtonTopConstraint;
	NSLayoutConstraint* _popupCloseButtonHorizontalConstraint;
	
	id<UIViewControllerPreviewing> _previewingContext;
}

- (instancetype)initWithContainerViewController:(__kindof UIViewController*)containerController
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
	
	[self.popupBar.toolbar setAlpha:1.0 - percent];
	[self.popupBar.progressView setAlpha:1.0 - percent];
	
	CGRect contentFrame = _containerController.view.bounds;
	contentFrame.origin.x = self.popupBar.frame.origin.x;
	contentFrame.origin.y = self.popupBar.frame.origin.y + self.popupBar.frame.size.height;
	
	CGFloat fractionalHeight = heightForContent - (self.popupBar.frame.origin.y + self.popupBar.frame.size.height);
	contentFrame.size.height = ceil(fractionalHeight);
	
	self.popupContentView.frame = contentFrame;
	_containerController.popupContentViewController.view.frame = _containerController.view.bounds;
	
	[self _repositionPopupCloseButton];
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
	return 1 - (CGRectGetMaxY(self.popupBar.frame) / _cachedDefaultFrame.origin.y);
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
	else if(state == LNPopupPresentationStateClosed || (state == LNPopupPresentationStateTransitioning && _popupControllerTargetState == LNPopupPresentationStateHidden))
	{
		targetFrame = [self _frameForClosedPopupBar];
	}
	
	_cachedDefaultFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
	_cachedInsets = [_containerController insetsForBottomDockingView];
	
	self.popupBar.frame = targetFrame;
	
	if(state != LNPopupPresentationStateTransitioning)
	{
		[_containerController setNeedsStatusBarAppearanceUpdate];
	}
	
	[self _repositionPopupContentMovingBottomBar:YES];
}

- (void)_transitionToState:(LNPopupPresentationState)state animated:(BOOL)animated useSpringAnimation:(BOOL)spring allowPopupBarAlphaModification:(BOOL)allowBarAlpha completion:(void(^)(void))completion transitionOriginatedByUser:(BOOL)transitionOriginatedByUser
{
	if(_forceTouchOverride)
	{
		return;
	}
	
	if(transitionOriginatedByUser == YES && _popupControllerState == LNPopupPresentationStateTransitioning)
	{
		NSLog(@"LNPopupController: The popup controller is already in transition. Will ignore this transition request.");
		return;
	}
	
	if(state == _popupControllerState)
	{
		return;
	}
	
	UIViewController* contentController = _containerController.popupContentViewController;
	
	if(_popupControllerState == LNPopupPresentationStateClosed)
	{
		[contentController beginAppearanceTransition:YES animated:NO];
		[UIView performWithoutAnimation:^{
			contentController.view.frame = _containerController.view.bounds;
			contentController.view.clipsToBounds = NO;
			contentController.view.autoresizingMask = UIViewAutoresizingNone;
			
			if(CGColorGetAlpha(contentController.view.backgroundColor.CGColor) < 1.0)
			{
				//Support for iOS8, where this property was exposed as readonly.
				[self.popupContentView setValue:[UIBlurEffect effectWithStyle:self.popupBar.backgroundStyle] forKey:@"effect"];
				if(self.popupContentView.popupCloseButton.style == LNPopupCloseButtonStyleRound)
				{
					self.popupContentView.popupCloseButton.layer.shadowOpacity = 0.2;
				}
			}
			else
			{
				[self.popupContentView setValue:nil forKey:@"effect"];
				if(self.popupContentView.popupCloseButton.style == LNPopupCloseButtonStyleRound)
				{
					self.popupContentView.popupCloseButton.layer.shadowOpacity = 0.1;
				}
			}
			
			[self.popupContentView.contentView addSubview:contentController.view];
			[self.popupContentView.contentView sendSubviewToBack:contentController.view];
			
			[self.popupContentView.contentView setNeedsLayout];
			[self.popupContentView.contentView layoutIfNeeded];
		}];
		[contentController endAppearanceTransition];
	};
	
	_popupControllerState = LNPopupPresentationStateTransitioning;
	_popupControllerTargetState = state;
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	void (^updatePopupBarAlpha)(void) = ^ {
		if(allowBarAlpha && resolvedStyle == LNPopupInteractionStyleSnap)
		{
			CGRect frame = self.popupBar.frame;
			frame.size.height = state < LNPopupPresentationStateTransitioning ? _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController) : 0.0;
			self.popupBar.frame = frame;
			self.popupBar.alpha = state < LNPopupPresentationStateTransitioning;
		}
		else
		{
			self.popupBar.alpha = 1.0;
		}
	};
	
	[UIView animateWithDuration:animated ? (resolvedStyle == LNPopupInteractionStyleSnap ? 0.65 : 0.5) : 0.0 delay:0.0 usingSpringWithDamping:spring ? 0.8 : 1.0 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^
	 {
		 if(state != LNPopupPresentationStateTransitioning)
		 {
			 updatePopupBarAlpha();
		 }
		 
		 if(state == LNPopupPresentationStateClosed)
		 {
			 [contentController beginAppearanceTransition:NO animated:YES];
		 }
		 
		 [self _setContentToState:state];
		 [_containerController.view layoutIfNeeded];
	 } completion:^(BOOL finished)
	 {
		 if(state != LNPopupPresentationStateTransitioning)
		 {
			 updatePopupBarAlpha();
		 }
		 
		 if(state == LNPopupPresentationStateClosed)
		 {
			 [contentController.view removeFromSuperview];
			 [contentController endAppearanceTransition];
			 
			 [self _cleanupGestureRecognizersForController:contentController];
			 
			 [contentController.viewForPopupInteractionGestureRecognizer removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			 [self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			 
			 [self.popupBar _setTitleViewMarqueesPaused:NO];
			 
			 _popupContentView.accessibilityViewIsModal = NO;
			 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		 }
		 else if(state == LNPopupPresentationStateOpen)
		 {
			 [self.popupBar _setTitleViewMarqueesPaused:YES];
			 
			 [self.popupBar removeGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			 [contentController.viewForPopupInteractionGestureRecognizer addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
			 [self _fixupGestureRecognizersForController:contentController];
			 
			 _popupContentView.accessibilityViewIsModal = YES;
			 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, _popupContentView.popupCloseButton);
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
			[self _transitionToState:LNPopupPresentationStateTransitioning animated:NO useSpringAnimation:NO allowPopupBarAlphaModification:NO completion:^{
				[_containerController.view setNeedsLayout];
				[_containerController.view layoutIfNeeded];
				[self _transitionToState:LNPopupPresentationStateOpen animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
			} transitionOriginatedByUser:NO];
		}	break;
		default:
			break;
	}
}

- (void)_popupBarPresentationByUserPanGestureHandler_began:(UIPanGestureRecognizer*)pgr
{
	if(self.popupBar.customBarViewController != nil && self.popupBar.customBarViewController.wantsDefaultTapGestureRecognizer == NO)
	{
		return;
	}
	
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	if(resolvedStyle == LNPopupInteractionStyleSnap)
	{
		if((_popupControllerState == LNPopupPresentationStateClosed && [pgr velocityInView:self.popupBar].y < 0))
		{
			pgr.enabled = NO;
			pgr.enabled = YES;
			
			_popupControllerTargetState = LNPopupPresentationStateOpen;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self _transitionToState:_popupControllerTargetState animated:YES useSpringAnimation:_popupControllerTargetState == LNPopupPresentationStateClosed ? YES : NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
			});
		}
		else if((_popupControllerState == LNPopupPresentationStateClosed && [pgr velocityInView:self.popupBar].y > 0))
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
	
	if(_dismissGestureStarted == NO && (resolvedStyle == LNPopupInteractionStyleDrag || _popupControllerState > LNPopupPresentationStateClosed))
	{
		_lastSeenMovement = CACurrentMediaTime();
		BOOL prevState = self.popupBar.barHighlightGestureRecognizer.enabled;
		self.popupBar.barHighlightGestureRecognizer.enabled = NO;
		self.popupBar.barHighlightGestureRecognizer.enabled = prevState;
		_lastPopupBarLocation = self.popupBar.center;
		
		_statusBarThresholdDir = _popupControllerState == LNPopupPresentationStateOpen ? 1 : -1;
		
		_stateBeforeDismissStarted = _popupControllerState;
		
		[self _transitionToState:LNPopupPresentationStateTransitioning animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
		
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
		CGFloat targetCenterY = MIN(_lastPopupBarLocation.y + [pgr translationInView:self.popupBar.superview].y, _cachedDefaultFrame.origin.y - self.popupBar.frame.size.height / 2) - _dismissStartingOffset - _cachedInsets.bottom;
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
			
			_popupControllerTargetState = LNPopupPresentationStateClosed;
			[self _transitionToState:_popupControllerTargetState animated:YES useSpringAnimation:_popupControllerTargetState == LNPopupPresentationStateClosed ? YES : NO allowPopupBarAlphaModification:YES completion:^ {
				[_popupContentView.popupCloseButton _setButtonContainerStationary];
			} transitionOriginatedByUser:NO];
		}
		
		CGFloat statusBarHeightThreshold = UIApplication.sharedApplication.statusBarFrame.size.height / 2;
		
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
			BOOL hasPassedHeighThreshold = _stateBeforeDismissStarted == LNPopupPresentationStateClosed ? barTransitionPercent > LNPopupBarGestureHeightPercentThreshold : barTransitionPercent < (1.0 - LNPopupBarGestureHeightPercentThreshold);
			CGFloat panVelocity = [pgr velocityInView:_containerController.view].y;
			
			if(panVelocity < 0)
			{
				targetState = LNPopupPresentationStateOpen;
			}
			else if(panVelocity > 0)
			{
				targetState = LNPopupPresentationStateClosed;
			}
			else if(hasPassedHeighThreshold == YES)
			{
				targetState = _stateBeforeDismissStarted == LNPopupPresentationStateClosed ? LNPopupPresentationStateOpen : LNPopupPresentationStateClosed;
			}
		}
		
		[_popupContentView.popupCloseButton _setButtonContainerStationary];
		[self _transitionToState:targetState animated:YES useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:nil transitionOriginatedByUser:NO];
	}
	
	_dismissGestureStarted = NO;
}

- (void)_popupBarPresentationByUserPanGestureHandler:(UIPanGestureRecognizer*)pgr
{
	if(_dismissalOverride || _forceTouchOverride)
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
	self.popupBar.title = _currentPopupItem.title;
}

- (void)_reconfigure_subtitle
{
	self.popupBar.subtitle = _currentPopupItem.subtitle;
}

- (void)_reconfigure_image
{
	self.popupBar.image = _currentPopupItem.image;
}

- (void)_reconfigure_progress
{
	[UIView performWithoutAnimation:^{
		[self.popupBar.progressView setProgress:_currentPopupItem.progress animated:NO];
	}];
}

- (void)_reconfigure_accessibilityLavel
{
	self.popupBar.accessibilityCenterLabel = _currentPopupItem.accessibilityLabel;
}

- (void)_reconfigure_accessibilityHint
{
	self.popupBar.accessibilityCenterHint = _currentPopupItem.accessibilityHint;
}

- (void)_reconfigure_accessibilityImageLabel
{
	self.popupBar.accessibilityImageLabel = _currentPopupItem.accessibilityImageLabel;
}

- (void)_reconfigure_accessibilityProgressLabel
{
	self.popupBar.accessibilityProgressLabel = _currentPopupItem.accessibilityProgressLabel;
}

- (void)_reconfigure_accessibilityProgressValue
{
	self.popupBar.accessibilityProgressValue = _currentPopupItem.accessibilityProgressValue;
}

- (void)_reconfigureBarItems
{
	[self.popupBar _delayBarButtonLayout];
	[self.popupBar setLeftBarButtonItems:_currentPopupItem.leftBarButtonItems];
	[self.popupBar setRightBarButtonItems:_currentPopupItem.rightBarButtonItems];
	[self.popupBar _layoutBarButtonItems];
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
	if(self.popupBar.customBarViewController)
	{
		[self.popupBar.customBarViewController popupItemDidUpdate];
	}
	else
	{
		NSString* reconfigureSelector = [NSString stringWithFormat:@"_reconfigure_%@", key];
		
		void (*configureDispatcher)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
		configureDispatcher(self, NSSelectorFromString(reconfigureSelector));
	}
}

- (void)_reconfigureContent
{
	_currentPopupItem.itemDelegate = nil;
	_currentPopupItem = _containerController.popupContentViewController.popupItem;
	_currentPopupItem.itemDelegate = self;
	
	self.popupBar.popupItem = _currentPopupItem;
	
	if(_currentContentController)
	{
		__kindof UIViewController* oldContentController = _currentContentController;
		__kindof UIViewController* newContentController = _containerController.popupContentViewController;
		
		CGRect oldContentViewFrame = _currentContentController.view.frame;
		
		[newContentController beginAppearanceTransition:YES animated:NO];
		_LNPopupTransitionCoordinator* coordinator = [_LNPopupTransitionCoordinator new];
		[newContentController willTransitionToTraitCollection:_containerController.traitCollection withTransitionCoordinator:coordinator];
		[newContentController viewWillTransitionToSize:_containerController.view.bounds.size withTransitionCoordinator:coordinator];
		newContentController.view.frame = oldContentViewFrame;
		newContentController.view.clipsToBounds = NO;
		[self.popupContentView.contentView insertSubview:newContentController.view belowSubview:_currentContentController.view];
		[newContentController endAppearanceTransition];
		
		[_currentContentController beginAppearanceTransition:NO animated:NO];
		[_currentContentController.view removeFromSuperview];
		[_currentContentController endAppearanceTransition];
		
		_currentContentController = newContentController;
		
		if(_popupControllerState == LNPopupPresentationStateOpen)
		{
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
			
			[self _cleanupGestureRecognizersForController:oldContentController];
			[self _fixupGestureRecognizersForController:_currentContentController];
		}
	}
	
	if(self.popupBar.customBarViewController != nil)
	{
		[self.popupBar.customBarViewController popupItemDidUpdate];
	}
	else
	{
		NSArray<NSString*>* keys = @[@"title", @"subtitle", @"image", @"progress", @"leftBarButtonItems", @"accessibilityLavel", @"accessibilityHint", @"accessibilityImageLabel", @"accessibilityProgressLabel", @"accessibilityProgressValue"];
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
	
#ifndef LNPopupControllerEnforceStrictClean
	//backgroundView
	static NSString* const bV = @"X2JhY2tncm91bmRWaWV3";
	//backgroundView.shadowView.backgroundColor
	static NSString* const bVsVbC = @"YmFja2dyb3VuZFZpZXcuc2hhZG93Vmlldy5iYWNrZ3JvdW5kQ29sb3I=";
	
	NSString* str1 = _LNPopupDecodeBase64String(bV);
	
	if([_bottomBar respondsToSelector:NSSelectorFromString(str1)])
	{
		NSString* str2 = _LNPopupDecodeBase64String(bVsVbC);
		
		if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 10)
		{
			self.popupBar.systemShadowColor = [_bottomBar valueForKeyPath:str2];
		}
		else
		{
			self.popupBar.systemShadowColor = [UIColor lightGrayColor];
		}
	}
#endif
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

- (UIView*)_view:(UIView*)view selfOrSuperviewKindOfClass:(Class)aClass
{
	if([view isKindOfClass:aClass])
	{
		return view;
	}
	
	UIView* superview = view.superview;
	
	while(superview != nil)
	{
		if([superview isKindOfClass:aClass])
		{
			return superview;
		}
		
		superview = superview.superview;
	}
	
	return nil;
}

- (void)_repositionPopupCloseButton
{
	CGFloat startingTopConstant = _popupCloseButtonTopConstraint.constant;
	
	_popupCloseButtonTopConstraint.constant = _popupContentView.popupCloseButton.style == LNPopupCloseButtonStyleRound ? 12 : 8;
	
	CGFloat windowTopSafeAreaInset = 0;
	
	if (@available(iOS 11.0, *)) {
		windowTopSafeAreaInset += _popupContentView.window.safeAreaInsets.top;
	}
	
	_popupCloseButtonTopConstraint.constant += windowTopSafeAreaInset;
	if(windowTopSafeAreaInset == 0)
	{
		_popupCloseButtonTopConstraint.constant += (_containerController.popupContentViewController.prefersStatusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height);
	}
	
	id hitTest = [[_currentContentController view] hitTest:CGPointMake(12, _popupCloseButtonTopConstraint.constant) withEvent:nil];
	UINavigationBar* possibleBar = (id)[self _view:hitTest selfOrSuperviewKindOfClass:[UINavigationBar class]];
	if(possibleBar)
	{
		_popupCloseButtonTopConstraint.constant += CGRectGetHeight(possibleBar.bounds);
	}
	
	if(startingTopConstant != _popupCloseButtonTopConstraint.constant)
	{
		[_popupContentView setNeedsUpdateConstraints];
		[UIView animateWithDuration:UIApplication.sharedApplication.statusBarOrientationAnimationDuration delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
			[_popupContentView layoutIfNeeded];
		} completion:nil];
	}
}

- (void)_setUpCloseButtonForPopupContentView
{
	[_popupContentView.popupCloseButton removeFromSuperview];
	_popupContentView.popupCloseButton = nil;

	LNPopupCloseButtonStyle buttonStyle = _LNPopupResolveCloseButtonStyleFromCloseButtonStyle(_popupContentView.popupCloseButtonStyle);
	
	if(buttonStyle != LNPopupCloseButtonStyleNone)
	{
		_popupContentView.popupCloseButton = [[LNPopupCloseButton alloc] initWithStyle:buttonStyle];
		_popupContentView.popupCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
		[_popupContentView.popupCloseButton addTarget:self action:@selector(_closePopupContent) forControlEvents:UIControlEventTouchUpInside];
		[_popupContentView.contentView addSubview:self.popupContentView.popupCloseButton];
		
		[_popupContentView.popupCloseButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		[_popupContentView.popupCloseButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[_popupContentView.popupCloseButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		[_popupContentView.popupCloseButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		
		_popupCloseButtonTopConstraint = [_popupContentView.popupCloseButton.topAnchor constraintEqualToAnchor:_popupContentView.contentView.topAnchor constant:buttonStyle == LNPopupCloseButtonStyleRound ? 12 : 8];
		
		if(buttonStyle == LNPopupCloseButtonStyleRound)
		{
			_popupCloseButtonHorizontalConstraint = [_popupContentView.popupCloseButton.leadingAnchor constraintEqualToAnchor:_popupContentView.contentView.leadingAnchor constant:12];
		}
		else
		{
			_popupCloseButtonHorizontalConstraint = [_popupContentView.popupCloseButton.centerXAnchor constraintEqualToAnchor:_popupContentView.contentView.centerXAnchor];
		}
		
		[NSLayoutConstraint activateConstraints:@[_popupCloseButtonTopConstraint, _popupCloseButtonHorizontalConstraint]];
	}
}

- (LNPopupBar *)popupBarStorage
{
	if(_popupBar)
	{
		return _popupBar;
	}
	
	_popupBar = [LNPopupBar new];
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
	if(_popupControllerState == LNPopupPresentationStateHidden)
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
	_popupContentView.layer.masksToBounds = YES;
	[_popupContentView addObserver:self forKeyPath:@"popupCloseButtonStyle" options:NSKeyValueObservingOptionInitial context:NULL];
	
	_popupContentView.preservesSuperviewLayoutMargins = YES;
	_popupContentView.contentView.preservesSuperviewLayoutMargins = YES;
	
	_popupContentView.popupInteractionGestureRecognizer = [[LNPopupInteractionPanGestureRecognizer alloc] initWithTarget:self action:@selector(_popupBarPresentationByUserPanGestureHandler:) popupController:self];
	
	return _popupContentView;
}

- (void)dealloc
{
	//Cannot use self.popupBar in this method because it returns nil when the popup state is LNPopupPresentationStateHidden.
	
	if(_previewingContext)
	{
		[_containerController unregisterForPreviewingWithContext:_previewingContext];
	}
	
	if(_popupBar)
	{
		[_popupBar removeFromSuperview];
	}
	[_popupContentView removeObserver:self forKeyPath:@"popupCloseButtonStyle"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"popupCloseButtonStyle"] && object == _popupContentView)
	{
		[UIView performWithoutAnimation:^{
			[self _setUpCloseButtonForPopupContentView];
			[self _repositionPopupCloseButton];
		}];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	_LNPopupTransitionCoordinator* coordinator = [_LNPopupTransitionCoordinator new];
	[_containerController.popupContentViewController willTransitionToTraitCollection:_containerController.traitCollection withTransitionCoordinator:coordinator];
	[_containerController.popupContentViewController viewWillTransitionToSize:_containerController.view.bounds.size withTransitionCoordinator:coordinator];
	
	if(_popupControllerTargetState == LNPopupPresentationStateHidden)
	{
		_dismissalOverride = NO;
		
		if(open)
		{
			_popupControllerState = LNPopupPresentationStateClosed;
		}
		else
		{
			_popupControllerState = LNPopupPresentationStateTransitioning;
		}
		_popupControllerTargetState = LNPopupPresentationStateClosed;
		
		_bottomBar = _containerController.bottomDockingViewForPopup_internalOrDeveloper;
		
		self.popupBarStorage.hidden = NO;
		
		if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9)
		{
			_previewingContext = [_containerController registerForPreviewingWithDelegate:self sourceView:self.popupBarStorage];
		}
		
		[self _movePopupBarAndContentToBottomBarSuperview];
		[self _configurePopupBarFromBottomBar];
		
		[self.popupBar addGestureRecognizer:self.popupContentView.popupInteractionGestureRecognizer];
		
		[self _setContentToState:LNPopupPresentationStateClosed];
		[_containerController.view layoutIfNeeded];
		
		[self _reconfigureContent];
		
		[self.popupBar setNeedsLayout];
		[self.popupBar layoutIfNeeded];
		
		[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
		 {
			 CGRect barFrame = self.popupBar.frame;
			 barFrame.size.height = _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController);
			 self.popupBar.frame = barFrame;
			 self.popupBar.frame = [self _frameForClosedPopupBar];
			 
			 _LNPopupSupportFixInsetsForViewController(_containerController, YES, barFrame.size.height);
			 
			 if(open)
			 {
				 [self openPopupAnimated:animated completion:completionBlock];
			 }
		 } completion:^(BOOL finished)
		 {
			 if(!open)
			 {
				 _popupControllerState = LNPopupPresentationStateClosed;
			 }
			 
			 if(completionBlock != nil && !open)
			 {
				 completionBlock();
			 }
		 }];
	}
	else
	{
		[self _reconfigureContent];
		
		if(open)
		{
			[self openPopupAnimated:animated completion:completionBlock];
		}
		else if(completionBlock != nil)
		{
			completionBlock();
		}
	}
	
	_currentContentController = _containerController.popupContentViewController;
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self _transitionToState:LNPopupPresentationStateTransitioning animated:NO useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:^{
		[_containerController.view setNeedsLayout];
		[_containerController.view layoutIfNeeded];
		[self _transitionToState:LNPopupPresentationStateOpen animated:animated useSpringAnimation:NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:NO];
	} transitionOriginatedByUser:YES];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
	
	[self _transitionToState:LNPopupPresentationStateClosed animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap ? YES : NO allowPopupBarAlphaModification:YES completion:completionBlock transitionOriginatedByUser:YES];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(_popupControllerState != LNPopupPresentationStateHidden)
	{
		void (^dismissalAnimationCompletionBlock)(void) = ^
		{
			_popupControllerState = LNPopupPresentationStateTransitioning;
			_popupControllerTargetState = LNPopupPresentationStateHidden;
			
			[UIView animateWithDuration:animated ? 0.5 : 0.0 delay:0.0 usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
			 {
				 CGRect barFrame = self.popupBar.frame;
				 CGFloat oldHeight = barFrame.size.height;
				 barFrame.size.height = 0;
				 self.popupBar.frame = barFrame;
				 
				 _LNPopupSupportFixInsetsForViewController(_containerController, YES, - oldHeight);
			 } completion:^(BOOL finished)
			 {
				 _popupControllerState = LNPopupPresentationStateHidden;
				 
				 CGRect bottomBarFrame = [_containerController defaultFrameForBottomDockingView_internalOrDeveloper];
				 bottomBarFrame.origin.y -= _cachedInsets.bottom;
				 _bottomBar.frame = bottomBarFrame;
				 _bottomBar = nil;
				 
				 self.popupBarStorage.hidden = YES;
				 [self.popupBar removeFromSuperview];
				 
				 [self.popupContentView removeFromSuperview];
				 self.popupContentView.popupInteractionGestureRecognizer = nil;
				 [self.popupContentView removeObserver:self forKeyPath:@"popupCloseButtonStyle"];
				 self.popupContentView = nil;
				 
				 _LNPopupSupportFixInsetsForViewController(_containerController, YES, 0);
				 
				 [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
				 [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
				 
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
//			self.popupBarStorage.hidden = YES;
			_dismissalOverride = YES;
			self.popupContentView.popupInteractionGestureRecognizer.enabled = NO;
			self.popupContentView.popupInteractionGestureRecognizer.enabled = YES;
			
			LNPopupInteractionStyle resolvedStyle = _LNPopupResolveInteractionStyleFromInteractionStyle(_containerController.popupInteractionStyle);
			
			[self _transitionToState:LNPopupPresentationStateClosed animated:animated useSpringAnimation:resolvedStyle == LNPopupInteractionStyleSnap allowPopupBarAlphaModification:YES completion:dismissalAnimationCompletionBlock transitionOriginatedByUser:NO];
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
	[self.popupBar _setTitleViewMarqueesPaused:NO];
}

#pragma mark UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
	if(_popupControllerState != LNPopupPresentationStateClosed)
	{
		return nil;
	}
	
	UIViewController* rv = [_containerController.popupBar.previewingDelegate previewingViewControllerForPopupBar:_containerController.popupBar];
	
	if(rv)
	{
		//REALLY disable interaction if a preview view controller is about to be presented.
		_forceTouchOverride = YES;
		self.popupContentView.popupInteractionGestureRecognizer.enabled = NO;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			_forceTouchOverride = NO;
			self.popupContentView.popupInteractionGestureRecognizer.enabled = YES;
		});
	}
	
	return rv;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
	if([_containerController.popupBar.previewingDelegate respondsToSelector:@selector(popupBar:commitPreviewingViewController:)])
	{
		[_containerController.popupBar.previewingDelegate popupBar:_containerController.popupBar commitPreviewingViewController:viewControllerToCommit];
	}
}

#pragma mark _LNPopupBarDelegate

- (void)_popupBarStyleDidChange:(LNPopupBar*)bar
{
	CGRect barFrame = self.popupBar.frame;
	CGFloat currentHeight = barFrame.size.height;
	barFrame.size.height = _LNPopupBarHeightForBarStyle(_LNPopupResolveBarStyleFromBarStyle(self.popupBar.barStyle), self.popupBar.customBarViewController);
	barFrame.origin.y -= (barFrame.size.height - currentHeight);
	self.popupBar.frame = barFrame;
}

@end
