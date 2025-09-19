# LNPopupController

LNPopupController is a framework for presenting view controllers as popups of other view controllers, similar to the Apple Music and Podcasts mini-players.

For SwiftUI, check out the [LNPopupUI library](https://github.com/LeoNatan/LNPopupUI).

[![GitHub release](https://img.shields.io/github/release/LeoNatan/LNPopupController.svg)](https://github.com/LeoNatan/LNPopupController/releases) [![GitHub stars](https://img.shields.io/github/stars/LeoNatan/LNPopupController.svg)](https://github.com/LeoNatan/LNPopupController/stargazers) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/LeoNatan/LNPopupController/master/LICENSE) <span class="badge-paypal"><a href="https://paypal.me/LeoNatan25" title="Donate to this project using PayPal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg?style=flat" alt="PayPal Donation Button" /></a></span>

[![GitHub issues](https://img.shields.io/github/issues-raw/LeoNatan/LNPopupController.svg)](https://github.com/LeoNatan/LNPopupController/issues) [![GitHub contributors](https://img.shields.io/github/contributors/LeoNatan/LNPopupController.svg)](https://github.com/LeoNatan/LNPopupController/graphs/contributors) [![Swift Package Manager compatible](https://img.shields.io/badge/swift%20package%20manager-compatible-green)](https://swift.org/package-manager/) [![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center"><img src="./Supplements/open_floating_popup.gif"/></p>

Once a popup bar is presented with a content view controller, the user can swipe or tap the popup bar at any point to present the popup. After finishing, the user dismisses the popup by either swiping or tapping the popup close button.

The framework is intended to be very generic and work in most situations, so it is implemented as a category over `UIViewController`. Each view controller can present a popup bar, docked to a bottom view. 
For `UITabBarController` and its subclasses, the default docking view is the tab bar. 
For `UINavigationController` and its subclasses, the default docking view is the toolbar.
For other view controllers, the popup bar is presented at the bottom of the screen. View controller subclasses can provide their own docking views.

The framework correctly maintains the safe area insets of the container controller’s view and its child controllers, as the popup bar is presented and dismissed.

The information displayed on the popup bar is provided dynamically with popup item objects (instances of the `LNPopupItem` class) associated with the popup content view controllers. To change this information, update the popup item of the view controller.

Generally, it is recommended to present the popup bar on the outermost container controller. So if you have a view controller contained in a navigation controller, which is in turn contained in a tab bar controller, it is recommended to present the popup bar on the tab bar controller.

Check the demo project for many common use cases of the framework in various scenarios. It contains examples in Swift and Objective C.

> [!NOTE]
> To run the example project, don't forget to update submodules by running: `git submodule update --init --recursive`

### Features

* Supports iOS 26 glass design, while maintaining a system-apropriate look and feel on previous iOS versions
* Available for iOS 13 and above, as an Xcode framework or an SPM package
* Good citizen in modern UIKit world
* For SwiftUI, check out the [LNPopupUI library](https://github.com/LeoNatan/LNPopupUI).

## Adding to Your Project

### Swift Package Manager

Swift Package Manager is the recommended way to integrate `LNPopupController` in your project.

`LNPopupController` supports SPM versions 6.0 and above (Xcode 16). In Xcode, click `File` → `Add Package Dependencies…`, enter `https://github.com/LeoNatan/LNPopupController`. Select the version you’d like to use.

You can also manually add the package to your Package.swift file:

```swift
.package(url: "https://github.com/LeoNatan/LNPopupController.git", from: "4.0.0")
```

And the dependency in your target:

```swift
.target(name: "MyExampleApp", dependencies: ["LNPopupController"]),
```

## Using the Framework

### Project Integration

Import the module in your source files:

```swift
import LNPopupController
```

### Managing the Popup Bar

To present the popup bar, create a content controller, update its popup item and present the popup bar using `presentPopupBar(with:animated:completion:)`.

```swift
let demoVC = DemoPopupContentViewController()
demoVC.view.backgroundColor = .red
demoVC.popupItem.title = "Hello Title"
demoVC.popupItem.subtitle = "And a Subtitle!"
demoVC.popupItem.progress = 0.34
    
tabBarController?.presentPopupBar(with: demoVC, animated: true, completion: nil)
```

You can present a new content controller while the popup bar is presented and even when the popup itself is open.

To open and close the popup programatically, use `openPopup(animated:completion:)` and `closePopup(animated:completion:)` respectively.

```swift
tabBarController?.openPopup(animated: true, completion: nil)
```

Alternatively, you can present the popup bar and open the popup in one animation, using `presentPopupBar(with:openPopup:animated:completion:)`.

```swift
tabBarController?.presentPopupBar(with: demoVC, openPopup:true, animated: true, completion: nil)
```

To dismiss the popup bar, use `dismissPopupBar(animated:completion:)`.

```swift
tabBarController?.dismissPopupBar(animated: true, completion: nil)
```

If the popup is open when dismissing the popup bar, the popup will also be closed.

### Popup Items

A popup item should always reflect the popup information about the view controller with which it is associated. The popup item should provide a title and subtitles to display in the popup bar, when the view controller is presented as a popup content controller. In addition, the item may contain bar buttons to display, by setting the `barButtonItems` property.

### Popup Container View Controllers

Any `UIViewController` subclasses can be popup container view controllers. The popup bar is attached to a bottom docking view. By default, `UITabBarController` and `UINavigationController` subclasses return their bottom bars as docking view, while other controllers return a hidden 0pt height view on the bottom of the view. In your subclass, override `bottomDockingViewForPopupBar` and `defaultFrameForBottomDockingView` and return your view and frame accordingly. **The returned view must be attached to the bottom of the view controller's view, or results are undefined.**

```swift
override var bottomDockingViewForPopupBar: UIView? {
  return myCoolBottomView
}

override var defaultFrameForBottomDockingView: CGRect {
  var bottomViewFrame = myCoolBottomView.frame
  
  if isMyCoolBottomViewHidden {
    bottomViewFrame.origin = CGPoint(x: bottomViewFrame.x, y: view.bounds.height)
  } else {
    bottomViewFrame.origin = CGPoint(x: bottomViewFrame.x, y: view.bounds.height - bottomViewFrame.height)
  }
  
  return bottomViewFrame
}
```

### Appearance and Behavior

`LNPopupController` provides many different properties to present users with popup bars, open popups and let the user interact with them. By default, the framework chooses styles to match the user’s current operating system version, but can all be customized as required.

<p align="center"><img src="./Supplements/floating_bar_style.gif" width="360"/></p>

The defaults are:

- iOS 26:

  - Floating compact bar style
  - Snap interaction style
  - Grabber close button style

- iOS 17-18:

  - Floating bar style
  - Snap interaction style
  - Grabber close button style

- iOS 16 and below:

  - Prominent bar style
  - Snap interaction style
  - Chevron close button style

> [!NOTE]
> On iOS 26 and above, `UIDesignRequiresCompatibility` is supported, and the framework will use legacy styles and appearance when the key is present in your app’s Info.plist and is set to `YES`.

You can also present completely custom popup bars. For more information, see [Custom Popup Bars](#custom-popup-bars).

By default, for navigation and tab bar container controllers, the popup bar inherits its appearance from the bottom bar. For other container controllers, a default appearance is used, most suitable for the current environment.

To disable inheriting the bottom bar’s appearance, set the `inheritsAppearanceFromDockingView` property to `false`.

#### Bar Style

Customizing the popup bar style is achieved by setting the popup bar's `barStyle` property.

Starting with iOS 26, the framework supports primarily a floating and a compact floating popup bar.

```swift
navigationController?.popupBar.barStyle = .floating
```

###### Floating Compact:

<p align="center"><img src="./Supplements/floating_compact_no_scroll.gif" width="360"/></p>

###### Floating:

<p align="center"><img src="./Supplements/floating_no_scroll.gif" width="360"/></p>

##### Legacy Bar Styles

On iOS 18 and below, the framework presents popup bar styles and animations that are appropriate for the user's operating system. Non-floating prominent and compact bar styles are also available.

###### Floating:
<p align="center"><img src="./Supplements/legacy_floating_no_scroll.gif" width="360"/>

###### Prominent:
<p align="center"><img src="./Supplements/legacy_modern_no_scroll.gif" width="360"/></p>

###### Compact:
<p align="center"><img src="./Supplements/legacy_compact_scroll.gif" width="360"/></p>

> [!NOTE]
> On iOS 26 and later, non-floating bar styles will be automatically converted to the appropriate floating style.

#### Interaction Style

Customizing the popup interaction style is achieved by setting the popup presentation containing controller's `popupInteractionStyle` property.

```swift
navigationController?.popupInteractionStyle = .drag
```

<p align="center"><img src="./Supplements/interaction_snap.gif" width="360"/> <img src="./Supplements/interaction_drag.gif" width="360"/></p>

#### Progress View Style

Customizing the popup bar progress view style is achieved by setting the popup bar's `progressViewStyle` property.

```swift
navigationController?.popupBar.progressViewStyle = .top
```

By default, progress view is hidden.

<p align="center"><img src="./Supplements/progress_view_none.png" width="360"/><br/><br/><img src="./Supplements/progress_view_top.png" width="360"/><br/><br/><img src="./Supplements/progress_view_bottom.png" width="360"/></p>

#### Close Button Style

Customizing the popup close button style is achieved by setting the popup content view's `popupCloseButtonStyle` property.

```swift
navigationController.popupContentView.popupCloseButtonStyle = .round
```

To hide the popup close button, set the `popupCloseButtonStyle` property to `LNPopupCloseButton.Style.none`.

<p align="center"><img src="./Supplements/close_button_grabber.png" width="360"/><br/><br/><img src="./Supplements/close_button_chevron.png" width="360"/><br/><br/><img src="./Supplements/close_button_round.png" width="360"/><br/><br/><img src="./Supplements/close_button_none.png" width="360"/></p>

#### Text Marquee Scroll

Supplying long text for the title and/or subtitle will result in a scrolling text, if text marquee is enabled. Otherwise, the text will be truncated.

<p align="center"><img src="./Supplements/floating_no_scroll_delay.gif" width="360"/> <img src="./Supplements/legacy_compact_scroll.gif" width="360"/></p>

#### Popup Transitions

The framework supports popup image transitions:

<p align="center"><img src="./Supplements/popup_transitions.gif" width="360"/></p>

Transitions are opt-in and require you either use an `LNPopupImageView` image view in your popup content, which is discovered automatically by the system, or provide a view that will serve as the transition target/source by implementing `viewForPopupTransition(from:to:)` in popup content controller.

For optimal results, use an `LNPopupImageView` instance in your popup content view hierarchy, that displays the same image displayed in the popup bar's image view. By default, the system discovers the `LNPopupImageView` instance  automatically, and will use that as the transition target/source. The system will smoothly transition between the popup bar's image view and the `LNPopupImageView` instance, taking into account the corner radii and shadow of the view.

> [!TIP]
> When relying on automatic discovery, there must only be a single `LNPopupImageView` instance in your popup content controller's view hierarchy, or results will be undefined. For more advanced scenarios where automatic discovery fails, implement `viewForPopupTransition(from:to:)` in your content controller to return the correct instance.

You can return any custom view in `viewForPopupTransition(from:to:)` to serve as the transition target/source. The system will attempt to match the attributes of the provided view and the popup bar's image view as closely as possible to transition smoothly between them. Implement the `LNPopupTransitionView` protocol in your custom view to allow the system to smoothly transition between your custom view and the popup bar image view.

> [!CAUTION]
> Views returned from `viewForPopupTransition(from:to:)` must be part of the content controller's view hierarchy, or they will be ignored by the system and no transition will take place.

Transitions are only available for prominent and floating popup bar styles with drag interaction style. Any other combination will result in no transition and this method will not be called by the system.

#### Popup Bar Customization

`LNPopupBar` exposes many APIs to customize the popup bar's appearance. Use `LNPopupBarAppearance` objects to define the standard appearance of the bar.

Remember to set the `inheritsAppearanceFromDockingView` property to `false`, or some of your customizations might be overridden by inheriting the bottom bar’s appearance.

```swift
let appearance = LNPopupBarAppearance()
appearance.titleTextAttributes = AttributeContainer()
    .font(UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont(name: "Chalkduster", size: 14)!))
    .foregroundColor(UIColor.yellow)
appearance.subtitleTextAttributes = AttributeContainer()
    .font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont(name: "Chalkduster", size: 12)!))
    .foregroundColor(UIColor.green)

let floatingBarBackgroundShadow = NSShadow()
floatingBarBackgroundShadow.shadowColor = UIColor.red
floatingBarBackgroundShadow.shadowOffset = .zero
floatingBarBackgroundShadow.shadowBlurRadius = 8.0
appearance.floatingBarBackgroundShadow = floatingBarBackgroundShadow

let imageShadow = NSShadow()
imageShadow.shadowColor = UIColor.yellow
imageShadow.shadowOffset = .zero
imageShadow.shadowBlurRadius = 3.0
appearance.imageShadow = imageShadow

appearance.floatingBackgroundEffect = UIBlurEffect(style: .dark)

navigationController?.popupBar.standardAppearance = appearance
navigationController?.popupBar.tintColor = .yellow
```

<p align="center"><img src="./Supplements/floating_custom.png" width="360"/></p>

#### System Interactions

##### Bar Transitions

The `hidesBottomBarWhenPushed` property is supported for navigation and tab bar controllers. When set to `true`, the popup bar will transition to the bottom of the pushed controller's view. Setting  `isToolbarHidden = true` and calling `setToolbarHidden(_:animated:)` are also supported.

<p align="center"><img src="./Supplements/hidesBottomBar_TabBar.gif" width="360"/> <img src="./Supplements/hidesBottomBar_Toolbar.gif" width="360"/></p>

##### Tab Bar Sidebar

Starting with iPadOS 18, the framework supports `UITabBarController` sidebars. When the sidebar displaces the underlying content, the popup bar moves out of the way.

<p align="center"><img src="./Supplements/tab_bar_sidebar_floating.gif" width="600"/></p>

When the sidebar overlays the underlying content, the popup bar dims together with the content:

<p align="center"><img src="./Supplements/tab_bar_sidebar_portrait_floating.png" width="360"/></p>



##### Status Bar Management

Status bar management of the popup content view controller is respected and applied when appropriate.

<p align="center"><img src="./Supplements/statusbar_style.gif" width="360"/> <img src="./Supplements/statusbar_hidden.gif" width="360"/></p>

Home indicator visibility control is respected and applied when appropriate.

##### Context Menu Interactions

Context menus are supported. Add a `UIContextMenuInteraction` interaction object to the popup bar, and it will behave as expected.

<p align="center"><img src="./Supplements/popup_bar_context_menu.png" width="360"/></p>

##### Pointer Interactions

Pointer interactions are supported, and a default implementation is provided for system bar styles.

For custom popup bar controllers, the `LNPopupCustomBarViewController` class implements the `UIPointerInteractionDelegate` protocol. Implement the protocol's methods inside your subclass to implement custom pointer interactions.

<p align="center"><img src="./Supplements/pointer_interaction.gif"/></p>

##### Scroll-edge Appearance

With iOS versions 15 up to 18, scroll-edge appearance is automatically disabled for toolbars and tab bars when a popup bar is presented, regardless of the scroll position of the content. Once the popup bar is dismissed, the scroll-edge appearance is restored.

On iOS 26, this is no longer necessary.

<p align="center"><img src="./Supplements/scroll_edge_appearance.gif" width="360"/></p>

#### Custom Popup Bars

The framework supports implementing custom popup bars:

<p align="center"><img src="./Supplements/custom_bar.png" width="360"/></p>

To implement a custom popup bar, you subclass `LNPopupCustomBarViewController`.

In your `LNPopupCustomBarViewController` subclass, build your popup bar's view hierarchy and set the controller's `preferredContentSize` property with the preferred popup bar height. Override any of the `wantsDefaultTapGestureRecognizer`, `wantsDefaultPanGestureRecognizer` and/or `wantsDefaultHighlightGestureRecognizer` properties to disable the default gesture recognizers functionality in your custom popup bar.

In your subclass, implement the `popupItemDidUpdate()` method to be notified of updates to the popup content view controller's item, or when a new popup content view controller is presented (with a new popup item). You must call the `super` implementation of this method.

Finally, set the `customBarViewController` property of the popup bar object to an instance of your `LNPopupCustomBarViewController` subclass. This will automatically change the bar style to `LNPopupBar.Style.custom`.

The included demo project includes two example custom popup bar scenes.

> [!TIP]
> Only implement a custom popup bar if you need a design that is significantly different than the provided [standard popup bar styles](#bar-style). A lot of care and effort has been put into integrating these popup bar styles with the UIKit system, including look, feel, transitions and interactions. Custom bars provide a blank canvas for you to implement a bar of your own, but if you end up recreating a bar design that is similar to a standard bar style, you are more than likely losing subtleties that have been added and perfected over the years in the standard implementations. Instead, consider using the [many customization APIs](#popup-bar-customization) to tweak the standard bar styles to fit your app’s design.

#### ProMotion Support

`LNPopupController` fully supports ProMotion on iPhone and iPad.

For iPhone 13 Pro and above, you need to add the `CADisableMinimumFrameDurationOnPhone` key to your Info.plist and set it to `true`. See [Optimizing ProMotion Refresh Rates for iPhone 13 Pro and iPad Pro](https://developer.apple.com/documentation/quartzcore/optimizing_promotion_refresh_rates_for_iphone_13_pro_and_ipad_pro?language=objc) for more information. `LNPopupController` will log a single warning message in the console if this key is missing, or is set to `false`.

#### Interaction Gesture Recognizer

`LNPopupContentView` exposes access to the popup interaction gesture recognizer in the way of the `popupInteractionGestureRecognizer` property. This gesture recognizer is shared for opening the popup, by swiping or panning the popup bar up (when the popup is closed), and closing the popup, by swiping or panning the popup content view down (when the popup bar is open).

When opening the popup, the system queries the `viewForPopupInteractionGestureRecognizer` property of the popup content view controller to determine which view to add the interaction gesture recognizer. By default, the property returns the content controller's root view. Override the property's getter to change this behavior.

The system attempts to cooperate as best it can with other gestures, including system gestures, controls and scrolling. When the user scrolls inside the popup content view hierarchy, the system will do its best not to interfere with the user’s gestures, and will only react when at the edge of scrolled content.

For vertically scrolling content, the popup will close only when the user swipes or drags past the scroll content’s edge.

For horizontal scrolling content, the popup will close only when user swipes or drags down and there there is no horizontal scroll.

For both multidirectional scrolling content, only `isDirectionalLockEnabled = true` is supported. In that case, the popup will close if both conditions above are met.

For multidirectional scroll content, the system will not attempt to close the popup at any point. The user can still close the popup by tapping the close button or swiping or dragging outside of the scrollable area.

You can implement the delegate of the interaction gesture recognizer in order to influence its behavior, such as preventing popup interaction when the user is interacting with other controls or views inside the popup content view hierarchy.

> [!CAUTION]
> If you disable the gesture recognizer after opening the popup, you must monitor the state of the popup and reenable the gesture recognizer once closed by the user or through code. Instead, consider either implementing `viewForPopupInteractionGestureRecognizer` and return an appropriate view, or set the gesture recognizer's delegate and provide custom logic to disable interactions when required.

#### Full Right-to-Left Support

The framework has full right-to-left support.

<p align="center"><img src="./Supplements/rtl_english.png" width="360"/> <img src="./Supplements/rtl_hebrew.png" width="360"/></p>

By default, the popup bar will follow the system's user interface layout direction, but will preserve the bar button items' order.
To customize this behavior, modify the popup bar's ```semanticContentAttribute``` and ```barItemsSemanticContentAttribute``` properties.

#### Accessibility

The framework supports accessibility and will honor accessibility labels, traits, hints and values. By default, the accessibility label of the popup bar is the title and subtitle provided by the popup item.

<p align="center"><img src="./Supplements/default_bar_accessibility_label.png" width="360"/></p>

To modify the accessibility label and hint of the popup bar, set the `accessibilityLabel` and `accessibilityHint` properties of the `LNPopupItem` object of the popup content view controller.

```swift
demoVC.popupItem.accessibilityLabel = NSLocalizedString("Custom popup bar accessibility label", comment: "")
demoVC.popupItem.accessibilityHint = NSLocalizedString("Custom popup bar accessibility hint", comment: "")
```

To add accessibility labels and hints to buttons, set the `accessibilityLabel` and `accessibilityHint` properties of the `UIBarButtonItem` objects.

```swift
let upNext = UIBarButtonItem(image: UIImage(named: "next"), style: .plain, target: self, action: #selector(nextItem))
upNext.accessibilityLabel = NSLocalizedString("Up Next", comment: "")
upNext.accessibilityHint = NSLocalizedString("Double tap to show up next list", comment: "")
```
To modify the accessibility label and hint of the popup close button, set the `accessibilityLabel` and `accessibilityHint` properties of the `LNPopupCloseButton` object of the popup container view controller.

```swift
tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Custom popup close button accessibility label", comment: "")
tabBarController?.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString("Custom popup close button accessibility hint", comment: "")
```

To modify the accessibility label and value of the popup bar progress view, set the `accessibilityProgressLabel` and `accessibilityProgressValue` properties of the `LNPopupItem` object of the popup content view controller.

```swift
demoVC.popupItem.accessibilityImageLabel = NSLocalizedString("Custom image label", comment: "")
demoVC.popupItem.accessibilityProgressLabel = NSLocalizedString("Custom accessibility progress label", comment: "")
demoVC.popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.stringFromTimeInterval(NSTimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.stringFromTimeInterval(totalTime)!)"
```

## Notes

* Legacy non-translucent tab bar and toolbars are not supported and can cause visual artifacts or layout glitches. Apple has many problem with such bars, and supporting those is not a priority for `LNPopupController`.
  * The correct way to achieve an opaque bar is to use the `UIBarAppearance.configureWithOpaqueBackground()` API, which is supported by `LNPopupController`.
* Manually setting bottom bar properties, such as setting a tab bar’s or a toolbar’s `isHidden = true` **is explicitly discouraged by Apple and not supported by the framework**; it will lead to undefined behavior by the framework.
  * `UINavigationController.setToolbarHidden(_:animated:)` and `UITabBarController.setTabBarHidden(_:animated:)` are fully supported


## Acknowledgements

The framework uses:
* [MarqueeLabel](https://github.com/cbpowell/MarqueeLabel) Copyright (c) 2011-2023 Charles Powell
* [smooth-gradient](https://github.com/janselv/smooth-gradient) Copyright (c) 2016 Jansel Valentin

Additionally, the demo project uses:

* [LoremIpsum](https://github.com/lukaskubanek/LoremIpsum) Copyright (c) 2013 Lukas Kubanek

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=LeoNatan/LNPopupController&type=Date)](https://star-history.com/#LeoNatan/LNPopupController&Date)
