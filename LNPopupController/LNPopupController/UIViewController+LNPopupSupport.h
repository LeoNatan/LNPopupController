//
//  UIViewController+LNPopupSupport.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupDefinitions.h>
#import <LNPopupController/LNPopupContentView.h>
#import <LNPopupController/LNPopupBar.h>
#import <LNPopupController/LNPopupItem.h>

NS_ASSUME_NONNULL_BEGIN

NS_REFINED_FOR_SWIFT
/// The default popup snap percent. See `UIViewController.popupSnapPercent` for more information.
extern const double LNSnapPercentDefault;

NS_REFINED_FOR_SWIFT
/// Available interaction styles with the popup bar and popup content view.
typedef NS_ENUM(NSInteger, LNPopupInteractionStyle) {
	/// The default interaction style for the current environment.
	///
	/// On iOS, the default interaction style is snap.
	///
	/// On macOS, the default interaction style is scroll.
	LNPopupInteractionStyleDefault,
	
	/// Drag interaction style.
	LNPopupInteractionStyleDrag,
	
	/// Snap interaction style.
	LNPopupInteractionStyleSnap,
	
	/// Scroll interaction style.
	LNPopupInteractionStyleScroll,
	
	/// No interaction
	LNPopupInteractionStyleNone = 0xFFFF
} NS_SWIFT_NAME(__LNPopupInteractionStyle);

/// The state of the popup presentation.
typedef NS_ENUM(NSInteger, LNPopupPresentationState){
	/// The popup bar is hidden and no presentation is taking place.
	LNPopupPresentationStateBarHidden = 0,
	
	/// The popup bar is presented and is closed.
	LNPopupPresentationStateBarPresented = 1,
	
	/// The popup is open and the content controller's view is displayed.
	LNPopupPresentationStateOpen = 3,
	
	LNPopupPresentationStateHidden LN_DEPRECATED_API("Use LNPopupPresentationStateBarHidden instead.") = LNPopupPresentationStateBarHidden,
	LNPopupPresentationStateClosed LN_DEPRECATED_API("Use LNPopupPresentationStateBarPresented instead.") = LNPopupPresentationStateBarPresented,
	LNPopupPresentationStateTransitioning LN_DEPRECATED_API("Should no longer be used.") = 2,
};

/// Popup content support for ``UIViewController`` subclasses.
@interface UIViewController (LNPopupContent)

/// The popup item used to represent the view controller in a popup presentation. (read-only)
///
/// This is a unique instance of ``LNPopupItem``, created to represent the view controller when it is presented in a popup. The ``LNPopupItem`` object is created the first time the property is accessed. Therefore, you should not access this property if you are not using popup presentation to display the view controller. To ensure the popup item is configured, you can either override this property and add code to create the bar button items when first accessed or create the items in your view controller's initialization code.
///
/// The default behavior is to create a popup item that displays the view controller's title.
@property (nonatomic, retain, readonly) LNPopupItem* popupItem;

/// Return the view to which the popup interaction gesture recognizer should be added to.
///
/// The default implementation returns the controller's view. @see `UIViewController.popupContentView`
@property (nonatomic, strong, readonly) __kindof UIView* viewForPopupInteractionGestureRecognizer;

/// Gives the popup content controller the opportunity to place the popup close button within its own view hierarchy, instead of the system-defined placement.
///
/// The default implementation of this method does nothing and returns `false`.
///
/// - Returns: Return `true` if the popup close button has been positioned in the controller's view hierarchy, or `false` to allow the system to handle positioning of the button.
- (BOOL)positionPopupCloseButton:(LNPopupCloseButton*)popupCloseButton;

/// Called to notify the view controller that its view is about to be added to the container controller's popup content view.
///
/// - Parameter popupContentView: The popup content view, or `nil`.
- (void)viewWillMoveToPopupContainerContentView:(nullable LNPopupContentView*)popupContentView NS_REQUIRES_SUPER;

/// Called to notify the view controller that its view has just been added to the container controller's popup content view.
///
/// - Parameter popupContentView: The popup content view, or `nil`.
- (void)viewDidMoveToPopupContainerContentView:(nullable LNPopupContentView*)popupContentView NS_REQUIRES_SUPER;

@end

/// A set of methods, used to respond to popup presentation changes.
@protocol LNPopupPresentationDelegate <NSObject>

@optional

/// Notifies the delegate that the popup bar is about to be presented.
- (void)popupPresentationControllerWillPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;

/// Notifies the delegate that the popup bar has been presented.
- (void)popupPresentationControllerDidPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;

