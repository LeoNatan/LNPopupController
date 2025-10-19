//
//  LNPopupBarContentViewController.m
//  LNPopupController
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupCustomBarViewController+Private.h"
#import "_LNPopupSwizzlingUtils.h"

@interface LNPopupCustomBarViewController ()

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation LNPopupCustomBarViewController

@dynamic preferredContentSize;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if([self isMemberOfClass:[LNPopupCustomBarViewController class]])
	{
		[NSException raise:NSInternalInconsistencyException format:@"Do not initialize instances of LNPopupCustomBarViewController directly. You should subclass LNPopupCustomBarViewController and use instances of that subclass."];
		return nil;
	}
	
	return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)setContainingPopupBar:(LNPopupBar *)containingPopupBar
{
	[self willMoveToPopupBar:containingPopupBar];
	
	_containingPopupBar = containingPopupBar;
	
	[self didMoveToPopupBar];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.preservesSuperviewLayoutMargins = YES;
}

- (BOOL)wantsDefaultTapGestureRecognizer
{
	return YES;
}

- (BOOL)wantsDefaultPanGestureRecognizer
{
	return YES;
}

- (BOOL)wantsDefaultHighlightGestureRecognizer
{
	return YES;
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize
{
	[super setPreferredContentSize:preferredContentSize];
}

- (void)popupItemDidUpdate
{
	
}

- (void)willMoveToPopupBar:(LNPopupBar *)newPopupBar
{
	
}

- (void)didMoveToPopupBar
{
	
}

- (void)_activeAppearanceDidChange:(LNPopupBarAppearance*)activeAppearance
{
	if(activeAppearance == nil)
	{
		return;
	}
	
	[self activeAppearanceDidChange:activeAppearance];
}

- (void)activeAppearanceDidChange:(LNPopupBarAppearance *)activeAppearance
{
	
}

- (UIViewController*)popupContentViewController
{
	return self.popupController.currentContentController;
}

- (UIViewController*)popupPresentationContainerViewController
{
	return self.popupController.containerController;
}

- (LNPopupItem *)popupItem
{
	return self.containingPopupBar.popupItem;
}

- (LNPopupBar *)popupBar
{
	return self.containingPopupBar;
}

- (void)_userFacing_viewWillAppear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewIsAppearing:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewIsAppearing:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidAppear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidAppear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewWillDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (void)_userFacing_viewDidDisappear:(BOOL)animated
{
	__ln_popup_suppressViewControllerLifecycle = YES;
	
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidDisappear:), animated);
	
	__ln_popup_suppressViewControllerLifecycle = NO;
}

- (BOOL)_ln_popupUIRequiresZeroInsets
{
	return YES;
}

@end

#pragma mark - Custom bar controller appearance control

@implementation _LNPopupCustomBarViewController_AppearanceControl

- (void)viewWillAppear:(BOOL)animated
{
	//Ignored
}

- (void)viewIsAppearing:(BOOL)animated
{
	//Ignore
}

- (void)viewDidAppear:(BOOL)animated
{
	//Ignored
}

- (void)viewWillDisappear:(BOOL)animated
{
	//Ignored
}

- (void)viewDidDisappear:(BOOL)animated
{
	//Ignored
}

- (Class)class
{
	return LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
}

@end

#pragma clang diagnostic pop
