//
//  LNPopupBarAppearance.m
//  LNPopupController
//
//  Created by Leo Natan on 6/9/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "LNPopupBarAppearance+Private.h"
#import "_LNPopupSwizzlingUtils.h"

//appearance:categoriesChanged:
static NSString* const aCC = @"YXBwZWFyYW5jZTpjYXRlZ29yaWVzQ2hhbmdlZDo=";
//changeObserver
static NSString* const cO = @"Y2hhbmdlT2JzZXJ2ZXI=";

@implementation _LNPopupBarAppearanceChainProxy
{
	NSArray<UIBarAppearance*>* _chain;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p chain: %@>", self.class, self, _chain];
}

- (instancetype)initWithAppearanceChain:(NSArray<UIBarAppearance*>*)chain
{
	self = [super init];
	
	if(self)
	{
		_chain = chain;
	}
	
	return self;
}

- (id)objectForKey:(NSString*)key
{
	__block id rv = nil;
	
	[_chain enumerateObjectsUsingBlock:^(UIBarAppearance * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		id candidateRV;
		if([obj respondsToSelector:NSSelectorFromString(key)])
		{
			candidateRV = [obj valueForKey:key];
			rv = candidateRV;
			*stop = YES;
		}
	}];
	
	return rv;
}

- (BOOL)boolForKey:(NSString*)key
{
	return [[self objectForKey:key] boolValue];
}

- (NSUInteger)unsignedIntegerForKey:(NSString*)key
{
	return [[self objectForKey:key] unsignedIntegerValue];
}

- (double)doubleForKey:(NSString*)key
{
	return [[self objectForKey:key] doubleValue];
}

- (void)setChainDelegate:(id<_LNPopupBarAppearanceDelegate>)delegate
{
	for (LNPopupBarAppearance* appearance in _chain) {
		if([appearance isKindOfClass:LNPopupBarAppearance.class])
		{
			appearance.delegate = delegate;
		}
	}
}

@end

@implementation LNPopupBarAppearance

+ (void)load
{
	@autoreleasepool
	{
		Method m1 = class_getInstanceMethod(self, @selector(a:cC:));
		class_addMethod(self, NSSelectorFromString(_LNPopupDecodeBase64String(aCC)), method_getImplementation(m1), method_getTypeEncoding(m1));
	}
}

- (void)_notify
{
	[self.delegate popupBarAppearanceDidChange:self];
}

//appearance:categoriesChanged:
- (void)a:(UIBarAppearance *)arg1 cC:(NSUInteger)arg2
{
	[self _notify];
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
	_titleTextAttributes = [titleTextAttributes copy];
	
	[self _notify];
}

- (void)setSubtitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)subtitleTextAttributes
{
	_subtitleTextAttributes = [subtitleTextAttributes copy];
	
	[self _notify];
}

- (void)setButtonAppearance:(UIBarButtonItemAppearance *)buttonAppearance
{
	_buttonAppearance = [buttonAppearance copy];
	
	[self _notify];
}

- (void)setDoneButtonAppearance:(UIBarButtonItemAppearance *)doneButtonAppearance
{
	_doneButtonAppearance = [doneButtonAppearance copy];
	
	[self _notify];
}

- (void)setMarqueeScrollEnabled:(BOOL)marqueeScrollEnabled
{
	_marqueeScrollEnabled = marqueeScrollEnabled;
	
	[self _notify];
}

- (void)setMarqueeScrollRate:(CGFloat)marqueeScrollRate
{
	_marqueeScrollRate = marqueeScrollRate;
	
	[self _notify];
}

- (void)setMarqueeScrollDelay:(NSTimeInterval)marqueeScrollDelay
{
	_marqueeScrollDelay = marqueeScrollDelay;
	
	[self _notify];
}

- (void)setCoordinateMarqueeScroll:(BOOL)coordinateMarqueeScroll
{
	_coordinateMarqueeScroll = coordinateMarqueeScroll;
	
	[self _notify];
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
	_highlightColor = highlightColor;
	
	[self _notify];
}

- (void)_commonInit
{
	//changeObserver
	[self setValue:self forKey:_LNPopupDecodeBase64String(cO)];
}

