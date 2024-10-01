//
//  NSAttributedString+LNPopupSupport.m
//  LNPopupController
//
//  Created by Léo Natan on 2021-09-19.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "NSAttributedString+LNPopupSupport.h"

@implementation NSAttributedString (LNPopupSupport)

+ (instancetype)ln_attributedStringWithAttributedString:(NSAttributedString*)orig defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id>*)attribs
{
	NSMutableAttributedString* rv = [[NSMutableAttributedString alloc] initWithString:orig.string attributes:attribs];
	
	[orig enumerateAttributesInRange:NSMakeRange(0, orig.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
		[rv addAttributes:attrs range:range];
	}];
	
	return rv;
}

@end
