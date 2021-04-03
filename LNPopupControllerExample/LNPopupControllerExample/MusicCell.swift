//
//  MusicCell.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/7/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class MusicCell: UITableViewCell {
	let selectionEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		selectionEffectView.frame = bounds
		selectionEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		selectionEffectView.isHidden = true
		addSubview(selectionEffectView)
		sendSubviewToBack(selectionEffectView)
		
		selectionStyle = .none
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView?.frame = CGRect(x: self.layoutMargins.left, y: bounds.height / 2 - 24, width: 48, height: 48)
		imageView?.layer.cornerRadius = 3
		
		textLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: textLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: textLabel!.frame.height)
		detailTextLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: detailTextLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: detailTextLabel!.frame.height)
		
		separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		guard isHighlighted != highlighted else {
			return
		}

		super.setHighlighted(highlighted, animated: animated)

		selectionEffectView.alpha = highlighted ? 0.0 : 1.0
		selectionEffectView.isHidden = false
		UIView.animate(withDuration: highlighted ? 0.0 : 0.35) {
			self.selectionEffectView.alpha = highlighted ? 1.0 : 0.0
		} completion: { _ in
			self.selectionEffectView.isHidden = highlighted == false
		}
	}
}
