//
//  UIView+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 8/1/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "UIView+LNPopupSupportPrivate.h"
#import "_LNPopupSwizzlingUtils.h"
@import ObjectiveC;

static const void* LNPopupAwaitingViewInWindowHierarchy = &LNPopupAwaitingViewInWindowHierarchy;

#if ! LNPopupControllerEnforceStrictClean
//_didMoveFromWindow:toWindow:
static NSString* dMFWtW = @"X2RpZE1vdmVGcm9tV2luZG93OnRvV2luZG93Og==";
#endif

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
static void _LNNotify(UIView* self, NSMutableArray<LNInWindowBlock>* waiting, NSUInteger idx)
{
	if(waiting.count == idx)
	{
		if(waiting.count > 0)
		{
			[self _ln_forgetAboutIt];
		}
		
		return;
	}
	
	LNInWindowBlock block = waiting[idx];
	block(^ {
		_LNNotify(self, waiting, idx + 1);
	});
}

- (void)_ln_notify
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchy);
	
	_LNNotify(self, waiting, 0);
}

- (void)_ln_letMeKnowWhenViewInWindowHierarchy:(LNInWindowBlock)block
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchy);
	if(waiting == nil)
	{
		waiting = [NSMutableArray new];
		objc_setAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchy, waiting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[waiting addObject:block];
}

- (void)_ln_forgetAboutIt
{
	NSMutableArray<LNInWindowBlock>* waiting = objc_getAssociatedObject(self, LNPopupAwaitingViewInWindowHierarchy);
	[waiting removeAllObjects];
}

@end
