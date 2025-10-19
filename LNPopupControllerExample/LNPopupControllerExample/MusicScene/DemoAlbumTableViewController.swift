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

@available(iOS 18.0, *)
class DemoAlbumTableViewController: UITableViewController, LNPopupBarDataSource, LNPopupBarDelegate {
	@IBOutlet var demoAlbumImageView: UIImageView!
	@IBOutlet var galleryBarButton: UIBarButtonItem!
	
	var playlist = [LNPopupItem]()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		
		if self.navigationController?.tabBarItem.image == nil {
			self.navigationController?.tabBarItem.image = UIImage(systemName: "square.stack.fill")
		}
	}
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		tabBarController?.view.tintColor = view.tintColor
		
		let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
		tableView.tableFooterView = footer
		
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 55
		
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
		
		for idx in 0..<Int.random(in: 20...50) {
			let item = LNPopupItem()
			
			item.title = LoremIpsum.title
			item.subtitle = tabIsEven ? LoremIpsum.sentence : LoremIpsum.sentences(withNumber: UInt.random(in: 1...3))
			item.image = UIImage(named: "genre\((idx % 30) + 1)")!
			item.userInfo = ["idx": idx]

			playlist.append(item)
		}
    }
	
	var tabIsEven: Bool {
		(self.tabBarController!.viewControllers?.firstIndex(of: self.navigationController!))! % 2 == 0
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return playlist.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
		
		var cellConfig = UIListContentConfiguration.subtitleCell()
		cellConfig.image = playlist[indexPath.row].image
		cellConfig.imageProperties.cornerRadius = 8
		cellConfig.imageProperties.maximumSize = CGSize(width: 48, height: 48)
		cellConfig.text = playlist[indexPath.row].title
		cellConfig.textProperties.font = .preferredFont(forTextStyle: .body)
		cellConfig.textProperties.numberOfLines = tabIsEven ? 1 : 0
		cellConfig.secondaryText = playlist[indexPath.row].subtitle
		cellConfig.secondaryTextProperties.font = .preferredFont(forTextStyle: .footnote)
		cellConfig.secondaryTextProperties.numberOfLines = tabIsEven ? 1 : 0
		cellConfig.imageToTextPadding = 10
		cellConfig.textToSecondaryTextVerticalPadding = tabIsEven ? 2 : 4
		cellConfig.directionalLayoutMargins = NSDirectionalEdgeInsets(top: tabIsEven ? 4 : 8, leading: 0, bottom: tabIsEven ? 4 : 8, trailing: 0)
		
		cell.contentConfiguration = cellConfig
		
		if tabBarController?.popupBar.dataSource === self && tabBarController?.popupBar.popupItem?.userInfo?["idx"] as? Int == indexPath.row {
			var bg = UIBackgroundConfiguration.listCell()
			bg.backgroundColor = .tintColor.withAlphaComponent(0.2)
			cell.backgroundConfiguration = bg
		} else {
			cell.backgroundConfiguration = nil
		}
		
        return cell
    }
	
	func popupItem(before popupItem: LNPopupItem) -> LNPopupItem? {
		guard let idx = popupItem.userInfo?["idx"] as? Int else {
			return nil
		}
		
		if idx == 0 {
			return nil
		}
		
		let rv = playlist[idx - 1]
		rv.progress = 0.0
		return rv
	}
	
	func popupItem(after popupItem: LNPopupItem) -> LNPopupItem? {
		guard let idx = popupItem.userInfo?["idx"] as? Int else {
			return nil
		}
		
		if idx == playlist.count - 1 {
			return nil
		}
		
		let rv = playlist[idx + 1]
		rv.progress = 0.0
		return rv
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
#if LNPOPUP
		let item = playlist[indexPath.row]
		item.progress = 0.0
		tabBarController?.popupBar.popupItem = item
		tabBarController?.popupBar.dataSource = self
		tabBarController?.popupBar.delegate = self
		
		updateCells(highlighting: indexPath.row)
		
		if let popupContent = tabBarController?.popupContent as? DemoMusicPlayerController {
			popupContent.nextSong = { [weak self] item in
				guard let self else {
					return false
				}
				
				guard let item = popupItem(after: item) else {
					return false
				}
				
				tabBarController?.popupBar.popupItem = item
				return true
			}
			popupContent.prevSong = { [weak self] item in
				guard let self else {
					return
				}
				
				guard let item = popupItem(before: item) else {
					return
				}
				
				tabBarController?.popupBar.popupItem = item
			}
			
			popupContent.play()
		}
#endif
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func popupBar(_ popupBar: LNPopupBar, popupItemBefore popupItem: LNPopupItem) -> LNPopupItem? {
		self.popupItem(before: popupItem)
	}
	
	func popupBar(_ popupBar: LNPopupBar, popupItemAfter popupItem: LNPopupItem) -> LNPopupItem? {
		self.popupItem(after: popupItem)
	}
	
	func updateCells(highlighting idx: Int) {
		for cell in tableView.visibleCells {
			cell.backgroundConfiguration = nil
		}
		
		if let cell = tableView.cellForRow(at: IndexPath(row: idx, section: 0)) {
			var bg = UIBackgroundConfiguration.listCell()
			bg.backgroundColor = .tintColor.withAlphaComponent(0.2)
			cell.backgroundConfiguration = bg
		}
	}
	
	func popupBar(_ popupBar: LNPopupBar, didDisplay newPopupItem: LNPopupItem, previous previousPopupItem: LNPopupItem?) {
		guard let idx = newPopupItem.userInfo?["idx"] as? Int else {
			return
		}
		
		UIView.animate(.spring) {
			updateCells(highlighting: idx)
		}
	}
}
