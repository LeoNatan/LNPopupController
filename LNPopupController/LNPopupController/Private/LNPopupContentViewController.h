//
//  LNPopupContentViewController.h
//  LNPopupController
//
//  Created by Leo Natan on 9/12/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/UIViewController+LNPopupSupport.h>
@class LNPopupController;

@interface LNPopupContentViewController : UIViewController

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPopupController:(LNPopupController*)popupController;

@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;
@property (nonatomic, weak) LNPopupBar* popupBar;
@property (nonatomic, weak) UIView* bottomBar;

@property (nonatomic) LNPopupPresentationStyle popupPresentationStyle;
@property (nonatomic) BOOL dimsBackgroundInPresentation;
@property (nonatomic) BOOL dismissOnDimTap;

@end
