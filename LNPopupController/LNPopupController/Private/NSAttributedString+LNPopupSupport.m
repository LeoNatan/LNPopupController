//
//  NSAttributedString+LNPopupSupport.m
//  LNPopupController
//
//  Created by Leo Natan on 9/19/21.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
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
