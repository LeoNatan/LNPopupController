//
//  _LNPopupBarSupportObject.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPopupBar+Private.h"
#import "LNPopupControllerLongPressGestureDelegate.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "LNPopupCloseButton.h"

@interface LNPopupContentContainerView : UIVisualEffectView

- (instancetype)initWithFrame:(CGRect)frame popupBarStyle:(UIBarStyle)popupBarStyle;

@end

@interface LNPopupController : NSObject

- (instancetype)initWithContainerViewController:(LNObjectOfKind(UIViewController*))containerController;

@property (nonatomic, weak) UIView* bottomBar;

@property (nonatomic, strong) LNPopupBar* popupBar;
@property (nonatomic, strong) LNPopupContentContainerView* popupContentView;
@property (nonatomic, strong) LNPopupCloseButton* popupCloseButton;

@property (nonatomic) LNPopupPresentationState popupControllerState;
@property (nonatomic) LNPopupPresentationState popupControllerTargetState;

@property (nonatomic, strong) UILongPressGestureRecognizer* popupBarLongPressGestureRecognizer;
@property (nonatomic, strong) LNPopupControllerLongPressGestureDelegate* popupBarLongPressGestureRecognizerDelegate;
@property (nonatomic, strong) UITapGestureRecognizer* popupBarTapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer* popupBarUserPresentPanGestureRecognizer;
@property (nonatomic) CGPoint lastPopupBarLocation;
@property (nonatomic) CFTimeInterval lastSeenMovement;

@property (nonatomic, weak) UIViewController* effectiveStatusBarUpdateController;

- (CGFloat)_percentFromPopupBar;

- (void)_setContentToState:(LNPopupPresentationState)state;

- (void)_movePopupBarAndContentToBottomBarSuperview;

- (void)presentPopupBarAnimated:(BOOL)animated completion:(void(^)())completionBlock;
- (void)openPopupAnimated:(BOOL)animated completion:(void(^)())completionBlock;
- (void)closePopupAnimated:(BOOL)animated completion:(void(^)())completionBlock;
- (void)dismissPopupBarAnimated:(BOOL)animated completion:(void(^)())completionBlock;

- (void)_configurePopupBarFromBottomBar;

@end
