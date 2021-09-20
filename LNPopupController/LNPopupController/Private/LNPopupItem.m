//
//  LNPopupItem.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupItem+Private.h"
#import "LNPopupController.h"

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

+(void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__LNPopupItemObservedKeys = @[
			NSStringFromSelector(@selector(title)),
			NSStringFromSelector(@selector(subtitle)),
			NSStringFromSelector(@selector(attributedTitle)),
			NSStringFromSelector(@selector(attributedSubtitle)),
			NSStringFromSelector(@selector(image)),
			NSStringFromSelector(@selector(progress)),
			NSStringFromSelector(@selector(leadingBarButtonItems)),
			NSStringFromSelector(@selector(trailingBarButtonItems)),
			NSStringFromSelector(@selector(accessibilityLabel)),
			NSStringFromSelector(@selector(accessibilityHint)),
			NSStringFromSelector(@selector(accessibilityImageLabel)),
			NSStringFromSelector(@selector(accessibilityProgressLabel)),
			NSStringFromSelector(@selector(accessibilityProgressValue)),
			NSStringFromSelector(@selector(swiftuiImageController)),
			NSStringFromSelector(@selector(swiftuiTitleController)),
			NSStringFromSelector(@selector(swiftuiSubtitleController)),
			NSStringFromSelector(@selector(standardAppearance))
		];
	});
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		[__LNPopupItemObservedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self addObserver:self forKeyPath:obj options:0 context:_LNPopupItemObservationContext];
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
		[self._itemDelegate _popupItem:self didChangeValueForKey:keyPath];
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
	
	[self willChangeValueForKey:@"title"];
	
	self.attributedTitle = nil;
	_title = [title copy];
	
	[self didChangeValueForKey:@"title"];
}

- (void)setSubtitle:(NSString *)subtitle
{
	if(_subtitle == subtitle || [_subtitle isEqualToString:subtitle])
	{
		return;
	}
	
	[self willChangeValueForKey:@"subtitle"];
	
	self.attributedSubtitle = nil;
	_subtitle = [subtitle copy];
	
	[self didChangeValueForKey:@"subtitle"];
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
	
	[self willChangeValueForKey:@"attributedTitle"];
	
	self.title = [attributedTitle.string copy];
	_attributedTitle = [attributedTitle copy];;
	
	[self didChangeValueForKey:@"attributedTitle"];
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
	
	[self willChangeValueForKey:@"attributedSubtitle"];
	
	self.subtitle = [attributedSubtitle.string copy];
	_attributedSubtitle = [attributedSubtitle copy];
	
	[self didChangeValueForKey:@"attributedSubtitle"];
}

- (void)setProgress:(float)progress
{
	[self willChangeValueForKey:NSStringFromSelector(_cmd)];
	if(progress > 1.0) { progress = 1.0; }
	if(progress < 0.0) { progress = 0.0; }
	_progress = progress;
	[self didChangeValueForKey:NSStringFromSelector(_cmd)];
}

- (NSArray<UIBarButtonItem *> *)barButtonItems
{
	return self.trailingBarButtonItems;
}

- (void)setBarButtonItems:(NSArray<UIBarButtonItem *> *)barButtonItems
{
	self.trailingBarButtonItems = barButtonItems;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation LNPopupItem (Deprecated)

- (NSArray<UIBarButtonItem *> *)leftBarButtonItems
{
	return self.leadingBarButtonItems;
}

- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems
{
	self.leadingBarButtonItems = leftBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)rightBarButtonItems
{
	return self.trailingBarButtonItems;
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems
{
	self.trailingBarButtonItems = rightBarButtonItems;
}

@end

#pragma clang diagnostic pop
