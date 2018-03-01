//
//  _LNWeakRef.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _LNWeakRef : NSObject

@property (nonatomic, weak, readonly) id object;

+ (instancetype)refWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
