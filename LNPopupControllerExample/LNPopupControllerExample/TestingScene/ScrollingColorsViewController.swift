//
//  ScrollingColorsViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2024-09-26.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import UIKit
import LNPopupController

class ScrollingColorsViewController: UICollectionViewController {
	var colors: [UIColor] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for _ in 0..<collectionView(collectionView, numberOfItemsInSection: 0) {
			colors.append(LNRandomSystemColor())
		}
		
		collectionView.collectionViewLayout = isVertical ? createVerticalGridLayout() : createHorizontalGridLayout()
		
#if compiler(>=6.2)
		if #available(iOS 26.0, *) {
			collectionView.topEdgeEffect.isHidden = true
			collectionView.bottomEdgeEffect.isHidden = true
		}
#endif
		
		let useCompact = LNBarIsCompact()
		
		let gridBarButtonItem = UIBarButtonItem()
		gridBarButtonItem.image = LNSystemImage(isVertical ? "square.grid.3x3.fill" : "rectangle.portrait.fill", scale: useCompact ? .compact : .normal)
		popupItem.barButtonItems = [gridBarButtonItem]
		
		LNApplyTitleWithSettings(to: self)
		
//		collectionView.contentInsetAdjustmentBehavior = .always
//		collectionView.isDirectionalLockEnabled = true
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
	
	var isVertical: Bool {
		UserDefaults.settings.integer(forKey: .useScrollingPopupContent) == 10
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		isVertical ? 1000 : 30
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
		cell.contentView.backgroundColor = colors[indexPath.item]
		return cell
	}
	
	func createVerticalGridLayout() -> UICollectionViewLayout {
		UICollectionViewCompositionalLayout { sectionIdx, environment in
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			
			group.interItemSpacing = .fixed(2)
			
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 2
			return section
		}
	}
	
	func createHorizontalGridLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { sectionIdx, environment in
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(1.0))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 16
			return section
		}
		
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal
		config.contentInsetsReference = .none
		
		layout.configuration = config
		
		return layout
	}
}
