//
//  LNPopupBar.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModernObjCSupport.h"

@interface LNPopupBar : UIView

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, copy) LNArrayOfType(UIBarButtonItem*)* leftBarButtonItems;
@property (nonatomic, copy) LNArrayOfType(UIBarButtonItem*)* rightBarButtonItems;

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, copy) UIColor* barTintColor;

@end
