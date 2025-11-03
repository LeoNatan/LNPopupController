//
//  CustomContainerController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 3/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
#if LNPOPUP
import LNPopupController
#endif

let buttonSize: CGFloat = 44.0
let buttonSpacing: CGFloat = buttonSize / 3.0
let buttonPadding: CGFloat = 3.0

@available(iOS 18.0, *)
class CustomTabBar: UIView {
	var tabs: [UITab] = [] {
		didSet {
			updateButtons()
		}
	}
	var selectedTab: UITab? {
		didSet {
			updateButtons()
		}
	}
	
	var effectView = UIVisualEffectView()
	var stackView = {
		let rv = UIStackView()
		rv.axis = .horizontal
		rv.distribution = .fillEqually
		rv.spacing = buttonSpacing
		return rv
	}()
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		if #available(iOS 26, *) {
			effectView.cornerConfiguration = .capsule()
			stackView.cornerConfiguration = .capsule()
		} else {
			clipsToBounds = true
			layer.cornerRadius = 8
			layer.cornerCurve = .continuous
		}
		
		effectView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(effectView)

		if #available(iOS 26, *) {
			let glass = UIGlassEffect(style: .regular)
			glass.isInteractive = true
			effectView.effect = glass
		} else {
			effectView.effect = UIBlurEffect(style: .systemChromeMaterial)
		}
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		effectView.contentView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
			effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
			effectView.topAnchor.constraint(equalTo: topAnchor),
			effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			stackView.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor, constant: buttonPadding),
			stackView.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor, constant: -buttonPadding),
			stackView.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: buttonPadding),
			stackView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -buttonPadding)
		])
	}
	
	func updateButtons() {
		for view in stackView.arrangedSubviews {
			view.removeFromSuperview()
		}
		
		for (idx, tab) in tabs.enumerated() {
			let isSelected = tab == selectedTab
			var config = isSelected ? UIButton.Configuration.borderedProminent() : UIButton.Configuration.plain()
			config.image = tab.image
			let fontSize = buttonSize / 2.5
			config.preferredSymbolConfigurationForImage = .init(font: isSelected ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize))
			if #available(iOS 26.0, *) {
				config.cornerStyle = .capsule
			} else {
				config.cornerStyle = .dynamic
			}
			
			let button = UIButton(configuration: config, primaryAction: UIAction(handler: { [weak self] action in
				guard let self else {
					return
				}
				
				self.delegate?.customTabBar(self, didSelect: (action.sender as! UIButton).tag)
			}))
			button.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
			button.tag = idx
			
			stackView.addArrangedSubview(button)
		}
	}
	
	protocol Delegate: NSObjectProtocol {
		func customTabBar(_ customTabBar: CustomTabBar, didSelect tabAtIndex: Int)
	}
	weak var delegate: Delegate?
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@available(iOS 18.0, *)
@objc(LNCustomContainerController)
class CustomContainerController: DemoTabBarController {
	var customTabBar = CustomTabBar()
	var isCustomTabBarHidden: Bool = false {
		didSet {
			view.setNeedsLayout()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setTabBarHidden(true, animated: false)
		
		view.addSubview(customTabBar)
		updateCustomTabBarFrame()
		
		customTabBar.tabs = tabs
		customTabBar.selectedTab = selectedTab
		customTabBar.delegate = self
	}
	
	override var tabs: [UITab] {
		didSet {
			updateCustomTabBarFrame()
			
			for tab in tabs {
				if let vc = tab.viewController as? UINavigationController {
					vc.delegate = self
				}
			}
			
			customTabBar.tabs = tabs
			view.setNeedsLayout()
		}
	}
	override var selectedTab: UITab? {
		didSet {
			customTabBar.selectedTab = selectedTab
		}
	}
	
	func updateCustomTabBarFrame() {
		let size = CGSize(width: max(CGFloat(tabs.count) * buttonSize + CGFloat(tabs.count - 1) * buttonSpacing, buttonSize) + 2 * buttonPadding, height: buttonSize + 2 * buttonPadding)
		
		let y: CGFloat
		if isCustomTabBarHidden {
			y = view.bounds.size.height + size.height
		} else {
			y = view.bounds.size.height - size.height - 0.5 * view.safeAreaInsets.bottom
		}
		
		let origin = CGPoint(x: view.bounds.midX - size.width / 2, y: y)
		let frame = CGRect(origin: origin, size: size)
		customTabBar.frame = frame
		
		for tab in tabs {
			tab.viewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: isCustomTabBarHidden ? 0 : customTabBar.bounds.size.height - 0.5 * view.safeAreaInsets.bottom, right: 0)
		}
		
		view.layoutIfNeeded()
	}
	
	override func viewDidLayoutSubviews() {
		view.bringSubviewToFront(customTabBar)
		
		super.viewDidLayoutSubviews()
		
		updateCustomTabBarFrame()
		
		setTabBarHidden(true, animated: false)
		tabBar.removeFromSuperview()
	}
}

#if LNPOPUP
// MARK: LNPopupController custom container support

@available(iOS 18.0, *)
extension CustomContainerController {
	override var bottomDockingViewForPopupBar: UIView? {
		return customTabBar
	}
	
	override var defaultFrameForBottomDockingView: CGRect {
		customTabBar.frame
	}
	
	override var isBottomDockingViewForPopupBarHidden: Bool {
		isCustomTabBarHidden
	}
	
	override var bottomDockingViewMarginForPopupBar: CGFloat {
		8.0
	}
	
	override var requiresIndirectSafeAreaManagement: Bool {
		true
	}
}
#endif

@available(iOS 18.0, *)
extension CustomContainerController: CustomTabBar.Delegate {
	func customTabBar(_ customTabBar: CustomTabBar, didSelect tabAtIndex: Int) {
		selectedTab = tabs[tabAtIndex]
	}
}

@available(iOS 18.0, *)
extension CustomContainerController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		let wasHidden = isCustomTabBarHidden
		var shouldRevert: Bool = false
		
		//The animateAlongside: completion handler is called twice, while this is called only once per cancellation,
		//so we mark here that the interactive pop was cancelled, so that we can restore the hidden value in the completion handler.
		navigationController.transitionCoordinator?.notifyWhenInteractionChanges { context in
			if context.isCancelled {
				shouldRevert = true
			}
		}
		
		navigationController.transitionCoordinator?.animate { context in
			defer {
				self.updateCustomTabBarFrame()
			}
			
			guard viewController != navigationController.viewControllers.first else {
				self.isCustomTabBarHidden = false
				return
			}
			
			self.isCustomTabBarHidden = viewController.hidesBottomBarWhenPushed
		} completion: { context in
			if shouldRevert {
				self.isCustomTabBarHidden = wasHidden
			}
		}
	}
}
