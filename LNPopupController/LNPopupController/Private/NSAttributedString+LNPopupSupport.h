//
//  NSAttributedString+LNPopupSupport.h
//  LNPopupController
//
//  Created by Leo Natan on 9/19/21.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (LNPopupSupport)

+ (instancetype)ln_attributedStringWithAttributedString:(NSAttributedString*)orig defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id>*)attribs;

@end

NS_ASSUME_NONNULL_END
