//
//  UISplitView+LNPopupInheritedBarMetricsSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "UISplitView+LNPopupInheritedBarMetricsSupport.h"
#import "LNPopupBar+Private.h"

@implementation UISplitViewController (LNPopupInheritedBarMetricsSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar
{
	NSDirectionalEdgeInsets barInsets = NSDirectionalEdgeInsetsZero;
	
	if(self.style == UISplitViewControllerStyleUnspecified || self.primaryBackgroundStyle != UISplitViewControllerBackgroundStyleSidebar)
	{
		return barInsets;
	}
	
	if(popupBar.inheritsBottomBarMetrics)
	{
		CGFloat width = self.primaryColumnWidth;
		BOOL isPrimaryShown;
		if(@available(iOS 26.0, *))
		{
			isPrimaryShown = [self isShowingColumn:UISplitViewControllerColumnPrimary];
		}
		else
		{
			isPrimaryShown = [self viewControllerForColumn:UISplitViewControllerColumnPrimary].view.window != nil;
		}
		
		if(self.primaryEdge == UISplitViewControllerPrimaryEdgeLeading)
		{
			barInsets.leading = isPrimaryShown ? width : 0;
		}
		else
		{
			barInsets.trailing = isPrimaryShown ? width : 0;
		}
	}
	
	return barInsets;
}

@end
