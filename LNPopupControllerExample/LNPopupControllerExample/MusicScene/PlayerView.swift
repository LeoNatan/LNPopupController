//
//  MusicPlayerView.swift
//  LNPopupControllerExample
//
//  Created by Léo Natan on 19/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

import SwiftUI

@available(iOS 17.0, *)
@Observable
class PlaybackState {
	var popupItem: LNPopupItem? = nil
	
	var isPlaying: Bool = false
	
	var progress: Float = 0.0
	var isUserScrubbing: Bool = false
	var volume: Float = 0.5
	
	var onPrevSong: (() -> Void)?
	var onNextSong: (() -> Void)?
}

@available(iOS 17.0, *)
struct PlayerView: View {
	@State var playbackState = PlaybackState()
	
	func imageToUse() -> UIImage {
		playbackState.popupItem?.image ?? UIImage(named: "NotPlaying")!
	}
	
	@ViewBuilder
	func albumArtImage(with geometry: GeometryProxy) -> some View {
		PopupTransitionImage(uiImage: imageToUse(), isEmptyPlayback: playbackState.popupItem == nil)
			.aspectRatio(1.0, contentMode: .fit)
			.padding([.leading, .trailing], 10)
			.padding([.top], geometry.size.height * 60 / 896.0)
	}
	
	@ViewBuilder
	func titles(with geometry: GeometryProxy) -> some View {
		HStack {
			VStack(alignment: .leading) {
				Text(playbackState.popupItem?.title ?? "")
					.font(.system(size: 20, weight: .bold))
				Text(playbackState.popupItem?.subtitle ?? "")
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
	}
	
	@ViewBuilder
	func slider(with geometry: GeometryProxy) -> some View {
		let slider = Slider(value: $playbackState.progress)
			.simultaneousGesture(DragGesture(minimumDistance: 0.0).onChanged { _ in
				playbackState.isUserScrubbing = true
			} .onEnded { _ in
				playbackState.isUserScrubbing = false
			})
			.padding([.bottom], geometry.size.height * 30.0 / 896.0)
		
		if #available(iOS 26.0, *) {
			slider.sliderThumbVisibility(.hidden)
		} else {
			slider
		}
	}
	
	@ViewBuilder
	func playbackControls(with geometry: GeometryProxy) -> some View {
		HStack {
			Button {
				playbackState.onPrevSong?()
			} label: {
				Image(systemName: "backward.fill")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			Button {
				playbackState.isPlaying.toggle()
			} label: {
				Image(systemName: playbackState.isPlaying ? "pause.fill" : "play.fill")
					.contentTransition(.symbolEffect(.replace))
			}
			.font(.system(size: 50, weight: .bold))
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
			Button {
				playbackState.onNextSong?()
			} label: {
				Image(systemName: "forward.fill")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
		}
		.font(.system(size: 30, weight: .regular))
		.padding([.bottom], geometry.size.height * 20.0 / 896.0)
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
	func secondaryControls(with geometry: GeometryProxy) -> some View {
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
	
	var body: some View {
		GeometryReader { geometry in
			return VStack {
				albumArtImage(with: geometry)
				VStack(spacing: geometry.size.height * 30.0 / 896.0) {
					titles(with: geometry)
					slider(with: geometry)
					playbackControls(with: geometry)
					volumeControls(with: geometry)
					secondaryControls(with: geometry)
				}
				.disabled(playbackState.popupItem == nil)
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
						Image(uiImage: imageToUse())
							.resizable()
						Color(uiColor: .systemBackground)
							.opacity(0.4)
					}.compositingGroup().blur(radius: 90, opaque: true)
					BackgroundView()
				}.edgesIgnoringSafeArea(.all)
			}
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
		rv.cornerRadius = 30.0
		
		let shadow = NSShadow()
		shadow.shadowOffset = .zero
		shadow.shadowColor = isEmptyPlayback ? UIColor.clear : UIColor.black.withAlphaComponent(0.3333)
		shadow.shadowBlurRadius = 10.0
		rv.shadow = shadow
		
		return rv
	}
	
	func updateUIView(_ uiView: LNPopupImageView, context: Context) {
		uiView.image = uiImage
		uiView.shadow.shadowColor = isEmptyPlayback ? UIColor.clear : UIColor.black.withAlphaComponent(0.3333)
	}
}
