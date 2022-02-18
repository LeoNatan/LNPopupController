//
//  _LNPopupSwizzlingUtils.m
//  LNPopupController
//
//  Created by Leo Natan on 1/14/18.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "_LNPopupSwizzlingUtils.h"

NSString* _LNPopupDecodeBase64String(NSString* base64String)
{
	return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64String options:0] encoding:NSUTF8StringEncoding];
}
