//
//  _LNPopupTitlesController.h
//  LNPopupController
//
//  Created by Léo Natan on 16/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;
@class LNPopupItem;

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupTitlesController : UIViewController

- (instancetype)initWithPopupBar:(LNPopupBar*)popupBar;
- (instancetype)initWithPopupBar:(LNPopupBar*)popupBar popupItem:(nullable LNPopupItem*)popupItem;

@property (nonatomic, weak, nullable, readonly) LNPopupBar* popupBar;
@property (nonatomic, strong, nullable) LNPopupItem* popupItem;

@property (nonatomic) CGFloat spacing;

@property (nonatomic, readonly) NSUInteger numberOfLabels;
@property (nonatomic, readonly) CGFloat heightFittingTitleLabel;
@property (nonatomic, readonly) CGFloat heightFittingSubtitleLabel;

@property (nonatomic, getter=isMarqueePaused) BOOL marqueePaused;

- (void)setNeedsTitleLayoutRemovingLabels:(BOOL)remove;
- (void)updateAccessibility;

@end

NS_ASSUME_NONNULL_END
