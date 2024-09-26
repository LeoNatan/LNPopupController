//
//  ScrollingColorsPageViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-27.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

import UIKit
import LNPopupController

class ScrollingColorsPageViewController: UIPageViewController, UIPageViewControllerDataSource {
	var colors: [UIColor] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		for _ in 0..<30 {
			colors.append(LNRandomSystemColor())
		}

		let useCompact = UserDefaults.settings.integer(forKey: .barStyle) == LNPopupBar.Style.compact.rawValue
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage("rectangle.portrait.fill", useCompactConfig: useCompact)
		popupItem.barButtonItems = [gridBarButtonItem]
		
		LNApplyTitleWithSettings(to: self)
		
		dataSource = self
		
		setViewControllers([viewController(at: 0)], direction: .forward, animated: false)
    }
	
	var isVertical: Bool {
		self.navigationOrientation == .vertical
	}
	
	func viewController(at index: Int) -> PageCardViewController {
		let rv = self.storyboard?.instantiateViewController(withIdentifier: "PagedCard") as! PageCardViewController
		rv.index = index
		rv.loadViewIfNeeded()
		rv.cardView.backgroundColor = colors[index]
		return rv
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let viewController = viewController as! PageCardViewController
		
		if viewController.index == 0 {
			return nil
		}
		
		return self.viewController(at: viewController.index - 1)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let viewController = viewController as! PageCardViewController
		
		if viewController.index == colors.count - 1 {
			return nil
		}
		
		return self.viewController(at: viewController.index + 1)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
}
