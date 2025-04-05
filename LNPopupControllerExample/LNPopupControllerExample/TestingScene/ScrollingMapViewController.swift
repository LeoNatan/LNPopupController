//
//  ScrollingMapViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-27.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

class ScrollingMapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

#if LNPOPUP
		let useCompact = UserDefaults.settings.integer(forKey: .barStyle) == LNPopupBar.Style.compact.rawValue
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage("map", scale: useCompact ? .compact : .normal)
		popupItem.barButtonItems = [gridBarButtonItem]
		
		LNApplyTitleWithSettings(to: self)
#endif
    }
}
