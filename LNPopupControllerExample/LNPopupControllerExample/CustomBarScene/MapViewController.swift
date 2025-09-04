//
//  MapViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
import LNPopupController
#endif
import UIKit
import MapKit

private extension UIImage {
	class func gradientImage(withHeight height: CGFloat, scale: CGFloat, colors: [UIColor], locations: [CGFloat]) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: height))
		let image = renderer.image { context in
			let context = UIGraphicsGetCurrentContext()!
			let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map { $0.cgColor } as CFArray, locations: locations)!
	
			context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: height), options: [])
		}
		
		return image
	}
}

class MapViewController: UIViewController, UISearchBarDelegate {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var galleryBarButton: UIBarButtonItem!
	@IBOutlet weak var topVisualEffectView: UIVisualEffectView!
	private var popupContentVC: LocationsController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if LNPopupSettingsHasOS26Glass() {
			galleryBarButton.title = nil
		} else {
			galleryBarButton.image = nil
		}
		
		let present = UIBarButtonItem(image: UIImage(systemName: "dock.arrow.up.rectangle"), style: .plain, target: self, action: #selector(MapViewController.presentButtonTapped(_:)))
		let dismiss = UIBarButtonItem(image: UIImage(systemName: "dock.arrow.down.rectangle"), style: .plain, target: self, action: #selector(MapViewController.dismissButtonTapped(_:)))
		if #available(iOS 16.0, *) {
			let group = UIBarButtonItemGroup(barButtonItems: [present, dismiss], representativeItem: nil)
			navigationItem.leadingItemGroups = [group]
		} else {
			navigationItem.leftBarButtonItems = [present, dismiss]
		}
		
		mapView.showsTraffic = false
		mapView.pointOfInterestFilter = .includingAll
		
	    if #available(iOS 17.0, *) {
		   topVisualEffectView.effect = UIBlurEffect(variableBlurRadius: 3.0, imageMask: UIImage(named: "statusBarMask")!)
	    } else {
		   topVisualEffectView.effect = UIBlurEffect(blurRadius: 10.0)
	    }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.presentPopupBarIfNeeded(animated: false)
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
#if LNPOPUP
		navigationController!.openPopup(animated: true, completion: nil)
		
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
		guard navigationController!.popupBar.customBarViewController == nil else {
			return
		}
		
		navigationController!.popupBar.inheritsAppearanceFromDockingView = false
		navigationController!.popupBar.standardAppearance.shadowColor = .clear
		
		if let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as? CustomMapBarViewController {
			navigationController!.popupBar.customBarViewController = customMapBar
			
			customMapBar.view.backgroundColor = .clear
			customMapBar.searchBar.delegate = self
			
			if let searchTextField = customMapBar.searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
				clearButton.addTarget(self, action: #selector(self.clearButtonTapped), for: .primaryActionTriggered)
			}
		} else {
			//Manual layout bar scene
			navigationController!.shouldExtendPopupBarUnderSafeArea = false
			navigationController!.popupBar.customBarViewController = ManualLayoutCustomBarViewController()
		}
		
		navigationController!.popupContentView.popupCloseButtonStyle = .none
		navigationController!.popupContentView.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
		navigationController!.popupInteractionStyle = .customizedSnap(percent: 0.15)
		
		popupContentVC = (storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController)
		popupContentVC.tableView.backgroundColor = .clear
		
		navigationController!.presentPopupBar(with: self.popupContentVC, animated: animated, completion: nil)
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
		navigationController!.dismissPopupBar(animated: true) {
			self.navigationController!.popupBar.customBarViewController = nil
		}
#endif
	}

#if LNPOPUP
	override var shouldFadePopupBarOnDismiss: Bool {
		return !LNPopupSettingsHasOS26Glass()
	}
#endif
}
