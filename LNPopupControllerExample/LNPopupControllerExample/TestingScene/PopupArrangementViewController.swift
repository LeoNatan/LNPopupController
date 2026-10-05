//
//  PopupArrangementViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 4/10/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

import UIKit

#if canImport(UIKit, _version: 9127.0.85)
@available(iOS 27.1, *) @objc public
class PopupArrangementViewController: UIArrangementViewController {
	weak var containingPopupContentView: LNPopupContentView?
	
	public override func viewDidMove(toPopupContainerContentView popupContentView: LNPopupContentView?) {
		super.viewDidMove(toPopupContainerContentView: popupContentView)
		
		containingPopupContentView = popupContentView
	}
	
	public override func addChild(_ childController: UIViewController) {
		super.addChild(childController)
		
		DispatchQueue.main.async {
			childController.viewDidMove(toPopupContainerContentView: self.containingPopupContentView)
		}
	}
	
	public override var popupItem: LNPopupItem {
		viewController(for: .primary)?.popupItem ?? super.popupItem
	}
}
#endif
