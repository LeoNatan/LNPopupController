//
//  ManualLayoutCustomBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan (Wix) on 9/1/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#if LNPOPUP
class ManualLayoutCustomBarViewController: LNPopupCustomBarViewController {
	let centeredButton = UIButton(type: .system)
	let leftButton = UIButton(type: .system)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		centeredButton.setTitle("Centered", for: .normal)
		centeredButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
//		centeredButton.tintColor = .white
		centeredButton.sizeToFit()
		view.addSubview(centeredButton)
		
		leftButton.setTitle("<- Left", for: .normal)
		leftButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
//		leftButton.tintColor = .white
		leftButton.sizeToFit()
		view.addSubview(leftButton)
		
		preferredContentSize = CGSize(width: 0, height: 100)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		centeredButton.center = view.center
		leftButton.frame = CGRect(x: view.layoutMargins.left, y: view.center.y - leftButton.bounds.size.height / 2, width: leftButton.bounds.size.width, height: leftButton.bounds.size.height)
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
