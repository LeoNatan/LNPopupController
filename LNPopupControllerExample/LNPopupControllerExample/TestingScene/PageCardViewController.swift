//
//  PageCardViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-27.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

class PageCardViewController: UIViewController {
	@IBOutlet var cardView: UIView!
	@IBOutlet var indexLabel: UILabel!
	public
var prefix: String? = nil {
		didSet {
			if isViewLoaded {
				indexLabel.text = "\(prefix == nil ? "" : prefix!)\(index)"
			}
		}
	}
	public
var index: Int = -1 {
		didSet {
			if isViewLoaded {
				indexLabel.text = "\(prefix == nil ? "" : prefix!)\(index)"
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		cardView.layer.cornerCurve = .continuous
		cardView.layer.cornerRadius = 40
		
		indexLabel.text = "\(prefix == nil ? "" : prefix!)\(index)"
    }
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
}
