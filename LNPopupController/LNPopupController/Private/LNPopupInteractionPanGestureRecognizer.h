//
//  LNPopupInteractionPanGestureRecognizer.h
//  LNPopupController
//
//  Created by Leo Natan on 15/07/2017.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupController;

@interface LNPopupInteractionPanGestureRecognizer : UIPanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action popupController:(LNPopupController*)popupController;

@end