- (instancetype)initWithIdiom:(UIUserInterfaceIdiom)idiom
{
	self = [super initWithIdiom:UIUserInterfaceIdiomUnspecified];
	
	if(self)
	{
		[self configureWithDefaultBackground];
		
		[self configureWithDefaultHighlightColor];
		[self configureWithDefaultMarqueeScroll];
		[self configureWithDisabledMarqueeScroll];	

		[self _commonInit];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if(coder.allowsKeyedCoding == NO)
	{
		[NSException raise:NSInvalidArgumentException format:@"Only coders with allowsKeyedCoding=true supported."];
	}
	
	[super encodeWithCoder:coder];
	
	[coder encodeObject:self.titleTextAttributes forKey:@"titleTextAttributes"];
	[coder encodeObject:self.subtitleTextAttributes forKey:@"subtitleTextAttributes"];
	[coder encodeObject:self.buttonAppearance forKey:@"buttonAppearance"];
	[coder encodeObject:self.doneButtonAppearance forKey:@"doneButtonAppearance"];
	[coder encodeBool:self.marqueeScrollEnabled forKey:@"marqueeScrollEnabled"];
	[coder encodeDouble:self.marqueeScrollRate forKey:@"marqueeScrollRate"];
	[coder encodeDouble:self.marqueeScrollDelay forKey:@"marqueeScrollDelay"];
	[coder encodeBool:self.coordinateMarqueeScroll forKey:@"coordinateMarqueeScroll"];
	[coder encodeObject:self.highlightColor forKey:@"highlightColor"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if(coder.allowsKeyedCoding == NO)
	{
		[NSException raise:NSInvalidArgumentException format:@"Only coders with allowsKeyedCoding=true supported."];
		return nil;
	}
	
	self = [super initWithCoder:coder];
	
	if(self)
	{
		self.titleTextAttributes = [coder decodeObjectForKey:@"titleTextAttributes"];
		self.subtitleTextAttributes = [coder decodeObjectForKey:@"subtitleTextAttributes"];
		self.buttonAppearance = [coder decodeObjectForKey:@"buttonAppearance"];
		self.doneButtonAppearance = [coder decodeObjectForKey:@"doneButtonAppearance"];
		self.marqueeScrollEnabled = [coder decodeBoolForKey:@"marqueeScrollEnabled"];
		self.marqueeScrollRate = [coder decodeDoubleForKey:@"coordinateMarqueeScroll"];
		self.marqueeScrollDelay = [coder decodeDoubleForKey:@"marqueeScrollDelay"];
		self.coordinateMarqueeScroll = [coder decodeBoolForKey:@"coordinateMarqueeScroll"];
		self.highlightColor = [coder decodeObjectForKey:@"highlightColor"];
		
		[self _commonInit];
	}
	
	return self;
}

- (instancetype)initWithBarAppearance:(UIBarAppearance *)barAppearance
{
	self = [super initWithBarAppearance:barAppearance];
	
	if(self && [barAppearance isKindOfClass:LNPopupBarAppearance.class])
	{
		LNPopupBarAppearance* other = (LNPopupBarAppearance*)barAppearance;
		self.titleTextAttributes = other.titleTextAttributes;
		self.subtitleTextAttributes = other.subtitleTextAttributes;
		self.buttonAppearance = other.buttonAppearance;
		self.doneButtonAppearance = other.doneButtonAppearance;
		self.marqueeScrollEnabled = other.marqueeScrollEnabled;
		self.marqueeScrollRate = other.marqueeScrollRate;
		self.marqueeScrollDelay = other.marqueeScrollDelay;
		self.coordinateMarqueeScroll = other.coordinateMarqueeScroll;
		self.highlightColor = other.highlightColor;
		
		[self _commonInit];
	}
	
	return self;
}

- (instancetype)copy
{
	return [self copyWithZone:nil];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	LNPopupBarAppearance* copy = [super copyWithZone:zone];
	
	copy.titleTextAttributes = self.titleTextAttributes;
	copy.subtitleTextAttributes = self.subtitleTextAttributes;
	copy.buttonAppearance = self.buttonAppearance;
	copy.doneButtonAppearance = self.doneButtonAppearance;
	copy.marqueeScrollEnabled = self.marqueeScrollEnabled;
	copy.marqueeScrollRate = self.marqueeScrollRate;
	copy.marqueeScrollDelay = self.marqueeScrollDelay;
	copy.coordinateMarqueeScroll = self.coordinateMarqueeScroll;
	copy.highlightColor = self.highlightColor;
	
	return copy;
}

- (void)configureWithDefaultHighlightColor
{
	_highlightColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
		if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
		{
			return [UIColor.whiteColor colorWithAlphaComponent:0.15];
		}
		else
		{
			return [UIColor.systemGray2Color colorWithAlphaComponent:0.35];
		}
	}];
}

- (void)configureWithDefaultMarqueeScroll
{
	_marqueeScrollEnabled = YES;
	_marqueeScrollRate = 30;
	_marqueeScrollDelay = 2.0;
	_coordinateMarqueeScroll = YES;
}

- (void)configureWithDisabledMarqueeScroll
{
	_marqueeScrollEnabled = NO;
}

@end
