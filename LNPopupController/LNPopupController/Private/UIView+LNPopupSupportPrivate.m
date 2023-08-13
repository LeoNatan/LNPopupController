//
//  UIView+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 8/1/20.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "UIView+LNPopupSupportPrivate.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupSwizzlingUtils.h"
#import "LNPopupBar+Private.h"
@import ObjectiveC;
#if TARGET_OS_MACCATALYST
@import AppKit;
#endif

static const void* LNPopupAwaitingViewInWindowHierarchyKey = &LNPopupAwaitingViewInWindowHierarchyKey;
static const void* LNPopupNotifyingKey = &LNPopupNotifyingKey;
static const void* LNPopupTabBarProgressKey = &LNPopupTabBarProgressKey;
static const void* LNPopupBarBackgroundViewForceAnimatedKey = &LNPopupBarBackgroundViewForceAnimatedKey;

#if ! LNPopupControllerEnforceStrictClean
//_viewControllerForAncestor
static NSString* _vCFA = @"X3ZpZXdDb250cm9sbGVyRm9yQW5jZXN0b3I=";
//_didMoveFromWindow:toWindow:
static NSString* _dMFWtW = @"X2RpZE1vdmVGcm9tV2luZG93OnRvV2luZG93Og==";
//_backdropViewLayerGroupName
static NSString* _bVLGN = @"X2JhY2tkcm9wVmlld0xheWVyR3JvdXBOYW1l";
//hostWindow
static NSString* _hW = @"aG9zdFdpbmRvdw==";
//attachedWindow
static NSString* _aW = @"YXR0YWNoZWRXaW5kb3c=";
//currentEvent
static NSString* _cE = @"Y3VycmVudEV2ZW50";
//backgroundTransitionProgress
static NSString* _bTP = @"YmFja2dyb3VuZFRyYW5zaXRpb25Qcm9ncmVzcw==";
//_UIBarBackground
static NSString* _UBB = @"X1VJQmFyQmFja2dyb3VuZA==";
//transitionBackgroundViewsAnimated:
static NSString* _tBVA = @"dHJhbnNpdGlvbkJhY2tncm91bmRWaWV3c0FuaW1hdGVkOg==";
//_backgroundView
static NSString* _bV = @"X2JhY2tncm91bmRWaWV3";

#endif

@interface UIViewController ()

- (void)_ln_popup_viewDidMoveToWindow;

@end

@implementation UIView (LNPopupSupportPrivate)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
#if ! LNPopupControllerEnforceStrictClean
		NSString* sel = _LNPopupDecodeBase64String(_dMFWtW);
		LNSwizzleMethod(self,
						NSSelectorFromString(sel),
						@selector(_ln__dMFW:tW:));
#else
		LNSwizzleMethod(self,
						@selector(didMoveToWindow),
						@selector(_ln_didMoveToWindow));
#endif
	});
}

- (UIViewController*)_ln_containerController
{
#if ! LNPopupControllerEnforceStrictClean
	static NSString* property = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		property = _LNPopupDecodeBase64String(_vCFA);
	});
	return [self valueForKey:property];
#else
	UIResponder* next = self.nextResponder;
	while(next)
	{
		if([next isKindOfClass:UIViewController.class])
		{
			return (id)next;
		}
		next = next.nextResponder;
	}
	
	return nil;
#endif
}

- (void)_ln_triggerScrollEdgeAppearanceRefreshIfNeeded
{
	//Do nothing on UIView.
}

- (BOOL)_ln_scrollEdgeAppearanceRequiresFadeForPopupBar:(LNPopupBar*)popupBar
{
	return NO;
}

#if ! LNPopupControllerEnforceStrictClean
//_didMoveFromWindow:toWindow:
- (void)_ln__dMFW:(UIWindow*)fromWindow tW:(UIWindow*)toWindow
{
	[self _ln__dMFW:fromWindow tW:toWindow];
	
	if([self.nextResponder isKindOfClass:UIViewController.class] && [self.nextResponder respondsToSelector:@selector(_ln_popup_viewDidMoveToWindow)])
	{
		[(id)self.nextResponder _ln_popup_viewDidMoveToWindow];
	}
	
	[self _ln_notify];
}
#else
- (void)_ln_didMoveToWindow
{
	[self _ln_didMoveToWindow];
	
	[self _ln_notify];
}
#endif

