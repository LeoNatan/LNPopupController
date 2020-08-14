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
		
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		#if LNPOPUP
		searchBar.text = popupItem.title
		#endif
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView .deselectRow(at: indexPath, animated: true)
		searchBar.resignFirstResponder()
		#if LNPOPUP
		popupItem.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
		popupPresentationContainer?.closePopup(animated: true, completion: nil)
		#endif
	}
}
