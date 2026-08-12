//
//  MusicPlayerView.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 19/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import AVKit
#if LNPOPUP
import LNPopupController

@available(iOS 26.0, *)
struct PlayerViewMac: View, PlaybackStateContainer {
	@State var playbackState = PlaybackState()
	
	func imageToUse() -> UIImage {
		playbackState.popupItem?.image ?? UIImage(named: "NotPlaying")!
	}
	
	@ViewBuilder
	func albumArtImage() -> some View {
		PopupTransitionImage(uiImage: imageToUse(), isEmptyPlayback: playbackState.popupItem == nil)
			.aspectRatio(1.0, contentMode: .fit)
			.frame(maxWidth: 360, maxHeight: 360)
	}
	
	@ViewBuilder
	func titles() -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				Text(playbackState.popupItem?.title ?? "Not Playing")
					.font(.title2)
				Text(playbackState.popupItem?.subtitle ?? "—")
					.font(.title3)
					.foregroundStyle(.secondary)
			}
			.lineLimit(1)
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   alignment: .topLeading)
			Button {} label: {
				Image(systemName: "ellipsis")
					.font(.title2)
					.padding(6)
			}
			.buttonStyle(.bordered)
			.buttonBorderShape(.circle)
		}
	}
	
	@ViewBuilder
	func slider() -> some View {
		Slider(value: $playbackState.progress)
			.simultaneousGesture(DragGesture(minimumDistance: 0.0).onChanged { _ in
				playbackState.isUserScrubbing = true
			} .onEnded { _ in
				playbackState.isUserScrubbing = false
			})
	}
	
	@ViewBuilder
	func playbackControls() -> some View {
		HStack {
			Button {} label: {
				Image(systemName: "shuffle")
					.font(.system(size: 12))
			}
			Spacer()
			Button {
				playbackState.onPrevSong?()
			} label: {
				Image(systemName: "backward.fill")
					.font(.system(size: 20))
			}
			Spacer()
			Button {
				playbackState.isPlaying.toggle()
			} label: {
				Image(systemName: playbackState.isPlaying ? "pause.fill" : "play.fill")
					.contentTransition(.symbolEffect(.replace, options: .speed(2)))
					.font(.system(size: 30))
			}
			Spacer()
			Button {
				playbackState.onNextSong?()
			} label: {
				Image(systemName: "forward.fill")
					.font(.system(size: 20))
			}
			Spacer()
			Button {} label: {
				Image(systemName: "repeat")
					.font(.system(size: 12))
			}
		}
		.imageScale(.large)
	}
	
	@ViewBuilder
	func volumeControls(with geometry: GeometryProxy) -> some View {
		HStack {
			Image(systemName: "speaker.fill")
			Slider(value: $playbackState.volume)
			Image(systemName: "speaker.wave.2.fill")
		}
		.font(.footnote)
		.foregroundColor(.secondary)
	}
	
	@ViewBuilder
	func backgroundView() -> some View {
		ZStack {
			ZStack {
				Image(uiImage: imageToUse())
					.resizable()
				Color(uiColor: .systemBackground)
					.opacity(0.2)
			}.compositingGroup().blur(radius: 200, opaque: true)
			BackgroundView()
		}.edgesIgnoringSafeArea(.all)
	}
	
	@ViewBuilder
	func playerContent() -> some View {
		VStack(spacing: 20) {
			albumArtImage()
			titles()
			slider()
			playbackControls()
				.padding(.bottom, 20)
		}
		.buttonStyle(.plain)
		.frame(maxWidth: 360)
		.disabled(playbackState.popupItem == nil)
	}
	
	func volumeImageName() -> String {
		switch playbackState.volume {
		case 0.0:
			"speaker.slash.fill"
		case 0.0..<0.3333:
			"speaker.wave.1.fill"
		case 0.3333..<0.66667:
			"speaker.wave.2.fill"
		case 0.66667...1.0:
			"speaker.wave.3.fill"
		default: fatalError()
		}
	}
	
	@ViewBuilder
	func chromeWrapper() -> some View {
		VStack {
			HStack {
				Spacer()
				HStack {
					AirPlayView()
						.frame(width: 12, height: 12)
						.padding(4)
					Divider()
						.frame(height: 15)
					Slider(value: $playbackState.volume)
						.padding(.vertical, 2)
						.controlSize(.small)
					ZStack {
						Image(systemName: volumeImageName())
						Image(systemName: "speaker.wave.3.fill").opacity(0.0)
					}.font(.system(size: 17, weight: .medium))
				}
				.padding(.horizontal, 10)
				.glassEffect()
				.frame(width: 218)
				.padding(9)
			}.ignoresSafeArea()
			Spacer()
		}.ignoresSafeArea()
	}
	
	var body: some View {
		ZStack(alignment: .center) {
			backgroundView()
			playerContent()
			chromeWrapper()
		}
	}
}

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
	let isEmptyPlayback: Bool
	
	func makeUIView(context: Context) -> LNPopupImageView {
		let rv = LNPopupImageView()
		rv.translatesAutoresizingMaskIntoConstraints = false
		rv.image = uiImage
		rv.cornerRadius = 10.0
		rv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		rv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		
		let shadow = NSShadow()
		shadow.shadowOffset = .zero
		shadow.shadowColor = isEmptyPlayback ? UIColor.clear : UIColor.black.withAlphaComponent(0.3333)
		shadow.shadowBlurRadius = 20.0
		rv.shadow = shadow
		
		return rv
	}
	
	func updateUIView(_ uiView: LNPopupImageView, context: Context) {
		uiView.image = uiImage
		uiView.shadow.shadowColor = isEmptyPlayback ? UIColor.clear : UIColor.black.withAlphaComponent(0.3333)
	}
}

fileprivate struct AirPlayView: UIViewRepresentable {
	
	func makeUIView(context: Context) -> UIView {
		
		let routePickerView = AVRoutePickerView()
		routePickerView.backgroundColor = .clear
		routePickerView.activeTintColor = .label
		routePickerView.tintColor = .tintColor
		
		return routePickerView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
	}
}

#endif
