//
//  CatalystLandingViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 17/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#if targetEnvironment(macCatalyst)

import UIKit

@objc(LNCatalystLandingViewController)
class CatalystLandingViewController: UISplitViewController {
	init() {
		super.init(style: .doubleColumn)
		
		primaryBackgroundStyle = .sidebar
		let sidebar = SidebarViewController()
		setViewController(sidebar, for: .primary)
		
		let contentNavigationController = UINavigationController()
		
#if LNPOPUP
		let demoPopupApplier: (UIViewController) -> Void = { viewController in
			let demo = IntroWebViewController()
			viewController.presentPopupBar(with: demo, animated: false)
			viewController.popupBar.addInteraction(LNPopupDemoContextMenuInteraction())
		}
		
		demoPopupApplier(self)
#endif
		
		setViewController(contentNavigationController, for: .secondary)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#endif
