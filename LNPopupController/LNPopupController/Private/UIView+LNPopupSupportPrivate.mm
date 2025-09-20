//
//  UIView+LNPopupSupportPrivate.m
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-01.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "UIView+LNPopupSupportPrivate.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupController.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "LNPopupBar+Private.h"
#import "_LNPopupUIBarAppearanceProxy.h"
#import "_LNWeakRef.h"
#import <objc/runtime.h>

@implementation _LNPopupBarBackgroundGroupNameOverride

+ (__kindof id<NSObject>)defaultValue
{
	return nil;
}

@end

static const void* LNPopupAttachedPopupController = &LNPopupAttachedPopupController;
static const void* LNPopupAwaitingViewInWindowHierarchyKey = &LNPopupAwaitingViewInWindowHierarchyKey;
static const void* LNPopupNotifyingKey = &LNPopupNotifyingKey;
static const void* LNPopupTabBarProgressKey = &LNPopupTabBarProgressKey;
static const void* LNPopupBarBackgroundViewForceAnimatedKey = &LNPopupBarBackgroundViewForceAnimatedKey;

@interface __LNPopupUIViewFrozenInsets : NSObject @end
@implementation __LNPopupUIViewFrozenInsets

+ (void)load
{
	@autoreleasepool 
	{
		const char* encoding = method_getTypeEncoding(LNSwizzleClassGetInstanceMethod(UIView.class, @selector(needsUpdateConstraints)));
		class_addMethod(self, NSSelectorFromString(LNPopupHiddenString("_safeAreaInsetsFrozen")), imp_implementationWithBlock(^ (id self, SEL _cmd) {
			return YES;
		}), encoding);
	}
}

@end

@interface UIViewController ()

- (void)_ln_popup_viewDidMoveToWindow;

@end

@implementation NSObject (LNPopupSupportPrivate)

- (LNPopupController *)_ln_attachedPopupController
{
	_LNWeakRef* rv = objc_getAssociatedObject(self, LNPopupAttachedPopupController);
	if(rv != nil && rv.object == nil)
	{
		[self _ln_setAttachedPopupController:nil];
	}
	return rv.object;
}

