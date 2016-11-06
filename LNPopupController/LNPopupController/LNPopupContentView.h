//
//  LNPopupItem.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupCloseButton.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Holds the popup content container view, as well as the popup close button and the popup interaction gesture recognizer.
 */
@interface LNPopupContentView : UIView

/**
 *  The gesture recognizer responsible for interactive opening and closing of the popup. (read-only)
 *  
 *  The system installs this gesture recognizer on either the popup bar or the popup content view and uses it to open or close the popup.
 *  Be careful with modifying this gesture recognizer. It is shared for interactively opening the popup by panning the popup bar (when it is closed), or interactively closing the popup interactively by panning the popup content view (when the popup is open). If you disable the gesture recognizer after opening the popup, you must monitor the state of the popup and reenable the gesture recognizer once closed by the user or through code.
 */
@property (nullable, nonatomic, strong, readonly) UIPanGestureRecognizer* popupInteractionGestureRecognizer;

/**
 *  The popup close button. (read-only)
 */
@property (nonatomic, strong, readonly) LNPopupCloseButton* popupCloseButton;

@property (nonatomic, strong, readonly) UIView* contentView;

@end

NS_ASSUME_NONNULL_END
