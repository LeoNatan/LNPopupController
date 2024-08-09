//
//  LNAddressInfo.h
//  LNPopupController
//
//  Created by Léo Natan on 9/8/24.
//  Copyright © 2024 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNAddressInfo : NSObject

- (instancetype)initWithAddress:(NSUInteger)address;

@property (nonatomic, readonly) NSUInteger address;
@property (nonatomic, copy, readonly) NSString* image;
@property (nonatomic, copy, readonly) NSString* symbol;
@property (nonatomic, readonly) NSUInteger offset;

- (NSString*)formattedDescriptionForIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
