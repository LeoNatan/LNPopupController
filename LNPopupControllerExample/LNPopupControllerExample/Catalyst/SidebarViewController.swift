//
//  SidebarViewController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#if targetEnvironment(macCatalyst)

import UIKit
import LoremIpsum

private let reuseIdentifier = "Cell"

enum SidebarSection {
	case main
	case library
	case playlists
}

enum SidebarItem: Hashable {
	case header(title: String)
	case item(tab: UITab)
}

class SidebarCell: UICollectionViewListCell {
	override var canBecomeFirstResponder: Bool {
		return false
	}
	
	override var canBecomeFocused: Bool {
		return false
	}
}

class SidebarViewController: UICollectionViewController {
	@ViewLoading
	var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>
	
	init() {
		super.init(collectionViewLayout: Self.createLayout())
		
		clearsSelectionOnViewWillAppear = false
		
		let cellRegistration = UICollectionView.CellRegistration<SidebarCell, SidebarItem> { cell, indexPath, item in
			var content: UIListContentConfiguration
			var background: UIBackgroundConfiguration
			switch item {
			case .header(let title):
				content = UIListContentConfiguration.header()
				content.text = title
				
				background = UIBackgroundConfiguration.listHeader()
				
				let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
				cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
			case .item(let tab):
				content = UIListContentConfiguration.cell()
				let first = AttributedString(tab.title)
				var second = try! AttributedString(markdown: ".")
				second.font = UIFont.systemFont(ofSize: 1)
				second.foregroundColor = UIColor.red.withAlphaComponent(0.0)
				content.attributedText = NSAttributedString(first + second)
				content.image = tab.image
				
				background = UIBackgroundConfiguration.listCell()
				
				cell.accessories = []
			}
			
			content.textProperties.allowsDefaultTighteningForTruncation = false
			
			cell.contentConfiguration = content
			cell.backgroundConfiguration = background
		}
		
		dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: SidebarItem) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}
		
		let snapshots = cleanSnapshots
		for (section, sectionSnapshot) in snapshots {
			dataSource.apply(sectionSnapshot, to: section, animatingDifferences: false)
		}
		
		let indexPath = IndexPath(item: 1, section: 0)
		collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
		DispatchQueue.main.async {
			self.collectionView(self.collectionView, didSelectItemAt: indexPath)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let tab = dataSource.itemIdentifier(for: indexPath), case let .item(tab) = tab, let viewController = tab.viewController else {
			return
		}
		
		viewController.navigationItem.title = tab.title
		
		guard let navigationController = splitViewController?.viewController(for: .secondary) as? UINavigationController else {
			fatalError()
		}
		
		navigationController.viewControllers = [viewController]
	}
	
	static func createLayout() -> UICollectionViewLayout {
		UICollectionViewCompositionalLayout { section, layoutEnvironment in
			var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
			if section != 0 {
				configuration.headerTopPadding = 10
			}
			configuration.backgroundColor = .clear
			configuration.showsSeparators = false
			if section == 0 {
				configuration.headerMode = .none
			} else {
				configuration.headerMode = .supplementary
			}
			let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
			return section
		}
	}
	
	var cleanSnapshots: Array<(SidebarSection, NSDiffableDataSourceSectionSnapshot<SidebarItem>)> {
		var mainSection = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
		mainSection.append([
			.item(tab: UITab(title: "Search", image: UIImage(systemName: "magnifyingglass"), identifier: "search", viewControllerProvider: { _ in
				UIViewController()
			})),
			.item(tab: UITab(title: "Home", image: UIImage(systemName: "house"), identifier: "home", viewControllerProvider: { _ in
				UIViewController()
			})),
			.item(tab: UITab(title: "New", image: UIImage(systemName: "square.grid.2x2"), identifier: "new", viewControllerProvider: { _ in
				UIViewController()
			})),
			.item(tab: UITab(title: "Radio", image: UIImage(systemName: "dot.radiowaves.left.and.right"), identifier: "radio", viewControllerProvider: { _ in
				UIViewController()
			})),
		], to: nil)
		
//		if let systemAlbumsHeader {
//			systemAlbumsSection.append([systemAlbumsHeader])
//		}
//		
//		if hasTabBarController == false || isPickerStyle {
//			systemAlbumsSection.append([.library], to: systemAlbumsHeader)
//		}
//		
//		if displaysPlaces {
//			systemAlbumsSection.append([.places], to: systemAlbumsHeader)
//		}
//		
//		func filterFromDelegate(_ collection: inout [PHAssetCollection]) {
//			guard let delegate else {
//				return
//			}
//			
//			collection = collection.filter { delegate.sidebarViewController(self, shouldDisplay: $0) }
//		}
//		
//		var systemFetchedCollections = systemFetchResult.objects(at: IndexSet(0..<systemFetchResult.count)).sorted { SidebarItem.systemAlbumSort.firstIndex(of: $0.assetCollectionSubtype.rawValue)! < SidebarItem.systemAlbumSort.firstIndex(of: $1.assetCollectionSubtype.rawValue)! }
//		filterFromDelegate(&systemFetchedCollections)
//		systemAlbumsSection.append(systemFetchedCollections.map { .album($0) }, to: systemAlbumsHeader)
//		
//		if !isPickerStyle {
//			systemAlbumsSection.append([.widgetCurrent], to: systemAlbumsHeader)
//			systemAlbumsSection.append([.widgetHidden], to: systemAlbumsHeader)
//		}
//		
//		if !isPickerStyle, PhotoDB.shared.allRequiredScales().count > 0 {
//			systemAlbumsSection.append([.widgetErrors], to: systemAlbumsHeader)
//		}
//		
//		if let systemAlbumsHeader {
//			systemAlbumsSection.expand([systemAlbumsHeader])
//		}
//		
//		let mediaTypeHeader = SidebarItem.headerTitle(String(localized: "Media Types"))
//		var mediaTypeSection = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
//		mediaTypeSection.append([mediaTypeHeader])
//		var mediaTypeFetchedCollections = mediaTypeFetchResult.objects(at: IndexSet(0..<mediaTypeFetchResult.count)).sorted { SidebarItem.mediaTypeAlbumSort.firstIndex(of: $0.assetCollectionSubtype.rawValue)! < SidebarItem.mediaTypeAlbumSort.firstIndex(of: $1.assetCollectionSubtype.rawValue)! }
//		filterFromDelegate(&mediaTypeFetchedCollections)
//		mediaTypeSection.append(mediaTypeFetchedCollections.map { .album($0) }, to: mediaTypeHeader)
//		mediaTypeSection.expand([mediaTypeHeader])
//		
//		let userAlbumsHeader: SidebarItem?
//		
//		if !hasTabBarController || isPickerStyle {
//			userAlbumsHeader = SidebarItem.headerTitle(String(localized: "Albums"))
//		} else {
//			userAlbumsHeader = nil
//		}
//		
//		var userAlbumsSection = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
//		
//		if let userAlbumsHeader {
//			userAlbumsSection.append([userAlbumsHeader])
//		}
//		
//		if append(parse(fetchResult), to: userAlbumsHeader, in: &userAlbumsSection) == 0 {
//			if let userAlbumsHeader {
//				userAlbumsSection.delete([userAlbumsHeader])
//			}
//		} else {
//			if let userAlbumsHeader {
//				userAlbumsSection.expand([userAlbumsHeader])
//			}
//		}
//		
//		if hasTabBarController && !isPickerStyle {
//			return [(.userAlbum, userAlbumsSection), (.systemAlbum, systemAlbumsSection), (.mediaTypeAlbum, mediaTypeSection)]
//		} else {
//			return [(.systemAlbum, systemAlbumsSection), (.mediaTypeAlbum, mediaTypeSection), (.userAlbum, userAlbumsSection)]
//		}
		
		return [(.main, mainSection)]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#endif
