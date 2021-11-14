//
//  LNPopupBarContentViewController.m
//  LNPopupController
//
//  Created by Leo Natan on 15/12/2016.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupCustomBarViewController+Private.h"
#import "_LNPopupSwizzlingUtils.h"

@interface LNPopupCustomBarViewController ()

@end

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
	return self.popupContentViewController.popupItem;
}

- (LNPopupBar *)popupBar
{
	return self.containingPopupBar;
}

- (void)_userFacing_viewWillAppear:(BOOL)animated
{
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillAppear:), animated);
}

- (void)_userFacing_viewDidAppear:(BOOL)animated
{
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidAppear:), animated);
}

- (void)_userFacing_viewWillDisappear:(BOOL)animated
{
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewWillDisappear:), animated);
}

- (void)_userFacing_viewDidDisappear:(BOOL)animated
{
	Class superclass = LNDynamicSubclassSuper(self, _LNPopupCustomBarViewController_AppearanceControl.class);
	struct objc_super super = {.receiver = self, .super_class = superclass};
	void (*super_class)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_class(&super, @selector(viewDidDisappear:), animated);
}

@end

#pragma mark - Custom bar controller appearance control

@implementation _LNPopupCustomBarViewController_AppearanceControl

- (void)viewWillAppear:(BOOL)animated
{
	//Ignored
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
