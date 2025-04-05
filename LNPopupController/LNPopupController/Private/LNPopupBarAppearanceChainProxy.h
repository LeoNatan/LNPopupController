//
//  LNPopupBarAppearanceChainProxy.h
//  LNPopupBarAppearanceChainProxy
//
//  Created by Léo Natan on 2021-08-07.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBarAppearance+Private.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface LNPopupBarAppearanceChainProxy : NSObject

@property (nonatomic, strong) NSArray<UIBarAppearance*>* chain API_AVAILABLE(ios(13.0));

- (instancetype)initWithAppearanceChain:(NSArray<UIBarAppearance*>*)chain API_AVAILABLE(ios(13.0));
- (id)objectForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (NSUInteger)unsignedIntegerForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;

- (void)setChainDelegate:(nullable id<_LNPopupBarAppearanceDelegate>)delegate;

@end


NS_ASSUME_NONNULL_END
