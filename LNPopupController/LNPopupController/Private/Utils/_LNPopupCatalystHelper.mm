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

@implementation _LNPopupCatalystHelper
{
	UIWindowScene* _currentScene;
	UITitlebarTitleVisibility _previousVisibility;
	UITitlebarSeparatorStyle _previousSeparatorStyle;
	id _toolbarView;
	BOOL _toolbarWasHidden;
}

- (void)startHidingToolbarWithScene:(UIWindowScene*)scene
{
	if(_currentScene != nil)
	{
		[self restore];
	}
	
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
		
		_currentScene = scene;
		_previousVisibility = scene.titlebar.titleVisibility;
		scene.titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
		_previousSeparatorStyle = scene.titlebar.separatorStyle;
		scene.titlebar.separatorStyle = UITitlebarSeparatorStyleNone;
		
		static auto NSApplication = LNPopupHiddenString("NSApplication");
		static auto keyPath = LNPopupHiddenString("sharedApplication.mainWindow.toolbar.toolbarView");
		
		_toolbarView = [NSClassFromString(NSApplication) valueForKeyPath:keyPath];
		_toolbarWasHidden = [_toolbarView isHidden];
		[_toolbarView setHidden:YES];
	}];
}

- (void)restore
{
	_currentScene.titlebar.titleVisibility = _previousVisibility;
	_currentScene.titlebar.separatorStyle = _previousSeparatorStyle;
	[_toolbarView setHidden:_toolbarWasHidden];
	_currentScene = nil;
	_toolbarView = nil;
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
