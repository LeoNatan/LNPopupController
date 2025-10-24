//
//  SwiftRefinements.swift
//  LNPopupController
//
//  Created by Léo Natan on 2021-08-02.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
#if canImport(LNPopupController_ObjC)
import LNPopupController_ObjC
#endif

import SwiftUI

extension UIView {
	@objc(_ln_fixUIHostingViewHitTest)
	static private
	func __fixUIHostingViewHitTest() {
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

	@objc(_ln_animateUsingSwiftUIWithDuration:animations:completion:)
	static private
	func __animateUsingSwiftUI(duration: TimeInterval, changes: @escaping () -> Void, completion: (() -> Void)? = nil) {
		if #available(iOS 18.0, *) {
			UIView.animate(.spring(.snappy(duration: duration)), changes: changes, completion: completion)
		} else {
			UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0.0, animations: changes) { _ in
				completion?()
			}
		}
	}
	
	@objc(_ln_animateInteractiveUsingSwiftUIWithDuration:animations:completion:)
	static private
	func __animateInteractiveUsingSwiftUI(duration: TimeInterval, changes: @escaping () -> Void, completion: (() -> Void)? = nil) {
		if #available(iOS 18.0, *) {
			UIView.animate(.interactiveSpring(duration: duration), changes: changes, completion: completion)
		} else {
			UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0.0, animations: changes) { _ in
				completion?()
			}
		}
	}
}
