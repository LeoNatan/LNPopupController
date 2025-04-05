//
//  LNPopupBarContentViewController.h
//  LNPopupController
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>

@class LNPopupBar;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR
/// An object that manages a custom popup bar view hierarchy.
///
/// Implement the `UIPointerInteractionDelegate` methods to customize pointer interactions.
@interface LNPopupCustomBarViewController : UIViewController <UIPointerInteractionDelegate>

/// The containing popup bar. (read-only)
@property (nonatomic, weak, readonly, nullable) LNPopupBar* containingPopupBar;

/// Indicates whether the default tap gesture recognizer should be added to the popup bar.
///
/// Defaults to `true`.
@property (nonatomic, assign, readonly) BOOL wantsDefaultTapGestureRecognizer;

/// Indicates whether the default pan gesture recognizer should be added to the popup bar.
///
/// Defaults to `true`.
@property (nonatomic, assign, readonly) BOOL wantsDefaultPanGestureRecognizer;

/// Indicates whether the default highlight gesture recognizer should be added to the popup bar.
///
/// Defaults to `true`.
@property (nonatomic, assign, readonly) BOOL wantsDefaultHighlightGestureRecognizer;

/// The content size of the popup bar view.
///
/// This property's value is used for height calculation of the popup bar. Update this property if you need to resize the popup bar.
@property (nonatomic, assign) CGSize preferredContentSize;

/// Called after the view has been loaded. For view controllers created in code, this is after `loadView()`. For view controllers unarchived from a nib, this is after the view is set.
- (void)viewDidLoad NS_REQUIRES_SUPER;

/// Called by the framework to notify the popup bar content view controller that one or more keys of the the popup item have been updated, or the entire popup item has changed.
- (void)popupItemDidUpdate;

/// Called by the framework no notify the popup bar content view controller that the custom bar is about to move to a popup bar.
///
/// - Parameter newPopupBar: The new popup bar
- (void)willMoveToPopupBar:(nullable LNPopupBar*)newPopupBar;

/// Called by the framework no notify the popup bar content view controller that the custom bar has moved to a popup bar.
- (void)didMoveToPopupBar;

/// Called by the framework to notify the popup bar content view controller that the active appearance has changed.
///
/// - Parameter activeAppearance: A merged appearance from the popup item, the system appearance and popup bar appearance, as appropriate.
- (void)activeAppearanceDidChange:(LNPopupBarAppearance*)activeAppearance API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
