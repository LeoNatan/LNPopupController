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
		if(@available(iOS 27.0, *))
		{
			if(popupBar.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(popupBar.window.windowScene.interfaceOrientation))
			{
				barInsets = NSDirectionalEdgeInsetsMake(0, 8, 0, 8);
			}
		}
		else
		{
			static CGFloat margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 28 : 8;
			
			NSDirectionalEdgeInsets floatingLayoutMargins = popupBar.floatingLayoutMargins;
			auto viewInsets = _LNDirectionalEdgeInsetsFromEdgeInsets(controller.view, controller.view.safeAreaInsets);
			barInsets.leading = MAX(margin - (floatingLayoutMargins.leading - viewInsets.leading), 0);
			barInsets.trailing = MAX(margin - (floatingLayoutMargins.trailing - viewInsets.trailing), 0);
		}
	}
	
	return barInsets;
}

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	return [UINavigationController _ln_popupBarMarginsForPopupBar:popupBar inController:self];
}

@end
