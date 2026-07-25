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
		LNApplyTitleWithSettings(to: self)
#endif
    }

#if LNPOPUP
	override func viewDidMove(toPopupContainerContentView popupContentView: LNPopupContentView?) {
		super.viewDidMove(toPopupContainerContentView: popupContentView)
		
		guard let popupBar = popupPresentationContainer?.popupBar else {
			return
		}
		
		let useCompact = LNBarIsClassicCompact(popupBar)
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage("map.fill", scale: useCompact ? .compact : .normal)
		popupItem.barButtonItems = [gridBarButtonItem]
	}
#endif
}
