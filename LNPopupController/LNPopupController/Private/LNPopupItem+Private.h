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

/**
 * The accessibility label of the image, in a localized string.
 */
@property (nonatomic, copy) NSString* accessibilityImageLabel;

/**
 * The accessibility label of the progress, in a localized string.
 */
@property (nonatomic, copy) NSString* accessibilityProgressLabel;

/**
 * The accessibility value of the progress, in a localized string.
 */
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, weak, setter=_setItemDelegate:, getter=_itemDelegate) id<_LNPopupItemDelegate> itemDelegate;
@property (nonatomic, weak, setter=_setContainerController:, getter=_containerController) __kindof UIViewController* containerController;

@end
