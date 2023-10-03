//
//  SettingsViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 02/10/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

import SwiftUI
import LNPopupController

extension UIBlurEffect.Style {
	static let `default` = UIBlurEffect.Style(rawValue: 0xffff)!
}

fileprivate extension Picker where Label == EmptyView {
	init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
		self.init(selection: selection, content: content) {
			EmptyView()
		}
	}
}

fileprivate var isLNPopupUIExample: Bool = {
	return ProcessInfo.processInfo.processName == "LNPopupUIExample"
}()

struct SettingsView : View {
	@AppStorage(PopupSettingsBarStyle) var barStyle: LNPopupBarStyle = .default
	@AppStorage(PopupSettingsInteractionStyle) var interactionStyle: __LNPopupInteractionStyle = .default
	@AppStorage(PopupSettingsCloseButtonStyle) var closeButtonStyle: LNPopupCloseButtonStyle = .default
	@AppStorage(PopupSettingsProgressViewStyle) var progressViewStyle: LNPopupBarProgressViewStyle = .default
	@AppStorage(PopupSettingsMarqueeStyle) var marqueeStyle: Int = 0
	@AppStorage(PopupSettingsVisualEffectViewBlurEffect) var blurEffectStyle: UIBlurEffect.Style = .default
	
	@AppStorage(PopupSettingsExtendBar) var extendBar: Bool = true
	@AppStorage(PopupSettingsHidesBottomBarWhenPushed) var hideBottomBar: Bool = true
	@AppStorage(PopupSettingsCustomBarEverywhereEnabled) var customPopupBar: Bool = false
	@AppStorage(PopupSettingsEnableCustomizations) var enableCustomizations: Bool = false
	@AppStorage(PopupSettingsContextMenuEnabled) var contextMenu: Bool = false
	@AppStorage(PopupSettingsTouchVisualizerEnabled) var touchVisualizer: Bool = false
	