/// Notifies the delegate that the popup bar is about to be dismissed.
- (void)popupPresentationControllerWillDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;

/// Notifies the delegate that the popup bar has been dismissed.
- (void)popupPresentationControllerDidDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;

/// Notifies the delegate that the popup is about to be opened with the specified popup content controller.
- (void)popupPresentationController:(UIViewController*)popupPresentationController willOpenPopupWithContentController:(UIViewController*)popupContentController animated:(BOOL)animated;

/// Notifies the delegate that the popup has been opened with the specified popup content controller.
- (void)popupPresentationController:(UIViewController*)popupPresentationController didOpenPopupWithContentController:(UIViewController*)popupContentController  animated:(BOOL)animated;

/// Notifies the delegate that the popup is about to be closed with the specified popup content controller.
- (void)popupPresentationController:(UIViewController*)popupPresentationController willClosePopupWithContentController:(UIViewController*)popupContentController animated:(BOOL)animated;

/// Notifies the delegate that the popup has been closed with the specified popup content controller.
- (void)popupPresentationController:(UIViewController*)popupPresentationController didClosePopupWithContentController:(UIViewController*)popupContentController animated:(BOOL)animated;

/// Notifies the delegate that the popup is about to be opened.
- (void)popupPresentationControllerWillOpenPopup:(UIViewController*)popupPresentationController animated:(BOOL)animated LN_DEPRECATED_API("Use popupPresentationController:willOpenPopupWithContentController:animated: instead");

/// Notifies the delegate that the popup has been opened.
- (void)popupPresentationControllerDidOpenPopup:(UIViewController*)popupPresentationController animated:(BOOL)animated LN_DEPRECATED_API("Use popupPresentationController:didOpenPopupWithContentController:animated: instead");

/// Notifies the delegate that the popup is about to be closed.
- (void)popupPresentationControllerWillClosePopup:(UIViewController*)popupPresentationController animated:(BOOL)animated LN_DEPRECATED_API("Use popupPresentationController:willClosePopupWithContentController:animated: instead");

/// Notifies the delegate that the popup has been closed.
- (void)popupPresentationControllerDidClosePopup:(UIViewController*)popupPresentationController animated:(BOOL)animated LN_DEPRECATED_API("Use popupPresentationController:didClosePopupWithContentController:animated: instead");

@end

/// Popup presentation support for ``UIViewController`` subclasses.
@interface UIViewController (LNPopupPresentation)

/// Presents an interactive popup bar in the receiver's view hierarchy. The popup bar is attached to the receiver's docking view.
///
/// You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
///
/// The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
///
/// See `UIViewController.bottomDockingViewForPopupBar` for more information on the bottom docking view..
/// - Parameters:
///   - controller: The controller for popup presentation.
///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
///   - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
- (void)presentPopupBarWithContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(nullable void(^)(void))completion NS_SWIFT_DISABLE_ASYNC;


/// Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation. The popup bar is attached to the receiver's docking view.
///
/// You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
///
/// The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
/// - Parameters:
///   - controller: The controller for popup presentation.
///   - openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
///   - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
- (void)presentPopupBarWithContentViewController:(UIViewController*)controller openPopup:(BOOL)openPopup animated:(BOOL)animated completion:(nullable void(^)(void))completion NS_SWIFT_DISABLE_ASYNC;

/// Opens the popup, displaying the content view controller's view.
/// - Parameters:
///   - animated: Pass `true` to animate; otherwise, pass `false`.
///   - completion: The block to execute after the popup is opened. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
- (void)openPopupAnimated:(BOOL)animated completion:(nullable void(^)(void))completion NS_SWIFT_DISABLE_ASYNC;

/// Closes the popup, hiding the content view controller's view.
/// - Parameters:
///   - animated: Pass `true` to animate; otherwise, pass `false`.
///   - completion: The block to execute after the popup is closed. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
- (void)closePopupAnimated:(BOOL)animated completion:(nullable void(^)(void))completion NS_SWIFT_DISABLE_ASYNC;

/// Dismisses the popup presentation, closing the popup if open and dismissing the popup bar.
/// - Parameters:
///   - animated: Pass `true` to animate; otherwise, pass `false`.
///   - completion: The block to execute after the dismissal. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
- (void)dismissPopupBarAnimated:(BOOL)animated completion:(nullable void(^)(void))completion NS_SWIFT_DISABLE_ASYNC;


/// The popup bar interaction style.
@property (nonatomic, assign) LNPopupInteractionStyle popupInteractionStyle NS_REFINED_FOR_SWIFT;


