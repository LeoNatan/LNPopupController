//
//  UIView+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan on 8/1/20.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import "UIView+LNPopupSupportPrivate.h"
#import "_LNPopupSwizzlingUtils.h"
@import ObjectiveC;
#if TARGET_OS_MACCATALYST
@import AppKit;
#endif

static const void* LNPopupAwaitingViewInWindowHierarchyKey = &LNPopupAwaitingViewInWindowHierarchyKey;
static const void* LNPopupNotifyingKey = &LNPopupNotifyingKey;

#if ! LNPopupControllerEnforceStrictClean
//_didMoveFromWindow:toWindow:
static NSString* dMFWtW = @"X2RpZE1vdmVGcm9tV2luZG93OnRvV2luZG93Og==";
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
		NSString* sel = _LNPopupDecodeBase64String(dMFWtW);
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

- (NSUInteger)_ln_currentEventType
{
#if LNPopupControllerEnforceStrictClean
	return 0;
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
	id event = [hostingWindow valueForKey:cE];
	
	return [[event valueForKey:@"type"] unsignedIntegerValue];
#endif
}

@end


#endif
