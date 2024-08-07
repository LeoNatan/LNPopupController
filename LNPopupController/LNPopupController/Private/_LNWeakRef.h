//
//  _LNWeakRef.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNWeakRef : NSObject

@property (nonatomic, weak, readonly) id object;

+ (instancetype)refWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