/// The percent of the container controller's view height to drag before closing the popup.
@property (nonatomic, assign) double popupSnapPercent NS_REFINED_FOR_SWIFT;


/// The popup bar managed by the system. (read-only)
@property (nonatomic, strong, readonly) LNPopupBar* popupBar;


/// Controls whether the popup bar should extend under the safe area, to the bottom of the screen.
///
/// When a popup bar is presented on a view controller with the system bottom docking view, or a navigation controller with hidden toolbar, the popup bar's background view will extend under the safe area.
///
/// The default value of this property is `true`.
@property (nonatomic, assign) BOOL shouldExtendPopupBarUnderSafeArea;

/// Call this method to update the popup bar appearance (background effect, tint color, etc.) according to its docking view. You should call this after updating the docking view.
///
/// If the popup bar's ``inheritsAppearanceFromDockingView`` property is set to `false`, or a custom popup bar view controller is used, this method has no effect.
///
/// See `LNPopupBar.inheritsAppearanceFromDockingView` and `LNPopupBar.customBarViewController` for more information.
- (void)setNeedsPopupBarAppearanceUpdate;

/// The popup content container view. (read-only)
@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;

/// The state of the popup presentation. (read-only)
///
/// This property is KVO-compliant.
@property (nonatomic, readonly) LNPopupPresentationState popupPresentationState;

/// The delegate that handles popup presentation-related messages.
///
@property (nonatomic, weak) id<LNPopupPresentationDelegate> popupPresentationDelegate;

/// The content view controller of the receiver. If there is no popover presentation, the property will be @c nil. (read-only)
@property (nullable, nonatomic, strong, readonly) __kindof UIViewController* popupContentViewController;

/// The popup presentation container view controller of the receiver. If the receiver is not part of a popover presentation, the property will be @c nil. (read-only)
@property (nullable, nonatomic, weak, readonly) __kindof UIViewController* popupPresentationContainerViewController;

@end

/// Popup presentation containment support in custom container view controller subclasses.
@interface UIViewController (LNPopupCustomContainer)

/// Return a view to dock the popup bar to, or @c nil to use an appropriate system-provided view.
///
/// A default implementation is provided for @c UIViewController, @c UINavigationController and @c UITabBarController.
///
/// The default implmentation for @c UIViewController returns an invisible @c UIView instance, docked to the bottom. For @c UINavigationController, the toolbar is returned. For @c UITabBarController, the tab bar is returned.
@property (nullable, nonatomic, strong, readonly) __kindof UIView* bottomDockingViewForPopupBar;

/// Controls whether the popup bar should fade out during its dismissal animation.
///
/// By default, this property's value is @c true if the popup bar is extended (see @c UIViewController.shouldExtendPopupBarUnderSafeArea) and the extension is visible, or if the bottom bar (toolbar or tab bar) is about to transition to its scroll edge appearance, and the scroll edge appearance has a transparent background.
@property (nonatomic, assign, readonly) BOOL shouldFadePopupBarOnDismiss;

/// Return the default frame for the docking view, when the popup is in hidden or closed state. If @c bottomDockingViewForPopupBar returns @c nil, this method is not called, and the default system-provided frame is used.
///
/// A default implementation is provided for @c UIViewController, @c UINavigationController and @c UITabBarController.
@property (nonatomic, readonly) CGRect defaultFrameForBottomDockingView;

/// The insets for the bottom docking view from bottom of the container controller's view. By default, this returns @c UIEdgeInsetsZero. Currently, only the bottom inset is respected.
///
/// The system calculates the position of the popup bar and the bottom docking view by summing the bottom docking view's height and the bottom of the insets.
///
/// @warning This API is experimental and will probably change in the future. Use with care.
@property (nonatomic, readonly) UIEdgeInsets insetsForBottomDockingView;

@end

@interface UIViewController (Deprecations)

/// @warning This API is no longer supported. Use @c bottomDockingViewForPopupBar instead.
@property (nullable, nonatomic, strong, readonly) __kindof UIView* bottomDockingViewForPopup LN_UNAVAILABLE_API("Use bottomDockingViewForPopupBar instead.");

/// Call this method to update the popup bar appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
///
/// If the popup bar's @c inheritsAppearanceFromDockingView property is set to @c false, or a custom popup bar view controller is used, this method has no effect. See @c LNPopupBar.inheritsAppearanceFromDockingView and @c LNPopupBar.customBarViewController for more information.
- (void)updatePopupBarAppearance LN_DEPRECATED_API("Use setNeedsPopupBarAppearanceUpdate instead.");

@end

NS_ASSUME_NONNULL_END
