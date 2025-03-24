//
//  ManualLayoutCustomBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2020-09-01.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
@objc public class ManualLayoutCustomBarViewController: LNPopupCustomBarViewController {
	let centeredButton = UIButton(type: .system)
	let leftButton = UIButton(type: .system)
	let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		view.autoresizingMask = []
		
		backgroundView.layer.masksToBounds = true
		backgroundView.layer.cornerCurve = .continuous
		backgroundView.layer.cornerRadius = 15
		view.addSubview(backgroundView)
		
		centeredButton.setTitle(NSLocalizedString("Centered", comment: ""), for: .normal)
		centeredButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		centeredButton.sizeToFit()
		view.addSubview(centeredButton)
		
		leftButton.setTitle("<- \(NSLocalizedString("Leading", comment: ""))", for: .normal)
		leftButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		leftButton.sizeToFit()
		view.addSubview(leftButton)
		
		self.preferredContentSize = CGSize(width: 0, height: 50)
		animateSize()
	}
	
	var idx = 0
	func animateSize() {
		idx = 1 - idx;
		UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction]) {
			self.preferredContentSize = CGSize(width: 0, height: 50 + self.idx * 50)
		} completion: { [weak self] _ in
			guard let self else {
				return
			}
			
			self.animateSize()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let insetLeft = CGFloat.maximum(view.safeAreaInsets.left, 20)
		let insetRight = CGFloat.maximum(view.safeAreaInsets.right, 20)
		
		backgroundView.frame = CGRect(x: insetLeft, y: 2, width: view.bounds.width - insetLeft - insetRight, height: view.bounds.height - 4)
		centeredButton.center = backgroundView.center
		if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .leftToRight {
			leftButton.frame = CGRect(x: insetLeft + 20, y: backgroundView.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
		} else {
			leftButton.frame = CGRect(x: view.bounds.width - insetRight - leftButton.bounds.width - 20, y: backgroundView.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
		}
	}
	
	public override var wantsDefaultTapGestureRecognizer: Bool {
		return false
	}
	
	public override var wantsDefaultPanGestureRecognizer: Bool {
		return false
	}
	
	public override var wantsDefaultHighlightGestureRecognizer: Bool {
		return false
	}
}
#endif
