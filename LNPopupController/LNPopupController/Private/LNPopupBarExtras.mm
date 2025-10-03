//
//  LNPopupBarExtras.mm
//  LNPopupController
//
//  Created by Léo Natan on 2025-04-07.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupBar+Private.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupBase64Utils.hh"
#import "_LNPopupGlassUtils.h"
#import "UIView+LNPopupSupportPrivate.h"

#ifndef LNPopupControllerEnforceStrictClean
static SEL _effectWithStyle_tintColor_invertAutomaticStyle_SEL;
static id(*_effectWithStyle_tintColor_invertAutomaticStyle)(id, SEL, NSUInteger, UIColor*, BOOL);

__attribute__((constructor))
static void __setupFunction(void)
{
	_effectWithStyle_tintColor_invertAutomaticStyle_SEL = NSSelectorFromString(LNPopupHiddenString("_effectWithStyle:tintColor:invertAutomaticStyle:"));
	Method m = LNSwizzleClassGetClassMethod(UIBlurEffect.class, _effectWithStyle_tintColor_invertAutomaticStyle_SEL);
	_effectWithStyle_tintColor_invertAutomaticStyle = reinterpret_cast<decltype(_effectWithStyle_tintColor_invertAutomaticStyle)>(method_getImplementation(m));
}
#endif

@implementation _LNTransitionPopupBar

#if DEBUG
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}
#endif

@end

@implementation _LNPopupBarContentView @end

@implementation _LNPopupBarTitlesView @end

@implementation _LNPopupTitleLabelWrapper

+ (instancetype)wrapperForLabel:(UILabel*)wrapped
{
	_LNPopupTitleLabelWrapper* rv = [[_LNPopupTitleLabelWrapper alloc] initWithFrame:wrapped.bounds];
	rv.wrapped = wrapped;
	rv.wrapped.translatesAutoresizingMaskIntoConstraints = NO;
	
	rv.translatesAutoresizingMaskIntoConstraints = wrapped.translatesAutoresizingMaskIntoConstraints;
	[rv addSubview:wrapped];
	
	rv.wrappedWidthConstraint = [wrapped.widthAnchor constraintEqualToConstant:rv.bounds.size.width];
	
	[NSLayoutConstraint activateConstraints:@[
		[rv.leadingAnchor constraintEqualToAnchor:wrapped.leadingAnchor],
		[rv.heightAnchor constraintEqualToAnchor:wrapped.heightAnchor],
		rv->_wrappedWidthConstraint
	]];
	
	return rv;
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	
	if(_wrappedWidthConstraint.constant == bounds.size.width)
	{
		return;
	}
	
	if(UIView.inheritedAnimationDuration == 0.0)
	{
		_wrappedWidthConstraint.constant = bounds.size.width;
		[self layoutSubviews];
	}
	else
	{
		[UIView _ln_animatedUsingSwiftUIWithDuration:UIView.inheritedAnimationDuration animations:^{
			_wrappedWidthConstraint.constant = bounds.size.width;
			[self layoutSubviews];
		} completion:nil];
	}
}

@end

@implementation _LNPopupBarShadowView

#if DEBUG

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

#endif

@end

@interface NSObject ()

- (id)initWithToolbar:(id)arg1;

@end

@implementation _LNPopupToolbar

//+_visualProviderForToolbar:
+ (id)_ln_vPFT:(id)arg1 API_AVAILABLE(ios(26.0))
{
	static Class visualProviderClass = NSClassFromString(LNPopupHiddenString("_UIToolbarVisualProviderModernIOS"));
	
	return [[visualProviderClass alloc] initWithToolbar:arg1];
}

