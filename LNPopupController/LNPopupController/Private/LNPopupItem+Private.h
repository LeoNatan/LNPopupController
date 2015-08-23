//
//  LNPopupItem+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupItem.h>
#import "LNPopupController.h"

@class LNPopupItem;

@protocol _LNPopupItemDelegate <NSObject>

- (void)_popupItem:(LNPopupItem*)popupItem didChangeValueForKey:(NSString*)key;

@end

@interface LNPopupItem ()

@property (nonatomic, weak, setter=_setItemDelegate:, getter=_itemDelegate) id<_LNPopupItemDelegate> itemDelegate;
@property (nonatomic, weak, setter=_setContainerController:, getter=_containerController) LNObjectOfKind(UIViewController*) containerController;

@end