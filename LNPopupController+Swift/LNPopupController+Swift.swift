//
//  LNPopupController+Swift.swift
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
import SwiftUI
#if canImport(LNPopupController_ObjC)
@_exported import LNPopupController_ObjC
#endif

public
extension Double {
	/// The default popup snap percent. See `LNPopupInteractionStyle.customizedSnap(percent:)` for more information.
	static var defaultPopupSnapPercent: Double {
		return __LNSnapPercentDefault
	}
}

public
extension UIViewController {
	/// Available interaction styles with the popup bar and popup content view.
	enum PopupInteractionStyle {
		/// The default interaction style for the current environment.
		case `default`
		/// Drag interaction style.
		case drag
		/// Snap interaction style.
		case snap
		/// Customized snap interaction style.
		/// - Parameter percent: The percent of the container controller's view height to drag before closing the popup.
		case customizedSnap(percent: Double)
		/// Scroll interaction style.
		case scroll
		/// No interaction.
		case none
	}

	
	/// The popup bar interaction style.
	var popupInteractionStyle: PopupInteractionStyle {
		get {
			switch __popupInteractionStyle {
			case .default:
				return .default
			case .drag:
				return .drag
			case .snap:
				return __popupSnapPercent == .defaultPopupSnapPercent ? .snap : .customizedSnap(percent: __popupSnapPercent)
			case .scroll:
				return .scroll
			case .none:
				return .none
			@unknown default:
				fatalError("Please open an issue here: https://github.com/LeoNatan/LNPopupController/issues/new/choose")
			}
		}
		set {
			switch newValue {
			case .default:
				__popupInteractionStyle = .default
				return
			case .drag:
				__popupInteractionStyle = .drag
				return
			case .snap:
				__popupInteractionStyle = .snap
				__popupSnapPercent = .defaultPopupSnapPercent
				return
			case .customizedSnap(let percent):
				__popupInteractionStyle = .snap
				__popupSnapPercent = percent
				return
			case .scroll:
				__popupInteractionStyle = .scroll
				return
			case .none:
				__popupInteractionStyle = .none
				return
			}
		}
	}
	
	/// The effective popup interaction style. (read-only)
	///
	/// Use this property's value to determine, at runtime, what interaction style the system has chosen to use.
	var effectivePopupInteractionStyle: PopupInteractionStyle {
		switch __effectivePopupInteractionStyle {
		case .drag:
			return .drag
		case .snap:
			return __popupSnapPercent == .defaultPopupSnapPercent ? .snap : .customizedSnap(percent: __popupSnapPercent)
		case .scroll:
			return .scroll
		case .none:
			return .none
		case .default:
			fallthrough
		@unknown default:
			fatalError("Please open an issue here: https://github.com/LeoNatan/LNPopupController/issues/new/choose")
		}
	}
}

public
extension LNPopupItem {
	/// The popup item's attributed title.
	///
	/// If no title or subtitle is set, the system will use the view controller's title.
	@available(iOS 15, *)
	var attributedTitle: AttributedString? {
		get {
			return __attributedTitle != nil ? AttributedString(__attributedTitle!) : nil
		}
		set {
			__attributedTitle = newValue == nil ? nil : NSAttributedString(newValue!)
		}
	}
	
	/// The popup item's attributed subtitle.
	@available(iOS 15, *)
	var attributedSubtitle: AttributedString? {
		get {
			return __attributedSubtitle != nil ? AttributedString(__attributedSubtitle!) : nil
		}
		set {
			__attributedSubtitle = newValue == nil ? nil : NSAttributedString(newValue!)
		}
	}
}

public
extension LNPopupBarAppearance {
	/// Display attributes for the popup bar’s title text.
	///
	/// Only attributes from the UIKit scope are supported.
	@available(iOS 15, *)
	var titleTextAttributes: AttributeContainer? {
		get {
			return __titleTextAttributes != nil ? AttributeContainer(__titleTextAttributes!) : nil
		}
		set {
			__titleTextAttributes = newValue != nil ? Dictionary(newValue!) : nil
		}
	}
	
