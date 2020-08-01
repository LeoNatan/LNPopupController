//
//  UIViewController+LNPopupSupport.m
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupItem+Private.h"
#import "_LNWeakRef.h"
#import "UIView+LNPopupSupportPrivate.h"
@import ObjectiveC;

static const void* _LNPopupItemKey = &_LNPopupItemKey;
static const void* _LNPopupControllerKey = &_LNPopupControllerKey;
const void* _LNPopupPresentationContainerViewControllerKey = &_LNPopupPresentationContainerViewControllerKey;
const void* _LNPopupContentViewControllerKey = &_LNPopupContentViewControllerKey;
static const void* _LNPopupInteractionStyleKey = &_LNPopupInteractionStyleKey;
static const void* _LNPopupBottomBarSupportKey = &_LNPopupBottomBarSupportKey;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation UIViewController (LNPopupSupportPrivate)

@dynamic ln_popupController, popupPresentationContainerViewController, popupContentViewController, bottomBarSupport;

@end
#pragma clang diagnostic pop

@implementation UIViewController (LNPopupSupport)

- (void)presentPopupBarWithContentViewController:(UIViewController*)controller openPopup:(BOOL)openPopup animated:(BOOL)animated completion:(nullable void(^)(void))completionBlock;
{
	if(self.view.window == nil)
	{
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			[self presentPopupBarWithContentViewController:controller openPopup:openPopup animated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	if(controller == nil)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Content view controller cannot be nil."];
	}
	
	self.popupContentViewController = controller;
	controller.popupPresentationContainerViewController = self;
	
	[self._ln_popupController presentPopupBarAnimated:animated openPopup:openPopup completion:completionBlock];
}

- (void)presentPopupBarWithContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	[self presentPopupBarWithContentViewController:controller openPopup:NO animated:animated completion:completionBlock];
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			[self openPopupAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate openPopupAnimated:animated completion:completionBlock];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			[self closePopupAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate closePopupAnimated:animated completion:completionBlock];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)(void))completionBlock
{
	if(self.view.window == nil)
	{
		[self.view _ln_letMeKnowWhenViewInWindowHierarchy:^(dispatch_block_t completionBlockInWindow) {
			[self dismissPopupBarAnimated:NO completion:^{
				if(completionBlock) { completionBlock(); }
				completionBlockInWindow();
			}];
		}];
		
		return;
	}
	
	[self._ln_popupController_nocreate dismissPopupBarAnimated:animated completion:^{
		//Cleanup
		self.popupContentViewController.popupPresentationContainerViewController = nil;
		self.popupContentViewController = nil;
		
		//The LNPopupController is no longer released here.
		//There should be one popup controller per presenting controller per instance.
		
		if(completionBlock)
		{
			completionBlock();
		}
	}];
}

- (void)updatePopupBarAppearance
{
	[self._ln_popupController_nocreate _configurePopupBarFromBottomBar];
}

- (LNPopupPresentationState)popupPresentationState
{
	return self._ln_popupController_nocreate.popupControllerState;
}

- (BOOL)_isContainedInPopupController
{
	if(self.popupPresentationContainerViewController != nil)
	{
		return YES;
	}
	
	return [self.parentViewController _isContainedInPopupController];
}

- (UIViewController *)popupPresentationContainerViewController
{
	return [(_LNWeakRef*)objc_getAssociatedObject(self, _LNPopupPresentationContainerViewControllerKey) object];
}

- (void)setPopupPresentationContainerViewController:(UIViewController *)popupPresentationContainerViewController
{
	[self willChangeValueForKey:@"popupPresentationContainerViewController"];
	_LNWeakRef* weakRef = [_LNWeakRef refWithObject:popupPresentationContainerViewController];
	objc_setAssociatedObject(self, _LNPopupPresentationContainerViewControllerKey, weakRef, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"popupPresentationContainerViewController"];
}

- (UIViewController *)popupContentViewController
{
	return objc_getAssociatedObject(self, _LNPopupContentViewControllerKey);
}

- (void)setPopupContentViewController:(UIViewController *)popupContentViewController
{
	[self willChangeValueForKey:@"popupContentViewController"];
	objc_setAssociatedObject(self, _LNPopupContentViewControllerKey, popupContentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"popupContentViewController"];
}

- (LNPopupItem *)popupItem
{
	LNPopupItem* rv = objc_getAssociatedObject(self, _LNPopupItemKey);
	
	if(rv == nil)
	{
		rv = [LNPopupItem new];
		objc_setAssociatedObject(self, _LNPopupItemKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[rv _setContainerController:self];
	}
	
	return rv;
}

- (LNPopupBar *)popupBar
{
	return self._ln_popupController.popupBarStorage;
}

- (LNPopupContentView *)popupContentView
{
	return self._ln_popupController.popupContentView;
}

- (LNPopupInteractionStyle)popupInteractionStyle
{
	return [objc_getAssociatedObject(self, _LNPopupInteractionStyleKey) unsignedIntegerValue];
}

- (void)setPopupInteractionStyle:(LNPopupInteractionStyle)popupInteractionStyle
{
	objc_setAssociatedObject(self, _LNPopupInteractionStyleKey, @(popupInteractionStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LNPopupController*)_ln_popupController_nocreate
{
	return objc_getAssociatedObject(self, _LNPopupControllerKey);
}

- (__kindof UIView *)viewForPopupInteractionGestureRecognizer
{
	return self.view;
}

@end

@implementation UIViewController (LNCustomContainerPopupSupport)

- (LNPopupController *)_ln_popupController
{
	LNPopupController* rv = [self _ln_popupController_nocreate];
	
	if(rv == nil)
	{
		rv = [[LNPopupController alloc] initWithContainerViewController:self];
		objc_setAssociatedObject(self, _LNPopupControllerKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return rv;
}

- (_LNPopupBottomBarSupport *)_ln_bottomBarSupport_nocreate
{
	return objc_getAssociatedObject(self, _LNPopupBottomBarSupportKey);
}

- (_LNPopupBottomBarSupport *)_ln_bottomBarSupport
{
	_LNPopupBottomBarSupport* rv = [self _ln_bottomBarSupport_nocreate];
	
	if(rv == nil)
	{
		rv = [[_LNPopupBottomBarSupport alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0)];
		
		objc_setAssociatedObject(self, _LNPopupBottomBarSupportKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		[self.view addSubview:rv];
	}
	
	return rv;
}


- (nullable UIView *)bottomDockingViewForPopup_nocreateOrDeveloper
{
	return self.bottomDockingViewForPopupBar ?: self._ln_bottomBarSupport_nocreate;
}

- (nonnull UIView *)bottomDockingViewForPopup_internalOrDeveloper
{
	return self.bottomDockingViewForPopupBar ?: self._ln_bottomBarSupport;
}

- (nullable UIView *)bottomDockingViewForPopupBar
{
	return nil;
}

- (UIEdgeInsets)insetsForBottomDockingView
{
	if(self.presentingViewController != nil && [NSStringFromClass(self.presentationController.class) containsString:@"Preview"])
	{
		return UIEdgeInsetsZero;
	}
	
	return UIEdgeInsetsMake(0, 0, self.view.superview.safeAreaInsets.bottom, 0);
}

- (CGRect)defaultFrameForBottomDockingView
{
	return CGRectZero;
}

- (CGRect)defaultFrameForBottomDockingView_internal
{
	return CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0);
}

- (CGRect)defaultFrameForBottomDockingView_internalOrDeveloper
{
	return [self bottomDockingViewForPopupBar] != nil ? [self defaultFrameForBottomDockingView] : [self defaultFrameForBottomDockingView_internal];
}

@end
