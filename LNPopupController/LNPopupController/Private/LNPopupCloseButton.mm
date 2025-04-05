//
//  LNPopupCloseButton.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupCloseButton+Private.h"
#import <objc/runtime.h>
#import "LNChevronView.h"
#import "_LNPopupBase64Utils.hh"
#import "LNPopupContentView+Private.h"

@interface LNPopupCloseButton ()

- (id)_aPVFGR;
- (void)_didTouchDown;
- (void)_didTouchDragExit;
- (void)_didTouchDragEnter;
- (void)_didTouchUp;
- (void)_didTouchCancel;

@end

@interface LNPopupCloseButton () <UIPointerInteractionDelegate> @end

__attribute__((objc_direct_members))
@implementation LNPopupCloseButton
{
	__weak LNPopupContentView* _contentView;
	
	UIVisualEffectView* _effectView;
	UIView* _highlightView;
	
	LNChevronView* _chevronView;
}

#ifndef LNPopupControllerEnforceStrictClean

+ (void)load
{
	@autoreleasepool
	{
		Method m = class_getInstanceMethod(self, @selector(_aPVFGR));
		class_addMethod(self, NSSelectorFromString(LNPopupHiddenString("_actingParentViewForGestureRecognizers")), method_getImplementation(m), method_getTypeEncoding(m));
	}
}

//_actingParentViewForGestureRecognizers
- (id)_aPVFGR
{
	return _contentView.currentPopupContentViewController.view;
}

#endif

- (instancetype)initWithContainingContentView:(LNPopupContentView*)contentView
{
	self = [super init];
	
	if(self)
	{
		_contentView = contentView;
		
		self.accessibilityLabel = NSLocalizedString(@"Close", @"");
		
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		_style = LNPopupCloseButtonStyleGrabber;
		[self _setupForChevronButton];
		
		if(@available(iOS 13.4, *))
		{
			self.pointerInteractionEnabled = YES;
			self.pointerStyleProvider = ^UIPointerStyle * _Nullable(UIButton * _Nonnull button, UIPointerEffect * _Nonnull proposedEffect, UIPointerShape * _Nonnull proposedShape) {
				UIPointerLiftEffect* effect = [UIPointerLiftEffect effectWithPreview:[[UITargetedPreview alloc] initWithView:self]];
				UIPointerShape* shape = nil;//[UIPointerShape shapeWithRoundedRect:interaction.view.frame];
				
				return [UIPointerStyle styleWithEffect:effect shape:shape];
			};
		}
	}
	
	return self;
}

- (LNPopupCloseButtonStyle)effectiveStyle
{
	return self.popupContentView.effectivePopupCloseButtonStyle;
}

- (void)setStyle:(LNPopupCloseButtonStyle)style
{
	//This will take care of cases where the user sets LNPopupCloseButtonStyleDefault as well as close button repositioning.
	[self.popupContentView setPopupCloseButtonStyle:style];
}

- (void)_setStyle:(LNPopupCloseButtonStyle)style
{
	if(_style == style)
	{
		return;
	}
	
	_style = style;
	
	[self _cleanup];
	
	if(_style == LNPopupCloseButtonStyleRound)
	{
		[self _setupForCircularButton];
	}
	else if(_style == LNPopupCloseButtonStyleChevron || _style == LNPopupCloseButtonStyleGrabber)
	{
		[self _setupForChevronButton];
	}
}

- (UIVisualEffectView*)backgroundView
{
	return _effectView;
}

- (void)_cleanup
{
	[_chevronView removeFromSuperview];
	_chevronView = nil;
	
	[_effectView removeFromSuperview];
	_effectView = nil;
	
	[_highlightView removeFromSuperview];
	_highlightView = nil;
	
	[self setImage:nil forState:UIControlStateNormal];
	self.tintColor = nil;
	
	self.layer.shadowColor = nil;
	self.layer.shadowOpacity = 0;
	self.layer.shadowRadius = 0;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.masksToBounds = YES;
}

- (void)_setupForChevronButton
{
	CGRect frame;
	if(_style == LNPopupCloseButtonStyleGrabber)
	{
		frame = CGRectMake(0, 0, 36, 15);
	}
	else
	{
		frame = CGRectMake(0, 0, 40, 20);
	}
	
	_chevronView = [[LNChevronView alloc] initWithFrame:frame];
	_chevronView.width = 5.0;
	[_chevronView setState:_style == LNPopupCloseButtonStyleGrabber ? LNChevronViewStateFlat : LNChevronViewStateUp animated:NO];
	
	self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	[self addSubview:_chevronView];
}

