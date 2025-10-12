//
//  ScrollingColorsPageViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-27.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit

protocol Indexable {
	var index: Int { get set }
}

class _ScrollingColorsPageViewController<T: UIViewController & Indexable>: UIPageViewController, UIPageViewControllerDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
#if LNPOPUP
		let useCompact = LNBarIsCompact()
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage("rectangle.portrait.fill", scale: useCompact ? .compact : .normal)
		popupItem.barButtonItems = [gridBarButtonItem]
		
		LNApplyTitleWithSettings(to: self)
#endif
		
		dataSource = self
		
		setViewControllers([viewController(at: 0)], direction: .forward, animated: false)
    }
	
	var isVertical: Bool {
		self.navigationOrientation == .vertical
	}
	
	dynamic func viewController(at index: Int) -> T {
		fatalError()
	}
	
	dynamic var totalCount: Int {
		fatalError()
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let viewController = viewController as! T
		
		if viewController.index == 0 {
			return nil
		}
		
		return self.viewController(at: viewController.index - 1)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let viewController = viewController as! T
		
		if viewController.index == totalCount - 1 {
			return nil
		}
		
		return self.viewController(at: viewController.index + 1)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if #available(iOS 26.0, *), let scrollView = value(forKey: "scrollView") as? UIScrollView {
			scrollView.topEdgeEffect.isHidden = true
			scrollView.bottomEdgeEffect.isHidden = true
		}
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
}

extension PageCardViewController: Indexable {}

class ScrollingColorsPageViewController: _ScrollingColorsPageViewController<PageCardViewController>, Indexable {
	var colors: [UIColor] = []
	var index: Int = -1
	var prefix: String? = nil {
		didSet {
			(viewControllers as! [PageCardViewController]).forEach { $0.prefix = prefix }
		}
	}
	
	override var totalCount: Int {
		colors.count
	}
	
	override func viewDidLoad() {
		for _ in 0..<30 {
			colors.append(LNRandomSystemColor())
		}
		
		super.viewDidLoad()
	}
	
	override func viewController(at index: Int) -> PageCardViewController {
		let rv = self.storyboard!.instantiateViewController(withIdentifier: "PagedCard") as! PageCardViewController
		rv.index = index
		rv.prefix = prefix
		rv.loadViewIfNeeded()
		rv.cardView.backgroundColor = colors[index]
		return rv
	}
}

class ScrollingGroupedColorsPageViewController: _ScrollingColorsPageViewController<ScrollingColorsPageViewController> {
	override var totalCount: Int {
		return 10
	}
	
	override func viewController(at index: Int) -> ScrollingColorsPageViewController {
		let identifier: String
		if isVertical {
			identifier = "HorizontalPagedScrollingColors"
		} else {
			identifier = "VerticalPagedScrollingColors"
		}
		
		let rv = self.storyboard!.instantiateViewController(withIdentifier: identifier) as! ScrollingColorsPageViewController
		rv.index = index
		rv.prefix = "\(index)_"
		return rv
	}
}
