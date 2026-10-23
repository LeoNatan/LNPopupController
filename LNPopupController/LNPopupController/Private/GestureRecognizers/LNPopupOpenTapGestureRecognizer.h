//
//  LNPopupOpenTapGestureRecognizer.h
//  LNPopupController
//
//  Created by Léo Natan on 2017-07-15.
//  Copyright © 2015-2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNPopupController;

@interface LNPopupOpenTapGestureRecognizer : UITapGestureRecognizer

- (instancetype)initWithPopupController:(LNPopupController*)popupController action:(SEL)action;

@end
