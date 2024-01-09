//
//  LNPopupBarAppearanceChainProxy.h
//  LNPopupBarAppearanceChainProxy
//
//  Created by Leo Natan on 8/7/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

@import UIKit;
#import "LNPopupBarAppearance+Private.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface LNPopupBarAppearanceChainProxy : NSObject

@property (nonatomic, strong) NSArray<UIBarAppearance*>* chain;

- (instancetype)initWithAppearanceChain:(NSArray<UIBarAppearance*>*)chain;
- (id)objectForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (NSUInteger)unsignedIntegerForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;

- (void)setChainDelegate:(nullable id<_LNPopupBarAppearanceDelegate>)delegate;

@end


NS_ASSUME_NONNULL_END
