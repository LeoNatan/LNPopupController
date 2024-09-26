//
//  PageCardViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-27.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

import UIKit

class PageCardViewController: UIViewController {
	@IBOutlet var cardView: UIView!
	@IBOutlet var indexLabel: UILabel!
	public var index: Int = -1 {
		didSet {
			if isViewLoaded {
				indexLabel.text = "\(index)"
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		cardView.layer.cornerCurve = .continuous
		cardView.layer.cornerRadius = 40
		
		indexLabel.text = "\(index)"
    }
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
}
