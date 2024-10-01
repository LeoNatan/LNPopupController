//
//  LNPopupDemoContextMenuInteraction.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2021-12-17.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNPopupDemoContextMenuInteraction : UIContextMenuInteraction

- (instancetype)init;
- (instancetype)initWithTitle:(BOOL)title;
+ (instancetype)new;

@end

NS_ASSUME_NONNULL_END
