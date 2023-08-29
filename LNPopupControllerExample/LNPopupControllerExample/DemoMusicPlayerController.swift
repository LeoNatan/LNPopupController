//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
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
}

struct PlayerView: View {
	@ObservedObject var playbackSettings = PlaybackSettings()
	
	init() {
	}
	
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
//					if #available(iOS 14.0, *) {
//						ProgressView(value: playbackSettings.playbackProgress)
//							.padding([.bottom], geometry.size.height * 30.0 / 896.0)
//					} else {
						Slider(value: $playbackSettings.playbackProgress, onEditingChanged: { editing in
							playbackSettings.progressEditedByUser = editing
						})
						.padding([.bottom], geometry.size.height * 30.0 / 896.0)
//					}
					HStack {
						Button(action: {}, label: {
							Image(systemName: "backward.fill")
						})
						.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {
							playbackSettings.isPlaying.toggle()
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
	
	fileprivate func LNSystemImage(named: String) -> UIImage {
		let config : UIImage.SymbolConfiguration
		if LNPopupBarStyle(rawValue: UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? Int ?? 0)! == LNPopupBarStyle.compact {
			config = UIImage.SymbolConfiguration(scale: .unspecified)
		} else {
			config = UIImage.SymbolConfiguration(weight: .bold)
		}
		
		return UIImage(systemName: named, withConfiguration: config)!
	}
	
	required init() {
		super.init(rootView: playerView)
		
		timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
		
		let pause = UIBarButtonItem(image: LNSystemImage(named: "pause.fill"), style: .plain, target: nil, action: nil)
		pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		let next = UIBarButtonItem(image: LNSystemImage(named: "forward.fill"), style: .plain, target: nil, action: nil)
		next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
		
		if LNPopupBarStyle(rawValue: UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? Int ?? 0)! == LNPopupBarStyle.compact {
			popupItem.leadingBarButtonItems = [ pause ]
			popupItem.trailingBarButtonItems = [ next ]
		} else {
			pause.width = 60
			next.width = 60
			popupItem.barButtonItems = [ pause, next ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
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
			if LNPopupBarStyle(rawValue: UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? Int ?? 0)! == .compact {
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
		if playerView.playbackSettings.progressEditedByUser == false {
			playerView.playbackSettings.playbackProgress += 0.01
		}
		
		popupItem.progress = playerView.playbackSettings.playbackProgress
		
		popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
		let totalTime = TimeInterval(250)
		popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
		
		if popupItem.progress >= 1.0 {
			timer.invalidate()
			popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
		}
	}
}

#endif
