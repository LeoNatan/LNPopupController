//
//  LNPopupInteractionPanGestureRecognizer.h
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupController;

@interface LNPopupInteractionPanGestureRecognizer : UIPanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action popupController:(LNPopupController*)popupController;

@end
