//
//  MapViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#if LNPOPUP
import LNPopupController
#endif
import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var topVisualEffectView: UIVisualEffectView!
	private var popupContentVC: LocationsController!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		#if LNPOPUP
		let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as! CustomMapBarViewController
		customMapBar.view.backgroundColor = .clear
		customMapBar.searchBar.delegate = self
		
		popupBar.customBarViewController = customMapBar
		popupContentView.popupCloseButtonStyle = .none
		if #available(iOS 13.0, *) {
			popupContentView.backgroundStyle = .systemChromeMaterial
		} else {
			popupContentView.backgroundStyle = .extraLight
		}
//		popupContentView.isTranslucent = false
		popupInteractionStyle = .snap
		
		popupContentVC = (storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController)
		popupContentVC.tableView.backgroundColor = .clear
		
		self.presentPopupBar(withContentViewController: self.popupContentVC, animated: false, completion: nil)
		#endif
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		#if LNPOPUP
		openPopup(animated: true, completion: nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
			self.popupContentVC.searchBar.becomeFirstResponder()
		}
		#endif
		
		return false;
	}
	
	@IBAction private func backButtonTapped(_ sender: Any) {
	}
}
