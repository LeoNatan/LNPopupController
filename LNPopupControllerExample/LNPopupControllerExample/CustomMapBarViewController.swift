//
//  CustomMapBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

import UIKit

class CustomMapBarViewController: LNPopupCustomBarViewController {
	@IBOutlet weak var searchBar: HigherSearchBar!
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		get {
			return false;
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = CGSize(width: -1, height: 65)
	}
	
	override func popupItemDidUpdate() {
		searchBar.text = containingPopupBar.popupItem?.title
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { [unowned self] context in
			self.preferredContentSize = CGSize(width: -1, height: self.traitCollection.horizontalSizeClass == .regular ? 45 : 65)
		}, completion: nil)
	}
}
