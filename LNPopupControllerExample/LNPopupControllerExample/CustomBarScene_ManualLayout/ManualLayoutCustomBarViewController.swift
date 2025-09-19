//
//  ManualLayoutCustomBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2020-09-01.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
@objc public
class ManualLayoutCustomBarViewController: LNPopupCustomBarViewController {
	let centeredButton = UIButton(type: .system)
	let leftButton = UIButton(type: .system)
	let backgroundView = UIVisualEffectView(effect: nil)
	
	let userCustomCornerConfiguration: Bool
	
	@objc(initWithCustomCornerConfiguration:)
	init(userCustomCornerConfiguration: Bool = true) {
		self.userCustomCornerConfiguration = userCustomCornerConfiguration
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupBackgroundView() {
		backgroundView.effect = UIBlurEffect(style: .systemChromeMaterial)
		backgroundView.layer.masksToBounds = true
		backgroundView.layer.cornerCurve = .continuous
		backgroundView.layer.cornerRadius = 15
		view.addSubview(backgroundView)
	}
	
	public
	override func viewDidLoad() {
		super.viewDidLoad()

		if !LNPopupSettingsHasOS26Glass() {
			containingPopupBar?.standardAppearance.configureWithTransparentBackground()
		}
		
		view.autoresizingMask = []
		
#if compiler(>=6.2)
		if #available(iOS 26, *), LNPopupSettingsHasOS26Glass() {
			// Use system background
		} else {
			setupBackgroundView()
		}
#else
		setupBackgroundView()
#endif
		
		centeredButton.setTitle(NSLocalizedString("Centered", comment: ""), for: .normal)
		centeredButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		centeredButton.sizeToFit()
		view.addSubview(centeredButton)
		
		leftButton.setTitle("<- \(NSLocalizedString("Leading", comment: ""))", for: .normal)
		leftButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		leftButton.sizeToFit()
		view.addSubview(leftButton)
		
		self.preferredContentSize = CGSize(width: 0, height: 170)
	}
	
	var idx = 1
	@IBAction
	func animateSize(_ sender: UIBarButtonItem) {
		idx = 1 - idx;
		
		let changes = {
			self.preferredContentSize = CGSize(width: 0, height: 70 + self.idx * 100)
			sender.image = self.idx == 0 ? UIImage(systemName: "rectangle.expand.vertical") : UIImage(systemName: "rectangle.compress.vertical")
		}
		
		if #available(iOS 18.0, *) {
			UIView.animate(.easeInOut, changes: changes)
		} else {
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0.0, animations: changes)
		}
	}
	
	public
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let insetLeft = LNPopupSettingsHasOS26Glass() ? 0.0 : CGFloat.maximum(view.safeAreaInsets.left, 20)
		let insetRight = LNPopupSettingsHasOS26Glass() ? 0.0 : CGFloat.maximum(view.safeAreaInsets.right, 20)
		
		backgroundView.frame = CGRect(x: insetLeft, y: 2, width: view.bounds.width - insetLeft - insetRight, height: view.bounds.height - 4.0)
		centeredButton.center = backgroundView.center
		if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .leftToRight {
			leftButton.frame = CGRect(x: insetLeft + 20, y: backgroundView.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
		} else {
			leftButton.frame = CGRect(x: view.bounds.width - insetRight - leftButton.bounds.width - 20, y: backgroundView.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
		}
	}
	
	public
	override var wantsDefaultTapGestureRecognizer: Bool {
		return false
	}
	
	public
	override var wantsDefaultPanGestureRecognizer: Bool {
		return false
	}
	
	public
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return false
	}
}
#endif
