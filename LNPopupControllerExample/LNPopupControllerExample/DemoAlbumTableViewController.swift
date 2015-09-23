//
//  DemoAlbumTableViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/7/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit

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
		tabBarController?.view.tintColor = UIColor.redColor()
		
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
		tableView.contentInset = insets
		tableView.scrollIndicatorInsets = insets
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.setContentOffset(CGPointMake(0, -tableView.contentInset.top), animated: false)
	}
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 2
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let separator = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 1 / UIScreen.mainScreen().scale))
		separator.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
		separator.autoresizingMask = .FlexibleWidth
		let view = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 2))
		view.addSubview(separator)
		return view
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath)

		cell.imageView?.image = images[indexPath.row]
		cell.textLabel?.text = titles[indexPath.row]
		cell.textLabel?.textColor = UIColor.whiteColor()
		cell.detailTextLabel?.text = subtitles[indexPath.row]
		cell.detailTextLabel?.textColor = UIColor.whiteColor()
		
		let selectionView = UIView()
		selectionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.45)
		cell.selectedBackgroundView = selectionView
		
        return cell
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let popupContentController = storyboard?.instantiateViewControllerWithIdentifier("DemoMusicPlayerController") as! DemoMusicPlayerController
		popupContentController.songTitle = titles[indexPath.row]
		popupContentController.albumTitle = subtitles[indexPath.row]
		
		tabBarController?.presentPopupBarWithContentViewController(popupContentController, animated: true, completion: nil)
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = UIColor.clearColor()
	}
}
