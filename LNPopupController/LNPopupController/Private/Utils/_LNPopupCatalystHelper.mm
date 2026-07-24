//
//  _LNPopupCatalystHelper.mm
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "_LNPopupCatalystHelper.h"
#import "_LNPopupBase64Utils.hh"

#if TARGET_OS_MACCATALYST

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
	
	_currentScene = scene;
	_previousVisibility = scene.titlebar.titleVisibility;
	scene.titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
	_previousSeparatorStyle = scene.titlebar.separatorStyle;
	scene.titlebar.separatorStyle = UITitlebarSeparatorStyleNone;
	
	_toolbarView = [NSClassFromString(@"NSApplication") valueForKeyPath:LNPopupHiddenString("sharedApplication.mainWindow.toolbar.toolbarView")];
	_toolbarWasHidden = [_toolbarView isHidden];
	[_toolbarView setHidden:YES];
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
