//
//  AppDelegate.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingKeys.h"
@import ObjectiveC;

@interface NSBundle ()

- (NSString *) localizedStringForKey:(NSString *)arg1 value:(NSString *)arg2 table:(NSString *)arg3 localizations:(id)arg4;
- (NSAttributedString *)localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localization:(id)arg4;
@end

@interface NSBundle (HebrewTransliteration) @end

@implementation NSBundle (HebrewTransliteration)

- (NSString *)_hebrew_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localizations:(id)arg4
{
	return [self _hebrew_localizedStringForKey:key value:value table:tableName];
}

- (NSAttributedString *)_hebrew_localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	return [[NSAttributedString alloc] initWithString:[self _hebrew_localizedStringForKey:key value:value table:tableName]];
}

- (NSAttributedString *)_hebrew_localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localization:(id)arg4
{
	return [[NSAttributedString alloc] initWithString:[self _hebrew_localizedStringForKey:key value:value table:tableName]];
}

- (NSString *)_hebrew_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	NSString* stringToTransliterate = value.length > 0 ? value : key;
	
	return [stringToTransliterate stringByApplyingTransform:@"Latin-Hebrew" reverse:NO];
}

+ (void)load
{
	@autoreleasepool 
	{
		if([NSUserDefaults.standardUserDefaults boolForKey:PopupSettingForceRTL] == NO)
		{
			return;
		}
		
		Method m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedStringForKey:value:table:));
		Method m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedStringForKey:value:table:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedStringForKey:value:table:localizations:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedStringForKey:value:table:localizations:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedAttributedStringForKey:value:table:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedAttributedStringForKey:value:table:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedAttributedStringForKey:value:table:localization:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedAttributedStringForKey:value:table:localization:));
		method_exchangeImplementations(m1, m2);
	}
}

@end

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	self.window.layer.speed = 0.2;
	
	return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
	UISceneConfiguration* config = [[UISceneConfiguration alloc] initWithName:@"LNPopupExample" sessionRole:connectingSceneSession.role];
	
	
	return config;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions
{
	// Called when the user discards a scene session.
	// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
	// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
