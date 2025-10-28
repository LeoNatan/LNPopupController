//
//  LNPopupItem+Private.h
//  LNPopupController
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupItem.h>
#import "LNPopupControllerImpl.h"

extern NSArray* __LNPopupItemObservedKeys;

@class LNPopupItem;

@protocol _LNPopupItemDelegate <NSObject>

- (void)_popupItem:(LNPopupItem*)popupItem didChangeToValue:(id)value forKey:(NSString*)key;

@end

@interface LNPopupItem ()

@property (nonatomic, strong) UIViewController* swiftuiImageController;

@property (nonatomic, strong) UIView* swiftuiTitleContentView;
@property (nonatomic, strong) UIViewController* swiftuiTitleContentViewController;

@property (nonatomic, strong) UIViewController* swiftuiHiddenLeadingController;
@property (nonatomic, strong) UIViewController* swiftuiHiddenTrailingController;

@property (nonatomic, copy) NSString* accessibilityImageLabel;
@property (nonatomic, copy) NSString* accessibilityProgressLabel;
@property (nonatomic, copy) NSString* accessibilityProgressValue;

@property (nonatomic, weak, setter=_setItemDelegate:, getter=_itemDelegate) id<_LNPopupItemDelegate> itemDelegate;
@property (nonatomic, weak, setter=_setContainerController:, getter=_containerController) __kindof UIViewController* containerController;

@end