	/// Display attributes for the popup bar’s subtitle text.
	///
	/// Only attributes from the UIKit scope are supported.
	@available(iOS 15, *)
	var subtitleTextAttributes: AttributeContainer? {
		get {
			return __subtitleTextAttributes != nil ? AttributeContainer(__subtitleTextAttributes!) : nil
		}
		set {
			__subtitleTextAttributes = newValue != nil ? Dictionary(newValue!) : nil
		}
	}
	
#if compiler(>=6.2)
	/// A configuration that defines the corners of the floating background view.
	///
	/// Set to `nil` to use the system default.
	@available(iOS 26, *)
	var floatingBackgroundCornerConfiguration: UICornerConfiguration? {
		//These convert from/to Swift UIKit.UICornerConfiguration to/from Objective C UICornerConfiguration
		get {
			if let __floatingBackgroundCornerConfiguration {
				let helper = UIView()
				helper.setValue(__floatingBackgroundCornerConfiguration, forKey: "cornerConfiguration")
				return helper.cornerConfiguration
			} else {
				return nil
			}
		}
		set {
			if let newValue {
				let helper = UIView()
				helper.cornerConfiguration = newValue
				setValue(helper.value(forKey: "cornerConfiguration"), forKey: "floatingBackgroundCornerConfiguration")
			} else {
				__floatingBackgroundCornerConfiguration = nil
			}
		}
	}
#endif
}

public
extension UIViewController {
	/// Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation. The popup bar is attached to the receiver's docking view.
	///
	/// You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
	///
	/// The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
	/// - Parameters:
	///   - contentViewController: The controller for popup presentation.
	///   - openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
	///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	///   - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func presentPopupBar(with contentViewController: UIViewController, openPopup: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
		__presentPopupBar(withContentViewController: contentViewController, openPopup: openPopup, animated: animated, completion: completion)
	}
	
	/// Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation. The popup bar is attached to the receiver's docking view.
	///
	/// You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
	///
	/// The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
	/// - Parameters:
	///   - contentViewController: The controller for popup presentation.
	///   - openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
	///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	///   - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	@available(*, deprecated, message: "Use presentPopupBar(with:openPopup:animated:completion:) instead.")
	func presentPopupBar(withContentViewController contentViewController: UIViewController, openPopup: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
		__presentPopupBar(withContentViewController: contentViewController, openPopup: openPopup, animated: animated, completion: completion)
	}
	
	/// Opens the popup, displaying the content view controller's view.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the popup is opened. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func openPopup(animated: Bool = true, completion: (() -> Void)? = nil) {
		__openPopup(animated: animated, completion: completion)
	}
	
	/// Closes the popup, hiding the content view controller's view.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the popup is closed. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func closePopup(animated: Bool = true, completion: (() -> Void)? = nil) {
		__closePopup(animated: animated, completion: completion)
	}
	
	/// Dismisses the popup presentation, closing the popup if open and dismissing the popup bar.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the dismissal. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func dismissPopupBar(animated: Bool = true, completion: (() -> Void)? = nil) {
		__dismissPopupBar(animated: animated, completion: completion)
	}
}

public
extension LNPopupBar {
	/// A trait that specifies the `LNPopupBar.Environment`, if any, of the view or view controller. It is set on popup bars, views inside custom popup bars and popup content view controllers. Defaults to `LNPopupBar.Environment.unspecified`.
	struct EnvironmentTrait: UITraitDefinition {
		public static let defaultValue = LNPopupBar.Environment.unspecified
		public static let name = "LNPopupBarEnvironmentTrait"
		public static let identifier = "com.LeoNatan.LNPopupController.LNPopupBarEnvironmentTrait"
	}
	
	@available(iOS 17.0, *)
	struct Placement: EnvironmentKey, UITraitBridgedEnvironmentKey {
		public static
		let defaultValue = LNPopupBar.Environment.unspecified
		
		public static
		func read(from traitCollection: UITraitCollection) -> LNPopupBar.Environment {
			traitCollection.popUpBarEnvironment
		}
		
		public static
		func write(to mutableTraits: inout any UIMutableTraits, value: LNPopupBar.Environment) {
			
		}
	}
}

public
extension UITraitCollection {
	/// The popup bar environment represents whether a given trait collection is from a popup bar, a view in a custom popup bar or a popup content view controller.
	var popUpBarEnvironment: LNPopupBar.Environment {
		guard #available(iOS 17.0, *) else {
			return .unspecified
		}
		
		return self[LNPopupBar.EnvironmentTrait.self]
	}
}

public
extension EnvironmentValues {
	var popupBarPlacement: LNPopupBar.Environment {
		get {
			guard #available(iOS 17.0, *) else {
				return .unspecified
			}
			
			return self[LNPopupBar.Placement.self] }
		set { guard #available(iOS 27.0, *) else { return }
			self[LNPopupBar.Placement.self] = newValue
		}
	}
}


