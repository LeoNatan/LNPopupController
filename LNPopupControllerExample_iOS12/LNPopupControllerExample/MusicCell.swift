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
		
		imageView?.frame = CGRect(x: 20.0, y: bounds.height / 2 - 24, width: 48, height: 48)
		imageView?.layer.cornerRadius = 6
		
		separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
	}
	
}
