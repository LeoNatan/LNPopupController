//
//  _LNPopupAddressInfo.h
//  LNPopupController
//
//  Created by Léo Natan on 2024-08-09.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupAddressInfo : NSObject

- (instancetype)initWithAddress:(NSUInteger)address;

@property (nonatomic, readonly) NSUInteger address;
@property (nonatomic, copy, readonly) NSString* image;
@property (nonatomic, copy, readonly) NSString* symbol;
@property (nonatomic, readonly) NSUInteger offset;

@end

NS_ASSUME_NONNULL_END
