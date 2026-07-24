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
#if LNPOPUP
	let popupContentController = IntroWebViewController()
#endif
	
	init() {
		super.init(style: .doubleColumn)
		
		minimumPrimaryColumnWidth = 250
		maximumPrimaryColumnWidth = 400
		
		preferredSplitBehavior = .tile
		preferredDisplayMode = .oneBesideSecondary
		
		primaryBackgroundStyle = .sidebar
		let sidebar = SidebarViewController()
		setViewController(sidebar, for: .primary)
		
		let contentNavigationController = UINavigationController()
		setViewController(contentNavigationController, for: .secondary)
		
#if LNPOPUP
		presentPopupBar(with: popupContentController, animated: false)
		popupBar.addInteraction(LNPopupDemoContextMenuInteraction())
		popupBar.inheritsAppearanceFromDockingView = false
		popupBar.tintColor = .label
		popupBar.progressViewStyle = .bottom
		popupBar.semanticContentAttribute = .forceLeftToRight
		popupContentView.popupCloseButtonPositioning = .leading
#endif
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		popupContentController.setNeedsPopupButtonsUpdate(animated: false)
	}
}

#endif
