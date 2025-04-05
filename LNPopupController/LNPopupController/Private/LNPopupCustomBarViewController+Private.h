//
//  LNPopupItem+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupItem.h>
#import <LNPopupController/LNPopupCustomBarViewController.h>
#import "LNPopupController.h"

@interface LNPopupCustomBarViewController ()

@property (nonatomic, weak, readwrite) LNPopupBar* containingPopupBar;
@property (nonatomic, weak) LNPopupController* popupController;

- (void)_activeAppearanceDidChange:(LNPopupBarAppearance*)activeAppearance API_AVAILABLE(ios(13.0));

- (void)_userFacing_viewWillAppear:(BOOL)animated;
- (void)_userFacing_viewIsAppearing:(BOOL)animated API_AVAILABLE(ios(13.0));
- (void)_userFacing_viewDidAppear:(BOOL)animated;
- (void)_userFacing_viewWillDisappear:(BOOL)animated;
- (void)_userFacing_viewDidDisappear:(BOOL)animated;

@end

@interface _LNPopupCustomBarViewController_AppearanceControl : LNPopupCustomBarViewController @end
