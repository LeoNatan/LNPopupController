//
//  SafeSystemImages.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2023-09-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

@import UIKit;
#if LNPOPUP
@import LNPopupController;
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LNSystemImageScale) {
	LNSystemImageScaleExtraCompact,
	LNSystemImageScaleCompact,
	LNSystemImageScaleNormal,
	LNSystemImageScaleLarge,
	LNSystemImageScaleLarger
};

#if LNPOPUP
@class LNPopupItem;

extern BOOL LNBarIsClassicCompact(LNPopupBar*);
extern BOOL LNBarIsFloatingCompact(LNPopupBar*);
extern void LNPopupItemSetStandardMusicControls(LNPopupItem* item, LNPopupBar* targetBar, BOOL play, BOOL animated, UITraitCollection* traitCollection, UIAction* __nullable prevAction, UIAction* __nullable playPauseAction, UIAction* __nullable nextAction);
#endif

extern UIImage* LNSystemImage(NSString* named, LNSystemImageScale scale) NS_SWIFT_NAME(LNSystemImage(_:scale:));
extern UIBarButtonItem* LNSystemBarButtonItem(NSString* named, LNSystemImageScale scale, __nullable id target, __nullable SEL action) NS_SWIFT_NAME(LNSystemBarButtonItem(_:scale:target:action:));
extern UIBarButtonItem* LNSystemBarButtonItemAction(NSString* named, LNSystemImageScale scale, UIAction* __nullable primaryAction) NS_SWIFT_NAME(LNSystemBarButtonItem(_:scale:primaryAction:));

NS_ASSUME_NONNULL_END