LNAlwaysInline
static void _LNNotify(UIView* self, NSMutableArray<LNInWindowBlock>* waiting)
{
	if(waiting.count == 0)
	{
		[self _ln_setNotifying:NO];
		return;
	}
	
	LNInWindowBlock block = waiting.firstObject;
	[waiting removeObjectAtIndex:0];
	block(^ {
		_LNNotify(self, waiting);
	});
}

- (void)_ln_setNotifying:(BOOL)notifying
{
	objc_setAssociatedObject(self, LNPopupNotifyingKey, @(notifying), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)_ln_isNotifying
{
	return [objc_getAssociatedObject(self, LNPopupNotifyingKey) boolValue];
}

- (void)_ln_notify
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchyKey);
	
	if(waiting.count == 0)
	{
		return;
	}
	
	[self _ln_setNotifying:YES];
	
	_LNNotify(self, waiting);
}

- (void)_ln_letMeKnowWhenViewInWindowHierarchy:(LNInWindowBlock)block
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchyKey);
	if(waiting == nil)
	{
		waiting = [NSMutableArray new];
		objc_setAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchyKey, waiting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[waiting addObject:block];
	
	if(self.window != nil && self._ln_isNotifying == NO)
	{
		[self _ln_notify];
	}
}

- (void)_ln_forgetAboutIt
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchyKey);
	[waiting removeAllObjects];
}

- (NSString*)_ln_effectGroupingIdentifierIfAvailable
{
#if ! LNPopupControllerEnforceStrictClean
	static NSString* key = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		key = _LNPopupDecodeBase64String(_bVLGN);
	});
	
	if([self respondsToSelector:NSSelectorFromString(key)])
	{
		return [self valueForKey:key];
	}
	else
	{
#endif
		return nil;
#if ! LNPopupControllerEnforceStrictClean
	}
#endif
}

@end

#if TARGET_OS_MACCATALYST
	
@implementation UIWindow (MacCatalystSupport)

- (UIEvent*)_ln_currentEvent
{
#if LNPopupControllerEnforceStrictClean
	return nil;
#else
	//hostWindow
	static NSString* hW;
	//attachedWindow
	static NSString* aW;
	//currentEvent
	static NSString* cE;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		hW = _LNPopupDecodeBase64String(_hW);
		aW = _LNPopupDecodeBase64String(_aW);
		cE = _LNPopupDecodeBase64String(_cE);
	});
	
	//Obtain the actual NSWindow object
	id hostingWindow = [self valueForKey:hW];
	if([NSStringFromClass([hostingWindow class]) hasSuffix:@"Proxy"])
	{
		//On Big Sur, the hosting window is abstracted behind a proxy object, but we need the actual NSWindow
		hostingWindow = [hostingWindow valueForKey:aW];
	}
	//Obtain the current NSEvent
	return [hostingWindow valueForKey:cE];
#endif
}

@end


#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 150000
LNAlwaysInline
BOOL _LNBottomBarIsInPopupPresentation(id self)
{
	UIViewController* vc = nil;
	if([self respondsToSelector:@selector(delegate)])
	{
		//Terrible logic to find UITabBarController when a UINavigationController is embedded inside it.
		vc = [self valueForKey:@"delegate"];
		if([vc isKindOfClass:UIViewController.class] == NO)
		{
			vc = nil;
		}
	}
	
	if(vc == nil)
	{
		vc = [self _ln_containerController];
	}
	
	return vc != nil && vc._ln_popupController_nocreate.popupControllerTargetState >= LNPopupPresentationStateBarPresented;
}

LNAlwaysInline
id _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(id self, SEL standardAppearanceSelector, SEL scrollEdgeAppearanceSelector)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if(_LNBottomBarIsInPopupPresentation(self))
	{
		return [self performSelector:standardAppearanceSelector];
	}
	else
	{
		return [self performSelector:scrollEdgeAppearanceSelector];
	}
#pragma clang diagnostic pop
}

