//
//  UIToolbar+LNPopupInheritedBarMetricsSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 13/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UIToolbar+LNPopupInheritedBarMetricsSupport.h"
#import "LNPopupBar+Private.h"
#import "_LNPopupBase64Utils.hh"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "UIView+LNPopupSupportPrivate.h"

@implementation UINavigationController (LNPopupInheritedBarMetricsSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(popupBar.inheritsBottomBarMetrics && LNPopupEnvironmentHasGlass())
	{
		static CGFloat margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 28 : 8;
		
		NSDirectionalEdgeInsets floatingLayoutMargins = self.popupBar.floatingLayoutMargins;
		barInsets.leading = MAX(margin - (floatingLayoutMargins.leading - self.view.safeAreaInsets.left), 0);
		barInsets.trailing = MAX(margin - (floatingLayoutMargins.trailing - self.view.safeAreaInsets.right), 0);
		
		BOOL isPhone = popupBar.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
		if(@available(iOS 27.0, *))
		{
			BOOL isRegular = self.view.window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
			BOOL isCompact = self.view.window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
			BOOL compactButHasSafeArea = isCompact && popupBar.safeAreaInsets.left > 10;
			BOOL isLandscape = UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation);
			
			auto windowInsets = _LNDirectionalEdgeInsetsFromEdgeInsets(self.view.window, self.view.window.safeAreaInsets);
			auto viewInsets = _LNDirectionalEdgeInsetsFromEdgeInsets(self.view, self.view.safeAreaInsets);

			if(isPhone && compactButHasSafeArea)
			{
				if(windowInsets.leading == viewInsets.leading)
				{
					barInsets.leading -= 35;
				}
				if(windowInsets.trailing == viewInsets.trailing)
				{
					barInsets.trailing -= 35;
				}
			}
			else if(isPhone && isCompact && isLandscape)
			{
				barInsets.leading += 10;
				barInsets.trailing += 10;
			}
			else if(isPhone && isRegular)
			{
				if(windowInsets.leading == viewInsets.leading)
				{
					barInsets.leading -= 52;
				}
				if(windowInsets.trailing == viewInsets.trailing)
				{
					barInsets.trailing -= 52;
				}
				else if(self.splitViewController != nil)
				{
					barInsets.trailing -= 18;
				}
			}
		}
	}
	
	return barInsets;
}

@end
