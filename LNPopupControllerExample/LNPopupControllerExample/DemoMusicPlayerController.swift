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

@available(iOS 13.0, *)
fileprivate struct BlurView: UIViewRepresentable {
	var style: UIBlurEffect.Style = .systemMaterial
	func makeUIView(context: Context) -> UIVisualEffectView {
		return UIVisualEffectView(effect: UIBlurEffect(style: style))
	}
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = UIBlurEffect(style: style)
	}
}

@available(iOS 13.0, *)
class PlaybackSettings: ObservableObject {
	@Published var songTitle: String = ""
	@Published var albumTitle: String = ""
	@Published var albumArt: UIImage = UIImage()
	
	@Published var playbackProgress: Float = 0.0
	@Published var volume: Float = 0.5
	@Published var isPlaying: Bool = true
}

@available(iOS 13.0, *)
struct PlayerView: View {
	@ObservedObject var playbackSettings = PlaybackSettings()
	
	init() {
	}
	
	var body: some View {
		VStack {
			Image(uiImage: playbackSettings.albumArt)
				.resizable()
				.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
				.aspectRatio(contentMode: .fit)
				.padding([.leading, .trailing], 20)
				.padding([.top], 40)
				.shadow(radius: 5)
			VStack(spacing: 40) {
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
				if #available(iOS 14.0, *) {
					ProgressView(value: playbackSettings.playbackProgress)
				} else {
					Slider(value: $playbackSettings.playbackProgress)
				}
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
					.frame(minWidth: 0, maxWidth: .infinity)
					Button(action: {}, label: {
						Image(systemName: "forward.fill")
					})
					.frame(minWidth: 0, maxWidth: .infinity)
				}
				.frame(height: 40)
				.font(.largeTitle)
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
			.padding(30)
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
					.aspectRatio(contentMode: .fill)
				BlurView()
			}
			.edgesIgnoringSafeArea(.all)
		}())
		.animation(.spring())
	}
}

@available(iOS 13.0, *)
class DemoMusicPlayerController: UIHostingController<PlayerView> {
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
	var timer : Timer?
	
	let playerView = PlayerView()
	
	fileprivate func LNSystemImage(named: String) -> UIImage {
		let config : UIImage.SymbolConfiguration
		if UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? LNPopupBarStyle == LNPopupBarStyle.compact {
			config = UIImage.SymbolConfiguration(scale: .unspecified)
		} else {
			config = UIImage.SymbolConfiguration(scale: .medium)
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
		
		if UserDefaults.standard.object(forKey: PopupSettingsBarStyle) as? LNPopupBarStyle == LNPopupBarStyle.compact {
			popupItem.leadingBarButtonItems = [ pause ]
			popupItem.trailingBarButtonItems = [ next ]
		} else {
			popupItem.barButtonItems = [ pause, next ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
	}
	
	var songTitle: String = "" {
		didSet {
			popupItem.title = songTitle
			playerView.playbackSettings.songTitle = songTitle
		}
	}
	
	var albumTitle: String = "" {
		didSet {
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
		popupItem.progress += 0.0002;
		popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
		
		let totalTime = TimeInterval(250)
		popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
		
		playerView.playbackSettings.playbackProgress = popupItem.progress
		
		if popupItem.progress >= 1.0 {
			timer.invalidate()
			popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
		}
	}
}

#endif
