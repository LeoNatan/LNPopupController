//
//  LNPopupVerticalBarSupport.mm
//  LNPopupController
//
//  Created by Léo Natan on 20/11/26.
//  Copyright © 2015-2026 Léo Natan. All rights reserved.
//

#import "LNPopupVerticalBarSupport.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupControllerImpl.h"
#import "LNPopupContentView+Private.h"
#import "LNPopupPresentationContainerSupport.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import <objc/runtime.h>

NSInteger _LNPopupResolvedVerticalBarBehavior(UIViewController* controller)
{
#if defined(__IPHONE_27_1)
	if(@available(iOS 27.1, *))
	{
		UIViewController* child = controller.childViewControllerForPreferredVerticalBarBehavior;
		while(child != nil)
		{
			controller = child;
			child = controller.childViewControllerForPreferredVerticalBarBehavior;
		}
		
		return controller.preferredVerticalBarBehavior;
	}
#endif
	
	return 0;
}

void _LNPopupSetVerticalBarDisabled(UIViewController* controller, BOOL disabled)
{
#if defined(__IPHONE_27_1)
	if(@available(iOS 27.1, *))
	{
		if(controller == nil)
		{
			return;
		}
		
		static Class vBATrait = NSClassFromString(LNPopupHiddenString("_UITraitVerticalBarAllowed"));
		if(vBATrait == nil)
		{
			return;
		}
		
		//_UIVerticalBarAllowedDisabled
		static const NSInteger disabledValue = 2;
		
		id<UITraitOverrides> traitOverrides = controller.traitOverrides;
		BOOL containsOverride = [traitOverrides containsTrait:vBATrait];
		if(disabled)
		{
			if(containsOverride == NO || [traitOverrides valueForNSIntegerTrait:vBATrait] != disabledValue)
			{
				[traitOverrides setNSIntegerValue:disabledValue forTrait:vBATrait];
			}
		}
		else if(containsOverride)
		{
			[traitOverrides removeTrait:vBATrait];
		}
	}
#endif
}

#if defined(__IPHONE_27_1)
static BOOL __ln_resolvingUnderlyingStatusBarAxis = NO;
static BOOL __ln_resolvingStatusBarAxisForStatusBarManager = NO;
static BOOL __ln_forcingHorizontalStatusBarAxis = NO;
static BOOL __ln_popupForcedStatusBarAxis = NO;
static const void* __LNPopupUnderlyingStatusBarAxisKey = &__LNPopupUnderlyingStatusBarAxisKey;

UIEdgeInsets _LNPopupInsetsAdjustedForHorizontalStatusBarAxis(UIView* view, UIEdgeInsets insets)
{
	UIWindow* window = view.window;
	if(window == nil)
	{
		return insets;
	}
	
	static SEL sBAFSAISEL = NSSelectorFromString(LNPopupHiddenString("_statusBarAxisForSafeAreaInsets"));
	static SEL sBVFSAISEL = NSSelectorFromString(LNPopupHiddenString("_statusBarVisibilityForSafeAreaInsets"));
	static SEL nSAIFSBASBVSEL = NSSelectorFromString(LNPopupHiddenString("_normalizedSafeAreaInsetsForStatusBarAxis:statusBarVisibility:"));
	if([window respondsToSelector:sBAFSAISEL] == NO || [window respondsToSelector:sBVFSAISEL] == NO || [window respondsToSelector:nSAIFSBASBVSEL] == NO)
	{
		return insets;
	}
	
	static NSInteger (*integerFunc)(id, SEL) = reinterpret_cast<decltype(integerFunc)>(objc_msgSend);
	static UIEdgeInsets (*nSAIFSBASBVFunc)(id, SEL, NSInteger, NSInteger) = reinterpret_cast<decltype(nSAIFSBASBVFunc)>(objc_msgSend);
	
	NSInteger axis = integerFunc(window, sBAFSAISEL);
	if(axis == 0)
	{
		return insets;
	}
	
	NSInteger visibility = integerFunc(window, sBVFSAISEL);
	UIEdgeInsets current = nSAIFSBASBVFunc(window, nSAIFSBASBVSEL, axis, visibility);
	UIEdgeInsets horizontal = nSAIFSBASBVFunc(window, nSAIFSBASBVSEL, 0, visibility);
	
	CGRect frameInWindow = [view convertRect:view.bounds toView:window];
	if(CGRectGetMinY(frameInWindow) <= 0)
	{
		insets.top = MAX(0, insets.top + horizontal.top - current.top);
	}
	if(CGRectGetMinX(frameInWindow) <= 0)
	{
		insets.left = MAX(0, insets.left + horizontal.left - current.left);
	}
	if(CGRectGetMaxX(frameInWindow) >= window.bounds.size.width)
	{
		insets.right = MAX(0, insets.right + horizontal.right - current.right);
	}
	
	return insets;
}

