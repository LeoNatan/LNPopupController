//
//  UITabBar+LNPopupMinimizationSupport.h
//  LNPopupController
//
//  Created by Léo Natan on 26/9/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LNPopupBar;

extern BOOL LNPopupEnvironmentTabBarSupportsMinimizationAPI(void);

@protocol _LNPopupTabBarMinimizationDelegate <NSObject>

- (void)tabBar:(UITabBar*)tabBar didMinimize:(BOOL)wasMinimized;

@end

@interface UITabBar (LNPopupMinimizationSupport)

@property (nonatomic, readonly, getter=_ln_wantsMinimizedPopupBar) BOOL requiresMinimizedPopupBar;
@property (nonatomic, readonly, getter =_ln_proposedFrameForPopupBar) CGRect proposedFrameForPopupBar;

@property (nonatomic, weak, nullable, getter=_ln_minimizationDelegate, setter=_ln_setMinimizationDelegate:) id<_LNPopupTabBarMinimizationDelegate> minimizationDelegate;

@end

@interface UITabBarController (LNPopupMinimizationSupport)

- (NSDirectionalEdgeInsets)_ln_popupBarMarginsForPopupBar:(LNPopupBar*)popupBar;

@end

NS_ASSUME_NONNULL_END
