//
//  UIViewController+LNPopupSupport.h
//  LNPopupController
//
//  Created by Leo Natan on 7/24/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNPopupController/LNPopupContentView.h>
#import <LNPopupController/LNPopupBar.h>
#import <LNPopupController/LNPopupItem.h>

#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))
#define LN_UNAVAILABLE_API(x) __attribute__((unavailable(x)))

NS_ASSUME_NONNULL_BEGIN

/**
 * Available interaction styles with the popup bar and popup content view.
 */
typedef NS_ENUM(NSUInteger, LNPopupInteractionStyle) {
	/**
	 * Use the most appropriate interaction style for the current operating system version—uses snap style for iOS 10 and above, otherwise drag.
	 */
	LNPopupInteractionStyleDefault,
	
	/**
	 * Drag interaction style
	 */
	LNPopupInteractionStyleDrag,
	/**
	 * Snap interaction style
	 */
	LNPopupInteractionStyleSnap,
	/**
	 * No interaction
	 */
	LNPopupInteractionStyleNone = 0xFFFF
};

/**
 * The state of the popup presentation.
 */
typedef NS_ENUM(NSUInteger, LNPopupPresentationState){
	/**
	 * The popup bar is hidden and no presentation is taking place.
	 */
	LNPopupPresentationStateBarHidden = 0,
	/**
	 * The popup bar is presented and is closed and no presentation is taking place.
	 */
	LNPopupPresentationStateBarPresented = 1,
	/**
	 * The popup is open and the content controller's view is displayed.
	 */
	LNPopupPresentationStateOpen = 3,
	
	LNPopupPresentationStateHidden LN_DEPRECATED_API("Use LNPopupPresentationStateBarHidden instead.") = LNPopupPresentationStateBarHidden,
	LNPopupPresentationStateClosed LN_DEPRECATED_API("Use LNPopupPresentationStateBarPresented instead.") = LNPopupPresentationStateBarPresented,
	LNPopupPresentationStateTransitioning LN_DEPRECATED_API("Should no longer be used.") = 2,
};

/**
 * Popup presentation support for @c UIViewController subclasses.
 */
@interface UIViewController (LNPopupContent)

/**
 * The popup item used to represent the view controller in a popup presentation. (read-only)
 *
 * This is a unique instance of @c LNPopupItem, created to represent the view controller when it is presented in a popup. The @c LNPopupItem object is created the first time the property is accessed. Therefore, you should not access this property if you are not using popup presentation to display the view controller. To ensure the popup item is configured, you can either override this property and add code to create the bar button items when first accessed or create the items in your view controller's initialization code.
 *
 * The default behavior is to create a popup item that displays the view controller's title.
 */
@property (nonatomic, retain, readonly) LNPopupItem* popupItem;

/**
 * Return the view to which the popup interaction gesture recognizer should be added to.
 *
 * The default implementation returns the controller's view. @see @c UIViewController.popupContentView
 *
 * @return The view to which the popup interaction gesture recognizer should be added to.
 */
@property (nonatomic, strong, readonly) __kindof UIView* viewForPopupInteractionGestureRecognizer;

@end

@protocol LNPopupPresentationDelegate <NSObject>

@optional

/**
 * Notifies the delegate that the popup bar is about to be presented.
 */
- (void)popupPresentationControllerWillPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup bar has been presented.
 */
- (void)popupPresentationControllerDidPresentPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup bar is about to be dismissed.
 */
- (void)popupPresentationControllerWillDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup bar has been dismissed.
 */
- (void)popupPresentationControllerDidDismissPopupBar:(UIViewController*)popupPresentationController animated:(BOOL)animated;

/**
 * Notifies the delegate that the popup is about to be opened.
 */
- (void)popupPresentationControllerWillOpenPopup:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup has been opened.
 */
- (void)popupPresentationControllerDidOpenPopup:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup is about to be closed.
 */
- (void)popupPresentationControllerWillClosePopup:(UIViewController*)popupPresentationController animated:(BOOL)animated;
/**
 * Notifies the delegate that the popup has been closed.
 */
- (void)popupPresentationControllerDidClosePopup:(UIViewController*)popupPresentationController animated:(BOOL)animated;


@end

@interface UIViewController (LNPopupPresentation)

/**
 * Presents an interactive popup bar in the receiver's view hierarchy. The popup bar is attached to the receiver's docking view. @see @c -[UIViewController bottomDockingViewForPopupBar]
 *
 * You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
 *
 * The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
 *
 * @param controller      The controller for popup presentation.
 * @param animated        Pass @c YES to animate the presentation; otherwise, pass @c NO.
 * @param completion      The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify @c nil for this parameter.
 */
- (void)presentPopupBarWithContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(nullable void(^)(void))completion;

