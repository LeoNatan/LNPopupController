//
//  _LNPopupSheetPresentationController_.m
//  LNPopupController
//
//  Created by Leo Natan on 9/13/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "_LNPopupSheetPresentationController_.h"
#import "_LNPopupPresentationController.h"
#import "LNPopupContentViewController.h"
#import "LNPopupBar+Private.h"
#import "_LNWeakRef.h"
@import Darwin;
@import ObjectiveC;

Class _LNPopupPageSheetPresentationController;
Class _LNPopupFormSheetPresentationController;

@implementation _LNPopupSheetPresentationController_
typedef void(^classBlock)(Class cls);

+ (void)load
{
	@autoreleasepool
	{
		//TODO: Hide
		NSDictionary<NSString*, classBlock>* classes = @{
			@"_UIPageSheetPresentationController": ^ (Class cls) {
				_LNPopupPageSheetPresentationController = cls;
			},
			@"_UIFormSheetPresentationController": ^ (Class cls) {
				_LNPopupFormSheetPresentationController = cls;
			},
		};
		
		[classes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, classBlock  _Nonnull obj, BOOL * _Nonnull stop) {
			NSString* className = [key stringByAppendingFormat:@"_LNPopup"];
			
			Class cls = objc_allocateClassPair(NSClassFromString(key), className.UTF8String, 0);
			
			unsigned int methodCount = 0;
			Method* methods = class_copyMethodList(_LNPopupSheetPresentationController_.class, &methodCount);
			for(unsigned int i = 0; i < methodCount; i++)
			{
				Method m = methods[i];
				class_addMethod(cls, method_getName(m), method_getImplementation(m), method_getTypeEncoding(m));
			}
			if(methods)
			{
				free(methods);
			}
			
			objc_property_t* properties = class_copyPropertyList(_LNPopupSheetPresentationController_.class, &methodCount);
			for(unsigned int i = 0; i < methodCount; i++)
			{
				objc_property_t p = properties[i];
				unsigned int attrCount = 0;
				objc_property_attribute_t *pa = property_copyAttributeList(p, &attrCount);
				class_addProperty(cls, property_getName(p), pa, attrCount);
				if(pa)
				{
					free(pa);
				}
			}
			if(properties)
			{
				free(properties);
			}
			
			objc_registerClassPair(cls);
			
			obj(cls);
		}];
	}
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
	struct objc_super superInfo = {
		self,
		self.superclass
	};
	id (*super_call)(struct objc_super*, SEL, id, id) = (void*)objc_msgSendSuper;
	self = super_call(&superInfo, _cmd, presentedViewController, presentingViewController);
	
	if(self)
	{
		[self setValue:@YES forKey:@"wantsFullScreen"];
		[self setValue:@YES forKey:@"wantsBottomAttached"];
		[self setValue:@YES forKey:@"allowsInteractiveDismissWhenFullScreen"];
	}
	
	return self;
}
#pragma clang diagnostic pop

- (CGRect)frameOfPresentedViewInContainerView
{
	struct objc_super superInfo = {
		self,
		self.superclass
	};
	
#if __arm64__
	CGRect (*super_call)(struct objc_super*, SEL) = (void*)objc_msgSendSuper;
#elif __x86_64__
	CGRect (*super_call)(struct objc_super*, SEL) = (void*)objc_msgSendSuper_stret;
#else
#error Open an issue on Github!
#endif
	CGRect frame = super_call(&superInfo, _cmd);
	
	return frame;
	
//	CGRect bottomBarFrame = [self bottomBarFrameForOpenPopup];
//
//	return CGRectMake(bottomBarFrame.origin.x, frame.origin.y, bottomBarFrame.size.width, self.containerView.bounds.size.height - frame.origin.y);
}

- (void)presentationTransitionWillBegin
{
	struct objc_super superInfo = {
		self,
		self.superclass
	};
	void (*super_call)(struct objc_super*, SEL) = (void*)objc_msgSendSuper;
	super_call(&superInfo, _cmd);
	
	if(self.frameOfPresentedViewInContainerView.size.width < self.containerView.bounds.size.width)
	{
		return;
	}
	
	UIView* bottomBarView = [self bottomBarSnapshotViewForTransition];
//	UIView* popupBarView = [self popupBarSnapshotViewForTransition];
	
	[bottomBarView setFrame:self.bottomBarFrameForClosedPopup];
//	[popupBarView setFrame:self.popupBarFrameForClosedPopup];
	
	[self.containerView addSubview:bottomBarView];
//	[self.containerView addSubview:popupBarView];
	
	[self.containerView addSubview:bottomBarView];
//	[self.containerView addSubview:popupBarView];
	
	CGRect bottomBarTargetFrame = self.bottomBarFrameForOpenPopup;
//	CGRect popupBarTargetFrame = self.popupBarFrameForOpenPopup;
	
	[self.popupContentController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[bottomBarView.superview bringSubviewToFront:bottomBarView];
//		[popupBarView.superview bringSubviewToFront:popupBarView];
		
		[bottomBarView setFrame:bottomBarTargetFrame];
//		[popupBarView setFrame:popupBarTargetFrame];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[bottomBarView removeFromSuperview];
//		[popupBarView removeFromSuperview];
	}];
}

