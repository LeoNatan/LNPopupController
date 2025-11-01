//
//  _LNPopupTitlesPagingController.h
//  LNPopupController
//
//  Created by Léo Natan on 16/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTitlesPagingController : UIPageViewController

- (instancetype)initWithPopupBar:(LNPopupBar*)popupBar;

@property (nonatomic) BOOL pagingEnabled;

@end

NS_ASSUME_NONNULL_END
