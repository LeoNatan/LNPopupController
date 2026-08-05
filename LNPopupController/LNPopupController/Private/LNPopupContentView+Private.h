//
//  LNPopupContentView+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-04.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupContentView.h>
#import <LNPopupController/LNPopupBarAppearance.h>
#import "UIView+LNPopupSupportPrivate.h"

#if !TARGET_OS_MACCATALYST
@interface _LNPopupContentViewLayoutController : UINavigationController @end
#endif

@interface LNPopupContentView ()

+ (LNPopupViewCorners)cornersForContentView:(LNPopupContentView*)contentView;

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readwrite) LNPopupInteractionPanGestureRecognizer* popupInteractionGestureRecognizer;
@property (nonatomic, strong, readwrite) LNPopupCloseButton* popupCloseButton;
@property (nonatomic, strong) UIVisualEffectView* effectView;
@property (nonatomic, strong, readonly) UIView* contentView;
#if !TARGET_OS_MACCATALYST
@property (nonatomic, strong, readonly, getter=_layoutController) UINavigationController* layoutController;
#endif

- (UIVisualEffect*)_currentEffect;

@property (nonatomic, weak) UIViewController* currentPopupContentViewController;

@property (nonatomic, strong) UIView* transitionView;

- (void)_applyBackgroundEffectWithContentViewController:(UIViewController*)vc popupBar:(LNPopupBar*)popupBar;

- (void)_repositionPopupCloseButton;
- (void)_repositionPopupCloseButtonAnimated:(BOOL)animated;

@property (nonatomic, getter=_applyScreenCorners, setter=_setApplyScreenCorners:) BOOL applyScreenCorners;

@end

@interface _LNPopupTransitionCoordinator : NSObject <UIViewControllerTransitionCoordinator> @end