/**
 * Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation. The popup bar is attached to the receiver's docking view. @see @c -[UIViewController bottomDockingViewForPopupBar]
 *
 * You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
 *
 * The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
 *
 * @param controller      The controller for popup presentation.
 * @param openPopup	   	  Pass @c YES to open the popup in the same animation; otherwise, pass @c NO.
 * @param animated        Pass @c YES to animate the presentation; otherwise, pass @c NO.
 * @param completion      The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify @c nil for this parameter.
 */
- (void)presentPopupBarWithContentViewController:(UIViewController*)controller openPopup:(BOOL)openPopup animated:(BOOL)animated completion:(nullable void(^)(void))completion;

/**
 * Opens the popup, displaying the content view controller's view.
 *
 * @param animated        Pass @c YES to animate; otherwise, pass @c NO.
 * @param completion      The block to execute after the popup is opened. This block has no return value and takes no parameters. You may specify @c nil for this parameter.
 */
- (void)openPopupAnimated:(BOOL)animated completion:(nullable void(^)(void))completion;

/**
 * Closes the popup, hiding the content view controller's view.
 *
 * @param animated        Pass @c YES to animate; otherwise, pass @c NO.
 * @param completion      The block to execute after the popup is closed. This block has no return value and takes no parameters. You may specify @c nil for this parameter.
 */
- (void)closePopupAnimated:(BOOL)animated completion:(nullable void(^)(void))completion;

/**
 * Dismisses the popup presentation, closing the popup if open and dismissing the popup bar.
 *
 * @param animated        Pass @c YES to animate; otherwise, pass @c NO.
 * @param completion      The block to execute after the dismissal. This block has no return value and takes no parameters. You may specify @c nil for this parameter.
 */
- (void)dismissPopupBarAnimated:(BOOL)animated completion:(nullable void(^)(void))completion;

/**
 * The popup bar interaction style.
 */
@property (nonatomic, assign) LNPopupInteractionStyle popupInteractionStyle;

/**
 * The popup bar managed by the system. (read-only)
 */
@property (nonatomic, strong, readonly) LNPopupBar* popupBar;

/**
 * Call this method to update the popup bar appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
 * If the popup bar's @c inheritsVisualStyleFromDockingView property is set to @c NO, this method has no effect. @see @c LNPopupBar.inheritsVisualStyleFromDockingView
 */
- (void)updatePopupBarAppearance;

/**
 * The popup content container view. (read-only)
 */
@property (nonatomic, strong, readonly) LNPopupContentView* popupContentView;

/**
 * The state of the popup presentation. (read-only)
 *
 * This property is KVO-compliant.
 */
@property (nonatomic, readonly) LNPopupPresentationState popupPresentationState;

/**
 * The delegate that handles popup presentation-related messages.
 */
@property (nonatomic, weak) id<LNPopupPresentationDelegate> popupPresentationDelegate;

/**
 * The content view controller of the receiver. If there is no popover presentation, the property will be @c nil. (read-only)
 */
@property (nullable, nonatomic, strong, readonly) __kindof UIViewController* popupContentViewController;

/**
 * The popup presentation container view controller of the receiver. If the receiver is not part of a popover presentation, the property will be @c nil. (read-only)
 */
@property (nullable, nonatomic, weak, readonly) __kindof UIViewController* popupPresentationContainerViewController;

@end

/**
 * Popup presentation containment support in custom container view controller subclasses.
 */
@interface UIViewController (LNPopupCustomContainer)

/**
 * Return a view to dock the popup bar to, or @c nil to use the system-provided view.
 *
 * A default implementation is provided for @c UIViewController, @c UINavigationController and @c UITabBarController.
 * The default implmentation for @c UIViewController returns an invisible @c UIView instance, docked to the bottom. For @c UINavigationController, the toolbar is returned. For @c UITabBarController, the tab bar is returned.
 */
@property (nullable, nonatomic, strong, readonly) __kindof UIView* bottomDockingViewForPopupBar;

/**
 * Return the default frame for the docking view, when the popup is in hidden or closed state. If @c bottomDockingViewForPopupBar returns nil, this method is not called, and the default system-provided frame is used.
 *
 * A default implementation is provided for @c UIViewController, @c UINavigationController and @c UITabBarController.
 */
@property (nonatomic, readonly) CGRect defaultFrameForBottomDockingView;

/**
 * The insets for the bottom docking view from bottom of the container controller's view. By default, this is set to the container controller view's safe area insets in iOS 11 or @c UIEdgeInsetsZero otherwise. Currently, only the bottom inset is respected.
 *
 * The system calculates the position of the popup bar by summing the bottom bar height and the bottom of the insets.
 *
 * @warning This API is experimental and will probably change in the future. Use with care.
 */
@property (nonatomic, readonly) UIEdgeInsets insetsForBottomDockingView;

@end

@interface UIViewController (Deprecations)

/**
 * @warning This API is deprecated. Use @c bottomDockingViewForPopupBar instead.
 */
@property (nullable, nonatomic, strong, readonly) __kindof UIView* bottomDockingViewForPopup LN_UNAVAILABLE_API("Use @c bottomDockingViewForPopupBar instead.");

@end

NS_ASSUME_NONNULL_END
