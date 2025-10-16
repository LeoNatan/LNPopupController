//
//  _LNPopupTitlesController.h
//  LNPopupController
//
//  Created by Léo Natan on 16/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTitlesController : UIViewController

- (instancetype)initWithPopupBar:(LNPopupBar*)popupBar;

@property (nonatomic) CGFloat spacing;

@property (nonatomic, readonly) NSUInteger numberOfLabels;
@property (nonatomic, readonly) CGFloat heightFittingTitleLabel;
@property (nonatomic, readonly) CGFloat heightFittingSubtitleLabel;

@property (nonatomic, getter=isMarqueePaused) BOOL marqueePaused;

- (void)layoutTitlesRemovingLabels:(BOOL)remove;
- (void)updateAccessibility;

@end

NS_ASSUME_NONNULL_END
