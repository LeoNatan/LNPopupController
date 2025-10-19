//
//  SafeSystemImages.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-09-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LNSystemImageScale) {
	LNSystemImageScaleCompact,
	LNSystemImageScaleNormal,
	LNSystemImageScaleLarge,
	LNSystemImageScaleLarger
};

#if LNPOPUP
@class LNPopupItem;

extern BOOL LNBarIsCompact(void);
extern BOOL LNBarIsFloatingCompact(void);
extern void LNPopupItemSetStandardMusicControls(LNPopupItem* item, BOOL play, BOOL animated, UITraitCollection* traitCollection, UIAction* prevAction, UIAction* playPauseAction, UIAction* nextAction);
#endif

extern UIImage* LNSystemImage(NSString* named, LNSystemImageScale scale) NS_SWIFT_NAME(LNSystemImage(_:scale:));
extern UIBarButtonItem* LNSystemBarButtonItem(NSString* named, LNSystemImageScale scale, __nullable id target, __nullable SEL action) NS_SWIFT_NAME(LNSystemBarButtonItem(_:scale:target:action:));
extern UIBarButtonItem* LNSystemBarButtonItemAction(NSString* named, LNSystemImageScale scale, UIAction* __nullable primaryAction) NS_SWIFT_NAME(LNSystemBarButtonItem(_:scale:primaryAction:));

NS_ASSUME_NONNULL_END
