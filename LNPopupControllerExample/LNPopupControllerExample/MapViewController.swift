//
//  MapViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

import LNPopupController
import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var bottomVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var topVisualEffectView: UIVisualEffectView!
	private var popupContentVC: LocationsController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			bottomVisualEffectView.effect = UIBlurEffect(style: .systemThinMaterial)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as! CustomMapBarViewController
		customMapBar.view.backgroundColor = .clear
		customMapBar.searchBar.delegate = self
		
		popupBar.customBarViewController = customMapBar
		popupContentView.popupCloseButtonStyle = .none
		if #available(iOS 13.0, *) {
			popupContentView.backgroundStyle = .systemUltraThinMaterial
		} else {
			popupContentView.backgroundStyle = .extraLight
		}
//		popupContentView.isTranslucent = false
		popupInteractionStyle = .snap
		
		popupContentVC = (storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController)
		popupContentVC.tableView.backgroundColor = .clear
		
		DispatchQueue.main.async {
			self.presentPopupBar(withContentViewController: self.popupContentVC, animated: false, completion: nil)
		}
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		openPopup(animated: true, completion: nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
			self.popupContentVC.searchBar.becomeFirstResponder()
		}
		
		return false;
	}
	
	@IBAction private func backButtonTapped(_ sender: Any) {
	}
}
