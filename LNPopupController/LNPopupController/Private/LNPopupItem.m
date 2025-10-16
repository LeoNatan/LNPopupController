//
//  LNPopupItem.m
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupItem+Private.h"
#import "LNPopupControllerImpl.h"
#import "_LNPopupSwizzlingUtils.h"

static void* _LNPopupItemObservationContext = &_LNPopupItemObservationContext;

NSArray* __LNPopupItemObservedKeys;

@implementation LNPopupItem

@synthesize accessibilityImageLabel = _accessibilityImageLabel;
@synthesize accessibilityProgressLabel = _accessibilityProgressLabel;
@synthesize accessibilityProgressValue = _accessibilityProgressValue;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize attributedTitle = _attributedTitle;
@synthesize attributedSubtitle = _attributedSubtitle;

+(void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__LNPopupItemObservedKeys = [LNPopupGetPropertyNames(self, nil, NO) arrayByAddingObjectsFromArray:@[@"accessibilityHint", @"accessibilityLabel"]];
	});
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		[__LNPopupItemObservedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew context:_LNPopupItemObservationContext];
		}];
	}
	
	return self;
}

- (void)dealloc
{
	[__LNPopupItemObservedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self removeObserver:self forKeyPath:obj context:_LNPopupItemObservationContext];
	}];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context
{
	if(context == _LNPopupItemObservationContext)
	{
		id value = change[NSKeyValueChangeNewKey];
		if([value isKindOfClass:NSNull.class])
		{
			value = nil;
		}
		[self._itemDelegate _popupItem:self didChangeToValue:value forKey:keyPath];
	}
}

- (NSString *)title
{
	if(_title == nil && _subtitle == nil)
	{
		return self._containerController.title;
	}
	
	return _title;
}

- (void)setTitle:(NSString *)title
{
	if(_title == title || [_title isEqualToString:title])
	{
		return;
	}
	
	_attributedTitle = nil;
	_title = [title copy];
	
	if(self.swiftuiTitleContentView != nil)
	{
		self.swiftuiTitleContentView = nil;
	}
}

- (NSAttributedString *)attributedTitle
{
	return _attributedTitle ?: self.title ? [[NSAttributedString alloc] initWithString:self.title] : nil;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
	if(_attributedTitle == attributedTitle || [_attributedTitle isEqualToAttributedString:attributedTitle])
	{
		return;
	}
	
	_title = nil;
	_attributedTitle = [attributedTitle copy];
	
	if(self.swiftuiTitleContentView != nil)
	{
		self.swiftuiTitleContentView = nil;
	}
}

- (void)setSubtitle:(NSString *)subtitle
{
	if(_subtitle == subtitle || [_subtitle isEqualToString:subtitle])
	{
		return;
	}
	
	_attributedSubtitle = nil;
	_subtitle = [subtitle copy];
	
	if(self.swiftuiTitleContentView != nil)
	{
		self.swiftuiTitleContentView = nil;
	}
}

- (NSAttributedString *)attributedSubtitle
{
	return _attributedSubtitle ?: self.subtitle ? [[NSAttributedString alloc] initWithString:self.subtitle] : nil;
}

- (void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
	if(_attributedSubtitle == attributedSubtitle || [_attributedSubtitle isEqualToAttributedString:attributedSubtitle])
	{
		return;
	}
	
	_subtitle = nil;
	_attributedSubtitle = [attributedSubtitle copy];
	
	if(self.swiftuiTitleContentView != nil)
	{
		self.swiftuiTitleContentView = nil;
	}
}

- (void)setSwiftuiTitleContentView:(UIView *)swiftuiTitleContentView
{
	_swiftuiTitleContentView = swiftuiTitleContentView;
	
	if(self.title != nil)
	{
		self.title = nil;
	}
	if(self.attributedTitle != nil)
	{
		self.attributedTitle = nil;
	}
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	
	if(self.swiftuiImageController != nil)
	{
		self.swiftuiImageController = nil;
	}
}

- (void)setSwiftuiImageController:(UIViewController *)swiftuiImageController
{
	_swiftuiImageController = swiftuiImageController;
	
	if(self.image != nil)
	{
		self.image = nil;
	}
}

- (void)setProgress:(float)progress
{
	if(progress > 1.0) { progress = 1.0; }
	if(progress < 0.0) { progress = 0.0; }
	_progress = progress;
}

- (NSArray<UIBarButtonItem *> *)barButtonItems
{
	return self.trailingBarButtonItems;
}

- (void)setBarButtonItems:(NSArray<UIBarButtonItem *> *)barButtonItems
{
	self.trailingBarButtonItems = barButtonItems;
}

- (void)setBarButtonItems:(NSArray<UIBarButtonItem *> *)barButtonItems animated:(BOOL)animated
{
	[LNPopupBar setAnimatesItemSetter:animated];
	
	[self setBarButtonItems:barButtonItems];
	
	[LNPopupBar setAnimatesItemSetter:NO];
}

- (void)setLeadingBarButtonItems:(NSArray<UIBarButtonItem *> *)leadingBarButtonItems animated:(BOOL)animated
{
	[LNPopupBar setAnimatesItemSetter:animated];
	
	[self setLeadingBarButtonItems:leadingBarButtonItems];
	
	[LNPopupBar setAnimatesItemSetter:NO];
}

- (void)setTrailingBarButtonItems:(NSArray<UIBarButtonItem *> *)trailingBarButtonItems animated:(BOOL)animated
{
	[LNPopupBar setAnimatesItemSetter:animated];
	
	[self setTrailingBarButtonItems:trailingBarButtonItems];
	
	[LNPopupBar setAnimatesItemSetter:NO];
}

@end
