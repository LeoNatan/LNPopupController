//
//  LNPopupItem.m
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import "LNPopupItem+Private.h"
#import "LNPopupController.h"

static void* _LNPopupItemObservationContext = &_LNPopupItemObservationContext;

static NSArray* __keys;

@implementation LNPopupItem

@synthesize accessibilityImageLabel = _accessibilityImageLabel;
@synthesize accessibilityProgressLabel = _accessibilityProgressLabel;
@synthesize accessibilityProgressValue = _accessibilityProgressValue;

+(void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__keys = @[NSStringFromSelector(@selector(title)), NSStringFromSelector(@selector(subtitle)), NSStringFromSelector(@selector(image)), NSStringFromSelector(@selector(progress)), NSStringFromSelector(@selector(leftBarButtonItems)), NSStringFromSelector(@selector(rightBarButtonItems)), NSStringFromSelector(@selector(accessibilityLabel)), NSStringFromSelector(@selector(accessibilityHint)), NSStringFromSelector(@selector(accessibilityImageLabel)), NSStringFromSelector(@selector(accessibilityProgressLabel)), NSStringFromSelector(@selector(accessibilityProgressValue))];
	});
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		[__keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self addObserver:self forKeyPath:obj options:0 context:_LNPopupItemObservationContext];
		}];
	}
	
	return self;
}

- (void)dealloc
{
	[__keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)setProgress:(float)progress
{
	[self willChangeValueForKey:NSStringFromSelector(_cmd)];
	if(progress > 1.0) { progress = 1.0; }
	_progress = progress;
	[self didChangeValueForKey:NSStringFromSelector(_cmd)];
}

@end