	var body: some View {
		Form {
			Picker(selection: $barStyle) {
				Text("Default").tag(LNPopupBarStyle.default)
				Text("Compact").tag(LNPopupBarStyle.compact)
				Text("Prominent").tag(LNPopupBarStyle.prominent)
				Text("Floating").tag(LNPopupBarStyle.floating)
			} label: {
				Text("Bar Style")
			}
			
			Picker(selection: $interactionStyle) {
				Text("Default").tag(__LNPopupInteractionStyle.default)
				Text("Drag").tag(__LNPopupInteractionStyle.drag)
				Text("Snap").tag(__LNPopupInteractionStyle.snap)
				Text("Scroll").tag(__LNPopupInteractionStyle.scroll)
				Text("None").tag(__LNPopupInteractionStyle.none)
			} label: {
				Text("Interaction Style")
			}
			
			Picker(selection: $closeButtonStyle) {
				Text("Default").tag(LNPopupCloseButtonStyle.default)
				Text("Round").tag(LNPopupCloseButtonStyle.round)
				Text("Chevron").tag(LNPopupCloseButtonStyle.chevron)
				Text("Flat").tag(LNPopupCloseButtonStyle.flat)
				Text("None").tag(LNPopupCloseButtonStyle.none)
			} label: {
				Text("Close Button Style")
			}
			
			Picker(selection: $progressViewStyle) {
				Text("Default").tag(LNPopupBarProgressViewStyle.default)
				Text("Top").tag(LNPopupBarProgressViewStyle.top)
				Text("Bottom").tag(LNPopupBarProgressViewStyle.bottom)
				Text("None").tag(LNPopupBarProgressViewStyle.none)
			} label: {
				Text("Progress View Style")
			}
			
			Picker(selection: $marqueeStyle) {
				Text("Default").tag(0)
				Text("Disabled").tag(1)
				Text("Enabled").tag(2)
			} label: {
				Text("Marquee")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					Text("Default").tag(UIBlurEffect.Style.default)
				}
			} header: {
				Text("Background Blur Style")
			} footer: {
				Text("Uses the default material chosen by the system.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					Text("Ultra Thin Material").tag(UIBlurEffect.Style.systemUltraThinMaterial)
					Text("Thin Material").tag(UIBlurEffect.Style.systemThinMaterial)
					Text("Material").tag(UIBlurEffect.Style.systemMaterial)
					Text("Thick Material").tag(UIBlurEffect.Style.systemThickMaterial)
					Text("Chrome Material").tag(UIBlurEffect.Style.systemChromeMaterial)
				}
			} footer: {
				Text("Material styles which automatically adapt to the user interface style. Available in iOS 13 and above.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					Text("Regular").tag(UIBlurEffect.Style.regular)
					Text("Prominent").tag(UIBlurEffect.Style.prominent)
				}
			} footer: {
				Text("Styles which automatically show one of the traditional blur styles, depending on the user interface style. Available in iOS 10 and above.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					Text("Extra Light").tag(UIBlurEffect.Style.extraLight)
					Text("Light").tag(UIBlurEffect.Style.light)
					Text("Dark").tag(UIBlurEffect.Style.dark)
				}
			} footer: {
				Text("Traditional blur styles. Available in iOS 8 and above.")
			}
			
			Section {
				Toggle("Extend Bar Under Safe Area", isOn: $extendBar)
			} header: {
				Text("Settings")
			} footer: {
				if isLNPopupUIExample {
					Text("Calls the `popupBarShouldExtendPopupBarUnderSafeArea()` modifier with a value of `true` in standard demo scenes.")
				} else {
					Text("Sets the `shouldExtendPopupBarUnderSafeArea` property to `true` in standard demo scenes.")
				}
			}
			
			Section {
				Toggle("Hides Bottom Bar When Pushed", isOn: !isLNPopupUIExample ? $hideBottomBar : Binding.constant(false))
			} footer: {
				if isLNPopupUIExample {
					Text("Not supported in SwiftUI yet.")
				} else {
					Text("Sets the `hidesBottomBarWhenPushed` property of pushed controllers in standard demo scenes.")
				}
			}.disabled(isLNPopupUIExample)
			
			Section {
				Toggle("Context Menu Interactions", isOn: $contextMenu)
			} footer: {
				Text("Enables popup bar context menu interaction in standard demo scenes.")
			}
			
			Section {
				Toggle("Customizations", isOn: $enableCustomizations)
			} footer: {
				Text("Enables popup bar customizations in standard demo scenes.")
			}
			
			Section {
				Toggle("Custom Popup Bar", isOn: $customPopupBar)
			} footer: {
				Text("Enables a custom popup bar in standard demo scenes.")
			}
			
			Section {
				Toggle("Touch Visualizer", isOn: $touchVisualizer)
			} footer: {
				Text("Enables visualization of touches within the app, for demo purposes.")
			}
		}.accentColor(.pink).pickerStyle(.inline)
	}
}

class SettingsViewController: UIHostingController<SettingsView> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: SettingsView())
	}
	
	class func reset() {
		UserDefaults.standard.removeObject(forKey: PopupSettingsEnableCustomizations)
		UserDefaults.standard.set(true, forKey: PopupSettingsExtendBar)
		UserDefaults.standard.set(true, forKey: PopupSettingsHidesBottomBarWhenPushed)
		UserDefaults.standard.removeObject(forKey: PopupSettingsTouchVisualizerEnabled)
		UserDefaults.standard.removeObject(forKey: PopupSettingsCustomBarEverywhereEnabled)
		UserDefaults.standard.removeObject(forKey: PopupSettingsContextMenuEnabled)
		UserDefaults.standard.removeObject(forKey: PopupSettingsVisualEffectViewBlurEffect)
		
		for key in [PopupSettingsBarStyle, PopupSettingsInteractionStyle, PopupSettingsCloseButtonStyle, PopupSettingsProgressViewStyle, PopupSettingsMarqueeStyle] {
			UserDefaults.standard.removeObject(forKey: key)
		}
		
		UserDefaults.standard.setValue(0xffff, forKey: PopupSettingsVisualEffectViewBlurEffect)
	}
	
	@IBAction func reset() {
		SettingsViewController.reset()
	}
}

@available(iOS 16.0, *)
struct SettingsNavView: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		NavigationStack {
			SettingsView()
				.navigationTitle("Settings")
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button("Reset") {
							SettingsViewController.reset()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							self.presentationMode.wrappedValue.dismiss()
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)
		}.frame(minWidth: 320, minHeight: 480)
	}
}
