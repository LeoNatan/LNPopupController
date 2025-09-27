//
//  DemoMusicSearchController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 26/9/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

import UIKit

class DemoMusicSearchController: UIViewController, UISearchResultsUpdating {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.searchController = UISearchController(searchResultsController: nil)
		navigationItem.searchController?.searchResultsUpdater = self
		
		guard #available(iOS 17.0, *) else {
			return
		}
		
		contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		guard #available(iOS 17.0, *) else {
			return
		}
		
		contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
	}
}
