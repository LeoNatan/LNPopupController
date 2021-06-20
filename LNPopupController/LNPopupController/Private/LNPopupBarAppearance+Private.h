//
//  LNPopupBarAppearance+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 6/9/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBarAppearance.h>

@protocol _LNPopupBarAppearanceDelegate <NSObject>

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance;

@end

@interface LNPopupBarAppearance ()

@property (nonatomic, weak) id<_LNPopupBarAppearanceDelegate> delegate;

@end

@interface _LNPopupBarAppearanceChainProxy : NSObject

- (instancetype)initWithAppearanceChain:(NSArray<UIBarAppearance*>*)chain;
- (id)objectForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (NSUInteger)unsignedIntegerForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;

- (void)setChainDelegate:(id<_LNPopupBarAppearanceDelegate>)delegate;

@end
