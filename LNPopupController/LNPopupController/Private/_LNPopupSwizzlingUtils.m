//
//  _LNPopupSwizzlingUtils.m
//  LNPopupController
//
//  Created by Léo Natan on 2018-01-15.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "_LNPopupSwizzlingUtils.h"
@import ObjectiveC;

NSArray<NSString*>* _LNPopupGetPropertyNames(Class cls, NSArray<NSString*>* excludedProperties)
{
	unsigned int propertyCount = 0;
	objc_property_t* properties = class_copyPropertyList(cls, &propertyCount);
	
	NSMutableArray* rv = [NSMutableArray new];
	for(unsigned int idx = 0; idx < propertyCount; idx++)
	{
		NSString* propertyName = @(property_getName(properties[idx]));
		if([excludedProperties containsObject:propertyName])
		{
			continue;
		}
		
		BOOL hasVar = NO;
		BOOL isWeak = NO;
		unsigned int attribCount = 0;
		objc_property_attribute_t* attribs = property_copyAttributeList(properties[idx], &attribCount);
		
		for(unsigned int idx2 = 0; idx2 < attribCount; idx2++)
		{
			if(strncmp(attribs[idx2].name, "V", 1) == 0 && strlen(attribs[idx2].value) > 0)
			{
				hasVar = YES;
			}
			
			if(strncmp(attribs[idx2].name, "W", 1) == 0)
			{
				isWeak = YES;
			}
		}
		
		free(attribs);
	
		if(hasVar && !isWeak)
		{
			[rv addObject:propertyName];
		}
	}
	
	free(properties);
	
	return rv;
}
