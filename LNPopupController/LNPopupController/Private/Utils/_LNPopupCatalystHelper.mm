//
//  _LNPopupCatalystHelper.mm
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "_LNPopupCatalystHelper.h"
#import "_LNPopupBase64Utils.hh"
#import "LNPopupControllerImpl.h"

#if TARGET_OS_MACCATALYST

@interface NSObject ()

+ (void)runAnimationGroup:(void (NS_NOESCAPE ^)(id context))changes;

@end

static SEL updateTitleVisibilityBehavior;
static SEL updateFromNavigationBarProxy;
static const void* _LNPopupApplyWindowFixes = &_LNPopupApplyWindowFixes;
static BOOL _LNPopupShouldApplyWindowsFixes(UITitlebar* titlebar)
{
	return [objc_getAssociatedObject(titlebar, _LNPopupApplyWindowFixes) boolValue];
}
static void _LNPopupSetShouldApplyWindowsFixes(UITitlebar* titlebar, BOOL should)
{
	objc_setAssociatedObject(titlebar, _LNPopupApplyWindowFixes, @(should), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[titlebar performSelector:updateFromNavigationBarProxy];
}

@interface LNPopupWindowToolbar: NSToolbar @end
@implementation LNPopupWindowToolbar @end

@interface NSObject /*UITitlebar*/ (LNPopupCatalystTitlebarSupport) @end
@implementation NSObject /*UITitlebar*/ (LNPopupCatalystTitlebarSupport)

- (id)_ln_titlebarWindow
{
	static NSString* keyPath = LNPopupHiddenString("hostWindow.attachedWindow");
	return [self valueForKeyPath:keyPath];
}

static NSString* const toolbarToolbarViewWindow = LNPopupHiddenString("toolbar.toolbarView.window");

+ (void)load
{
	@autoreleasepool
	{
		updateTitleVisibilityBehavior = NSSelectorFromString(LNPopupHiddenString("_updateTitleVisibilityBehavior"));
		updateFromNavigationBarProxy = NSSelectorFromString(LNPopupHiddenString("_updateFromNavigationBarProxy"));
		
		Class cls = NSClassFromString(@"UITitlebar");
		Method m = class_getInstanceMethod(cls, updateFromNavigationBarProxy);
		void (*orig)(id, SEL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
		method_setImplementation(m, imp_implementationWithBlock(^(UITitlebar* self) {
			if(_LNPopupShouldApplyWindowsFixes((id)self))
			{
				NSObject* window = self._ln_titlebarWindow;
				
				[window setValue:@YES forKey:@"titlebarAppearsTransparent"];
				[window setValue:@1 forKey:@"titleVisibility"];
				[window setValue:@1 forKey:@"titlebarSeparatorStyle"];
				[window setValue:@3 forKey:@"toolbarStyle"];
				
				window = [window valueForKeyPath:toolbarToolbarViewWindow];
				
				if([NSStringFromClass(window.class) containsString:@"FullScreen"])
				{
					static NSString* const alphaValue = LNPopupHiddenString("alphaValue");
					[window setValue:@0.0 forKey:alphaValue];
				}
				
				return;
			}
			orig(self, updateFromNavigationBarProxy);
		}));
	}
}

@end

@interface _LNPopupCatalystHelper () <NSToolbarDelegate> @end

@implementation _LNPopupCatalystHelper
{
	UIWindowScene* _currentScene;
	
	NSToolbar* _existingToolbar;
}

- (void)startHidingToolbarWithScene:(UIWindowScene*)scene
{
	if(_currentScene != nil)
	{
		[self restore];
	}
	
	_currentScene = scene;
		
	static auto NSAnimationContext = LNPopupHiddenString("NSAnimationContext");
	static auto allowsImplicitAnimation = LNPopupHiddenString("allowsImplicitAnimation");
	
	[NSClassFromString(NSAnimationContext) runAnimationGroup:^(id context) {
		[context setValue:@YES forKey:allowsImplicitAnimation];
		
		NSTimeInterval duration = 0.2;
#if DEBUG
		if(__LNEnableSlowTransitionsDebug())
		{
			duration = 2.0;
		}
#endif
		[context setValue:@(duration) forKey:@"duration"];

		id window = _currentScene.titlebar._ln_titlebarWindow;
		[window setValue:@YES forKeyPath:@"toolbar.toolbarView.hidden"];
		_LNPopupSetShouldApplyWindowsFixes(_currentScene.titlebar, YES);
	}];
}

- (void)restore
{
	NSObject* window = _currentScene.titlebar._ln_titlebarWindow;
	
	[window setValue:@NO forKeyPath:@"toolbar.toolbarView.hidden"];
	
	window = [window valueForKeyPath:toolbarToolbarViewWindow];
	
	if([NSStringFromClass(window.class) containsString:@"FullScreen"])
	{
		static NSString* const alphaValue = LNPopupHiddenString("alphaValue");
		[window setValue:@1.0 forKey:alphaValue];
	}
	
	_LNPopupSetShouldApplyWindowsFixes(_currentScene.titlebar, NO);
	
	_currentScene = nil;
}

- (void)dealloc
{
	if(_currentScene != nil)
	{
		[self restore];
	}
}

@end

#endif
