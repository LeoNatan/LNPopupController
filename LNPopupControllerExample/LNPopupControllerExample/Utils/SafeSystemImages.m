//
//  SafeSystemImages.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-09-02.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#include "SafeSystemImages.h"

UIImage* LNSystemImage(NSString* named, BOOL useCompactConfig)
{
	static UIImageSymbolConfiguration* largeConfig = nil;
	static UIImageSymbolConfiguration* compactConfig = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		largeConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleUnspecified];
		compactConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium];
	});
	
	UIImageSymbolConfiguration* config;
	if(useCompactConfig)
	{
		config = compactConfig;
	}
	else
	{
		config = largeConfig;
	}
	
	return [UIImage systemImageNamed:named withConfiguration:config];
}
