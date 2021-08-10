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
@import ObjectiveC;
#if TARGET_OS_MACCATALYST
@import AppKit;
#endif

static const void* LNPopupAwaitingViewInWindowHierarchyKey = &LNPopupAwaitingViewInWindowHierarchyKey;
static const void* LNPopupNotifyingKey = &LNPopupNotifyingKey;

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

- (NSString*)_effectGroupingIdentifierIfAvailable
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
id _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(UIView* self, SEL standardAppearanceSelector, SEL scrollEdgeAppearanceSelector)
{
	UIViewController* vc = self._ln_containerController;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if(vc != nil && vc._ln_popupController_nocreate.currentContentController != nil)
	{
		return [self performSelector:standardAppearanceSelector];
	}
	else
	{
		return [self performSelector:scrollEdgeAppearanceSelector];
	}
#pragma clang diagnostic pop
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
	}
}

- (void)_ln_triggerScrollEdgeAppearanceRefreshIfNeeded
{
	if(@available(iOS 15.0, *))
	{
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
}

- (UITabBarAppearance *)_lnpopup_scrollEdgeAppearance
{
	return _LNPopupReturnScrollEdgeAppearanceOrStandardAppearance(self, @selector(standardAppearance), @selector(_lnpopup_scrollEdgeAppearance));
}

@end
#endif
