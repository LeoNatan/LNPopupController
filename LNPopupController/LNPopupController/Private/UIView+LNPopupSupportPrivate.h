//
//  UIView+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-01.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupBar;
@class LNPopupController;

NS_ASSUME_NONNULL_BEGIN

typedef void (^LNInWindowBlock)(dispatch_block_t);

@interface NSObject (LNPopupSupportPrivate)

@property (nonatomic, weak, nullable, getter=_ln_attachedPopupController, setter=_ln_setAttachedPopupController:) LNPopupController* attachedPopupController;

@end

UIEdgeInsets _LNEdgeInsetsFromDirectionalEdgeInsets(UIView* forView, NSDirectionalEdgeInsets edgeInsets);

@interface UIView (LNPopupSupportPrivate)

- (void)_ln_triggerBarAppearanceRefreshIfNeededTriggeringLayout:(BOOL)layout API_AVAILABLE(ios(13.0));
- (BOOL)_ln_scrollEdgeAppearanceRequiresFadeForPopupBar:(LNPopupBar*)popupBar API_AVAILABLE(ios(13.0));

- (void)_ln_letMeKnowWhenViewInWindowHierarchy:(LNInWindowBlock)block;
- (void)_ln_forgetAboutIt;
- (nullable NSString*)_ln_effectGroupingIdentifierIfAvailable;

- (void)_ln_freezeInsets;

@end

@interface UIView ()

- (id)_lnpopup_scrollEdgeAppearance API_AVAILABLE(ios(13.0));

@end

@interface UITabBar ()

@property (nonatomic, getter=_ignoringLayoutDuringTransition, setter=_setIgnoringLayoutDuringTransition:) BOOL ignoringLayoutDuringTransition;

@end

@interface UIWindow (MacCatalystSupport)

@property (nonatomic, strong, readonly) UIEvent* _ln_currentEvent;

@end

NS_ASSUME_NONNULL_END

@interface UIScrollView (LNPopupSupportPrivate)

- (BOOL)_ln_hasHorizontalContent;
- (BOOL)_ln_hasVerticalContent;
- (BOOL)_ln_scrollingOnlyVertically;
- (BOOL)_ln_isAtTop;

@end

@interface _LNPopupBarBackgroundGroupNameOverride: NSObject <UIObjectTraitDefinition> @end
