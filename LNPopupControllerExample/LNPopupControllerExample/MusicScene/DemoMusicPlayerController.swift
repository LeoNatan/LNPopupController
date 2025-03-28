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

fileprivate struct BackgroundView: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		let rv = UIView()
		rv.tag = 666
		return rv
	}
	func updateUIView(_ uiView: UIView, context: Context) {
	}
}

fileprivate struct PopupTransitionImage: UIViewRepresentable {
	let uiImage: UIImage
	
	func makeUIView(context: Context) -> LNPopupImageView {
		let rv = LNPopupImageView()
		rv.image = uiImage
		rv.cornerRadius = 30.0
		
		let shadow = NSShadow()
		shadow.shadowOffset = .zero
		shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
		shadow.shadowBlurRadius = 10.0
		rv.shadow = shadow

		return rv
	}
	
	func updateUIView(_ uiView: LNPopupImageView, context: Context) {
		uiView.image = uiImage
	}
}

class PlaybackSettings: ObservableObject {
	@Published var songTitle: String = ""
	@Published var albumTitle: String = ""
	@Published var albumArt: UIImage = UIImage()
	
	@Published var playbackProgress: Float = 0.0
	@Published var progressEditedByUser: Bool = false
	@Published var volume: Float = 0.5
	@Published var isPlaying: Bool = true
	
	var onPlayPause: (() -> ())? = nil
}

struct PlayerView: View {
	@ObservedObject var playbackSettings = PlaybackSettings()
	
