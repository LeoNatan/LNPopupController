//
//  DemoAlbumTableViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/7/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit
#if LNPOPUP
import LNPopupController
#endif
import LoremIpsum

@available(iOS 13.0, *)
class DemoAlbumTableViewController: UITableViewController {

	@IBOutlet var demoAlbumImageView: UIImageView!
	
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
		
		let backgroundImageView = UIImageView(image: UIImage(named: "demoAlbum"))
		backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		backgroundImageView.contentMode = .scaleAspectFill
		let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
		backgroundEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let container = UIView(frame: tableView.bounds)
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		backgroundImageView.frame = container.bounds
		backgroundEffectView.frame = container.bounds
		container.addSubview(backgroundImageView)
		container.addSubview(backgroundEffectView)
		
		tableView.backgroundView = container
		
		tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemThinMaterial))
		
#if LNPOPUP
		tabBarController?.popupBar.barStyle = LNPopupBarStyle(rawValue: UserDefaults.standard.object(forKey: PopupSettingsBarStyle)  as? Int ?? 0)!
#endif
		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		navigationItem.standardAppearance = appearance

		demoAlbumImageView.layer.cornerCurve = .continuous
		demoAlbumImageView.layer.cornerRadius = 8
		demoAlbumImageView.layer.masksToBounds = true
		
		for idx in 1...self.tableView(tableView, numberOfRowsInSection: 0) {
			images += [UIImage(named: "genre\(idx)")!]
			titles += [LoremIpsum.title]
			subtitles += [LoremIpsum.sentence]
		}
    }
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let appearance = UINavigationBarAppearance()
		
		if scrollView.contentOffset.y > -scrollView.adjustedContentInset.top {
			appearance.configureWithDefaultBackground()
		} else {
			appearance.configureWithTransparentBackground()
		}
		navigationItem.standardAppearance = appearance
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
		let separator = UIView(frame: CGRect(x: view.layoutMargins.left, y: 0, width: tableView.bounds.size.width - view.layoutMargins.left, height: 1 / UIScreen.main.scale))
		separator.backgroundColor = .separator
		separator.autoresizingMask = .flexibleWidth
		let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 2))
		view.addSubview(separator)
		return view
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
		
//		tabBarController?.popupBar.customBarViewController = ManualLayoutCustomBarViewController()
		tabBarController?.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
		tabBarController?.popupBar.imageView.layer.cornerRadius = 3
		tabBarController?.popupBar.tintColor = UIColor.label
		tabBarController?.popupBar.progressViewStyle = .top
		
		#endif
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
