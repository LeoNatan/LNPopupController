//
//  DemoAlbumTableViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/7/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit
import LNPopupController

class DemoAlbumTableViewController: UITableViewController {

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
		
        super.viewDidLoad()
		
		for idx in 1...self.tableView(tableView, numberOfRowsInSection: 0) {
			images += [UIImage(named: "genre\(idx)")!]
			titles += [LoremIpsum.title()]
			subtitles += [LoremIpsum.sentence()]
		}
		
		tableView.backgroundColor = LNRandomDarkColor()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
//		tableView.contentInset = insets
//		tableView.scrollIndicatorInsets = insets
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let separator = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1 / UIScreen.main.scale))
		separator.backgroundColor = UIColor.white.withAlphaComponent(0.4)
		separator.autoresizingMask = .flexibleWidth
		let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 2))
		view.addSubview(separator)
		return view
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)

		cell.imageView?.image = images[(indexPath as NSIndexPath).row]
		cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
		cell.textLabel?.textColor = UIColor.white
		cell.detailTextLabel?.text = subtitles[(indexPath as NSIndexPath).row]
		cell.detailTextLabel?.textColor = UIColor.white
		
		let selectionView = UIView()
		selectionView.backgroundColor = UIColor.white.withAlphaComponent(0.45)
		cell.selectedBackgroundView = selectionView
		
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let popupContentController = storyboard?.instantiateViewController(withIdentifier: "DemoMusicPlayerController") as! DemoMusicPlayerController
		popupContentController.songTitle = titles[(indexPath as NSIndexPath).row]
		popupContentController.albumTitle = subtitles[(indexPath as NSIndexPath).row]
		popupContentController.albumArt = images[(indexPath as NSIndexPath).row]
		
		popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
		tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
		
		tabBarController?.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
		tabBarController?.popupBar.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = UIColor.clear
	}
}
