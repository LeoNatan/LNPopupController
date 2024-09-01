//
//  UIContextMenuInteraction+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Léo Natan on 2021-03-28.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "UIViewController+LNPopupSupportPrivate.h"
#import "UIContextMenuInteraction+LNPopupSupportPrivate.h"
#import "LNPopupBar+Private.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"

#ifndef LNPopupControllerEnforceStrictClean

@implementation UIContextMenuInteraction (LNPopupSupportPrivate)

+ (void)load
{
	@autoreleasepool
	{
		NSString* selName = LNPopupHiddenString("_delegate_previewForHighlightingForConfiguration:");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_d_pFHFC:));
		
		selName = LNPopupHiddenString("_delegate_contextMenuInteractionWillEndForConfiguration:presentation:");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_d_cMIWEFC:p:));
		
		selName = LNPopupHiddenString("_delegate_contextMenuInteractionWillDisplayForConfiguration:");
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
		params.backgroundColor = [UIColor.systemBackgroundColor colorWithAlphaComponent:0.0];
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
		[popupBar setWantsBackgroundCutout:NO allowImplicitAnimations:NO];
	}
	
	return rv;
}

//_delegate_contextMenuInteractionWillDisplayForConfiguration:
- (id)_ln_d_cMIWDFC:(id)arg1
{
	id<UIContextMenuInteractionCommitAnimating> animator = [self _ln_d_cMIWDFC:arg1];
	
	if([self.view isKindOfClass:LNPopupBar.class])
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
		LNPopupBar* popupBar = (LNPopupBar*)self.view;
		
		popupBar.bottomShadowView.alpha = 0.0;
		popupBar.bottomShadowView.hidden = NO;
		
		dispatch_block_t alongside = ^ {
			if(popupBar.resolvedStyle != LNPopupBarStyleFloating && popupBar.barContainingController._ln_shouldDisplayBottomShadowViewDuringTransition)
			{
				popupBar.bottomShadowView.alpha = 1.0;
			}
		};
		
		dispatch_block_t animation = ^ {
			popupBar.floatingBackgroundShadowView.alpha = 1.0;
		};
		
		dispatch_block_t completion = ^ {
			popupBar.bottomShadowView.alpha = 0.0;
			popupBar.bottomShadowView.hidden = YES;
			[popupBar setWantsBackgroundCutout:YES allowImplicitAnimations:NO];
		};
		
		if(animator)
		{
			[animator addAnimations:alongside];
			[animator addCompletion:completion];
			[UIView animateWithDuration:0.2 delay:0.15 usingSpringWithDamping:500 initialSpringVelocity:0.0 options:0 animations:animation completion:nil];
		}
		else
		{
			animation();
			completion();
		}
	}
	
	return animator;
}

@end
#endif
