//
//  _LNPopupBase64Utils.m
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 1/14/18.
//  Copyright © 2018 Leo Natan. All rights reserved.
//

#import "_LNPopupBase64Utils.h"

NSString* _LNPopupDecodeBase64String(NSString* base64String)
{
	return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64String options:0] encoding:NSUTF8StringEncoding];
}
