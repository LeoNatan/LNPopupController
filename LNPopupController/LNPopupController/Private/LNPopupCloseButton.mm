//
//  LNPopupCloseButton.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupControllerImpl.h"
#import "LNPopupCloseButton+Private.h"
#import <objc/runtime.h>
#import "LNChevronView.h"
#import "_LNPopupBase64Utils.hh"
#import "LNPopupContentView+Private.h"
#import "_LNPopupGlassUtils.h"
#import "_LNPopupSwizzlingUtils.h"

BOOL _LNPopupCloseButtonStyleIsGlass(LNPopupCloseButtonStyle style)
{
	static const NSUInteger __LNPopupButtonGlassStyleMask = 0x100;
	return (style != LNPopupCloseButtonStyleNone && (style & __LNPopupButtonGlassStyleMask) == __LNPopupButtonGlassStyleMask);
}

void _LNPopupResolveCloseButtonStyleAndPositioning(LNPopupCloseButtonStyle style, LNPopupCloseButtonPositioning positioning, LNPopupCloseButtonStyle* resolvedStyle, LNPopupCloseButtonPositioning* resolvedPositioning)
{
	*resolvedStyle = style;
	if(style == LNPopupCloseButtonStyleDefault)
	{
		if(LNPopupEnvironmentHasGlass())
		{
			if([LNPopupBar isCatalystApp])
			{
				*resolvedStyle = LNPopupCloseButtonStyleProminentGlass;
			}
			else
			{
				*resolvedStyle = LNPopupCloseButtonStyleGrabber;
			}
		}
		else
		{
			if([LNPopupBar isCatalystApp])
			{
				*resolvedStyle =  LNPopupCloseButtonStyleRound;
			}
			else
			{
				*resolvedStyle = LNPopupCloseButtonStyleGrabber;
			}
		}
	}
	
	if(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26.0 && _LNPopupCloseButtonStyleIsGlass(style))
	{
		*resolvedStyle = LNPopupCloseButtonStyleRound;
	}
	
	*resolvedPositioning = positioning;
	if(positioning == LNPopupCloseButtonPositioningDefault)
	{
		if(_LNPopupCloseButtonStyleIsGlass(*resolvedStyle))
		{
			*resolvedPositioning = LNPopupCloseButtonPositioningTrailing;
		}
		else
		{
			switch(*resolvedStyle)
			{
				case LNPopupCloseButtonStyleChevron:
				case LNPopupCloseButtonStyleGrabber:
					*resolvedPositioning = LNPopupCloseButtonPositioningCenter;
					break;
				case LNPopupCloseButtonStyleRound:
				default:
					*resolvedPositioning = LNPopupCloseButtonPositioningLeading;
					break;
			}
		}
	}
}

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
	UIVisualEffectView* _effectView;
	UIView* _highlightView;
	
	LNChevronView* _chevronView;
}

@synthesize style=__style;

#ifndef LNPopupControllerEnforceStrictClean

+ (void)load
{
	@autoreleasepool
	{
		Method m = LNSwizzleClassGetInstanceMethod(self, @selector(_aPVFGR));
		class_addMethod(self, NSSelectorFromString(LNPopupHiddenString("_actingParentViewForGestureRecognizers")), method_getImplementation(m), method_getTypeEncoding(m));
	}
}

//_actingParentViewForGestureRecognizers
- (id)_aPVFGR
{
	return _popupContentView.currentPopupContentViewController.view;
}

#endif