static BOOL __ln_scrollEdgeAppearanceRequiresFadeForPopupBar(id bottomBar, LNPopupBar* popupBar)
{
	static NSString* bTP = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bTP = _LNPopupDecodeBase64String(_bTP);
	});
	
	BOOL isAtScrollEdge = [[bottomBar valueForKey:bTP] doubleValue] > 0;
	
	if(isAtScrollEdge == NO)
	{
		return NO;
	}
	
	UIBarAppearance* scrollEdgeAppearance = [bottomBar _lnpopup_scrollEdgeAppearance];
	
	return scrollEdgeAppearance.backgroundEffect == nil && scrollEdgeAppearance.backgroundColor == nil && scrollEdgeAppearance.backgroundImage == nil;
}

@interface UIToolbar (ScrollEdgeSupport) @end
@implementation UIToolbar (ScrollEdgeSupport)

+ (void)load
{
	@autoreleasepool
	{
		if(@available(iOS 15.0, *))
		{
			LNSwizzleMethod(self, @selector(scrollEdgeAppearance), @selector(_lnpopup_scrollEdgeAppearance));
			LNSwizzleMethod(self, @selector(compactScrollEdgeAppearance), @selector(_lnpopup_compactScrollEdgeAppearance));
		}
	}
}

- (void)_ln_triggerScrollEdgeAppearanceRefreshIfNeeded
{
	if(@available(iOS 15.0, *))
	{
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
		self.compactScrollEdgeAppearance = self._lnpopup_compactScrollEdgeAppearance;
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
}

- (BOOL)_ln_scrollEdgeAppearanceRequiresFadeForPopupBar:(LNPopupBar*)popupBar
{
	return __ln_scrollEdgeAppearanceRequiresFadeForPopupBar(self, popupBar);
}

- (UIToolbarAppearance *)_lnpopup_scrollEdgeAppearance
{
	return _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(self, @selector(standardAppearance), @selector(_lnpopup_scrollEdgeAppearance));
}

- (UIToolbarAppearance *)_lnpopup_compactScrollEdgeAppearance
{
	return _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(self, @selector(standardAppearance), @selector(_lnpopup_compactScrollEdgeAppearance));
}

@end

@interface UITabBar (ScrollEdgeSupport) @end
@implementation UITabBar (ScrollEdgeSupport)

+ (void)load
{
	@autoreleasepool
	{
		if(@available(iOS 15.0, *))
		{
			LNSwizzleMethod(self, @selector(scrollEdgeAppearance), @selector(_lnpopup_scrollEdgeAppearance));
		}
		
#if ! LNPopupControllerEnforceStrictClean
		if(@available(iOS 17.0, *))
		{
			Class cls = NSClassFromString(_LNPopupDecodeBase64String(_UBB));
			SEL sel = NSSelectorFromString(_LNPopupDecodeBase64String(_tBVA));
			Method m = class_getInstanceMethod(cls, sel);
			void (*orig)(id, SEL, BOOL) = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(^(id _self, BOOL animated) {
				if([objc_getAssociatedObject(_self, LNPopupBarBackgroundViewForceAnimatedKey) boolValue] == YES)
				{
					animated = YES;
				}
				
				orig(_self, sel, animated);
			}));
		}
#endif
	}
}

- (void)_ln_transitionBackgroundViewsAnimated:(BOOL)arg1
{
	[self _ln_transitionBackgroundViewsAnimated:YES];
}

- (void)_ln_triggerScrollEdgeAppearanceRefreshIfNeeded
{
	if(@available(iOS 15.0, *))
	{
#if ! LNPopupControllerEnforceStrictClean
		id backgroundView = [self valueForKey:_LNPopupDecodeBase64String(_bV)];
		objc_setAssociatedObject(backgroundView, LNPopupBarBackgroundViewForceAnimatedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
		[self setNeedsLayout];
		[self layoutIfNeeded];
#if ! LNPopupControllerEnforceStrictClean
		objc_setAssociatedObject(backgroundView, LNPopupBarBackgroundViewForceAnimatedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
	}
}

- (BOOL)_ln_scrollEdgeAppearanceRequiresFadeForPopupBar:(LNPopupBar*)popupBar
{
	return __ln_scrollEdgeAppearanceRequiresFadeForPopupBar(self, popupBar);
}

- (UITabBarAppearance *)_lnpopup_scrollEdgeAppearance
{
	return _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(self, @selector(standardAppearance), @selector(_lnpopup_scrollEdgeAppearance));
}

@end
#endif
