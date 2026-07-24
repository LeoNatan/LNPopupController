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
	case header(String)
	case item(UITab)
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
				if content.image?.isSymbolImage == false {
					content.imageProperties.maximumSize = CGSizeMake(23, 23)
					content.imageProperties.reservedLayoutSize = CGSizeMake(28, 23)
					content.imageProperties.cornerRadius = 5
				}
				
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
				configuration.headerMode = .firstItemInSection
			}
			let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
			return section
		}
	}
	
	var cleanSnapshots: Array<(SidebarSection, NSDiffableDataSourceSectionSnapshot<SidebarItem>)> {
		let viewControllerCreator: () -> UIViewController = {
			let vc = UIViewController()
			vc.preferredContentSize = CGSize(width: 1000, height: -1)
			vc.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), primaryAction: UIAction { [weak vc] action in
				guard let vc else {
					return
				}
				
				let settings = UINavigationController(rootViewController: SettingsViewController())
				settings.modalPresentationStyle = .popover
				settings.popoverPresentationController?.sourceItem = action.sender as? UIPopoverPresentationControllerSourceItem
				vc.present(settings, animated: true)
			})
			return vc
		}
		
		var mainSection = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
		mainSection.append([
			.item(UITab(title: NSLocalizedString("Search", comment: ""), image: UIImage(systemName: "magnifyingglass"), identifier: "search", viewControllerProvider: { _ in
				viewControllerCreator()
			})),
			.item(UITab(title: NSLocalizedString("Home", comment: ""), image: UIImage(systemName: "house"), identifier: "home", viewControllerProvider: { _ in
				viewControllerCreator()
			})),
			.item(UITab(title: NSLocalizedString("New", comment: ""), image: UIImage(systemName: "square.grid.2x2"), identifier: "new", viewControllerProvider: { _ in
				viewControllerCreator()
			})),
			.item(UITab(title: NSLocalizedString("Radio", comment: ""), image: UIImage(systemName: "dot.radiowaves.left.and.right"), identifier: "radio", viewControllerProvider: { _ in
				viewControllerCreator()
			})),
		], to: nil)
		
		let playlistsHeader = SidebarItem.header(NSLocalizedString("Playlists", comment: ""))
		var playlistsSection = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
		playlistsSection.append([playlistsHeader])
		
		var playlists = [SidebarItem]()
		for idx in 1...30 {
			let playlist = SidebarItem.item(UITab(title: NSLocalizedString(LoremIpsum.words(withNumber: UInt.random(in: 2...4)).capitalized, comment: ""), image: UIImage(named: "genre\(idx)"), identifier: "playlist\(idx)", viewControllerProvider: { _ in
				UIStoryboard(name: "Music", bundle: nil).instantiateViewController(withIdentifier: "Album")
			}))
			playlists.append(playlist)
		}
		
		playlistsSection.append(playlists, to: playlistsHeader)
		playlistsSection.expand([playlistsHeader])
		
		return [(.main, mainSection), (.playlists, playlistsSection)]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#endif
