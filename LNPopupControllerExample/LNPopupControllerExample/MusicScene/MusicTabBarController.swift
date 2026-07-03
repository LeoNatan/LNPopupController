//
//  MusicTabBarController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

#if LNPOPUP
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
#endif

@available(iOS 18.0, *)
class MusicTabBarController: UITabBarController {
	var convertedTabs = [UITab]()
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return .portrait
	}
	
	override func awakeFromNib() {
		if let viewControllers {
			for enumed in viewControllers.enumerated() {
				let vc = enumed.element
				
				if vc.tabBarItem?.value(forKey: "systemItem") as? Int == UITabBarItem.SystemItem.search.rawValue {
					convertedTabs.append(UISearchTab(viewControllerProvider: { _ in
						vc
					}))
				} else {
					convertedTabs.append(UITab(title: vc.tabBarItem?.title ?? "Tab", image: vc.tabBarItem?.image, identifier: enumed.offset.formatted(), viewControllerProvider: { _ in
						vc
					}))
				}
			}
		}
		
		viewControllers = nil
		
		super.awakeFromNib()
	}
	
//	var timer: Timer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tabs = convertedTabs
		
#if LNPOPUP
		let barStyle = LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: PopupSetting.barStyle)  as? Int ?? 0)!
		
		popupBar.barStyle = barStyle
		popupBar.progressViewStyle = .top
		if #unavailable(iOS 27.0) {
			popupBar.standardAppearance.isFloatingBarShineEnabled = true
		}
		
		popupBar.usesContentControllersAsDataSource = false
		popupBar.popupItem = LNPopupItem.emptyPlayback
		
		popupBar.supportsMinimization = UserDefaults.settings.bool(forKey: PopupSetting.minimizationEnabled)
		
		let popupContentController = DemoMusicPlayerController()
		presentPopupBar(with: popupContentController)
		
#endif
		
//		timer = Timer(timeInterval: 5.0, repeats: true) { [self] _ in
//			print(view.layer.value(forKey: "recursiveDescription")!)
//		}
//		RunLoop.current.add(timer, forMode: .common)
		
		if #available(iOS 26.0, *) {
			tabBarMinimizeBehavior = .onScrollDown
		}
		
#if compiler(>=6.4)
		if #available(iOS 27.0, *) {
			prominentTabIdentifier = "com.apple.UIKit.Search"
		}
#endif
	}
}