-(void)_ln_setAttachedPopupController:(LNPopupController *)attachedPopupController
{
	id objToSet = nil;
	if(attachedPopupController != nil)
	{
		objToSet = [_LNWeakRef refWithObject:attachedPopupController];
	}
	objc_setAssociatedObject(self, LNPopupAttachedPopupController, objToSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	if([self isKindOfClass:UITabBar.class])
	{
		[[(UITabBar*)self selectedItem] _ln_setAttachedPopupController:attachedPopupController];
	}
}

@end

@implementation UIView (LNPopupSupportPrivate)

+ (void)load
{
	@autoreleasepool 
	{
#if ! LNPopupControllerEnforceStrictClean
		SEL updateBackgroundGroupNameSEL = NSSelectorFromString(LNPopupHiddenString("updateBackgroundGroupName"));
		
		id (^trampoline)(void (*)(id, SEL)) = ^ id (void (*orig)(id, SEL)){
			return ^ (id _self) {
				orig(_self, updateBackgroundGroupNameSEL);
				
				static NSString* groupNameKey = LNPopupHiddenString("groupName");
				static NSString* backgroundViewKey = LNPopupHiddenString("backgroundView");
				
				id backgroundView = [_self valueForKey:backgroundViewKey];
				
				NSString* groupName = [backgroundView valueForKey:groupNameKey];
				if([groupName hasSuffix:@"🤡"] == NO)
				{
					[backgroundView setValue:[NSString stringWithFormat:@"%@🤡", groupName] forKey:groupNameKey];
				}
			};
		};
		
		{
			Class cls = NSClassFromString(LNPopupHiddenString("_UINavigationBarVisualProvider"));
			Method m = LNSwizzleClassGetInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		{
			Class cls = NSClassFromString(LNPopupHiddenString("_UINavigationBarVisualProviderLegacyIOS"));
			Method m = LNSwizzleClassGetInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		{
			Class cls = NSClassFromString(LNPopupHiddenString("_UINavigationBarVisualProviderModernIOS"));
			Method m = LNSwizzleClassGetInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		{
			Class cls = NSClassFromString(LNPopupHiddenString("_UITabBarVisualProviderLegacyIOS"));
			Method m = LNSwizzleClassGetInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		NSString* sel = LNPopupHiddenString("_didMoveFromWindow:toWindow:");
		LNSwizzleMethod(self,
						NSSelectorFromString(sel),
						@selector(_ln__dMFW:tW:));
#else
		LNSwizzleMethod(self,
						@selector(didMoveToWindow),
						@selector(_ln_didMoveToWindow));
#endif
	}
}

- (void)_ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:(BOOL)layout
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
void _LNNotify(UIView* self, NSMutableArray<LNInWindowBlock>* waiting)
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
	static NSString* key = LNPopupHiddenString("_backdropViewLayerGroupName");
	
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

- (void)_ln_freezeInsets
{
	LNDynamicSubclass(self, __LNPopupUIViewFrozenInsets.class);
}

- (BOOL)_ln_isAncestorOfView:(UIView *)view
{
	for(UIView* parent = view.superview; parent; parent = parent.superview)
	{
		if(parent == self)
		{
			return YES;
		}
	}
	
	return NO;
}

- (CGFloat)_ln_simulatedCornerRadiusFromCorners
{
	static NSString* cornersName = LNPopupHiddenString("cornerRadii");
	
	NSValue* corners = [self.layer valueForKey:cornersName];
	CGSize asArray[4];
	[corners getValue:asArray size:sizeof(asArray)];
	
	CGFloat radius = CGFLOAT_MAX;
	for(size_t idx = 0; idx < 4; idx++) {
		CGSize size = asArray[idx];
		
		radius = MIN(radius, MIN(size.width, size.height));
	}
	
	return radius;
}

@end

#if ! LNPopupControllerEnforceStrictClean
@interface UIWindow (ScrollToTopFix) @end
@implementation UIWindow (ScrollToTopFix)

+ (void)load
{
	@autoreleasepool
	{
		NSString* selName = LNPopupHiddenString("_registeredScrollToTopViews");
		LNSwizzleMethod(self,
						NSSelectorFromString(selName),
						@selector(_ln_rSTTV));
	}
}

//_registeredScrollToTopViews
- (NSArray*)_ln_rSTTV
{
	NSArray* rv = [self _ln_rSTTV];
	NSMutableArray* popupRV = [NSMutableArray new];
	
	static NSString* vCFA = LNPopupHiddenString("_viewControllerForAncestor");
	
	for(UIView* scrollToTopCandidate in rv)
	{
		UIViewController* vc = [scrollToTopCandidate valueForKey:vCFA];
		
		if(vc == nil)
		{
			continue;
		}
		
		BOOL fromPopup = vc._isContainedInOpenPopupController;
		if(fromPopup)
		{
			[popupRV addObject:scrollToTopCandidate];
		}
	}
	
	if(popupRV.count > 0)
	{
		return popupRV;
	}
	
	return rv;
}

@end

#endif
	
@implementation UIWindow (LNPopupSupport)

- (UIEvent*)_ln_currentEvent
{
#if LNPopupControllerEnforceStrictClean
	return nil;
#else
	//hostWindow
	static NSString* hW = LNPopupHiddenString("hostWindow");
	//attachedWindow
	static NSString* aW = LNPopupHiddenString("attachedWindow");
	//currentEvent
	static NSString* cE = LNPopupHiddenString("currentEvent");
	
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

+ (void)load
{
	@autoreleasepool
	{
		LNSwizzleMethod(self,
						@selector(hitTest:withEvent:),
						@selector(_ln_hitTest:withEvent:));
	}
}

static const void* LNPopupInteractionOnlyKey = &LNPopupInteractionOnlyKey;
static const void* LNPopupWindowIsLocked = &LNPopupWindowIsLocked;

- (BOOL)_ln_isLockedForPopupTransition
{
	return [objc_getAssociatedObject(self, LNPopupWindowIsLocked) boolValue];
}

- (void)_ln_setLockedForPopupTransition:(BOOL)lockedForPopupTransition
{
	objc_setAssociatedObject(self, LNPopupWindowIsLocked, @(lockedForPopupTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)_ln_popupInteractionOnly
{
	return objc_getAssociatedObject(self, LNPopupInteractionOnlyKey);
}

- (void)_ln_setPopupInteractionOnly:(NSArray*)popupInteractionOnly
{
	objc_setAssociatedObject(self, LNPopupInteractionOnlyKey, popupInteractionOnly, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)_ln_hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if(self._ln_isLockedForPopupTransition == NO)
	{
		return [self _ln_hitTest:point withEvent:event];
	}
	
	id tested = [self _ln_hitTest:point withEvent:event];
	
	NSArray<UIView*>* allowedViews = self._ln_popupInteractionOnly;
	if(allowedViews && tested)
	{
		BOOL isAllowed = NO;
		
		for(UIView* allowedView in allowedViews)
		{
			if([tested isDescendantOfView:allowedView])
			{
				isAllowed = YES;
			}
		}
		
		if(isAllowed == NO)
		{
			tested = nil;
		}
	}
	
	if(tested == nil && self._ln_isLockedForPopupTransition)
	{
		//Suppress UIKit log print.
		return [UIView new];
	}
	
	return tested;
}

@end

LNAlwaysInline
BOOL _LNBottomBarIsInPopupPresentation(NSObject* self)
{
	LNPopupController* attachedController = self.attachedPopupController;
	return attachedController != nil && attachedController.popupControllerTargetState >= LNPopupPresentationStateBarPresented;
}

LNAlwaysInline
LNPopupBar* _LNPopupBarForBottomBarIfInPopupPresentation(NSObject* self)
{
	LNPopupController* attachedController = self.attachedPopupController;
	if(attachedController != nil && attachedController.popupControllerTargetState >= LNPopupPresentationStateBarPresented)
	{
		return attachedController.popupBar;
	}
	
	return nil;
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
	if(LNPopupEnvironmentHasGlass())
	{
		return NO;
	}
	
	//backgroundTransitionProgress
	static NSString* bTP = LNPopupHiddenString("backgroundTransitionProgress");
	
	BOOL isAtScrollEdge = [[bottomBar valueForKey:bTP] doubleValue] > 0;
	
	if(isAtScrollEdge == NO)
	{
		return NO;
	}
	
	UIBarAppearance* scrollEdgeAppearance = [bottomBar _lnpopup_scrollEdgeAppearance];
	
	return scrollEdgeAppearance.backgroundEffect == nil && scrollEdgeAppearance.backgroundColor == nil && scrollEdgeAppearance.backgroundImage == nil;
}

@interface NSObject ()

- (id)initWithToolbar:(id)arg1;

@end

@interface UIToolbar (ScrollEdgeSupport) @end
@implementation UIToolbar (ScrollEdgeSupport)

+ (void)load
{
	@autoreleasepool
	{
		if(@available(iOS 15.0, *))
		{
			LNSwizzleMethod(self, @selector(layoutSubviews), @selector(_ln_layoutSubviews));
			
			if(!LNPopupEnvironmentHasGlass())
			{
#if ! LNPopupControllerEnforceStrictClean
				LNSwizzleClassMethod(self, NSSelectorFromString(LNPopupHiddenString("_visualProviderForToolbar:")), @selector(_ln_vPFT:));
				LNSwizzleMethod(self, @selector(standardAppearance), @selector(_lnpopup_standardAppearance));
				LNSwizzleMethod(self, @selector(compactAppearance), @selector(_lnpopup_compactAppearance));
#endif
				LNSwizzleMethod(self, @selector(setStandardAppearance:), @selector(_lnpopup_setStandardAppearance:));
				LNSwizzleMethod(self, @selector(setCompactAppearance:), @selector(_lnpopup_setCompactAppearance:));
				LNSwizzleMethod(self, @selector(scrollEdgeAppearance), @selector(_lnpopup_scrollEdgeAppearance));
				LNSwizzleMethod(self, @selector(compactScrollEdgeAppearance), @selector(_lnpopup_compactScrollEdgeAppearance));
			}
		}
	}
}

#if ! LNPopupControllerEnforceStrictClean

//+_visualProviderForToolbar:
+ (id)_ln_vPFT:(id)arg1 API_AVAILABLE(ios(26.0))
{
	static Class visualProviderClass = NSClassFromString(LNPopupHiddenString("_UIToolbarVisualProviderModernIOS"));
	
	return [[visualProviderClass alloc] initWithToolbar:arg1];
}

#endif

- (void)_ln_layoutSubviews
{
	[self _ln_layoutSubviews];
	
	[self._ln_attachedPopupController _configurePopupBarFromBottomBarModifyingGroupingIdentifier:NO];
}

- (void)_ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:(BOOL)layout
{
	if(LNPopupEnvironmentHasGlass())
	{
		return;
	}
	
	if(@available(iOS 15.0, *))
	{
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
		self.compactScrollEdgeAppearance = self._lnpopup_compactScrollEdgeAppearance;
		if(layout)
		{
			[self setNeedsLayout];
			[self layoutIfNeeded];
		}
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

#if ! LNPopupControllerEnforceStrictClean
- (UIToolbarAppearance*)_lnpopup_standardAppearance
{
	__weak __typeof(self) weakSelf = self;
	
	UIToolbarAppearance* rv = self._lnpopup_standardAppearance;
	
	if(rv == nil)
	{
		return rv;
	}
	
	return (id)[[_LNPopupUIBarAppearanceProxy alloc] initWithProxiedObject:rv shadowColorHandler:^BOOL{
		LNPopupBar* popupBar = _LNPopupBarForBottomBarIfInPopupPresentation(weakSelf);
		return popupBar != nil && popupBar.resolvedIsFloating;
	}];
}

- (UIToolbarAppearance*)_lnpopup_compactAppearance
{
	__weak __typeof(self) weakSelf = self;
	
	UIToolbarAppearance* rv = self._lnpopup_compactAppearance;
	
	if(rv == nil)
	{
		return rv;
	}
	
	return (id)[[_LNPopupUIBarAppearanceProxy alloc] initWithProxiedObject:rv shadowColorHandler:^BOOL{
		LNPopupBar* popupBar = _LNPopupBarForBottomBarIfInPopupPresentation(weakSelf);
		return popupBar != nil && popupBar.resolvedIsFloating;
	}];
}
#endif

- (void)_lnpopup_setStandardAppearance:(UIToolbarAppearance *)standardAppearance
{
	[self _lnpopup_setStandardAppearance:standardAppearance];
	
	[self _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
}

- (void)_lnpopup_setCompactAppearance:(UIToolbarAppearance *)compactAppearance
{
	[self _lnpopup_setCompactAppearance:compactAppearance];
	
	[self _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
}

@end

@interface UITabBarItem (ScrollEdgeSupport) @end
@implementation UITabBarItem (ScrollEdgeSupport)

+ (void)load
{
	@autoreleasepool
	{
		if(!LNPopupEnvironmentHasGlass())
		{
			if(@available(iOS 15.0, *))
			{
#if ! LNPopupControllerEnforceStrictClean
				LNSwizzleMethod(self, @selector(standardAppearance), @selector(_lnpopup_standardAppearance));
#endif
				LNSwizzleMethod(self, @selector(setStandardAppearance:), @selector(_lnpopup_setStandardAppearance:));
				LNSwizzleMethod(self, @selector(scrollEdgeAppearance), @selector(_lnpopup_scrollEdgeAppearance));
			}
		}
	}
}

- (void)_ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:(BOOL)layout
{
	if(LNPopupEnvironmentHasGlass())
	{
		return;
	}
	
	if(@available(iOS 15.0, *))
	{
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
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

#if ! LNPopupControllerEnforceStrictClean
- (UITabBarAppearance *)_lnpopup_standardAppearance
{
	__weak __typeof(self) weakSelf = self;
	
	UITabBarAppearance* rv = self._lnpopup_standardAppearance;
	
	if(rv == nil)
	{
		return rv;
	}
	
	return (id)[[_LNPopupUIBarAppearanceProxy alloc] initWithProxiedObject:rv shadowColorHandler:^BOOL{
		LNPopupBar* popupBar = _LNPopupBarForBottomBarIfInPopupPresentation(weakSelf);
		return popupBar != nil && popupBar.resolvedIsFloating;
	}];
}
#endif

- (void)_lnpopup_setStandardAppearance:(UITabBarAppearance *)standardAppearance
{
	[self _lnpopup_setStandardAppearance:standardAppearance];
	
	[self _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
}

@end

static const void* LNPopupIgnoringLayoutDuringTransition = &LNPopupIgnoringLayoutDuringTransition;

@interface UITabBar (ScrollEdgeSupport) @end
@implementation UITabBar (ScrollEdgeSupport)

- (BOOL)_ignoringLayoutDuringTransition
{
	return [objc_getAssociatedObject(self, LNPopupIgnoringLayoutDuringTransition) boolValue];
}

- (void)_setIgnoringLayoutDuringTransition:(BOOL)ignoringLayoutDuringTransition
{
	objc_setAssociatedObject(self, LNPopupIgnoringLayoutDuringTransition, @(ignoringLayoutDuringTransition), OBJC_ASSOCIATION_RETAIN);
}

+ (void)load
{
	@autoreleasepool
	{
		LNSwizzleMethod(self, @selector(setFrame:), @selector(_ln_setFrame:));
		LNSwizzleMethod(self, @selector(layoutSubviews), @selector(_ln_layoutSubviews));
		LNSwizzleMethod(self, @selector(setSelectedItem:), @selector(_ln_setSelectedItem:));
		
		if(!LNPopupEnvironmentHasGlass())
		{
			if(@available(iOS 15.0, *))
			{
#if ! LNPopupControllerEnforceStrictClean
				LNSwizzleMethod(self, @selector(standardAppearance), @selector(_lnpopup_standardAppearance));
#endif
				LNSwizzleMethod(self, @selector(setStandardAppearance:), @selector(_lnpopup_setStandardAppearance:));
				LNSwizzleMethod(self, @selector(scrollEdgeAppearance), @selector(_lnpopup_scrollEdgeAppearance));
			}
		}
		
#if ! LNPopupControllerEnforceStrictClean
		if(@available(iOS 17.0, *))
		{
			Class cls = NSClassFromString(LNPopupHiddenString("_UIBarBackground"));
			SEL sel = NSSelectorFromString(LNPopupHiddenString("transitionBackgroundViewsAnimated:"));
			Method m = LNSwizzleClassGetInstanceMethod(cls, sel);
			void (*orig)(id, SEL, BOOL) = reinterpret_cast<decltype(orig)>(method_getImplementation(m));
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

- (void)_ln_setFrame:(CGRect)frame
{
	if(self._ignoringLayoutDuringTransition == NO)
	{
		[self _ln_setFrame:frame];
	}
}

- (void)_ln_layoutSubviews
{
	[self _ln_layoutSubviews];
	
	[self._ln_attachedPopupController _configurePopupBarFromBottomBarModifyingGroupingIdentifier:NO];
}

- (void)_ln_setSelectedItem:(UITabBarItem *)selectedItem
{
	[self _ln_setSelectedItem:selectedItem];
	
	[selectedItem _ln_setAttachedPopupController:self._ln_attachedPopupController];
	[self._ln_attachedPopupController _configurePopupBarFromBottomBarModifyingGroupingIdentifier:NO];
}

- (void)_ln_transitionBackgroundViewsAnimated:(BOOL)arg1
{
	[self _ln_transitionBackgroundViewsAnimated:YES];
}

- (void)_ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:(BOOL)layout
{
	if(LNPopupEnvironmentHasGlass())
	{
		return;
	}
	
	id backgroundView = nil;
	
	if(@available(iOS 15.0, *))
	{
#if ! LNPopupControllerEnforceStrictClean
		static NSString* backgroundViewKey = LNPopupHiddenString("_backgroundView");
		
		backgroundView = [self valueForKey:backgroundViewKey];
		if(backgroundView != nil)
		{
			objc_setAssociatedObject(backgroundView, LNPopupBarBackgroundViewForceAnimatedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
#endif
		
		self.scrollEdgeAppearance = self._lnpopup_scrollEdgeAppearance;
		
		[self.selectedItem _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:layout];
	}
	
	if(layout)
	{
		//This triggers a refresh of the bar appearance.
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
	
	if(@available(iOS 15.0, *))
	{
#if ! LNPopupControllerEnforceStrictClean
		if(backgroundView != nil)
		{
			objc_setAssociatedObject(backgroundView, LNPopupBarBackgroundViewForceAnimatedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
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

#if ! LNPopupControllerEnforceStrictClean
- (UITabBarAppearance *)_lnpopup_standardAppearance
{
	__weak __typeof(self) weakSelf = self;
	
	UITabBarAppearance* rv = self._lnpopup_standardAppearance;
	
	if(rv == nil)
	{
		return rv;
	}
	
	return (id)[[_LNPopupUIBarAppearanceProxy alloc] initWithProxiedObject:rv shadowColorHandler:^BOOL{
		LNPopupBar* popupBar = _LNPopupBarForBottomBarIfInPopupPresentation(weakSelf);
		return popupBar != nil && popupBar.resolvedIsFloating;
	}];
}
#endif

- (void)_lnpopup_setStandardAppearance:(UITabBarAppearance *)standardAppearance
{
	[self _lnpopup_setStandardAppearance:standardAppearance];
	
	[self _ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:YES];
}

@end

@implementation UIScrollView (LNPopupSupportPrivate)

static NSString* __ln_queueingScrollViewClassPrefix = LNPopupHiddenString("Queu");

- (CGRect)_ln_adjustedBounds
{
	if([NSStringFromClass(self.class) containsString:__ln_queueingScrollViewClassPrefix])
	{
		return self.bounds;
	}
	else
	{
		return UIEdgeInsetsInsetRect(self.bounds, self.adjustedContentInset);
	}
}

- (BOOL)_ln_hasHorizontalContent
{
	BOOL rv = self.contentSize.width > self._ln_adjustedBounds.size.width;
	
//	NSLog(@"_ln_hasHorizontalContent: %@ contentSize: %@ adjustedBounds: %@", @(rv), @(self.contentSize), @(self._ln_adjustedBounds));
	
	return rv;
}

- (BOOL)_ln_hasVerticalContent
{
	BOOL rv = self.contentSize.height > self._ln_adjustedBounds.size.height;
	
//	NSLog(@"_ln_hasVerticalContent: %@ contentSize: %@ adjustedBounds: %@ ajustedInsets: %@", @(rv), @(self.contentSize), @(self._ln_adjustedBounds), @(self.adjustedContentInset));
	
	return rv;
}

- (BOOL)_ln_scrollingOnlyVertically
{
	return self._ln_hasHorizontalContent == NO || [self.panGestureRecognizer translationInView:self].x == 0;
}

- (BOOL)_ln_isAtTop
{
	if([NSStringFromClass(self.class) containsString:__ln_queueingScrollViewClassPrefix])
	{
		if(self._ln_hasVerticalContent)
		{
			static SEL viewBeforeViewSEL = NSSelectorFromString(LNPopupHiddenString("_viewBeforeView:"));
			static id (*viewBeforeView)(id, SEL, id) = reinterpret_cast<decltype(viewBeforeView)>(method_getImplementation(LNSwizzleClassGetInstanceMethod(self.class, viewBeforeViewSEL)));
			static SEL visibleViewSEL = NSSelectorFromString(LNPopupHiddenString("visibleView"));
			static id (*visibleView)(id, SEL) = reinterpret_cast<decltype(visibleView)>(method_getImplementation(LNSwizzleClassGetInstanceMethod(self.class, visibleViewSEL)));
			
			id visible = visibleView(self, visibleViewSEL);
			return visible == nil || viewBeforeView(self, viewBeforeViewSEL, visible) == nil;
		}
		else
		{
			return YES;
		}
	}
	
	return self.contentOffset.y <= - (self.adjustedContentInset.top);
}

@end

UIEdgeInsets _LNEdgeInsetsFromDirectionalEdgeInsets(UIView* view, NSDirectionalEdgeInsets edgeInsets)
{
	if(view.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight)
	{
		return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.leading, edgeInsets.bottom, edgeInsets.trailing);
	}
	else
	{
		return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.trailing, edgeInsets.bottom, edgeInsets.leading);
	}
}

#if ! LNPopupControllerEnforceStrictClean

@interface UIVisualEffectView (LNPopupSupportPrivate) @end
@implementation UIVisualEffectView (LNPopupSupportPrivate)

+ (void)load
{
	@autoreleasepool
	{
		if(@available(iOS 17.0, *))
		{
			NSString* selName = LNPopupHiddenString("_setGroupName:");
			LNSwizzleMethod(self,
							NSSelectorFromString(selName),
							@selector(_ln_sGN:));
		}
	}
}

//_setGroupName:
- (void)_ln_sGN:(NSString*)name API_AVAILABLE(ios(17.0))
{
	NSString* override = [self.traitCollection objectForTrait:_LNPopupBarBackgroundGroupNameOverride.class];
	if(override != nil)
	{
		[self _ln_sGN:override];
		return;
	}
	
	[self _ln_sGN:name];
}

@end

#endif

@implementation UIViewPropertyAnimator (KeyFrameSupport)

- (void)ln_addAnimations:(void (^)(void))animation delayFactor:(CGFloat)delayFactor durationFactor:(CGFloat)durationFactor
{
#if LNPopupControllerEnforceStrictClean
	[self addAnimations:animation delayFactor:delayFactor];
#else
	static void (*impl)(id, SEL, void (^)(void), CGFloat, CGFloat);
	static SEL sel;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sel = NSSelectorFromString(LNPopupHiddenString("addAnimations:delayFactor:durationFactor:"));
		Method m = LNSwizzleClassGetInstanceMethod(UIViewPropertyAnimator.class, sel);
		impl = reinterpret_cast<decltype(impl)>(method_getImplementation(m));
	});
	impl(self, sel, animation, delayFactor, durationFactor);
#endif
}

@end
