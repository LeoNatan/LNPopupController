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
@import ObjectiveC;

static const void* _LNPopupItemKey = &_LNPopupItemKey;
static const void* _LNPopupControllerKey = &_LNPopupControllerKey;
const void* _LNPopupPresentationContainerViewControllerKey = &_LNPopupPresentationContainerViewControllerKey;
const void* _LNPopupContentViewControllerKey = &_LNPopupContentViewControllerKey;
static const void* _LNPopupBottomBarSupportKey = &_LNPopupBottomBarSupportKey;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation UIViewController (LNPopupSupportPrivate)

@dynamic ln_popupController, popupPresentationContainerViewController, popupContentViewController, bottomBarSupport;

@end
#pragma clang diagnostic pop

@implementation UIViewController (LNPopupSupport)

- (void)presentPopupBarWithContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)())completionBlock
{
	if(controller == nil)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Content view controller cannot be nil."];
	}
	
	self.popupContentViewController = controller;
	controller.popupPresentationContainerViewController = self;
	
	[self._ln_popupController presentPopupBarAnimated:animated completion:completionBlock];
}

- (void)openPopupAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[self._ln_popupController_nocreate openPopupAnimated:animated completion:completionBlock];
}

- (void)closePopupAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[self._ln_popupController_nocreate closePopupAnimated:animated completion:completionBlock];
}

- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)())completionBlock
{
	[self._ln_popupController_nocreate dismissPopupBarAnimated:animated completion:^{
		//Cleanup
		self.popupContentViewController.popupPresentationContainerViewController = nil;
		self.popupContentViewController = nil;
		
		//No longer need to retain the popup controller after dismissing.
		objc_setAssociatedObject(self, _LNPopupControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
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

- (LNPopupController*)_ln_popupController_nocreate
{
	return objc_getAssociatedObject(self, _LNPopupControllerKey);
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

- (_LNPopupBottomBarSupport *)_ln_bottomBarSupport
{
	_LNPopupBottomBarSupport* rv = objc_getAssociatedObject(self, _LNPopupBottomBarSupportKey);
	
	if(rv == nil)
	{
		rv = [[_LNPopupBottomBarSupport alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0)];
		
		objc_setAssociatedObject(self, _LNPopupBottomBarSupportKey, rv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		[self.view addSubview:rv];
	}
	
	return rv;
}

- (nonnull UIView *)bottomDockingViewForPopup
{
	return self._ln_bottomBarSupport;
}

- (CGRect)defaultFrameForBottomDockingView
{
	return CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0);
}

@end
