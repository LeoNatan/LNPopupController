//
//  UIToolbar+LNPopupMinimizationSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 13/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UIToolbar+LNPopupMinimizationSupport.h"
#import "LNPopupBar+Private.h"
#import "_LNPopupBase64Utils.hh"
#import "UIViewController+LNPopupSupportPrivate.h"

@implementation UINavigationController (LNPopupMinimizationSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(popupBar.supportsMinimization && self._ln_isToolbarHiddenOrSwiftUIBuggyToolbar == NO && LNPopupEnvironmentHasGlass())
	{
		static CGFloat margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 28 : 8;
		
		NSDirectionalEdgeInsets floatingLayoutMargins = self.popupBar.floatingLayoutMargins;
		barInsets.leading = MAX(margin - (floatingLayoutMargins.leading - self.view.safeAreaInsets.left), 0);
		barInsets.trailing = MAX(margin - (floatingLayoutMargins.trailing - self.view.safeAreaInsets.right), 0);
		
		BOOL isPhone = popupBar.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
		if(@available(iOS 27.0, *))
		{
			BOOL isRegular = popupBar.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
			BOOL compactButHasSafeArea = popupBar.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact && popupBar.safeAreaInsets.left > 10;
			
			if(isPhone && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion > 26 && compactButHasSafeArea)
			{
				barInsets.leading -= 35;
				barInsets.trailing -= 35;
			}
			else if(isPhone && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion > 26 && isRegular)
			{
				barInsets.leading -= 50;
				barInsets.trailing -= 50;
			}
		}
	}
	
	if(@available(iOS 27.0, *))
	{
		if(popupBar.supportsMinimization && self._ln_isToolbarHiddenOrSwiftUIBuggyToolbar == YES && LNPopupEnvironmentHasGlass())
		{
			barInsets.leading += 7;
			barInsets.trailing += 7;
		}
	}
	
	return barInsets;
}

@end
