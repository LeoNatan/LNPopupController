//
//  CustomMapBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#if LNPOPUP
import UIKit

class CustomMapBarView: UIView {
	override var frame: CGRect {
		didSet {
			print("Size: \(self.frame)")
		}
	}
}

class CustomMapBarViewController: LNPopupCustomBarViewController {
	@IBOutlet weak var searchBar: HigherSearchBar!
	@IBOutlet var heightConstraint: NSLayoutConstraint!
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		return false;
	}

	override var wantsDefaultTapGestureRecognizer: Bool {
		return false
	}
	
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return false
	}
	
	fileprivate func updateConstraint() {
		heightConstraint.constant = self.traitCollection.horizontalSizeClass == .regular ? 45 : 65
		self.preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		updateConstraint()
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
