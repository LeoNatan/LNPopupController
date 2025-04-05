//
//  MusicCell.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

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
		
		imageView?.layer.cornerRadius = 5
		imageView?.layer.cornerCurve = .continuous
		
		if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
			imageView?.frame = CGRect(x: layoutMargins.left, y: bounds.height / 2 - 24, width: 48, height: 48)
			
			textLabel?.textAlignment = .left
			textLabel?.lineBreakMode = .byTruncatingTail
			textLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: textLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: textLabel!.frame.height)
			detailTextLabel?.textAlignment = .left
			detailTextLabel?.lineBreakMode = .byTruncatingTail
			detailTextLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: detailTextLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: detailTextLabel!.frame.height)
			
			separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
		} else {
			imageView?.frame = CGRect(x: contentView.bounds.width - layoutMargins.right - 48, y: bounds.height / 2 - 24, width: 48, height: 48)
			
			textLabel?.textAlignment = .right
			textLabel?.lineBreakMode = .byTruncatingHead
			textLabel?.frame = CGRect(x: 20, y: textLabel!.frame.minY, width: contentView.bounds.width - (2 * layoutMargins.right) - imageView!.bounds.width - 20, height: textLabel!.frame.height)
			detailTextLabel?.textAlignment = .right
			detailTextLabel?.lineBreakMode = .byTruncatingHead
			detailTextLabel?.frame = CGRect(x: 20, y: detailTextLabel!.frame.minY, width: contentView.bounds.width - (2 * layoutMargins.right) - imageView!.bounds.width - 20, height: detailTextLabel!.frame.height)
			
			separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
		}
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
