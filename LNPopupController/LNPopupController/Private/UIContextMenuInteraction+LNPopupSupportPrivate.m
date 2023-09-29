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
//_delegate_contextMenuInteractionWillDisplayForConfiguration:
static NSString* const dCMIWDFCBase64 = @"X2RlbGVnYXRlX2NvbnRleHRNZW51SW50ZXJhY3Rpb25XaWxsRGlzcGxheUZvckNvbmZpZ3VyYXRpb246";

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
		
		//_delegate_contextMenuInteractionWillDisplayForConfiguration:
		selName = _LNPopupDecodeBase64String(dCMIWDFCBase64);
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_d_cMIWDFC:));
	}
}

//_delegate_previewForHighlightingForConfiguration:
- (id)_ln_d_pFHFC:(id)arg1
{
	UITargetedPreview* rv = [self _ln_d_pFHFC:arg1];
	
	if([self.view isKindOfClass:LNPopupBar.class] && rv == nil)
	{
		LNPopupBar* bar = (LNPopupBar*)self.view;
		UIView* view = bar.resolvedStyle == LNPopupBarStyleFloating ? bar.contentView : bar;
		UIView* targetView = bar.resolvedStyle == LNPopupBarStyleFloating ? bar : bar.superview.superview;
		UIPreviewTarget* target = [[UIPreviewTarget alloc] initWithContainer:targetView center:[targetView convertPoint:CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)) fromView:view]];
		
		UIPreviewParameters* params = [UIPreviewParameters new];
		params.backgroundColor = [UIColor.systemBackgroundColor colorWithAlphaComponent:0.5];
		rv = [[UITargetedPreview alloc] initWithView:view parameters:params target:target];
	}
	else if([self.view isKindOfClass:LNPopupBar.class] && rv.view == self.view)
	{
		LNPopupBar* bar = (LNPopupBar*)self.view;
		UIView* view = bar.resolvedStyle == LNPopupBarStyleFloating ? bar.contentView : bar;
		
		rv = [[UITargetedPreview alloc] initWithView:view parameters:rv.parameters target:rv.target];
	}
	
	if([self.view isKindOfClass:LNPopupBar.class])
	{
		LNPopupBar* popupBar = self.view;
		[popupBar setHighlighted:NO animated:YES];
		[popupBar _cancelAnyUserInteraction];
	}
	
	return rv;
}

//_delegate_contextMenuInteractionWillDisplayForConfiguration:
- (id)_ln_d_cMIWDFC:(id)arg1
{
	id<UIContextMenuInteractionCommitAnimating> animator = [self _ln_d_cMIWDFC:arg1];
	
	if([self.view isKindOfClass:LNPopupBar.class] && [arg1 valueForKey:@"previewProvider"] != nil)
	{
		dispatch_block_t animation = ^ {
			[(LNPopupBar*)self.view floatingBackgroundShadowView].alpha = 0.0;
		};
		
		if(animator)
		{
			[animator addAnimations:animation];
		}
		else
		{
			animation();
		}
	}
	
	return animator;
}

//_delegate_contextMenuInteractionWillEndForConfiguration:presentation:
- (id)_ln_d_cMIWEFC:(id)arg1 p:(id)arg2;
{
	id<UIContextMenuInteractionCommitAnimating> animator = [self _ln_d_cMIWEFC:arg1 p:arg2];
	
	if([self.view isKindOfClass:LNPopupBar.class])
	{
		dispatch_block_t animation = ^ {
			[[(LNPopupBar*)self.view floatingBackgroundShadowView] setAlpha:1.0];
		};
		
		if(animator)
		{
			[UIView animateWithDuration:0.2 delay:0.2 options:0 animations:animation completion:nil];
		}
		else
		{
			animation();
		}
	}
	
	return animator;
}

@end
#endif
