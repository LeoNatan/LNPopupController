//
//  MapViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan (Wix) on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

import LNPopupController
import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate {
	@IBOutlet weak var mapView: MKMapView!
	private var popupContentVC: LocationsController!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as! CustomMapBarViewController
		customMapBar.view.backgroundColor = .clear
		customMapBar.searchBar.delegate = self
		
		popupBar.customBarViewController = customMapBar
		popupContentView.popupCloseButtonStyle = .none
		popupInteractionStyle = .snap
		
		popupContentVC = storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController
		popupContentVC.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
		
		presentPopupBar(withContentViewController: popupContentVC, animated: false, completion: nil)
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		openPopup(animated: true, completion: nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
			self.popupContentVC.searchBar.becomeFirstResponder()
		}
		
		return false;
	}
	
	@IBAction @objc private func backButtonTapped(_ sender: Any) {
	}
}
