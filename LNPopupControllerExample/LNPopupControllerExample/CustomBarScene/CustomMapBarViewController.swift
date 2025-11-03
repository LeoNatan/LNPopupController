//
//  CustomMapBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
import UIKit

class CustomMapBarViewController: LNPopupCustomBarViewController {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet var heightConstraint: NSLayoutConstraint!

	override var wantsDefaultTapGestureRecognizer: Bool {
		return false
	}
	
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return false
	}
	
	fileprivate func updateConstraint() {
		heightConstraint.constant = 65
		self.preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		updateConstraint()
		
		if #available(iOS 26.0, *), LNPopupSettingsHasOS26Glass() {
			updateFromUserInterfaceStyle()
		} else {
			guard let backgroundView = containingPopupBar?.value(forKey: "backgroundView") as? UIView else {
				return
			}
			
			backgroundView.clipsToBounds = true
			backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			backgroundView.layer.cornerRadius = 20
			backgroundView.layer.cornerCurve = .continuous
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		if #available(iOS 26.0, *) {
			updateFromUserInterfaceStyle()
		}
	}
	
	@available(iOS 26.0, *)
	func updateFromUserInterfaceStyle() {
		containingPopupBar?.standardAppearance.configureWithOpaqueFloatingBackground()
		if containingPopupBar?.traitCollection.userInterfaceStyle == .dark {
			searchBar.searchTextField.backgroundColor = .clear
			let glass = UIGlassEffect(style: .clear)
			glass.isInteractive = true
			glass.tintColor = UIColor.systemBackground.withAlphaComponent(0.55)
			containingPopupBar?.standardAppearance.floatingBackgroundEffect = glass
		} else {
			searchBar.searchTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
			containingPopupBar?.standardAppearance.configureWithDefaultFloatingBackground()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func popupItemDidUpdate() {
		searchBar.text = popupItem.title
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { [unowned self] context in
			updateConstraint()
		}, completion: nil)
	}
}
#endif
