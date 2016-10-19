//
//  LNPopupCloseButton.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNPopupCloseButton : UIButton

/**
 *  The button’s background view. (read-only)
 *  
 *  Although this property is read-only, its own properties are read/write. Use these properties to configure the appearance and behavior of the button’s background view.
 */
@property (nonatomic, strong, readonly) UIVisualEffectView* backgroundView;

@end
NS_ASSUME_NONNULL_END
