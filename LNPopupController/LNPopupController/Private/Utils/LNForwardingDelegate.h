//
//  LNForwardingDelegate.h
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNForwardingDelegate : NSObject

@property (nonatomic, weak) id forwardedDelegate;

+ (BOOL)isCallerUIKit:(NSArray*)callStackReturnAddresses;

@end
