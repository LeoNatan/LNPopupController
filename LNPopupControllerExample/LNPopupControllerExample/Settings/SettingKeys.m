//
//  SettingKeys.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "SettingKeys.h"
#import <LNTouchVisualizer/LNTouchVisualizer.h>

NSString* const PopupSettingsBarStyle = @"PopupSettingsBarStyle";
NSString* const PopupSettingsInteractionStyle = @"PopupSettingsInteractionStyle";
NSString* const PopupSettingsProgressViewStyle = @"PopupSettingsProgressViewStyle";
NSString* const PopupSettingsCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
NSString* const PopupSettingsMarqueeStyle = @"PopupSettingsMarqueeStyle";
NSString* const PopupSettingsEnableCustomizations = @"PopupSettingsEnableCustomizations";
NSString* const PopupSettingsExtendBar = @"PopupSettingsExtendBar";
NSString* const PopupSettingsHidesBottomBarWhenPushed = @"PopupSettingsHidesBottomBarWhenPushed";
NSString* const PopupSettingsDisableScrollEdgeAppearance = @"PopupSettingsDisableScrollEdgeAppearance";
NSString* const PopupSettingsVisualEffectViewBlurEffect = @"PopupSettingsVisualEffectViewBlurEffect";
NSString* const PopupSettingsTouchVisualizerEnabled = @"PopupSettingsTouchVisualizerEnabled";
NSString* const PopupSettingsCustomBarEverywhereEnabled = @"PopupSettingsCustomBarEverywhereEnabled";
NSString* const PopupSettingsContextMenuEnabled = @"PopupSettingsContextMenuEnabled";

NSString* const __LNPopupBarHideContentView = @"__LNPopupBarHideContentView";
NSString* const __LNPopupBarHideShadow = @"__LNPopupBarHideShadow";
NSString* const __LNPopupBarEnableLayoutDebug = @"__LNPopupBarEnableLayoutDebug";
NSString* const __LNForceRTL = @"__LNForceRTL";
NSString* const __LNDebugScaling = @"__LNDebugScaling";

NSString* const DemoAppDisableDemoSceneColors = @"__LNPopupBarDisableDemoSceneColors";
NSString* const DemoAppEnableFunkyInheritedFont = @"DemoAppEnableFunkyInheritedFont";
NSString* const DemoAppEnableExternalScenes = @"DemoAppEnableExternalScenes";

@import ObjectiveC;

__attribute__((constructor))
void fixUIKitSwiftUIShit(void)
{
	[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"com.apple.SwiftUI.DisableCollectionViewBackedGroupedLists"];
	
	{
		Class cls = UICollectionViewCell.class;
		void (*orig)(id, SEL, BOOL, BOOL);
		SEL sel = NSSelectorFromString(@"_setHighlighted:animated:");
		Method m = class_getInstanceMethod(cls, sel);
		orig = (void*)method_getImplementation(m);
		method_setImplementation(m, imp_implementationWithBlock(^(UICollectionViewCell* _self,
																  BOOL highlighted,
																  BOOL animated) {
			if(highlighted == NO && [NSStringFromClass(_self.class) hasPrefix:@"SwiftUI."])
			{
				animated = YES;
			}
			
			orig(_self, sel, highlighted, animated);
		}));
	}
	{
		if(@available(iOS 17, *))
		{
			Class cls = NSClassFromString(@"UITabBarItem");
			SEL sel = NSSelectorFromString(@"setScrollEdgeAppearance:");
			void (*orig)(id, SEL, UITabBarAppearance*);
			Method m = class_getInstanceMethod(cls, sel);
			orig = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(^(id _self, UITabBarAppearance* appearance) {
				if([[appearance.class valueForKey:@"isFromSwiftUI"] boolValue] && appearance.backgroundEffect == nil && appearance.backgroundColor == nil && appearance.backgroundImage == nil)
				{
					appearance = nil;
				}
				
				
				orig(_self, sel, appearance);
			}));
		}
	}
}

@interface LNTouchVisualizerSupport: NSObject @end
@implementation LNTouchVisualizerSupport

+ (void)load
{
	@autoreleasepool
	{
		[NSUserDefaults.standardUserDefaults registerDefaults:@{
			PopupSettingsExtendBar: @YES,
			PopupSettingsHidesBottomBarWhenPushed: @YES
		}];
		
		[NSUserDefaults.standardUserDefaults addObserver:(id)self forKeyPath:PopupSettingsTouchVisualizerEnabled options:0 context:NULL];
		[NSUserDefaults.standardUserDefaults addObserver:(id)self forKeyPath:__LNDebugScaling options:0 context:NULL];
		
		[NSNotificationCenter.defaultCenter addObserverForName:UISceneWillConnectNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _updateTouchVisualizer];
				[self _updateScalingAnimated:NO];
			});
		}];
	}
}

+ (void)_updateTouchVisualizer
{
	for(UIWindowScene* windowScene in UIApplication.sharedApplication.connectedScenes)
	{
		if([windowScene isKindOfClass:UIWindowScene.class] == NO)
		{
			continue;
		}
		
		windowScene.touchVisualizerEnabled = [NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsTouchVisualizerEnabled];
		LNTouchConfig* rippleConfig = [LNTouchConfig rippleConfig];
		rippleConfig.fillColor = UIColor.systemPinkColor;
		windowScene.touchVisualizerWindow.touchRippleConfig = rippleConfig;
	}
}

+ (void)_updateScalingAnimated:(BOOL)animated
{	
	for(UIWindowScene* windowScene in UIApplication.sharedApplication.connectedScenes)
	{
		if([windowScene isKindOfClass:UIWindowScene.class] == NO)
		{
			continue;
		}
		
		CGFloat desiredWidth = [NSUserDefaults.standardUserDefaults doubleForKey:__LNDebugScaling];
		if(desiredWidth == 0)
		{
			desiredWidth = windowScene.screen.bounds.size.width;
		}
		   
		CGFloat scale = windowScene.screen.fixedCoordinateSpace.bounds.size.width / desiredWidth;
		
		for(UIWindow* window in windowScene.windows)
		{
			
			window.layer.allowsEdgeAntialiasing = YES;
			window.layer.magnificationFilter = kCAFilterTrilinear;
			window.layer.minificationFilter = kCAFilterTrilinear;
			CGAffineTransform targetTransform = scale == 1.0 ? CGAffineTransformIdentity : CGAffineTransformMakeScale(scale, scale);
			CGRect targetFrame = windowScene.screen.bounds;
			if(CGAffineTransformEqualToTransform(window.transform, targetTransform) == NO)
			{
				dispatch_block_t update = ^ {
					[UIView performWithoutAnimation:^{
						window.transform = targetTransform;
						window.frame = targetFrame;
					}];
				};
				
				if(animated == NO)
				{
					update();
					return;
				}
				
				[UIView transitionWithView:window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:update completion:nil];
			}
		}
	}
}

+ (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	[self _updateTouchVisualizer];
	[self _updateScalingAnimated:YES];
}

@end
