//
//  LNMarqueeLabelUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 23/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "LNMarqueeLabelUtils.h"

@implementation LNNonMarqueeLabel

@synthesize marqueeScrollEnabled, running, synchronizedLabels;

- (void)reset {}

@end

@implementation LNLegacyMarqueeLabel
{
	BOOL _enabled;
	NSHashTable<LNLegacyMarqueeLabel*>* _weakSynchronizedLabels;
}

- (id)initWithFrame:(CGRect)frame rate:(CGFloat)pixelsPerSec andFadeLength:(CGFloat)aFadeLength
{
	self = [super initWithFrame:frame rate:pixelsPerSec andFadeLength:aFadeLength];
	if(self)
	{
		_enabled = YES;
	}
	return self;
}

- (BOOL)isMarqueeScrollEnabled
{
	return _enabled;
}

-(void)setMarqueeScrollEnabled:(BOOL)marqueeScrollEnabled
{
	if(_enabled == marqueeScrollEnabled)
	{
		return;
	}
	
	_enabled = marqueeScrollEnabled;
	if(!_enabled)
	{
		[self shutdownLabel];
	}
	
	self.holdScrolling = !_enabled;
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
	}
	else
	{
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
