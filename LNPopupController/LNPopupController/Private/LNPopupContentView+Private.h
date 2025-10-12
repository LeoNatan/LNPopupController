//
//  LNPopupContentView+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2020-08-04.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupContentView.h>
#import <LNPopupController/LNPopupBarAppearance.h>

@interface LNPopupContentView ()

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* popupInteractionGestureRecognizer;
@property (nonatomic, strong, readwrite) LNPopupCloseButton* popupCloseButton;
@property (nonatomic, strong) UIVisualEffectView* effectView;
@property (nonatomic, strong, readonly) UIView* contentView;

@property (nonatomic, weak) UIViewController* currentPopupContentViewController;

- (void)_applyBackgroundEffectWithContentViewController:(UIViewController*)vc activeAppearance:(LNPopupBarAppearance*)appearance;

- (void)_repositionPopupCloseButton;
- (void)_repositionPopupCloseButtonAnimated:(BOOL)animated;

@property (nonatomic) UIUserInterfaceStyle userUserInterfaceStyleTraitModifier API_AVAILABLE(ios(17.0));
@property (nonatomic) UIUserInterfaceStyle systemUserInterfaceStyleTraitModifier API_AVAILABLE(ios(17.0));

@end

@interface _LNPopupTransitionCoordinator : NSObject <UIViewControllerTransitionCoordinator> @end
