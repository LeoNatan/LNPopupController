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

@implementation LNPopupItem

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		[self addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:0 context:_LNPopupItemObservationContext];
		[self addObserver:self forKeyPath:NSStringFromSelector(@selector(subtitle)) options:0 context:_LNPopupItemObservationContext];
		[self addObserver:self forKeyPath:NSStringFromSelector(@selector(progress)) options:0 context:_LNPopupItemObservationContext];
		[self addObserver:self forKeyPath:NSStringFromSelector(@selector(leftBarButtonItems)) options:0 context:_LNPopupItemObservationContext];
		[self addObserver:self forKeyPath:NSStringFromSelector(@selector(rightBarButtonItems)) options:0 context:_LNPopupItemObservationContext];
	}
	
	return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(title)) context:_LNPopupItemObservationContext];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(subtitle)) context:_LNPopupItemObservationContext];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(progress)) context:_LNPopupItemObservationContext];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(leftBarButtonItems)) context:_LNPopupItemObservationContext];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(rightBarButtonItems)) context:_LNPopupItemObservationContext];
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
