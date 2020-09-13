//
//  _LNPopupPresentationController.c
//  LNPopupController
//
//  Created by Leo Natan on 9/13/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "_LNPopupPresentationController.h"

UIView* _LNPopupSnapshotView(UIView* view)
{
#if ! LNPopupControllerEnforceStrictClean
	//TODO: Hide
	UIView* rv = [NSClassFromString(@"_UIPortalView") new];
	[rv setValue:view forKey:@"sourceView"];
	[rv setValue:@YES forKey:@"allowsBackdropGroups"];
	[rv setValue:@YES forKey:@"matchesAlpha"];
	[rv setValue:@YES forKey:@"hidesSourceView"];
#else
	UIView* rv = [view snapshotViewAfterScreenUpdates:NO];
#endif
	
	return rv;
}
