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
	
	let accessibilityDateComponentsFormatter = NSDateComponentsFormatter()
	
	var timer : NSTimer?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: nil, action: nil)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let more = UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: nil, action: nil)
		more.accessibilityLabel = NSLocalizedString("More", comment: "")
		
		if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == .Pad {
			let prev = UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: nil, action: nil)
			prev.accessibilityLabel = NSLocalizedString("Previous Track", comment: "")
			let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: nil, action: nil)
			next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
			let list = UIBarButtonItem(image: UIImage(named: "next"), style: .Plain, target: nil, action: nil)
			list.accessibilityLabel = NSLocalizedString("Up Next", comment: "")
			list.accessibilityHint = NSLocalizedString("Double Tap to Show Up Next List", comment: "")
			
			self.popupItem.leftBarButtonItems = [ prev, pause, next ]
			self.popupItem.rightBarButtonItems = [ list, more ]
		}
		else {
			self.popupItem.leftBarButtonItems = [ pause ]
			self.popupItem.rightBarButtonItems = [ more ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .SpellOut
		
		timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
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
		popupItem.progress += 0.0002;
		popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
		
		let totalTime = NSTimeInterval(250)
		popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.stringFromTimeInterval(NSTimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.stringFromTimeInterval(totalTime)!)"
		
		progressView.progress = popupItem.progress
		
		if popupItem.progress >= 1.0 {
			timer.invalidate()
			popupPresentationContainerViewController?.dismissPopupBarAnimated(true, completion: nil)
		}
	}
}
