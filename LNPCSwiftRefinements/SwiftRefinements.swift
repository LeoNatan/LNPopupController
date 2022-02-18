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

/// Available interaction styles with the popup bar and popup content view.
public enum LNPopupInteractionStyle {
	public init?(rawValue: Int) {
		guard let objc = __LNPopupInteractionStyle(rawValue: rawValue) else {
			return nil
		}
		
		switch objc {
		case .none:
			self = .none
		case .drag:
			self = .drag
		case .snap:
			self = .snap
		default:
			self = .default
		}
	}
	
	/// The default interaction style for the current environment.
	///
	/// On iOS, the default interaction style is `snap`.
	///
	/// On macOS, the default interaction style is `scroll`.
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
				return __popupSnapPercent == LNSnapPercentDefault ? .snap : .customizedSnap(percent: __popupSnapPercent)
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
