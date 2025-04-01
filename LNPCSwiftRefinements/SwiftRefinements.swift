//
//  SwiftRefinements.swift
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
#if canImport(LNPopupController_ObjC)
@_exported import LNPopupController_ObjC
#endif

#if canImport(SwiftUI)
import SwiftUI

@_cdecl("__ln_doNotCall__fixUIHostingViewHitTest")
@_spi(LNPopupControllerInternal)
public
func __ln_doNotCall__fixUIHostingViewHitTest() {
	DispatchQueue.main.async {
		guard let view = UIHostingController(rootView: EmptyView()).view else {
			return
		}
		
		let cls = type(of: view)
		let sel = #selector(UIView.hitTest(_:with:))
		let method = class_getInstanceMethod(cls, sel)!
		
		let _orig: @convention(c) (_ self: UIView, _ sel: Selector, _ point: CGPoint, _ event: UIEvent?) -> UIView?
		_orig = unsafeBitCast(method_getImplementation(method), to: type(of: _orig))
		
		let orig: (UIView, CGPoint, UIEvent?) -> UIView? = { _self, point, event in
			_orig(_self, sel, point, event)
		}
		
		let impl: @convention(block) (UIView, CGPoint, UIEvent?) -> UIView? = { _self, point, event in
			if let popupContentView = _self.subviews.filter({ $0 is LNPopupContentView }).first, popupContentView.point(inside: popupContentView.convert(point, from: _self), with: event), let popupContentViewHitTest = popupContentView.hitTest(popupContentView.convert(point, from: _self), with: event) {
				return popupContentViewHitTest
			}
			
			if let popupBar = _self.subviews.filter({ $0 is LNPopupBar }).first, popupBar.point(inside: popupBar.convert(point, from: _self), with: event), let popupBarHitTest = popupBar.hitTest(popupBar.convert(point, from: _self), with: event) {
				return popupBarHitTest
			}
			
			return orig(_self, point, event)
		}
		
		method_setImplementation(method, imp_implementationWithBlock(impl))
	}
}
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
	func presentPopupBar(with contentViewController: UIViewController, openPopup: Bool = false, animated: Bool, completion: (() -> Void)? = nil) {
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
	func presentPopupBar(withContentViewController contentViewController: UIViewController, openPopup: Bool = false, animated: Bool, completion: (() -> Void)? = nil) {
		__presentPopupBar(withContentViewController: contentViewController, openPopup: openPopup, animated: animated, completion: completion)
	}
	
	/// Opens the popup, displaying the content view controller's view.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the popup is opened. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func openPopup(animated: Bool, completion: (() -> Void)? = nil) {
		__openPopup(animated: animated, completion: completion)
	}
	
	/// Closes the popup, hiding the content view controller's view.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the popup is closed. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func closePopup(animated: Bool, completion: (() -> Void)? = nil) {
		__closePopup(animated: animated, completion: completion)
	}
	
	/// Dismisses the popup presentation, closing the popup if open and dismissing the popup bar.
	/// - Parameters:
	///   - animated: Pass `true` to animate; otherwise, pass `false`.
	///   - completion: The block to execute after the dismissal. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
	func dismissPopupBar(animated: Bool, completion: (() -> Void)? = nil) {
		__dismissPopupBar(animated: animated, completion: completion)
	}
}
