//
//  LNPopupCloseButton+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2016-12-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupCloseButton.h>
#import <LNPopupController/LNPopupContentView.h>

CF_EXTERN_C_BEGIN

extern BOOL _LNPopupCloseButtonStyleIsGlass(LNPopupCloseButtonStyle style);
extern void _LNPopupResolveCloseButtonStyleAndPositioning(LNPopupCloseButtonStyle style, LNPopupCloseButtonPositioning positioning, LNPopupCloseButtonStyle* resolvedStyle, LNPopupCloseButtonPositioning* resolvedPositioning);

@interface LNPopupCloseButton ()

- (instancetype)initWithContainingContentView:(LNPopupContentView*)contentView;

@property (nonatomic, weak) LNPopupContentView* popupContentView;

- (void)_setStyle:(LNPopupCloseButtonStyle)style;
- (void)_setPositioning:(LNPopupCloseButtonPositioning)positioning;
- (void)_setButtonContainerStationary;
- (void)_setButtonContainerTransitioning;

@end

CF_EXTERN_C_END
