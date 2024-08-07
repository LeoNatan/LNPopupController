//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#if LNPOPUP
import UIKit
import SwiftUI
import LNPopupController

fileprivate struct BlurView: UIViewRepresentable {
	var style: UIBlurEffect.Style = .systemMaterial
	func makeUIView(context: Context) -> UIVisualEffectView {
		let rv = UIVisualEffectView(effect: UIBlurEffect(style: style))
		rv.tag = 666
		return rv
	}
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = UIBlurEffect(style: style)
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
				Image(uiImage: playbackSettings.albumArt)
					.resizable()
					.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
					.aspectRatio(contentMode: .fit)
					.padding([.leading, .trailing], 10)
					.padding([.top], geometry.size.height * 60 / 896.0)
					.shadow(radius: 5)
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
			.background({
				ZStack {
					Image(uiImage: playbackSettings.albumArt)
						.resizable()
					BlurView()
				}
				.edgesIgnoringSafeArea(.all)
			}())
		}
	}
}

class DemoMusicPlayerController: UIHostingController<PlayerView> {
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	var timer : Timer?
	var popupCloseButton: LNPopupCloseButton?
	
	lazy var vibrancyView : UIVisualEffectView = {
		let blur = self.view.viewWithTag(666) as! UIVisualEffectView
		let rv = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur.effect as! UIBlurEffect, style: .separator))
		rv.translatesAutoresizingMaskIntoConstraints = false
		blur.contentView.addSubview(rv)
		NSLayoutConstraint.activate([
			rv.leadingAnchor.constraint(equalTo: blur.safeAreaLayoutGuide.leadingAnchor),
			rv.trailingAnchor.constraint(equalTo: blur.safeAreaLayoutGuide.trailingAnchor),
			rv.topAnchor.constraint(equalTo: blur.safeAreaLayoutGuide.topAnchor),
			rv.bottomAnchor.constraint(equalTo: blur.safeAreaLayoutGuide.bottomAnchor)
		])
		
		return rv
	}()
	
	let playerView = PlayerView()
	
	required init() {
		super.init(rootView: playerView)
		
		playerView.playbackSettings.onPlayPause = { [weak self] in
			self?.updateBarItems()
		}
		
		timer = Timer(timeInterval: 0.01, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(timer!, forMode: .common)
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
		
		updateBarItems()
	}
	
	fileprivate func updateBarItems() {
		let playPauseAction = UIAction { [weak self] _ in
			self?.playerView.playbackSettings.isPlaying.toggle()
			self?.updateBarItems()
		}
		
		let play = UIBarButtonItem(image: LNSystemImage(named: "play.fill", useCompactConfig: false), primaryAction: playPauseAction)
		play.accessibilityLabel = NSLocalizedString("Play", comment: "")
		let pause = UIBarButtonItem(image: LNSystemImage(named: "pause.fill", useCompactConfig: false), primaryAction: playPauseAction)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let next = UIBarButtonItem(image: LNSystemImage(named: "forward.fill", useCompactConfig: false), style: .plain, target: nil, action: nil)
		next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
		
		let playPause = playerView.playbackSettings.isPlaying ? pause : play
		
		if LNPopupBar.Style(rawValue: UserDefaults.settings.object(forKey: .barStyle) as? Int ?? 0)! == LNPopupBar.Style.compact {
			popupItem.leadingBarButtonItems = [ playPause ]
			popupItem.trailingBarButtonItems = [ next ]
		} else {
			pause.width = 60
			play.width = 60
			next.width = 60
			popupItem.barButtonItems = [ playPause, next ]
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
