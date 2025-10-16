//
//  UITabBar+LNPopupMinimizationSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 26/9/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UITabBar+LNPopupMinimizationSupport.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupBar+Private.h"
#import "_LNPopupGlassUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "_LNWeakRef.h"
#import <objc/runtime.h>

/*
 @property (nonatomic, getter=_isMinimized, setter=_setMinimized:) BOOL _minimized;
 @property (copy, nonatomic, setter=_setMinimizedStateDidChangeHandler:) void(^_minimizedStateDidChangeHandler)(BOOL);
 @property (readonly, nonatomic) struct CGRect _frameForHostedAccessoryView;
 */

static BOOL __LNPopupTabBarSupportsMinimizationAPI = YES;
static NSString* __LNFrameForHostedAccessoryViewKey;
static NSString* __LNMinimizedStateDidChangeHandlerKey;
static NSString* __LNIsMinimizedKey;

BOOL LNPopupEnvironmentTabBarSupportsMinimizationAPI(void)
{
	return __LNPopupTabBarSupportsMinimizationAPI;
}

@implementation UITabBar (LNPopupMinimizationSupport)

+ (void)load
{
	@autoreleasepool
	{
		__LNFrameForHostedAccessoryViewKey = LNPopupHiddenString("_frameForHostedAccessoryView");
		__LNMinimizedStateDidChangeHandlerKey = LNPopupHiddenString("_minimizedStateDidChangeHandler");
		__LNIsMinimizedKey = LNPopupHiddenString("_isMinimized");
		
		BOOL glass = LNPopupEnvironmentHasGlass();
		BOOL m1 = [self instancesRespondToSelector:NSSelectorFromString(__LNFrameForHostedAccessoryViewKey)];
		BOOL m2 = [self instancesRespondToSelector:NSSelectorFromString(__LNMinimizedStateDidChangeHandlerKey)];
		BOOL m3 = [self instancesRespondToSelector:NSSelectorFromString(__LNIsMinimizedKey)];
		
		__LNPopupTabBarSupportsMinimizationAPI = glass && m1 && m2 && m3;
	}
}

- (BOOL)_ln_wantsMinimizedPopupBar
{
	if(__LNPopupTabBarSupportsMinimizationAPI == NO)
	{
		return NO;
	}
	
	return [[self valueForKey:__LNIsMinimizedKey] boolValue];
}

- (CGRect)_ln_proposedFrameForPopupBar
{
	return [[self valueForKey:__LNFrameForHostedAccessoryViewKey] CGRectValue];
}

static const void* __LNPopupTabBarMinimizationDelegateKey = &__LNPopupTabBarMinimizationDelegateKey;

- (id<_LNPopupTabBarMinimizationDelegate>)_ln_minimizationDelegate
{
	_LNWeakRef* ref = objc_getAssociatedObject(self, __LNPopupTabBarMinimizationDelegateKey);
	if(ref.object == nil)
	{
		objc_setAssociatedObject(self, __LNPopupTabBarMinimizationDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ref.object;
}

- (void)_ln_setMinimizationDelegate:(id<_LNPopupTabBarMinimizationDelegate>)minimizationDelegate
{
	_LNWeakRef* ref = [_LNWeakRef refWithObject:minimizationDelegate];
	objc_setAssociatedObject(self, __LNPopupTabBarMinimizationDelegateKey, ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	__weak __typeof(self) weakTabBar = self;
	void (^handler)(BOOL) = minimizationDelegate == nil ? (id)nil : (id)^(BOOL wasMinimized) {
		[weakTabBar._ln_minimizationDelegate tabBar:weakTabBar didMinimize:wasMinimized];
	};
	
	[self setValue:handler forKey:__LNMinimizedStateDidChangeHandlerKey];
}

@end

@implementation UITabBarController (LNPopupMinimizationSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(@available(iOS 18, *))
	{
		static NSString* outlineViewKey = LNPopupHiddenString("_outlineView");
		UIView* outlineView = [self.sidebar valueForKey:outlineViewKey];
		
		if(outlineView != nil)
		{
			static NSString* tabContainerViewKey = LNPopupHiddenString("visualStyle.tabContainerView");
			UIView* parentForPopupBar = [self valueForKeyPath:tabContainerViewKey];
			
			static NSString* sidebarLayoutKey = LNPopupHiddenString("sidebarLayout");
			
			NSUInteger sidebarLayout = [[parentForPopupBar valueForKey:sidebarLayoutKey] unsignedIntegerValue];
			
			if(sidebarLayout == 0)
			{
				barInsets.leading = self.sidebar.isHidden ? 0 : outlineView.bounds.size.width + 8;
			}
		}
	}
	
	if(__LNPopupTabBarSupportsMinimizationAPI && popupBar.supportsMinimization && [self _ln_isFloatingTabBar] == NO)
	{
		CGRect proposedMinimizedFrame = self.tabBar._ln_proposedFrameForPopupBar;
		NSDirectionalEdgeInsets floatingLayoutMargins = self.popupBar.floatingLayoutMargins;
		
		barInsets.leading = proposedMinimizedFrame.origin.x;
		barInsets.trailing = self.tabBar.bounds.size.width - proposedMinimizedFrame.size.width - proposedMinimizedFrame.origin.x;
		barInsets.leading -= floatingLayoutMargins.leading;
		barInsets.trailing -= floatingLayoutMargins.trailing;
	}
	
	return barInsets;
}

@end
