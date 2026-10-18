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
@interface _LNPopupContentViewLayoutEmptyController : UIViewController

#if defined(__IPHONE_27_1)
@property (nonatomic, readwrite) UIVerticalBarBehavior preferredVerticalBarBehavior API_AVAILABLE(ios(27.1), tvos(27.1), visionos(27.1));
#endif

@end

@interface _LNPopupContentViewLayoutController : UINavigationController

@property (nonatomic, weak) id<_LNPopupLayoutBarLayoutDelegate> _layoutDelegate;

@end
#endif

@interface LNPopupContentView ()

+ (LNPopupViewCorners)cornersForContentView:(LNPopupContentView*)contentView;

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readwrite) LNPopupInteractionPanGestureRecognizer* popupInteractionGestureRecognizer;
@property (nonatomic, strong, readwrite) LNPopupCloseButton* popupCloseButton;
@property (nonatomic, strong) UIVisualEffectView* effectView;
@property (nonatomic, strong, readonly) UIView* contentView;
#if !TARGET_OS_MACCATALYST
@property (nonatomic, strong, readonly, getter=_layoutController) _LNPopupContentViewLayoutController* layoutController;
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
