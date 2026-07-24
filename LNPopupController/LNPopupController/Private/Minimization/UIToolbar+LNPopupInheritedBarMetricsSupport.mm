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

+ (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar inController:(UIViewController*)controller
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(popupBar.inheritsBottomBarMetrics && LNPopupEnvironmentHasGlass())
	{
		static CGFloat margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 28 : 8;
		
		NSDirectionalEdgeInsets floatingLayoutMargins = popupBar.floatingLayoutMargins;
		auto viewInsets = _LNDirectionalEdgeInsetsFromEdgeInsets(controller.view, controller.view.safeAreaInsets);
		barInsets.leading = MAX(margin - (floatingLayoutMargins.leading - viewInsets.leading), 0);
		barInsets.trailing = MAX(margin - (floatingLayoutMargins.trailing - viewInsets.trailing), 0);
		
		BOOL isPhone = popupBar.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
		if(@available(iOS 27.0, *))
		{
			BOOL isRegular = controller.view.window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
			BOOL isCompact = controller.view.window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
			BOOL compactButHasSafeArea = isCompact && popupBar.safeAreaInsets.left > 10;
			BOOL isLandscape = UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation);
			
			auto windowInsets = _LNDirectionalEdgeInsetsFromEdgeInsets(controller.view.window, controller.view.window.safeAreaInsets);

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
				else if(controller.splitViewController != nil)
				{
					barInsets.trailing -= 18;
				}
			}
		}
	}
	
	return barInsets;
}

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	return [UINavigationController _ln_popupBarMarginsForPopupBar:popupBar inController:self];
}

@end