	var body: some View {
		GeometryReader { geometry in
			return VStack {
				PopupTransitionImage(uiImage: playbackSettings.albumArt)
					.aspectRatio(1.0, contentMode: .fit)
					.padding([.leading, .trailing], 10)
					.padding([.top], geometry.size.height * 60 / 896.0)
				VStack(spacing: geometry.size.height * 30.0 / 896.0) {
					HStack {
						VStack(alignment: .leading) {
							Text(playbackSettings.songTitle)
								.font(.system(size: 20, weight: .bold))
							Text(playbackSettings.albumTitle)
								.font(.system(size: 20, weight: .regular))
						}
						.lineLimit(1)
						.frame(minWidth: 0,
							   maxWidth: .infinity,
							   alignment: .topLeading)
						Button(action: {}, label: {
							Image(systemName: "ellipsis.circle")
								.font(.title)
						})
					}
					Slider(value: $playbackSettings.playbackProgress, onEditingChanged: { editing in
						playbackSettings.progressEditedByUser = editing
					})
					.padding([.bottom], geometry.size.height * 30.0 / 896.0)
					HStack {
						Button(action: {}, label: {
							Image(systemName: "backward.fill")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {
							playbackSettings.isPlaying.toggle()
							playbackSettings.onPlayPause?()
						}, label: {
							Image(systemName: playbackSettings.isPlaying ? "pause.fill" : "play.fill")
						})
						.font(.system(size: 50, weight: .bold))
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
						Button(action: {}, label: {
							Image(systemName: "forward.fill")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.system(size: 30, weight: .regular))
					.padding([.bottom], geometry.size.height * 20.0 / 896.0)
					HStack {
						Image(systemName: "speaker.fill")
						Slider(value: $playbackSettings.volume)
						Image(systemName: "speaker.wave.2.fill")
					}
					.font(.footnote)
					.foregroundColor(.gray)
					HStack {
						Button(action: {}, label: {
							Image(systemName: "shuffle")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {}, label: {
							Image(systemName: "airplayaudio")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {}, label: {
							Image(systemName: "repeat")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.body)
				}
				.padding(geometry.size.height * 40.0 / 896.0)
			}
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   minHeight: 0,
				   maxHeight: .infinity,
				   alignment: .top)
			.background {
				ZStack {
					ZStack {
						Image(uiImage: playbackSettings.albumArt)
							.resizable()
							.aspectRatio(contentMode: .fill)
						Color(uiColor: .systemBackground)
							.opacity(0.55)
					}.compositingGroup().blur(radius: 90)
					BackgroundView()
				}.edgesIgnoringSafeArea(.all)
			}
		}
	}
}

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
		
		playerView.playbackSettings.onPlayPause = { [weak self] in
			guard let self else {
				return
			}
			
			self.updateBarItems(with: self.traitCollection)
		}
		
		timer = Timer(timeInterval: 0.02, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(timer!, forMode: .common)
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
	}
	
	fileprivate func updateBarItems(with traitCollection: UITraitCollection) {
		let playPauseActionHandler: UIActionHandler = { [weak self] _ in
			guard let self else {
				return
			}
			self.playerView.playbackSettings.isPlaying.toggle()
			self.updateBarItems(with: self.traitCollection)
		}
		
		let scale: LNSystemImageScale
		let backForwardScale: LNSystemImageScale
		if LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: .barStyle) as? Int ?? 0)! == LNPopupBar.Style.compact {
			scale = .compact
			backForwardScale = .compact
		} else if UIDevice.current.userInterfaceIdiom == .pad && traitCollection.horizontalSizeClass == .regular {
			scale = .larger
			backForwardScale = .large
		} else {
			scale = .normal
			backForwardScale = .normal
		}
		
		let play = LNSystemBarButtonItem("play.fill", scale: scale != .larger ? .init(rawValue: scale.rawValue + 1)! : scale, primaryAction: UIAction(handler: playPauseActionHandler))
		play.accessibilityLabel = "Play"
		play.accessibilityIdentifier = "PlayButton";
		play.accessibilityTraits = .button
		
		let pause = LNSystemBarButtonItem("pause.fill", scale: scale != .larger ? .init(rawValue: scale.rawValue + 1)! : scale, primaryAction: UIAction(handler: playPauseActionHandler))
		pause.accessibilityLabel = "Pause"
		pause.accessibilityIdentifier = "PauseButton";
		pause.accessibilityTraits = .button
		
		let playPause = playerView.playbackSettings.isPlaying ? pause : play
		
		let next = LNSystemBarButtonItem("forward.fill", scale: backForwardScale, target: nil, action: nil)
		next.accessibilityLabel = "Next Track"
		next.accessibilityIdentifier = "NextButton";
		next.accessibilityTraits = .button
		
		let prev = LNSystemBarButtonItem("backward.fill", scale: backForwardScale, target: nil, action: nil)
		prev.accessibilityLabel = "Previous Track"
		prev.accessibilityIdentifier = "PrevButton";
		prev.accessibilityTraits = .button
		
		let more = LNSystemBarButtonItem("ellipsis", scale: backForwardScale, target: nil, action: nil)
		more.accessibilityLabel = "More"
		more.accessibilityIdentifier = "MoreButton";
		more.accessibilityTraits = .button
		
		if scale == .compact {
			if traitCollection.horizontalSizeClass == .compact {
				popupItem.leadingBarButtonItems = [playPause]
				popupItem.trailingBarButtonItems = [more]
			} else {
				popupItem.leadingBarButtonItems = [prev, playPause, next]
				popupItem.trailingBarButtonItems = [more]
			}
		} else {
			if traitCollection.horizontalSizeClass == .compact {
				popupItem.barButtonItems = [playPause, next]
			} else {
				popupItem.barButtonItems = [prev, playPause, next]
			}
		}
	}
	
	override func viewDidMove(toPopupContainerContentView popupContentView: LNPopupContentView?) {
		super.viewDidMove(toPopupContainerContentView: popupContentView)
		
		if popupContentView == nil {
			timer?.invalidate()
			timer = nil
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
		
		updateBarItems(with: traitCollection)
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
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		
		updateBarItems(with: newCollection)
	}
	
	var songTitle: String = "" {
		didSet {
			popupItem.title = songTitle
			playerView.playbackSettings.songTitle = songTitle
		}
	}
	
	var albumTitle: String = "" {
		didSet {
			if LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: .barStyle) as? Int ?? 0)! == .compact {
				popupItem.subtitle = albumTitle
			}
			playerView.playbackSettings.albumTitle = albumTitle
		}
	}

	var albumArt: UIImage = UIImage() {
		didSet {
			playerView.playbackSettings.albumArt = albumArt
			popupItem.image = albumArt
			popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
		}
	}
	
	@objc required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func _timerTicked(_ timer: Timer) {
		defer {
			popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
			let totalTime = TimeInterval(250)
			popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
		}
		
		guard playerView.playbackSettings.isPlaying && playerView.playbackSettings.progressEditedByUser == false else {
			return
		}
		
		playerView.playbackSettings.playbackProgress += 0.001
		popupItem.progress = playerView.playbackSettings.playbackProgress
		
		if popupItem.progress >= 1.0 {
			timer.invalidate()
			popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
		}
	}
}

#endif
