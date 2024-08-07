//
//  MapViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2016-12-30.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
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
	@IBOutlet weak var topVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var backButtonBackground: UIVisualEffectView!
	private var popupContentVC: LocationsController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.showsTraffic = false
		mapView.pointOfInterestFilter = .includingAll
		
		backButtonBackground.layer.cornerRadius = 10.0
		backButtonBackground.layer.borderWidth = 1.0
		backButtonBackground.layer.borderColor = self.view.tintColor.cgColor
		
		backButtonBackground.effect = UIBlurEffect(style: .systemChromeMaterial)
		backButtonBackground.layer.cornerCurve = .continuous
		
	    if #available(iOS 17.0, *) {
		   topVisualEffectView.effect = UIBlurEffect(variableBlurRadius: 3.0, imageMask: UIImage(named: "statusBarMask")!)
	    } else {
		   topVisualEffectView.effect = UIBlurEffect(blurRadius: 10.0)
	    }
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
		
		popupBar.standardAppearance.shadowColor = .clear
		if let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomMapBarViewController") as? CustomMapBarViewController {
			popupBar.customBarViewController = customMapBar
			
			customMapBar.view.backgroundColor = .clear
			customMapBar.searchBar.delegate = self
			
			if let searchTextField = customMapBar.searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
				clearButton.addTarget(self, action: #selector(self.clearButtonTapped), for: .primaryActionTriggered)
			}
		} else {
			//Manual layout bar scene
			shouldExtendPopupBarUnderSafeArea = false
			popupBar.customBarViewController = ManualLayoutCustomBarViewController()
			popupBar.standardAppearance.configureWithTransparentBackground()
		}
		
		popupContentView.popupCloseButtonStyle = .none
		popupContentView.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
//		popupContentView.isTranslucent = false
		popupInteractionStyle = .customizedSnap(percent: 0.15)
		
		popupContentVC = (storyboard!.instantiateViewController(withIdentifier: "PopupContentController") as! LocationsController)
		popupContentVC.tableView.backgroundColor = .clear
		
		presentPopupBar(with: self.popupContentVC, animated: animated, completion: nil)
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