- (void)dismissalTransitionWillBegin
{
	struct objc_super superInfo = {
		self,
		self.superclass
	};
	void (*super_call)(struct objc_super*, SEL) = (void*)objc_msgSendSuper;
	super_call(&superInfo, _cmd);
	
	__block UIView* bottomBarView;
	__block UIView* popupBarView;
	
	if(self.frameOfPresentedViewInContainerView.size.width < self.containerView.bounds.size.width)
	{
		return;
	}
	
	CGFloat previousExtendedHeight = self.popupContentController.popupBar.extendedBackgroundViewHeight;
	
	void (^animateBlock)(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) = ^ (id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[UIView performWithoutAnimation:^{
			bottomBarView = self.bottomBarSnapshotViewForTransition;
			CGRect bottomBarFrame = self.bottomBarFrameForOpenPopup;
			[bottomBarView setFrame:bottomBarFrame];
			[self.containerView addSubview:bottomBarView];
			
			CGFloat extensionHeight = (1.0 - context.percentComplete) * self.containerView.bounds.size.height;
			
			self.popupContentController.popupBar.extendedBackgroundViewHeight = extensionHeight;
			[self.popupContentController.popupBar layoutIfNeeded];
			
			popupBarView = self.popupBarSnapshotViewForTransition;
			CGRect popupBarFrame = self.popupBarFrameForClosedPopup;
			popupBarFrame.origin.y = (0.5 * context.percentComplete + 0.5) * self.containerView.bounds.size.height;
			popupBarView.frame = popupBarFrame;
			[self.containerView insertSubview:popupBarView atIndex:1];
		}];
		
		self.popupContentController.popupBar.extendedBackgroundViewHeight = previousExtendedHeight;
		[bottomBarView setFrame:self.bottomBarFrameForClosedPopup];
		[popupBarView setFrame:self.popupBarFrameForClosedPopup];
	};
	
	void (^endBlock)(BOOL) = ^(BOOL finished) {
		[bottomBarView removeFromSuperview];
		self.popupContentController.popupBar.extendedBackgroundViewHeight = previousExtendedHeight;
		[bottomBarView setFrame:self.bottomBarFrameForClosedPopup];
	};
	
	[self.popupContentController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		if(context.initiallyInteractive == NO)
		{
			animateBlock(context);
			return;
		}
		
		[self.popupContentController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			if(context.cancelled == YES)
			{
				return;
			}
			
			double remaining = context.transitionDuration * (1.0 - context.percentComplete);
			
			[UIView animateWithDuration:MAX(0.3, remaining) delay:0.0 usingSpringWithDamping:500.0 initialSpringVelocity:0.0 options:0 animations: ^ {
				animateBlock(context);
			} completion:endBlock];
		}];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		if(context.initiallyInteractive == YES)
		{
			return;
		}
		
		endBlock(YES);
	}];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
	struct objc_super superInfo = {
		self,
		self.superclass
	};
	void (*super_call)(struct objc_super*, SEL, BOOL) = (void*)objc_msgSendSuper;
	super_call(&superInfo, _cmd, completed);
	
	if(completed)
	{
		[self.popupPresentationControllerDelegate currentPresentationDidEnd];
		self.popupPresentationControllerDelegate = nil;
	}
}

- (UIView*)bottomBarSnapshotViewForTransition
{
	return _LNPopupSnapshotView(self.popupContentController.bottomBar);
}

- (UIView*)popupBarSnapshotViewForTransition
{
	return _LNPopupSnapshotView(self.popupContentController.popupBar);
}

- (CGRect)bottomBarFrameForOpenPopup
{
	CGRect bottomBarFrame = [self.containerView convertRect:self.popupContentController.bottomBar.bounds fromView:self.popupContentController.bottomBar];
	bottomBarFrame.origin.y = self.containerView.bounds.size.height;
	return bottomBarFrame;
}

- (CGRect)bottomBarFrameForClosedPopup
{
	CGRect bottomBarFrame = [self.containerView convertRect:self.popupContentController.bottomBar.bounds fromView:self.popupContentController.bottomBar];
	return bottomBarFrame;
}

- (CGRect)popupBarFrameForClosedPopup
{
	CGRect popupBarFrame =  [self.containerView convertRect:self.popupContentController.popupBar.bounds fromView:self.popupContentController.popupBar];
	return popupBarFrame;
}

- (id<LNPopupPresentationControllerDelegate>)popupPresentationControllerDelegate
{
	_LNWeakRef* ref = objc_getAssociatedObject(self, @selector(popupPresentationControllerDelegate));
	
	if(ref.object == nil)
	{
		[self setPopupPresentationControllerDelegate:nil];
	}
	
	return [ref object];
}

- (void)setPopupPresentationControllerDelegate:(id<LNPopupPresentationControllerDelegate>)popupPresentationControllerDelegate
{
	_LNWeakRef* weakRef;
	if(popupPresentationControllerDelegate != nil)
	{
		weakRef = [_LNWeakRef refWithObject:popupPresentationControllerDelegate];
	}
	objc_setAssociatedObject(self, @selector(popupPresentationControllerDelegate), weakRef, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LNPopupContentViewController *)popupContentController
{
	return nil;
}

@end
