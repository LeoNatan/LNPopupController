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

- (void)setFloatingBackgroundColor:(UIColor *)floatingBackgroundColor
{
	_floatingBackgroundColor = floatingBackgroundColor;
	
	[self _notify];
}

- (void)setFloatingBackgroundImage:(UIImage *)floatingBackgroundImage
{
	_floatingBackgroundImage = floatingBackgroundImage;
	
	[self _notify];
}

-(void)setFloatingBackgroundEffect:(UIBlurEffect *)floatingBackgroundEffect
{
	_floatingBackgroundEffect = floatingBackgroundEffect;
	
	[self _notify];
}

-(void)setFloatingBackgroundImageContentMode:(UIViewContentMode)floatingBackgroundImageContentMode
{
	_floatingBackgroundImageContentMode = floatingBackgroundImageContentMode;
	
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
		
		[self configureWithDefaultFloatingBackground];

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
	
	[coder encodeObject:self.floatingBackgroundEffect forKey:@"floatingBackgroundEffect"];
	[coder encodeObject:self.floatingBackgroundColor forKey:@"floatingBackgroundColor"];
	[coder encodeObject:self.floatingBackgroundImage forKey:@"floatingBackgroundImage"];
	[coder encodeInteger:self.floatingBackgroundImageContentMode forKey:@"floatingBackgroundImageContentMode"];
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
		
		self.floatingBackgroundEffect = [coder decodeObjectForKey:@"floatingBackgroundEffect"];
		self.floatingBackgroundColor = [coder decodeObjectForKey:@"floatingBackgroundColor"];
		self.floatingBackgroundImage = [coder decodeObjectForKey:@"floatingBackgroundImage"];
		self.floatingBackgroundImageContentMode = [coder decodeIntegerForKey:@"floatingBackgroundImageContentMode"];
		
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
		
		self.floatingBackgroundColor = other.floatingBackgroundColor;
		self.floatingBackgroundImage = other.floatingBackgroundImage;
		self.floatingBackgroundEffect = other.floatingBackgroundEffect;
		self.floatingBackgroundImageContentMode = other.floatingBackgroundImageContentMode;
		
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
	
	copy.floatingBackgroundColor = self.floatingBackgroundColor;
	copy.floatingBackgroundImage = self.floatingBackgroundImage;
	copy.floatingBackgroundEffect = self.floatingBackgroundEffect;
	copy.floatingBackgroundImageContentMode = self.floatingBackgroundImageContentMode;
	
	return copy;
}

- (BOOL)isEqual:(LNPopupBarAppearance*)other
{
	if([other isKindOfClass:LNPopupBarAppearance.class] == NO)
	{
		return NO;
	}
	
	BOOL rv = [super isEqual:other];
	
	NSLog(@" 0: %@", @(rv));
	
	rv = rv && [self.titleTextAttributes isEqualToDictionary:other.titleTextAttributes];
	NSLog(@" 1: %@", @(rv));
	rv = rv && [self.subtitleTextAttributes isEqualToDictionary:other.subtitleTextAttributes];
	NSLog(@" 2: %@", @(rv));
	rv = rv && [self.buttonAppearance isEqual:other.buttonAppearance];
	NSLog(@" 3: %@", @(rv));
	rv = rv && [self.doneButtonAppearance isEqual:other.doneButtonAppearance];
	NSLog(@" 4: %@", @(rv));
	rv = rv && (self.marqueeScrollEnabled == other.marqueeScrollEnabled);
	NSLog(@" 5: %@", @(rv));
	rv = rv && (self.marqueeScrollRate == other.marqueeScrollRate);
	NSLog(@" 6: %@", @(rv));
	rv = rv && (self.marqueeScrollDelay == other.marqueeScrollDelay);
	NSLog(@" 7: %@", @(rv));
	rv = rv && (self.coordinateMarqueeScroll == other.coordinateMarqueeScroll);
	NSLog(@" 8: %@", @(rv));
	rv = rv && [self.highlightColor isEqual:other.highlightColor];
	NSLog(@" 9: %@", @(rv));
	rv = rv && [self.floatingBackgroundColor isEqual:other.floatingBackgroundColor];
	NSLog(@"10: %@", @(rv));
	rv = rv && [self.floatingBackgroundImage isEqual:other.floatingBackgroundImage];
	NSLog(@"11: %@", @(rv));
	rv = rv && [self.floatingBackgroundEffect isEqual:other.floatingBackgroundEffect];
	NSLog(@"12: %@", @(rv));
	rv = rv && (self.floatingBackgroundImageContentMode == other.floatingBackgroundImageContentMode);
	NSLog(@"13: %@", @(rv));
	
	return rv;
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
			return [UIColor.systemGray3Color colorWithAlphaComponent:0.25];
		}
	}];
	
	[self _notify];
}

- (void)configureWithDefaultMarqueeScroll
{
	_marqueeScrollEnabled = YES;
	_marqueeScrollRate = 30;
	_marqueeScrollDelay = 2.0;
	_coordinateMarqueeScroll = YES;
	
	[self _notify];
}

- (void)configureWithDisabledMarqueeScroll
{
	_marqueeScrollEnabled = NO;
	
	[self _notify];
}

- (void)configureWithDefaultFloatingBackground
{
	UIBarAppearance* temp = [UIBarAppearance new];
	[temp configureWithDefaultBackground];
	
	self.floatingBackgroundColor = temp.backgroundColor;
	self.floatingBackgroundImage = temp.backgroundImage;
	self.floatingBackgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
	self.floatingBackgroundImageContentMode = temp.backgroundImageContentMode;
	
	[self _notify];
}

- (void)configureWithOpaqueFloatingBackground
{
	UIBarAppearance* temp = [UIBarAppearance new];
	[temp configureWithOpaqueBackground];
	
	self.floatingBackgroundColor = temp.backgroundColor;
	self.floatingBackgroundImage = temp.backgroundImage;
	self.floatingBackgroundEffect = temp.backgroundEffect;
	self.floatingBackgroundImageContentMode = temp.backgroundImageContentMode;
	
	[self _notify];
}

- (void)configureWithTransparentFloatingBackground;
{
	UIBarAppearance* temp = [UIBarAppearance new];
	[temp configureWithTransparentBackground];
	
	self.floatingBackgroundColor = temp.backgroundColor;
	self.floatingBackgroundImage = temp.backgroundImage;
	self.floatingBackgroundEffect = temp.backgroundEffect;
	self.floatingBackgroundImageContentMode = temp.backgroundImageContentMode;
	
	[self _notify];
}

@end
