//
//  LocationsController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

import UIKit

class LocationsController: UITableViewController {
	@IBOutlet weak var searchBar: HigherSearchBar!
	
	override var prefersStatusBarHidden: Bool {
		get {
			return true
		}
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		get {
			return .slide
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		searchBar.text = popupItem.title
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView .deselectRow(at: indexPath, animated: true)
		searchBar.resignFirstResponder()
		popupItem.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
		popupPresentationContainer?.closePopup(animated: true, completion: nil)
	}
}
