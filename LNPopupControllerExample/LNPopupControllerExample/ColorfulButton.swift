//
//  ColorfulButton.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan (Wix) on 9/4/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

import UIKit

@IBDesignable
class ColorfulButton: UIButton {
	fileprivate func resetBackgroundColor() {
		if traitCollection.userInterfaceStyle == .light {
			backgroundColor = isHighlighted ? .systemGray5 : .systemGray6
		} else {
			backgroundColor = isHighlighted ? .systemGray3 : .systemGray5
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		resetBackgroundColor()
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		setTitleColor(tintColor, for: .normal)
		setTitleColor(tintColor, for: .highlighted)
		let _image = image(for: .normal)?.withTintColor(tintColor, renderingMode: .alwaysTemplate)
		setImage(_image, for: .normal)
		setImage(_image, for: .highlighted)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.cornerRadius = 10
		layer.cornerCurve = .continuous
		
		resetBackgroundColor()
	}
	
	override var isHighlighted: Bool {
		didSet {
			resetBackgroundColor()
		}
	}
}
