//
//  UIView+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Leo Natan on 8/1/20.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;
@class LNPopupController;

NS_ASSUME_NONNULL_BEGIN

typedef void (^LNInWindowBlock)(dispatch_block_t);

@interface UIView (LNPopupSupportPrivate)

@property (nonatomic, weak, nullable) LNPopupController* attachedPopupController;

- (void)_ln_triggerBarAppearanceRefreshIfNeeded;
- (BOOL)_ln_scrollEdgeAppearanceRequiresFadeForPopupBar:(LNPopupBar*)popupBar;

- (void)_ln_letMeKnowWhenViewInWindowHierarchy:(LNInWindowBlock)block;
- (void)_ln_forgetAboutIt;
- (nullable NSString*)_ln_effectGroupingIdentifierIfAvailable;

@end

@interface UIView ()

- (id)_lnpopup_scrollEdgeAppearance;

@end

#if TARGET_OS_MACCATALYST

@interface UIWindow (MacCatalystSupport)

@property (nonatomic, strong, readonly) UIEvent* _ln_currentEvent;

@end

#endif

NS_ASSUME_NONNULL_END
