//
//  SwiftRefinements.swift
//  LNPopupController
//
//  Created by Leo Natan on 8/2/21.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

import UIKit
#if canImport(LNPopupController_ObjC)
@_exported import LNPopupController_ObjC
#endif

extension Double {
	/// The default popup snap percent. See `LNPopupInteractionStyle.customizedSnap(percent:)` for more information.
	static var defaultPopupSnapPercent: Double {
		return __LNSnapPercentDefault
	}
}

/// Available interaction styles with the popup bar and popup content view.
public enum LNPopupInteractionStyle {
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

public extension UIViewController {
	/// The popup bar interaction style.
	var popupInteractionStyle: LNPopupInteractionStyle {
		get {
			switch __popupInteractionStyle {
			case .none:
				return .none
			case .drag:
				return .drag
			case .snap:
				return __popupSnapPercent == .defaultPopupSnapPercent ? .snap : .customizedSnap(percent: __popupSnapPercent)
			default:
				return .default
			}
		}
		set {
			switch newValue {
			case .none:
				__popupInteractionStyle = .none
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
			default:
				__popupInteractionStyle = .default
				return
			}
		}
	}
}

public extension LNPopupItem {
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

public extension LNPopupBarAppearance {
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

public extension UIBlurEffect.Style {
	@available(*, deprecated, message: "Use LNPopupBarAppearance instead.")
	static var popupBarBackgroundInheritEffectStyle: Self {
		return __LNBackgroundStyleInherit
	}
}