static void __LNPopupInstallPresentationStatusBarAxisSupport(void) API_AVAILABLE(ios(27.1))
{
	Class cls = UIPresentationController.class;

	static SEL rPSBAFPSEL = NSSelectorFromString(LNPopupHiddenString("_resolvePreferredStatusBarAxisForPresentation"));
	static SEL pSBAFPSEL = NSSelectorFromString(LNPopupHiddenString("_preferredStatusBarAxisForPresentation"));
	static SEL pSBAFSBMSEL = NSSelectorFromString(LNPopupHiddenString("_preferredStatusBarAxisForStatusBarManager"));

	Method rPSBAFPM = class_getInstanceMethod(cls, rPSBAFPSEL);
	Method pSBAFPM = class_getInstanceMethod(cls, pSBAFPSEL);
	Method pSBAFSBMM = class_getInstanceMethod(cls, pSBAFSBMSEL);
	if(rPSBAFPM == NULL || pSBAFPM == NULL || pSBAFSBMM == NULL)
	{
		return;
	}

	static NSInteger (*orig_rPSBAFP)(id, SEL) = reinterpret_cast<decltype(orig_rPSBAFP)>(method_getImplementation(rPSBAFPM));
	method_setImplementation(rPSBAFPM, imp_implementationWithBlock(^ NSInteger (UIPresentationController* _self) {
		BOOL prev = __ln_popupForcedStatusBarAxis;
		__ln_popupForcedStatusBarAxis = NO;
		NSInteger rv = orig_rPSBAFP(_self, rPSBAFPSEL);
		BOOL popupForcedStatusBarAxis = __ln_popupForcedStatusBarAxis;
		__ln_popupForcedStatusBarAxis = prev;
		
		NSNumber* underlying = nil;
		if(popupForcedStatusBarAxis)
		{
			__ln_resolvingUnderlyingStatusBarAxis = YES;
			NSInteger underlyingAxis = orig_rPSBAFP(_self, rPSBAFPSEL);
			__ln_resolvingUnderlyingStatusBarAxis = NO;
			
			if(underlyingAxis != rv)
			{
				underlying = @(underlyingAxis);
			}
		}
		
		if(underlying != nil || objc_getAssociatedObject(_self, __LNPopupUnderlyingStatusBarAxisKey) != nil)
		{
			objc_setAssociatedObject(_self, __LNPopupUnderlyingStatusBarAxisKey, underlying, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
		
		return rv;
	}));

	static NSInteger (*orig_pSBAFP)(id, SEL) = reinterpret_cast<decltype(orig_pSBAFP)>(method_getImplementation(pSBAFPM));
	method_setImplementation(pSBAFPM, imp_implementationWithBlock(^ NSInteger (UIPresentationController* _self) {
		if(__ln_forcingHorizontalStatusBarAxis)
		{
			//_UIStatusBarAxisHorizontal
			return 0;
		}
		
		if(__ln_resolvingStatusBarAxisForStatusBarManager == NO)
		{
			NSNumber* underlying = objc_getAssociatedObject(_self, __LNPopupUnderlyingStatusBarAxisKey);
			if(underlying != nil)
			{
				return underlying.integerValue;
			}
		}

		return orig_pSBAFP(_self, pSBAFPSEL);
	}));

	static NSInteger (*orig_pSBAFSBM)(id, SEL) = reinterpret_cast<decltype(orig_pSBAFSBM)>(method_getImplementation(pSBAFSBMM));
	method_setImplementation(pSBAFSBMM, imp_implementationWithBlock(^ NSInteger (UIPresentationController* _self) {
		BOOL prev = __ln_resolvingStatusBarAxisForStatusBarManager;
		__ln_resolvingStatusBarAxisForStatusBarManager = YES;
		NSInteger rv = orig_pSBAFSBM(_self, pSBAFSBMSEL);
		__ln_resolvingStatusBarAxisForStatusBarManager = prev;

		return rv;
	}));
}

static void __LNPopupInstallContainerStatusBarAxisSupport(void) API_AVAILABLE(ios(27.1))
{
	__LNPopupInstallPresentationStatusBarAxisSupport();

	Class cls = LNPopupPresentationContainerSupport.class;
	
	static SEL cVCFSBASEL = NSSelectorFromString(LNPopupHiddenString("_childViewControllerForStatusBarAxis"));
	static SEL pSBASEL = NSSelectorFromString(LNPopupHiddenString("_preferredStatusBarAxis"));
	if([UIViewController instancesRespondToSelector:cVCFSBASEL] == NO || [UIViewController instancesRespondToSelector:pSBASEL] == NO)
	{
		return;
	}
	
	class_addMethod(cls, cVCFSBASEL, imp_implementationWithBlock(^ UIViewController* (UIViewController* _self) {
		if(__ln_resolvingUnderlyingStatusBarAxis == NO && [_self _ln_childViewControllerForStatusBarLogic] != nil)
		{
			return nil;
		}
		
		struct objc_super super = {.receiver = _self, .super_class = LNDynamicSubclassSuper(_self, LNPopupPresentationContainerSupport.class)};
		UIViewController* (*super_class)(struct objc_super*, SEL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
		return super_class(&super, cVCFSBASEL);
	}), "@16@0:8");
	
	class_addMethod(cls, pSBASEL, imp_implementationWithBlock(^ NSInteger (UIViewController* _self) {
		UIViewController* contentController = __ln_resolvingUnderlyingStatusBarAxis ? nil : [_self _ln_childViewControllerForStatusBarLogic];
		if(contentController != nil)
		{
			if(_LNPopupResolvedVerticalBarBehavior(contentController) == UIVerticalBarBehaviorDisabled)
			{
				__ln_popupForcedStatusBarAxis = YES;
				
				//_UIStatusBarAxisHorizontal
				return 0;
			}
			
			static NSInteger (*pSBAFunc)(id, SEL) = reinterpret_cast<decltype(pSBAFunc)>(objc_msgSend);
			return pSBAFunc(contentController, pSBASEL);
		}
		
		struct objc_super super = {.receiver = _self, .super_class = LNDynamicSubclassSuper(_self, LNPopupPresentationContainerSupport.class)};
		NSInteger (*super_class)(struct objc_super*, SEL) = reinterpret_cast<decltype(super_class)>(objc_msgSendSuper);
		return super_class(&super, pSBASEL);
	}), "q16@0:8");
}

void _LNPopupPerformForcingHorizontalStatusBarAxis(BOOL force, NS_NOESCAPE dispatch_block_t block)
{
	BOOL prev = __ln_forcingHorizontalStatusBarAxis;
	__ln_forcingHorizontalStatusBarAxis = force;
	block();
	__ln_forcingHorizontalStatusBarAxis = prev;
}

BOOL _LNPopupIsForcingHorizontalStatusBarAxis(void)
{
	return __ln_forcingHorizontalStatusBarAxis;
}

@interface UIViewController (LNPopupVerticalBarSupport) @end
@implementation UIViewController (LNPopupVerticalBarSupport)

+ (void)load
{
	@autoreleasepool
	{
		if(@available(iOS 27.1, *))
		{
			LNSwizzleMethod(self,
							@selector(setNeedsUpdateOfVerticalBarConfiguration),
							@selector(_ln_setNeedsUpdateOfVerticalBarConfiguration));
			
			__LNPopupInstallContainerStatusBarAxisSupport();
		}
	}
}

- (void)_ln_setNeedsUpdateOfVerticalBarConfiguration API_AVAILABLE(ios(27.1))
{
	UIViewController* contentController = self;
	while(contentController != nil && contentController.popupPresentationContainerViewController == nil)
	{
		contentController = contentController.parentViewController;
	}
	
	LNPopupController* popupController = contentController.popupPresentationContainerViewController._ln_popupController_nocreate;
	if(popupController != nil && popupController.currentContentController == contentController)
	{
		[popupController.popupContentView _updateLayoutAxisBehaviorFromContentController];
		[contentController.popupPresentationContainerViewController setNeedsStatusBarAppearanceUpdate];
		
		return;
	}
	
	[self _ln_setNeedsUpdateOfVerticalBarConfiguration];
}

@end
#else
void _LNPopupPerformForcingHorizontalStatusBarAxis(BOOL force, NS_NOESCAPE dispatch_block_t block)
{
	block();
}

BOOL _LNPopupIsForcingHorizontalStatusBarAxis(void)
{
	return NO;
}
#endif
