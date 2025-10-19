//
//  MusicTabBarController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

extension LNPopupItem {
	var isEmptyPlaybackItem: Bool {
		identifier == "noSong"
	}
	
	static
	var emptyPlayback: LNPopupItem {
		let rv = LNPopupItem()
		rv.identifier = "noSong"
		rv.title = NSLocalizedString("Not Playing", comment: "")
		rv.image = UIImage(named: "NotPlaying")?.withRenderingMode(.alwaysOriginal)
		return rv
	}
}

@available(iOS 17.0, *)
class MusicTabBarController: UITabBarController {
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return .portrait
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
#if LNPOPUP
		let barStyle = LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: PopupSetting.barStyle)  as? Int ?? 0)!
		
		popupBar.barStyle = barStyle
		popupBar.progressViewStyle = .top
		popupBar.standardAppearance.isFloatingBarShineEnabled = true
		
		popupBar.usesContentControllersAsDataSource = false
		popupBar.popupItem = LNPopupItem.emptyPlayback
		
		let popupContentController = DemoMusicPlayerController()
		presentPopupBar(with: popupContentController)
		
#endif
		
#if compiler(>=6.2)
		if #available(iOS 26.0, *) {
			tabBarMinimizeBehavior = .onScrollDown
		}
#endif
	}
}
