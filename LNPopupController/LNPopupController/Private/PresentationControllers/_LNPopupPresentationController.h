//
//  _LNPopupPresentationController.h
//  LNPopupController
//
//  Created by Leo Natan on 9/12/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNPopupContentViewController.h"

UIView* _LNPopupSnapshotView(UIView* view);

@protocol LNPopupPresentationControllerDelegate <NSObject>

- (void)currentPresentationDidEnd;

@end

@protocol _LNPopupPresentationController <NSObject>

@property (nonatomic, weak, readonly) LNPopupContentViewController* popupContentController;
@property (nonatomic, weak) id<LNPopupPresentationControllerDelegate> popupPresentationControllerDelegate;

@end
