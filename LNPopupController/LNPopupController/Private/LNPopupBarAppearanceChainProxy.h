//
//  LNPopupBarAppearanceChainProxy.h
//  LNPopupBarAppearanceChainProxy
//
//  Created by Léo Natan on 2021-08-07.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBarAppearance+Private.h"

NS_ASSUME_NONNULL_BEGIN

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