- (void)_setupForCircularButton
{
	UIBlurEffectStyle blurStyle;
	if(@available(iOS 13.0, *)) {
		blurStyle = UIBlurEffectStyleSystemChromeMaterial;
	}
	else
	{
		blurStyle = UIBlurEffectStyleExtraLight;
	}
	_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
	_effectView.userInteractionEnabled = NO;
	[self addSubview:_effectView];
	
	UIVisualEffectView* highlightEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect*)_effectView.effect]];
	highlightEffectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	highlightEffectView.frame = _effectView.contentView.bounds;
	_highlightView = [[UIView alloc] initWithFrame:highlightEffectView.contentView.bounds];
	_highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
	_highlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_highlightView.alpha = 0.0;
	[highlightEffectView.contentView addSubview:_highlightView];
	[_effectView.contentView addSubview:highlightEffectView];
	
	[self addTarget:self action:@selector(_didTouchDown) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(_didTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
	[self addTarget:self action:@selector(_didTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
	[self addTarget:self action:@selector(_didTouchUp) forControlEvents:UIControlEventTouchUpInside];
	[self addTarget:self action:@selector(_didTouchUp) forControlEvents:UIControlEventTouchUpOutside];
	[self addTarget:self action:@selector(_didTouchCancel) forControlEvents:UIControlEventTouchCancel];
	
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.15;
	self.layer.shadowRadius = 4.0;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.masksToBounds = NO;
	
	if(@available(iOS 13.0, *))
	{
		self.tintColor = UIColor.labelColor;
		
		[self setTitleColor:self.tintColor forState:UIControlStateNormal];
		
		UIImageSymbolConfiguration* config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightHeavy scale:UIImageSymbolScaleSmall];
		UIImage* image = [[UIImage systemImageNamed:@"chevron.down" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[self setImage:image forState:UIControlStateNormal];
	}
	else
	{
		self.tintColor = UIColor.darkTextColor;
	}
}

- (void)_didTouchDown
{
	[self _setHighlighted:YES animated:NO];
}

- (void)_didTouchDragExit
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_didTouchDragEnter
{
	[self _setHighlighted:YES animated:YES];
}

- (void)_didTouchUp
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_didTouchCancel
{
	[self _setHighlighted:NO animated:YES];
}

- (void)_setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		dispatch_block_t alphaBlock = ^{
			_highlightView.alpha = highlighted ? 1.0 : 0.0;
			_highlightView.alpha = highlighted ? 1.0 : 0.0;
		};
		
		if (animated) {
			[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
				alphaBlock();
			} completion:nil];
		} else {
			alphaBlock();
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if(_style == LNPopupCloseButtonStyleRound)
	{
		[self sendSubviewToBack:_effectView];
		
		CGFloat minSideSize = MIN(self.bounds.size.width, self.bounds.size.height);
		
		_effectView.frame = self.bounds;
		CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
		maskLayer.rasterizationScale = [UIScreen mainScreen].nativeScale;
		maskLayer.shouldRasterize = YES;
		
		CGPathRef path = CGPathCreateWithRoundedRect(self.bounds, minSideSize / 2, minSideSize / 2, NULL);
		maskLayer.path = path;
		CGPathRelease(path);
		
		_effectView.layer.mask = maskLayer;
		
		CGRect imageFrame = self.imageView.frame;
		imageFrame.origin.y += 0.5;
		self.imageView.frame = imageFrame;
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return CGSizeMake(24, 24);
	}
	else if(_style == LNPopupCloseButtonStyleChevron)
	{
		return CGSizeMake(42, 25);
	}
	else
	{
		return CGSizeMake(36, 25);
	}
}

- (CGSize)intrinsicContentSize
{
	return [self sizeThatFits:CGSizeZero];
}

- (void)_setButtonContainerStationary
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return;
	}
	
	if(_style == LNPopupCloseButtonStyleGrabber)
	{
		return;
	}
	
	[_chevronView setState:LNChevronViewStateUp animated:YES];
}

- (void)_setButtonContainerTransitioning
{
	if(_style == LNPopupCloseButtonStyleRound)
	{
		return;
	}
	
	if(_style == LNPopupCloseButtonStyleGrabber)
	{
		return;
	}
	
	[_chevronView setState:LNChevronViewStateFlat animated:YES];
}

- (void)setTintColor:(UIColor *)tintColor
{
	[super setTintColor:tintColor];
	
	_chevronView.tintColor = self.tintColor;
}

- (void)tintColorDidChange
{
	[self setTitleColor:self.tintColor forState:UIControlStateNormal];
}

@end
