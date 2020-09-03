//
//  MusicCell.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/7/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit

class MusicCell: UITableViewCell {
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView?.frame = CGRect(x: self.layoutMargins.left, y: bounds.height / 2 - 24, width: 48, height: 48)
		imageView?.layer.cornerRadius = 3
		
		textLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: textLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: textLabel!.frame.height)
		detailTextLabel?.frame = CGRect(x: imageView!.frame.maxX + 20, y: detailTextLabel!.frame.minY, width: accessoryView!.frame.minX - imageView!.frame.maxX - 40, height: detailTextLabel!.frame.height)
		
		separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
	}
	
}
