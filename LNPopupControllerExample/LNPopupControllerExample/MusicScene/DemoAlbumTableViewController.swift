//
//  DemoAlbumTableViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
import SwiftUI
#if LNPOPUP
import LNPopupController
#endif
import LoremIpsum

class DemoAlbumTableViewController: UITableViewController {
	@IBOutlet var demoAlbumImageView: UIImageView!
	@IBOutlet var galleryBarButton: UIBarButtonItem!
	
	var images: [UIImage]
	var titles: [String]
	var subtitles: [String]
	
	required init?(coder aDecoder: NSCoder) {
		images = []
		titles = []
		subtitles = []
		
		super.init(coder:aDecoder)
	}
	
    override func viewDidLoad() {
		tabBarController?.view.tintColor = view.tintColor
		
		let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
		tableView.tableFooterView = footer
//		tableView.showsVerticalScrollIndicator = false
		
        super.viewDidLoad()
		
		if LNPopupSettingsHasOS26Glass() {
			galleryBarButton.title = nil
		} else {
			galleryBarButton.image = nil
		}
		
//		let view = ZStack {
//			Image("demoAlbum")
//				.resizable()
//			Color(uiColor: .secondarySystemBackground)
//				.opacity(0.35)
//		}.compositingGroup().blur(radius: 80, opaque: true)
//		
//		tableView.backgroundView = UIHostingController(rootView: view).view
//		
//		tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemThinMaterial))
		
#if LNPOPUP
		let barStyle = LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: PopupSetting.barStyle)  as? Int ?? 0)!
		tabBarController?.popupBar.barStyle = barStyle
#endif
#if compiler(>=6.2)
		if #available(iOS 26.0, *) {
			tabBarController?.tabBarMinimizeBehavior = .onScrollDown
		}
#endif
		
		if !LNPopupSettingsHasOS26Glass() {
#if LNPOPUP
			if [.floating, .floatingCompact].contains(tabBarController?.popupBar.effectiveBarStyle) {
				let tba = UITabBarAppearance()
				tba.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
				tabBarController!.tabBar.standardAppearance = tba
				
				let nba = UINavigationBarAppearance()
				nba.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
				navigationController!.navigationBar.standardAppearance = nba
			}
#endif
		}

		demoAlbumImageView.layer.cornerCurve = .continuous
		demoAlbumImageView.layer.cornerRadius = 8
		demoAlbumImageView.layer.masksToBounds = true
		
		for idx in 1...self.tableView(tableView, numberOfRowsInSection: 0) {
			images += [UIImage(named: "genre\(idx)")!]
			
			var title = LoremIpsum.title
			var sentence = LoremIpsum.sentence
			
#if LNPOPUP
			if UserDefaults.standard.bool(forKey: PopupSetting.forceRTL) {
				title = title.applyingTransform(.latinToHebrew, reverse: false)!
				sentence = sentence.applyingTransform(.latinToHebrew, reverse: false)!
			}
#endif
			
			titles.append(title)
			subtitles.append(sentence)
		}
    }
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)

		cell.imageView?.image = images[(indexPath as NSIndexPath).row]
		cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
		cell.detailTextLabel?.text = subtitles[(indexPath as NSIndexPath).row]
		
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
#if LNPOPUP
		let popupContentController = DemoMusicPlayerController()
		popupContentController.songTitle = titles[(indexPath as NSIndexPath).row]
		popupContentController.albumTitle = subtitles[(indexPath as NSIndexPath).row]
		popupContentController.albumArt = images[(indexPath as NSIndexPath).row]
		
		popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
		tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
		
		tabBarController?.presentPopupBar(with: popupContentController, animated: true, completion: nil)
		tabBarController?.popupBar.tintColor = UIColor.label
		tabBarController?.popupBar.progressViewStyle = .top
		
#endif
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
