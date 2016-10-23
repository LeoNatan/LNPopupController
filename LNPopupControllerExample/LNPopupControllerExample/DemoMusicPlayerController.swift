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
	
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var albumArtImageView: UIImageView!
	
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	
	var timer : Timer?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: nil, action: nil)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: nil, action: nil)
		next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
		
		self.popupItem.leftBarButtonItems = [ pause ]
		self.popupItem.rightBarButtonItems = [ next ]
		
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
			if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 9 {
				popupItem.subtitle = albumTitle
			}
		}
	}
	var albumArt: UIImage = UIImage() {
		didSet {
			if isViewLoaded {
				backgroundImageView.image = albumArt
				albumArtImageView.image = albumArt
			}
			popupItem.image = albumArt
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		songNameLabel.text = songTitle
		albumNameLabel.text = albumTitle
		backgroundImageView.image = albumArt
		albumArtImageView.image = albumArt
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
