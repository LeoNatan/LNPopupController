//
//  ManualLayoutCustomBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 9/1/20.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#if LNPOPUP
class ManualLayoutCustomBarViewController: LNPopupCustomBarViewController {
	let centeredButton = UIButton(type: .system)
	let leftButton = UIButton(type: .system)
	let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundView.layer.masksToBounds = true
		backgroundView.layer.cornerCurve = .continuous
		backgroundView.layer.cornerRadius = 15
		view.addSubview(backgroundView)
		
		centeredButton.setTitle("Centered", for: .normal)
		centeredButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		centeredButton.sizeToFit()
		view.addSubview(centeredButton)
		
		leftButton.setTitle("<- Left", for: .normal)
		leftButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		leftButton.sizeToFit()
		view.addSubview(leftButton)
		
		preferredContentSize = CGSize(width: 0, height: 50)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		backgroundView.frame = view.bounds.insetBy(dx: view.layoutMargins.left, dy: 0)
		centeredButton.center = view.center
		leftButton.frame = CGRect(x: view.layoutMargins.left + 20, y: view.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
	}
	
	override var wantsDefaultTapGestureRecognizer: Bool {
		return false
	}
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		return false
	}
	
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return false
	}
}
#endif