- (instancetype)initWithContainingContentView:(LNPopupContentView*)contentView
{
	self = [super init];
	
	if(self)
	{
		_popupContentView = contentView;
		
		self.accessibilityLabel = NSLocalizedString(@"Close", @"");
		
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		__style = LNPopupCloseButtonStyleDefault;
		
		if(@available(iOS 13.4, *))
		{
			self.pointerInteractionEnabled = YES;
			self.pointerStyleProvider = ^UIPointerStyle * _Nullable(UIButton * _Nonnull button, UIPointerEffect * _Nonnull proposedEffect, UIPointerShape * _Nonnull proposedShape) {
				UIPointerLiftEffect* effect = [UIPointerLiftEffect effectWithPreview:[[UITargetedPreview alloc] initWithView:button]];
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

- (LNPopupCloseButtonPositioning)effectivePositioning
{
	return self.popupContentView.effectivePopupCloseButtonPositioning;
}

- (void)setStyle:(LNPopupCloseButtonStyle)style
{
	//This will take care of cases where the user sets LNPopupCloseButtonStyleDefault as well as close button repositioning.
	[self.popupContentView setPopupCloseButtonStyle:style];
}

- (void)_setStyle:(LNPopupCloseButtonStyle)style
{
	__style = style;
	
	[self _cleanup];
	
	if(@available(iOS 26.0, *))
	{
		if(_LNPopupCloseButtonStyleIsGlass(self.effectiveStyle))
		{
			[self _setupForGlassButton];
		}
	}
	if(self.effectiveStyle == LNPopupCloseButtonStyleRound)
	{
		[self _setupForCircularButton];
	}
	else if(self.effectiveStyle == LNPopupCloseButtonStyleChevron || self.effectiveStyle == LNPopupCloseButtonStyleGrabber)
	{
		[self _setupForChevronButton];
	}
}

- (void)setPositioning:(LNPopupCloseButtonPositioning)positioning
{
	[self.popupContentView setPopupCloseButtonPositioning:positioning];
}

- (void)_setPositioning:(LNPopupCloseButtonPositioning)positioning
{
	_positioning = positioning;
}

- (UIVisualEffectView*)backgroundView
{
	return _effectView;
}

- (void)_cleanup
{
	if(@available(iOS 21.0, *))
	{
		self.configuration = nil;
	}
	
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
	self.layer.masksToBounds = NO;
}

static CGFloat LNPopupCloseButtonGrabberWidth(void)
{
	static CGFloat rv;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		rv = LNPopupEnvironmentHasGlass() ? 70 : 42;
	});
	return rv;
}

- (void)_setupForChevronButton
{
	self.layer.masksToBounds = YES;
	
	_chevronView = [[LNChevronView alloc] initWithFrame:CGRectZero];
	_chevronView.translatesAutoresizingMaskIntoConstraints = NO;
	
	_chevronView.width = 5.0;
	[_chevronView setState:self.effectiveStyle == LNPopupCloseButtonStyleGrabber ? LNChevronViewStateFlat : LNChevronViewStateUp animated:NO];
	
	self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	[self addSubview:_chevronView];
	
	[NSLayoutConstraint activateConstraints:@[
		[_chevronView.topAnchor constraintEqualToAnchor:self.topAnchor],
		[_chevronView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
		[_chevronView.widthAnchor constraintEqualToConstant:self.effectiveStyle == LNPopupCloseButtonStyleGrabber ? LNPopupCloseButtonGrabberWidth() : 40],
		[_chevronView.heightAnchor constraintEqualToConstant:self.effectiveStyle == LNPopupCloseButtonStyleGrabber ? 15 : 20],
	]];
}

- (void)_setupForCircularButton
{
	UIBlurEffectStyle blurStyle = UIBlurEffectStyleSystemChromeMaterial;
	
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
	
	self.tintColor = [UIColor labelColor];
	[self setTitleColor:self.tintColor forState:UIControlStateNormal];
	
	UIImageSymbolConfiguration* config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightHeavy scale:UIImageSymbolScaleSmall];
	UIImage* image = [[UIImage systemImageNamed:@"chevron.down" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	[self setImage:image forState:UIControlStateNormal];
}

- (void)_setupForGlassButton API_AVAILABLE(ios(26.0))
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_18_5
	UIButtonConfiguration* glassConfig;
	switch(self.effectiveStyle)
	{
		case LNPopupCloseButtonStyleGlass:
			glassConfig = UIButtonConfiguration.glassButtonConfiguration;
			break;
		case LNPopupCloseButtonStyleClearGlass:
			glassConfig = UIButtonConfiguration.clearGlassButtonConfiguration;
			break;
		case LNPopupCloseButtonStyleProminentGlass:
			glassConfig = UIButtonConfiguration.prominentGlassButtonConfiguration;
			break;
		case LNPopupCloseButtonStyleProminentClearGlass:
			glassConfig = UIButtonConfiguration.prominentClearGlassButtonConfiguration;
			break;
		case LNPopupCloseButtonStyleShinyGlass:
			static NSString* const shinyGlassConfig = LNPopupHiddenString("_posterSwitcherGlassButtonConfiguration");
			if([UIButtonConfiguration respondsToSelector:NSSelectorFromString(shinyGlassConfig)])
			{
				glassConfig = [UIButtonConfiguration valueForKey:shinyGlassConfig];
			}
			else
			{
				glassConfig = UIButtonConfiguration.glassButtonConfiguration;
			}
			break;
		default:
			return;
			break;
	}
	glassConfig.image = [UIImage systemImageNamed:@"xmark"];
	glassConfig.preferredSymbolConfigurationForImage = [UIImageSymbolConfiguration configurationWithPointSize:17];
	self.configuration = glassConfig;
#endif
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
	if(self.effectiveStyle == LNPopupCloseButtonStyleRound)
	{
		dispatch_block_t alphaBlock = ^{
			_highlightView.alpha = highlighted ? 1.0 : 0.0;
			_highlightView.alpha = highlighted ? 1.0 : 0.0;
		};
		
		if(animated)
		{
			[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
				alphaBlock();
			} completion:nil];
		}
		else
		{
			alphaBlock();
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if(self.effectiveStyle == LNPopupCloseButtonStyleRound)
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
	if(_LNPopupCloseButtonStyleIsGlass(self.effectiveStyle))
	{
		return CGSizeMake(44, 44);
	}
	else if(self.effectiveStyle == LNPopupCloseButtonStyleRound)
	{
		return CGSizeMake(24, 24);
	}
	else if(self.effectiveStyle == LNPopupCloseButtonStyleChevron)
	{
		return CGSizeMake(42, 25);
	}
	else
	{
		return CGSizeMake(LNPopupCloseButtonGrabberWidth(), 25);
	}
}

- (CGSize)intrinsicContentSize
{
	return [self sizeThatFits:CGSizeZero];
}

- (void)_setButtonContainerStationary
{
	if(self.effectiveStyle != LNPopupCloseButtonStyleChevron)
	{
		return;
	}
	
	[_chevronView setState:LNChevronViewStateUp animated:YES];
}

- (void)_setButtonContainerTransitioning
{
	if(self.effectiveStyle != LNPopupCloseButtonStyleChevron)
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
	[super tintColorDidChange];
	
	if(_LNPopupCloseButtonStyleIsGlass(self.effectiveStyle) == NO)
	{
		[self setTitleColor:self.tintColor forState:UIControlStateNormal];
	}
}

@end
