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
	
	@IBOutlet weak var albumArtImageView: UIImageView!
	
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	
	var timer : Timer?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: nil, action: nil)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: nil, action: nil)
		next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
		
		if UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? LNPopupBarStyle == LNPopupBarStyle.compact || ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10 {
			popupItem.leftBarButtonItems = [ pause ]
			popupItem.rightBarButtonItems = [ next ]
		}
		else {
			popupItem.rightBarButtonItems = [ pause, next ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
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
				albumArtImageView.image = albumArt
			}
			popupItem.image = albumArt
			popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		songNameLabel.text = songTitle
		albumNameLabel.text = albumTitle
		albumArtImageView.image = albumArt
		
		timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
	}
	
	@objc func _timerTicked(_ timer: Timer) {
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
