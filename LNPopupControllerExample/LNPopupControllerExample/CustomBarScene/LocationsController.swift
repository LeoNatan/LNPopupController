//
//  LocationsController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
#if LNPOPUP
import LNPopupController
#endif

class LocationsController: UITableViewController, UISearchBarDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var trailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var closeButtonContainer: UIView?
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 26, *) {
			tableView.topEdgeEffect.isHidden = true
			tableView.bottomEdgeEffect.isHidden = true
		}
		
		if LNPopupSettingsHasOS26Glass() {
			trailingConstraint.constant = 74
		}
		
		searchBar.delegate = self
	}
	
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
		tableView.deselectRow(at: indexPath, animated: true)
		searchBar.resignFirstResponder()
#if LNPOPUP
		popupItem.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
		popupPresentationContainer?.closePopup()
#endif
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
#if LNPOPUP
		popupItem.title = searchText
#endif
	}
	
#if LNPOPUP
	override func positionPopupCloseButton(_ popupCloseButton: LNPopupCloseButton) -> Bool {
		closeButtonContainer?.addSubview(popupCloseButton)
		return closeButtonContainer != nil
	}
#endif
}
