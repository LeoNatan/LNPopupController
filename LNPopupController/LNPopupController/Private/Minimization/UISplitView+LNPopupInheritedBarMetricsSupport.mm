//
//  UISplitView+LNPopupInheritedBarMetricsSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "UISplitView+LNPopupInheritedBarMetricsSupport.h"
#import "LNPopupBar+Private.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "UIToolbar+LNPopupInheritedBarMetricsSupport.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupControllerImpl.h"
#import "_LNPopupSwizzlingUtils.h"

static const void* frozenAvoidPrimaryColumnValueKey = &frozenAvoidPrimaryColumnValueKey;

@implementation _LNPopupSplitViewDelegateWrapper
{
	NSNumber* _targetDisplayMode;
}

- (UISplitViewControllerDisplayMode)_displayModeForSplitViewController:(UISplitViewController *)svc
{
	if(_targetDisplayMode != nil)
	{
		return (UISplitViewControllerDisplayMode)[_targetDisplayMode integerValue];
	}
	
	return svc.displayMode;
}

- (void)splitViewController:(UISplitViewController *)svc willShowColumn:(UISplitViewControllerColumn)column
{
	if(column != UISplitViewControllerColumnPrimary)
	{
		return;
	}
	
	if([svc _ln_shouldAvoidPrimaryColumnWithVisible:YES forDisplayMode:[self _displayModeForSplitViewController:svc]])
	{
		[UIView performWithoutAnimation:^{
			[svc _ln_setFrozenAvoidPrimaryColumnValue:@(YES)];
			__LNPopupUpdateChildInsets(svc);
		}];
	}
	
	void (^todo)(id) = ^ (id context) {
		[svc.view setNeedsLayout];
		[svc.view layoutIfNeeded];
		__LNPopupUpdateChildInsets(svc);
		
		for(UIViewController* child in svc.childViewControllers)
		{
			[child.view setNeedsLayout];
			[child.view layoutIfNeeded];
		}
	};
	
	if(svc.transitionCoordinator)
	{
		[svc.transitionCoordinator animateAlongsideTransition:todo completion:nil];
	}
	else
	{
		todo(nil);
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate splitViewController:svc willShowColumn:column];
	}
}

- (void)splitViewController:(UISplitViewController *)svc willHideColumn:(UISplitViewControllerColumn)column
{
	if(column != UISplitViewControllerColumnPrimary)
	{
		return;
	}
	
	if([svc _ln_shouldAvoidPrimaryColumnWithVisible:svc._ln_isPrimaryShown forDisplayMode:svc.displayMode])
	{
		[UIView performWithoutAnimation:^{
			[svc _ln_setFrozenAvoidPrimaryColumnValue:@(YES)];
			__LNPopupUpdateChildInsets(svc);
		}];
	}
	
	void (^todo)(id) = ^ (id context) {
		[svc.view setNeedsLayout];
		[svc.view layoutIfNeeded];
		__LNPopupUpdateChildInsets(svc);
		
		for(UIViewController* child in svc.childViewControllers)
		{
			[child.view setNeedsLayout];
			[child.view layoutIfNeeded];
		}
	};
	
	void (^done)(id) = ^ (id context) {
		[svc _ln_setFrozenAvoidPrimaryColumnValue:nil];
		__LNPopupUpdateChildInsets(svc);
	};
	
	if(svc.transitionCoordinator)
	{
		[svc.transitionCoordinator animateAlongsideTransition:todo completion:done];
	}
	else
	{
		todo(nil);
		done(nil);
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate splitViewController:svc willHideColumn:column];
	}
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
//	BOOL avoidedBefore = [svc _ln_shouldAvoidPrimaryColumnWithVisible:svc._ln_isPrimaryShown forDisplayMode:svc.displayMode];
//	BOOL avoidedAfter = [svc _ln_shouldAvoidPrimaryColumnWithVisible:svc._ln_isPrimaryShown forDisplayMode:displayMode];
//	
//	if(avoidedBefore == YES && avoidedAfter != avoidedBefore)
//	{
//		[svc _ln_setFrozenAvoidPrimaryColumnValue:@(avoidedBefore)];
//	}
//	
//	[svc _ln_setFrozenAvoidPrimaryColumnValue:nil];
//	__LNPopupUpdateChildInsets(svc);
	
	_targetDisplayMode = @(displayMode);
	
	void (^todo)(id) = ^ (id context) {
		[svc.view setNeedsLayout];
		[svc.view layoutIfNeeded];
		__LNPopupUpdateChildInsets(svc);
		
		for(UIViewController* child in svc.childViewControllers)
		{
			[child.view setNeedsLayout];
			[child.view layoutIfNeeded];
		}
	};
	
	void (^done)(id) = ^ (id context) {
		_targetDisplayMode = nil;
	};
	
	if(svc.transitionCoordinator)
	{
		[svc.transitionCoordinator animateAlongsideTransition:todo completion:done];
	}
	else
	{
		todo(nil);
		done(nil);
	}
	
	if([self.forwardedDelegate respondsToSelector:_cmd])
	{
		return [self.forwardedDelegate splitViewController:svc willChangeToDisplayMode:displayMode];
	}
}

@end

@implementation UISplitViewController (LNPopupInheritedBarMetricsSupport)

- (NSNumber *)_ln_frozenAvoidPrimaryColumnValue
{
	return objc_getAssociatedObject(self, frozenAvoidPrimaryColumnValueKey);
}

- (void)_ln_setFrozenAvoidPrimaryColumnValue:(NSNumber *)frozenAvoidPrimaryColumnValue
{
	objc_setAssociatedObject(self, frozenAvoidPrimaryColumnValueKey, frozenAvoidPrimaryColumnValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)_ln_isPrimaryShown
{
	if(@available(iOS 26.0, *))
	{
		return [self isShowingColumn:UISplitViewControllerColumnPrimary];
	}
	
	return NO;
}

- (BOOL)_ln_shouldAvoidPrimaryColumn
{
	return [self _ln_shouldAvoidPrimaryColumnWithVisible:self._ln_isPrimaryShown forDisplayMode:self.displayMode];
}

- (BOOL)_ln_shouldAvoidPrimaryColumnWithVisible:(BOOL)visible forDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
	if(self.popupBarAvoidsPrimaryColumn == NO || self._ln_popupController_nocreate.popupControllerTargetState == LNPopupPresentationStateBarHidden)
	{
		return NO;
	}
	
	static NSArray* supportedDisplayModes = @[@(UISplitViewControllerDisplayModeOneBesideSecondary), @(UISplitViewControllerDisplayModeTwoBesideSecondary)];
	
	return visible && [supportedDisplayModes containsObject:@(displayMode)];
}

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	barInsets = [UINavigationController _ln_popupBarMarginsForPopupBar:popupBar inController:self];
	
	CGFloat width = 0.0;
	if(self._ln_shouldAvoidPrimaryColumn)
	{
		width = self.primaryColumnWidth;
	}
	
	if(self.primaryEdge == UISplitViewControllerPrimaryEdgeLeading)
	{
		barInsets.leading += (width - (barInsets.leading != 0 ? 10 : 0));
	}
	else
	{
		barInsets.trailing += (width - (barInsets.trailing != 0 ? 10 : 0));
	}
	
	return barInsets;
}

@end
