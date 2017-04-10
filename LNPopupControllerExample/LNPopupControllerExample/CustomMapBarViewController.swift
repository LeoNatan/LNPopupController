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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = CGSize(width: -1, height: 65)
		wantsDefaultPanGestureRecognizer = false
	}
	
	override func popupItemDidUpdate() {
		searchBar.text = containingPopupBar.popupItem?.title
	}
}
