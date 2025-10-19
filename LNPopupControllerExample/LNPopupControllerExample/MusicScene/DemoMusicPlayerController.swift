//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#if LNPOPUP
import UIKit
import SwiftUI
import LNPopupController

@available(iOS 17.0, *)
class DemoMusicPlayerController: UIHostingController<PlayerView> {
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	var timer : Timer?
	var popupCloseButton: LNPopupCloseButton?
	
	lazy var vibrancyView : UIVisualEffectView = {
		let background = self.view.viewWithTag(666)!
		let rv = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .separator))
		rv.translatesAutoresizingMaskIntoConstraints = false
		background.addSubview(rv)
		NSLayoutConstraint.activate([
			rv.leadingAnchor.constraint(equalTo: background.safeAreaLayoutGuide.leadingAnchor),
			rv.trailingAnchor.constraint(equalTo: background.safeAreaLayoutGuide.trailingAnchor),
			rv.topAnchor.constraint(equalTo: background.safeAreaLayoutGuide.topAnchor),
			rv.bottomAnchor.constraint(equalTo: background.safeAreaLayoutGuide.bottomAnchor)
		])
		
		return rv
	}()
	
	let playerView = PlayerView()
	
	required init() {
		super.init(rootView: playerView)
		
		registerForTraitChanges([LNPopupBar.EnvironmentTrait.self]) { (self: Self, previousTraitCollection) in
			self.updateBarItems(with: self.traitCollection.popupBarEnvironment)
		}
		
		playerView.playbackState.onPrevSong = { [weak self] in
			self?.goPrev()
		}
		
		playerView.playbackState.onNextSong = { [weak self] in
			self?.goNext()
		}
		
		updateTimerFromPlayerView()
		updateBarItemsFromPlayerView()
		updateItemProgressFromPlayerView()
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
	}
	
	func updateTimerFromPlayerView() {
		withObservationTracking {
			_ = playerView.playbackState.popupItem
			if playerView.playbackState.isUserScrubbing || !playerView.playbackState.isPlaying {
				stopTimer()
			} else {
				startTimer()
			}
		} onChange: {
			Task { @MainActor [weak self] in
				self?.updateTimerFromPlayerView()
			}
		}
	}
	
	func updateBarItemsFromPlayerView() {
		withObservationTracking {
			_ = playerView.playbackState.isPlaying
			self.reloadBarItems(with: self.traitCollection)
		} onChange: {
			Task { @MainActor [weak self] in
				self?.updateBarItemsFromPlayerView()
			}
		}
	}
	
	func updateItemProgressFromPlayerView() {
		withObservationTracking {
			let progress = playerView.playbackState.progress
			popupItem.progress = popupItem.isEmptyPlaybackItem ? 0.0 : progress
		} onChange: {
			Task { @MainActor [weak self] in
				self?.updateItemProgressFromPlayerView()
			}
		}

	}
	
	fileprivate func reloadBarItems(with traitCollection: UITraitCollection, animated: Bool = false) {
		LNPopupItemSetStandardMusicControls(popupItem, popupItem.isEmptyPlaybackItem || !playerView.playbackState.isPlaying, animated, traitCollection, UIAction { [weak self] _ in
			self?.goPrev()
		}, UIAction { [weak self] _ in
			self?.playerView.playbackState.isPlaying.toggle()
		}, UIAction { [weak self] _ in
			self?.goNext()
		})
		updateBarItems(with: traitCollection.popupBarEnvironment)
	}
	
	fileprivate func updateBarItems(with popupBarEnvironment: LNPopupBar.Environment) {
		popupItem.barButtonItems?.forEach { $0.isEnabled = !popupItem.isEmptyPlaybackItem }
		popupItem.barButtonItems?.last?.isHidden = traitCollection.popupBarEnvironment == .inline
	}
	
	override func viewDidMove(toPopupContainerContentView popupContentView: LNPopupContentView?) {
		super.viewDidMove(toPopupContainerContentView: popupContentView)
		
		if popupContentView == nil {
			stopTimer()
		}
	}
	
	override func positionPopupCloseButton(_ popupCloseButton: LNPopupCloseButton) -> Bool {
		#if targetEnvironment(macCatalyst)
		return false
		#else
		self.popupCloseButton = popupCloseButton
		self.view.setNeedsLayout()
		return true
		#endif
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		overrideUserInterfaceStyle = .dark
		view.tintColor = .white
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UIView.performWithoutAnimation {
			view.alpha = 0.0
		}
		
		view.alpha = 1.0
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		UIView.performWithoutAnimation {
			view.alpha = 1.0
		}
		
		view.alpha = 0.0
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let popupCloseButton = popupCloseButton, popupCloseButton.superview != vibrancyView.contentView {
			vibrancyView.contentView.addSubview(popupCloseButton)
			
			popupCloseButton.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint.activate([
				popupCloseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				popupCloseButton.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor, constant: 4),
			])
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
			reloadBarItems(with: traitCollection, animated: true)
		}
	}
	
	override func popupItemDidChange(_ previousPopupItem: LNPopupItem?) {
		playerView.playbackState.popupItem = popupItem.isEmptyPlaybackItem ? nil : popupItem
		playerView.playbackState.progress = 0.0
		if popupItem.isEmptyPlaybackItem {
			playerView.playbackState.isPlaying = false
		}
		reloadBarItems(with: traitCollection, animated: false)
	}
	
	@objc required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func startTimer() {
		stopTimer()
		
		timer = Timer(timeInterval: 0.02, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(timer!, forMode: .common)
	}
	
	func stopTimer() {
		if let timer {
			timer.invalidate()
		}
		timer = nil
	}
	
	@objc func _timerTicked(_ timer: Timer) {
		defer {
			popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
			let totalTime = TimeInterval(250)
			popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
		}
		
		playerView.playbackState.progress += 0.001
		
		if playerView.playbackState.progress >= 1.0 {
			stopTimer()
			goNext()
		}
	}
	
	func goNext() {
		if nextSong == nil || nextSong?(popupItem) == false {
			popupPresentationContainer?.popupBar.dataSource = nil
			popupPresentationContainer?.popupBar.popupItem = .emptyPlayback
		}
	}
	
	func goPrev() {
		prevSong?(popupItem)
	}
	
	func play() {
		playerView.playbackState.progress = 0.0
		playerView.playbackState.isPlaying = true
	}
	
	var nextSong: ((LNPopupItem) -> Bool)? = nil
	var prevSong: ((LNPopupItem) -> Void)? = nil
}

#endif
