//
//  ScrollingMapViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 27/9/24.
//  Copyright © 2024 Léo Natan. All rights reserved.
//

import UIKit

class ScrollingMapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

		let useCompact = UserDefaults.settings.integer(forKey: .barStyle) == LNPopupBar.Style.compact.rawValue
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage("map", useCompactConfig: useCompact)
		popupItem.barButtonItems = [gridBarButtonItem]
		
		LNApplyTitleWithSettings(to: self)
    }
}
