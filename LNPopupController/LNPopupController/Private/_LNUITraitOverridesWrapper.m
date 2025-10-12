//
//  _LNUITraitOverridesWrapper.m
//  LNPopupController
//
//  Created by Léo Natan on 12/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNUITraitOverridesWrapper.h"
#import "LNPopupContentView+Private.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation _LNUITraitOverridesWrapper
{
	id<UITraitOverrides> _traitOverrides;
	LNPopupContentView* _contentView;
}

- (instancetype)initWithTraitOverrides:(id<UITraitOverrides>)traitOverrides contentView:(LNPopupContentView*)contentView
{
	self = [super init];
	if(self)
	{
		_traitOverrides = traitOverrides;
		_contentView = contentView;
	}
	return self;
}

- (UIUserInterfaceStyle)userInterfaceStyle
{
	return _contentView.userUserInterfaceStyleTraitModifier;
}

- (void)setUserInterfaceStyle:(UIUserInterfaceStyle)userInterfaceStyle
{
	_contentView.userUserInterfaceStyleTraitModifier = userInterfaceStyle;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return _traitOverrides;
}

- (NSString *)description
{
	return _traitOverrides.description;
}

- (NSString *)debugDescription
{
	return _traitOverrides.debugDescription;
}

#pragma clang diagnostic pop

@end