+ (void)load
{
	if(@available(iOS 26.0, *))
	{
		@autoreleasepool
		{
			Method m = LNSwizzleClassGetClassMethod(self, @selector(_ln_vPFT:));
			Class metaclass = object_getClass(self);
			class_addMethod(metaclass, NSSelectorFromString(LNPopupHiddenString("_visualProviderForToolbar:")), method_getImplementation(m), method_getTypeEncoding(m));
		}
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* rv = [super hitTest:point withEvent:event];
	
	if(rv != nil && [rv isKindOfClass:UIControl.class] == NO && [NSStringFromClass(rv.class) containsString:@"BarItemView"] == NO)
	{
		rv = nil;
	}
	
	return rv;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//On iOS 11 and above reset the semantic content attribute to make sure it propagades to all subviews.
	[self setSemanticContentAttribute:self.semanticContentAttribute];
	
	[self._layoutDelegate _toolbarDidLayoutSubviews];
}

- (void)_deepSetSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute toView:(UIView*)view startingFromView:(UIView*)staringView;
{
	if(view == staringView)
	{
		[super setSemanticContentAttribute:semanticContentAttribute];
	}
	else
	{
		[view setSemanticContentAttribute:semanticContentAttribute];
	}
	
	[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:obj startingFromView:staringView];
	}];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute
{
	//On iOS 11, due to a bug in UIKit, the semantic content attribute must be propagaded recursively to all subviews, so that the system behaves correctly.
	[self _deepSetSemanticContentAttribute:semanticContentAttribute toView:self startingFromView:self];
}

- (UIToolbarAppearance *)standardAppearance
{
	return nil;
}

- (UIToolbarAppearance *)scrollEdgeAppearance
{
	return nil;
}

@end

@implementation LNNonMarqueeLabel

@synthesize marqueeScrollEnabled, running, synchronizedLabels;

- (void)reset {}

@end

@implementation LNLegacyMarqueeLabel
{
	BOOL _enabled;
	NSHashTable<LNLegacyMarqueeLabel*>* _weakSynchronizedLabels;
}

- (BOOL)isMarqueeScrollEnabled
{
	return _enabled;
}

-(void)setMarqueeScrollEnabled:(BOOL)marqueeScrollEnabled
{
	_enabled = marqueeScrollEnabled;
	if(!_enabled)
	{
		[self shutdownLabel];
	}
}

- (BOOL)isRunning
{
	return self.awayFromHome;
}

- (void)setRunning:(BOOL)running
{
	if(running)
	{
		[self triggerScrollStart];
	} else {
		[self shutdownLabel];
	}
}

- (NSArray<id<LNMarqueeLabel>> *)synchronizedLabels
{
	return _weakSynchronizedLabels.allObjects;
}

- (void)setSynchronizedLabels:(NSArray<id<LNMarqueeLabel>> *)synchronizedLabels
{
	_weakSynchronizedLabels = [NSHashTable weakObjectsHashTable];
	for (id object in synchronizedLabels)
	{
		[_weakSynchronizedLabels addObject:object];
	}
}

- (void)reset
{
	[self shutdownLabel];
}

- (void)labelReturnedToHome:(BOOL)finished
{
	NSIndexSet* stillRunning = [self.synchronizedLabels indexesOfObjectsPassingTest:^BOOL(id<LNMarqueeLabel> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		return obj.isMarqueeScrollEnabled && obj.isRunning;
	}];
	
	if(stillRunning.count > 0)
	{
		self.holdScrolling = YES;
		return;
	}
	
	for(LNLegacyMarqueeLabel* label in _weakSynchronizedLabels)
	{
		if(label.isMarqueeScrollEnabled)
		{
			label.holdScrolling = NO;
		}
	}
}

@end

/**
 A helper view for view controllers without real bottom bars.
 */
@implementation _LNPopupBottomBarSupport
{
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.userInteractionEnabled = NO;
	}
	return self;
}

#if DEBUG

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

#endif

@end

@implementation _LNPopupBarExtensionView

#if DEBUG

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}

- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

#endif

@end

//@implementation _LNPopupBarGlassGroupBackground
//
//+ (__kindof id<NSObject>)defaultValue
//{
//	return nil;
//}
//
//+ (NSString*)identifier
//{
//	return @"UIGlassGroupTrait";
//}
//
//+ (NSString*)name
//{
//	return @"GlassGroup";
//}
//
//+ (BOOL)_isPrivate
//{
//	return YES;
//}
//
//@end
