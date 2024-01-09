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
	@IBOutlet weak var backButtonBackground: UIVisualEffectView!
	private var popupContentVC: LocationsController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.showsTraffic = false
		
		backButtonBackground.layer.cornerRadius = 10.0
		backButtonBackground.layer.borderWidth = 1.0
		backButtonBackground.layer.borderColor = self.view.tintColor.cgColor
		
		backButtonBackground.effect = UIBlurEffect(style: .extraLight)
		
		topVisualEffectView.effect = UIBlurEffect(blurRadius: 10)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		backButtonBackground.layer.borderColor = self.view.tintColor.cgColor
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.presentPopupBarIfNeeded(animated: false)
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
	
	@IBAction private func presentButtonTapped(_ sender: Any) {
		presentPopupBarIfNeeded(animated: true)
	}
	
	private func presentPopupBarIfNeeded(animated: Bool) {
#if LNPOPUP
		guard popupBar.customBarViewController == nil else {
			return
		}
		
		if let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as? CustomMapBarViewController {
			popupBar.customBarViewController = customMapBar
			
			customMapBar.view.backgroundColor = .clear
			customMapBar.searchBar.delegate = self
			
			if let searchTextField = customMapBar.searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
				clearButton.addTarget(self, action: #selector(self.clearButtonTapped), for: .primaryActionTriggered)
			}
			
			popupBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			popupBar.layer.cornerRadius = 15
		} else {
			//Manual layout bar scene
			shouldExtendPopupBarUnderSafeArea = false
			popupBar.customBarViewController = ManualLayoutCustomBarViewController()
		}
		
		popupContentView.popupCloseButtonStyle = .none
		popupContentView.backgroundEffect = UIBlurEffect(style: .extraLight)
		//		popupContentView.isTranslucent = false
		popupInteractionStyle = .customizedSnap(percent: 0.15)
		
		popupContentVC = (storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController)
		popupContentVC.tableView.backgroundColor = .clear
		
		presentPopupBar(withContentViewController: self.popupContentVC, animated: animated, completion: nil)
#endif
	}
	
	@objc private func clearButtonTapped(_ sender: Any) {
#if LNPOPUP
		popupContentVC.popupItem.title = nil
		popupContentVC.searchBar.text = nil
#endif
	}
	
	@IBAction private func dismissButtonTapped(_ sender: Any) {
#if LNPOPUP
		dismissPopupBar(animated: true) {
			self.popupBar.customBarViewController = nil
		}
#endif
	}
	
#if LNPOPUP
	override var shouldFadePopupBarOnDismiss: Bool {
		return true
	}
#endif
}
