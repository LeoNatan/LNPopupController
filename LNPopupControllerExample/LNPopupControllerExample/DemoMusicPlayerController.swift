//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit
import LNPopupController

class DemoMusicPlayerController: UIViewController {

	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	
	var timer : Timer?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: nil, action: nil)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let more = UIBarButtonItem(image: UIImage(named: "action"), style: .plain, target: nil, action: nil)
		more.accessibilityLabel = NSLocalizedString("More", comment: "")
		
		if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
			let prev = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: nil, action: nil)
			prev.accessibilityLabel = NSLocalizedString("Previous Track", comment: "")
			let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: nil, action: nil)
			next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
			let list = UIBarButtonItem(image: UIImage(named: "next"), style: .plain, target: nil, action: nil)
			list.accessibilityLabel = NSLocalizedString("Up Next", comment: "")
			list.accessibilityHint = NSLocalizedString("Double Tap to Show Up Next List", comment: "")
			
			self.popupItem.leftBarButtonItems = [ prev, pause, next ]
			self.popupItem.rightBarButtonItems = [ list, more ]
		}
		else {
			self.popupItem.leftBarButtonItems = [ pause ]
			self.popupItem.rightBarButtonItems = [ more ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
		
		timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
	}
	
	var songTitle: String = "" {
		didSet {
			if isViewLoaded {
				songNameLabel.text = songTitle
			}
			
			popupItem.title = songTitle
		}
	}
	var albumTitle: String = "" {
		didSet {
			if isViewLoaded {
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

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
	func _timerTicked(_ timer: Timer) {
		popupItem.progress += 0.0002;
		popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
		
		let totalTime = TimeInterval(250)
		popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
		
		progressView.progress = popupItem.progress
		
		if popupItem.progress >= 1.0 {
			timer.invalidate()
			popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
		}
	}
}
