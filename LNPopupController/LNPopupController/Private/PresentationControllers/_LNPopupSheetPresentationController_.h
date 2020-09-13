//
//  _LNPopupSheetPresentationController_.h
//  LNPopupController
//
//  Created by Leo Natan on 9/13/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_LNPopupPresentationController.h"

#if ! LNPopupControllerEnforceStrictClean

extern Class _LNPopupPageSheetPresentationController;
extern Class _LNPopupFormSheetPresentationController;

@interface _LNPopupSheetPresentationController_ : UIPresentationController <_LNPopupPresentationController>

@property (nonatomic, assign) id<LNPopupPresentationControllerDelegate> popupPresentationControllerDelegate;

@end

#endif
