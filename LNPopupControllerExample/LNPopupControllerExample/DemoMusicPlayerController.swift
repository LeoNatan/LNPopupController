//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit

class DemoMusicPlayerController: UIViewController {

	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	
	var timer : NSTimer?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == .Pad {
			self.popupItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: nil, action: nil),
												UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: nil, action: nil),
												UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: nil, action: nil)]
			self.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "next"), style: .Plain, target: nil, action: nil),
												UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: nil, action: nil)]
		}
		else {
			self.popupItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: nil, action: nil)]
			self.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: nil, action: nil)]
		}
		
		
		timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "_timerTicked:", userInfo: nil, repeats: true)
	}
	
	var songTitle: String = "" {
		didSet {
			if isViewLoaded() {
				songNameLabel.text = songTitle
			}
			
			popupItem.title = songTitle
		}
	}
	var albumTitle: String = "" {
		didSet {
			if isViewLoaded() {
				albumNameLabel.text = albumTitle
			}
			popupItem.subtitle = albumTitle
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		songNameLabel.text = songTitle
		albumNameLabel.text = albumTitle
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	func _timerTicked(timer: NSTimer) {
		popupItem.progress += 0.007;
		progressView.progress = popupItem.progress
		
		if popupItem.progress == 1.0 {
			timer.invalidate()
			popupPresentationContainerViewController?.dismissPopupBarAnimated(true, completion: nil)
		}
	}
}
