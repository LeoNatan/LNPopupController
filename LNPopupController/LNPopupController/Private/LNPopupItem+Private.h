//
//  LNPopupItem+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupItem.h>
#import "LNPopupController.h"

extern NSArray* __LNPopupItemObservedKeys;

@class LNPopupItem;

@protocol _LNPopupItemDelegate <NSObject>

- (void)_popupItem:(LNPopupItem*)popupItem didChangeValueForKey:(NSString*)key;

@end

@interface LNPopupItem ()

@property (nonatomic, strong) UIViewController* swiftuiImageController;
@property (nonatomic, strong) UIViewController* swiftuiTitleController;
@property (nonatomic, strong) UIViewController* swiftuiSubtitleController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenLeadingController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenTrailingController;

@property (nonatomic, copy) NSString* accessibilityImageLabel;
@property (nonatomic, copy) NSString* accessibilityProgressLabel;
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, weak, setter=_setItemDelegate:, getter=_itemDelegate) id<_LNPopupItemDelegate> itemDelegate;
@property (nonatomic, weak, setter=_setContainerController:, getter=_containerController) __kindof UIViewController* containerController;

@end
