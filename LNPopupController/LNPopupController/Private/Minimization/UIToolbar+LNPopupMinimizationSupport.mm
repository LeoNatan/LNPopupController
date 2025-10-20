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

@implementation UINavigationController (LNPopupMinimizationSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(popupBar.supportsMinimization && self.isToolbarHidden == NO && LNPopupEnvironmentHasGlass())
	{
		static CGFloat margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 28 : 8;
		
		NSDirectionalEdgeInsets floatingLayoutMargins = self.popupBar.floatingLayoutMargins;
		barInsets.leading = MAX(margin - (floatingLayoutMargins.leading - self.view.safeAreaInsets.left), 0);
		barInsets.trailing = MAX(margin - (floatingLayoutMargins.trailing - self.view.safeAreaInsets.right), 0);
	}
	
	return barInsets;
}

@end
