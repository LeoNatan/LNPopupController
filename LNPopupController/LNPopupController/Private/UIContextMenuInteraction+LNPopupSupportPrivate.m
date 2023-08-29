//
//  UIContextMenuInteraction+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 3/28/21.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "UIContextMenuInteraction+LNPopupSupportPrivate.h"
#import "LNPopupBar+Private.h"
#import "_LNPopupSwizzlingUtils.h"

#ifndef LNPopupControllerEnforceStrictClean
//_delegate_previewForHighlightingForConfiguration:
static NSString* const dPFHFCBase64 = @"X2RlbGVnYXRlX3ByZXZpZXdGb3JIaWdobGlnaHRpbmdGb3JDb25maWd1cmF0aW9uOg==";
//_delegate_contextMenuInteractionWillEndForConfiguration:presentation:
static NSString* const dCMIWEFCpBase64 = @"X2RlbGVnYXRlX2NvbnRleHRNZW51SW50ZXJhY3Rpb25XaWxsRW5kRm9yQ29uZmlndXJhdGlvbjpwcmVzZW50YXRpb246";

@implementation UIContextMenuInteraction (LNPopupSupportPrivate)

+ (void)load
{
	@autoreleasepool
	{
		//_delegate_previewForHighlightingForConfiguration:
		NSString* selName = _LNPopupDecodeBase64String(dPFHFCBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_d_pFHFC:));
		
		//_delegate_contextMenuInteractionWillEndForConfiguration:presentation:
		selName = _LNPopupDecodeBase64String(dCMIWEFCpBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_d_cMIWEFC:p:));
	}
}

//_delegate_previewForHighlightingForConfiguration:
- (id)_ln_d_pFHFC:(id)arg1
{
	UITargetedPreview* x = [self _ln_d_pFHFC:arg1];
	
	if([self.view isKindOfClass:LNPopupBar.class] && x == nil)
	{
		LNPopupBar* bar = (LNPopupBar*)self.view;
		
		UIPreviewParameters* params = [UIPreviewParameters new];
		if(bar.resolvedStyle == LNPopupBarStyleFloating)
		{
			if (@available(iOS 14.0, *))
			{
				params.shadowPath = [UIBezierPath new];
			}
		}
		
		x = [[UITargetedPreview alloc] initWithView:bar.contentView parameters:params];
	}
	else if([self.view isKindOfClass:LNPopupBar.class] && x.view == self.view)
	{
		x = [[UITargetedPreview alloc] initWithView:[(LNPopupBar*)self.view contentView] parameters:x.parameters];
	}
	
	if([self.view isKindOfClass:LNPopupBar.class])
	{
		LNPopupBar* popupBar = self.view;
		[popupBar setHighlighted:YES animated:NO];
		[popupBar _cancelAnyUserInteraction];
	}
	
	return x;
}

//_delegate_contextMenuInteractionWillEndForConfiguration:presentation:
- (id)_ln_d_cMIWEFC:(id)arg1 p:(id)arg2;
{
	id<UIContextMenuInteractionAnimating> animator = [self _ln_d_cMIWEFC:arg1 p:arg2];
	
	if([self.view isKindOfClass:LNPopupBar.class])
	{
		dispatch_block_t highlight = ^ {
			[(LNPopupBar*)self.view setHighlighted:NO animated:YES];
		};
		
		if(animator)
		{
			[animator addCompletion:highlight];
		}
		else
		{
			highlight();
		}
	}
	
	return animator;
}

@end
#endif
