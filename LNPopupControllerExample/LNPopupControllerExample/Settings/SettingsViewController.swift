//
//  SettingsViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 02/10/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

import SwiftUI

#if LNPOPUP

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

fileprivate struct LNText: View {
	let text: Text
	public init(_ content: String) {
		@AppStorage(__LNForceRTL) var forceRTL: Bool = false
		@AppStorage("___WTFBBQ") var forceRTLAtOpen: Bool = false
		
		if isLNPopupUIExample || forceRTL == false || forceRTL != forceRTLAtOpen {
			text = Text(LocalizedStringKey(content))
		} else {
			text = Text(content.applyingTransform(.latinToHebrew, reverse: false)!)
		}
	}
	
	var body: some View {
		text
	}
}

fileprivate struct LNHeaderFooterView: View {
	let content: String
	public init(_ content: String) {
		self.content = content
	}
	
	var body: some View {
		LNText(content).font(.footnote)
	}
}

fileprivate struct CellPaddedText: View {
	let content: String
	public init(_ content: String) {
		self.content = content
	}
	
	var body: some View {
		LNText(content)
		//			.padding([.top, .bottom], 4.167)
	}
}

fileprivate struct CellPaddedToggle: View {
	let title: String
	let isOn: Binding<Bool>
	
	init(_ title: String, isOn: Binding<Bool>) {
		self.title = title
		self.isOn = isOn
	}
	
	var body: some View {
		Toggle(isOn: isOn, label: {
			LNText(title)
			//				.padding([.top, .bottom], 4.167)
		})
	}
}

struct SettingsView : View {
	@AppStorage(PopupSettingsBarStyle) var barStyle: LNPopupBar.Style = .default
	@AppStorage(PopupSettingsInteractionStyle) var interactionStyle: UIViewController.__PopupInteractionStyle = .default
	@AppStorage(PopupSettingsCloseButtonStyle) var closeButtonStyle: LNPopupCloseButton.Style = .default
	@AppStorage(PopupSettingsProgressViewStyle) var progressViewStyle: LNPopupBar.ProgressViewStyle = .default
	@AppStorage(PopupSettingsMarqueeStyle) var marqueeStyle: Int = 0
	@AppStorage(PopupSettingsVisualEffectViewBlurEffect) var blurEffectStyle: UIBlurEffect.Style = .default
	
	@AppStorage(PopupSettingsExtendBar) var extendBar: Bool = true
	@AppStorage(PopupSettingsHidesBottomBarWhenPushed) var hideBottomBar: Bool = true
	@AppStorage(PopupSettingsDisableScrollEdgeAppearance) var disableScrollEdgeAppearance: Bool = false
	@AppStorage(PopupSettingsCustomBarEverywhereEnabled) var customPopupBar: Bool = false
	@AppStorage(PopupSettingsEnableCustomizations) var enableCustomizations: Bool = false
	@AppStorage(PopupSettingsContextMenuEnabled) var contextMenu: Bool = false
	@AppStorage(PopupSettingsTouchVisualizerEnabled) var touchVisualizer: Bool = false
	
	@AppStorage(__LNPopupBarHideContentView) var hidePopupBarContentView: Bool = false
	@AppStorage(__LNPopupBarHideShadow) var hidePopupBarShadow: Bool = false
	@AppStorage(__LNPopupBarEnableLayoutDebug) var layoutDebug: Bool = false
	@AppStorage(__LNForceRTL) var forceRTL: Bool = false
	@AppStorage("___WTFBBQ") var forceRTLAtOpen: Bool = false
	@AppStorage(__LNDebugScaling) var debugScaling: Double = 0
	
	@AppStorage(DemoAppDisableDemoSceneColors) var disableDemoSceneColors: Bool = false
	@AppStorage(DemoAppEnableFunkyInheritedFont) var enableFunkyInheritedFont: Bool = false
	@AppStorage(DemoAppEnableExternalScenes) var enableExternalScenes: Bool = false
	
	@Environment(\.sizeCategory) var sizeCategory
	
	let sizeCategoryToCellHeight: [ContentSizeCategory: CGFloat] = [.extraLarge: 48, .extraExtraLarge: 52, .extraExtraExtraLarge: 58, .accessibilityMedium: 103, .accessibilityLarge: 121, .accessibilityExtraLarge: 193, .accessibilityExtraExtraLarge: 282, .accessibilityExtraExtraExtraLarge: 313]
	
	var body: some View {
		Form {
			Section {
				Picker(selection: $barStyle) {
					CellPaddedText("Default").tag(LNPopupBar.Style.default)
					CellPaddedText("Compact").tag(LNPopupBar.Style.compact)
					CellPaddedText("Prominent").tag(LNPopupBar.Style.prominent)
					CellPaddedText("Floating").tag(LNPopupBar.Style.floating)
				}
			} header: {
				LNHeaderFooterView("Bar Style")
			}
			
			Section {
				Picker(selection: $interactionStyle) {
					CellPaddedText("Default").tag(UIViewController.__PopupInteractionStyle.default)
					CellPaddedText("Drag").tag(UIViewController.__PopupInteractionStyle.drag)
					CellPaddedText("Snap").tag(UIViewController.__PopupInteractionStyle.snap)
					CellPaddedText("Scroll").tag(UIViewController.__PopupInteractionStyle.scroll)
					CellPaddedText("None").tag(UIViewController.__PopupInteractionStyle.none)
				}
			} header: {
				LNHeaderFooterView("Interaction Style")
			}
			
			Section {
				Picker(selection: $closeButtonStyle) {
					CellPaddedText("Default").tag(LNPopupCloseButton.Style.default)
					CellPaddedText("Round").tag(LNPopupCloseButton.Style.round)
					CellPaddedText("Chevron").tag(LNPopupCloseButton.Style.chevron)
					CellPaddedText("Grabber").tag(LNPopupCloseButton.Style.grabber)
					CellPaddedText("None").tag(LNPopupCloseButton.Style.none)
				}
			} header: {
				LNHeaderFooterView("Close Button Style")
			}
			
			Section {
				Picker(selection: $progressViewStyle) {
					CellPaddedText("Default").tag(LNPopupBar.ProgressViewStyle.default)
					CellPaddedText("Top").tag(LNPopupBar.ProgressViewStyle.top)
					CellPaddedText("Bottom").tag(LNPopupBar.ProgressViewStyle.bottom)
					CellPaddedText("None").tag(LNPopupBar.ProgressViewStyle.none)
				}
			} header: {
				LNHeaderFooterView("Progress View Style")
			}
			
			Section {
				Picker(selection: $marqueeStyle) {
					CellPaddedText("Default").tag(0)
					CellPaddedText("Disabled").tag(1)
					CellPaddedText("Enabled").tag(2)
				}
			} header: {
				LNHeaderFooterView("Marquee")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					CellPaddedText("Default").tag(UIBlurEffect.Style.default)
				}
			} header: {
				LNHeaderFooterView("Background Blur Style")
			} footer: {
				LNHeaderFooterView("Uses the default material chosen by the system.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					CellPaddedText("Ultra Thin Material").tag(UIBlurEffect.Style.systemUltraThinMaterial)
					CellPaddedText("Thin Material").tag(UIBlurEffect.Style.systemThinMaterial)
					CellPaddedText("Material").tag(UIBlurEffect.Style.systemMaterial)
					CellPaddedText("Thick Material").tag(UIBlurEffect.Style.systemThickMaterial)
					CellPaddedText("Chrome Material").tag(UIBlurEffect.Style.systemChromeMaterial)
				}
			} footer: {
				LNHeaderFooterView("Material styles which automatically adapt to the user interface style. Available in iOS 13 and above.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					CellPaddedText("Regular").tag(UIBlurEffect.Style.regular)
					CellPaddedText("Prominent").tag(UIBlurEffect.Style.prominent)
				}
			} footer: {
				LNHeaderFooterView("Styles which automatically show one of the traditional blur styles, depending on the user interface style. Available in iOS 10 and above.")
			}
			
			Section {
				Picker(selection: $blurEffectStyle) {
					CellPaddedText("Extra Light").tag(UIBlurEffect.Style.extraLight)
					CellPaddedText("Light").tag(UIBlurEffect.Style.light)
					CellPaddedText("Dark").tag(UIBlurEffect.Style.dark)
				}
			} footer: {
				LNHeaderFooterView("Traditional blur styles. Available in iOS 8 and above.")
			}
			
			Section {
				CellPaddedToggle("Extend Bar Under Safe Area", isOn: $extendBar)
			} header: {
				LNHeaderFooterView("Settings")
			} footer: {
				if isLNPopupUIExample {
					LNHeaderFooterView("Calls the `popupBarShouldExtendPopupBarUnderSafeArea()` modifier with a value of `true` in standard demo scenes.")
				} else {
					LNHeaderFooterView("Sets the `shouldExtendPopupBarUnderSafeArea` property to `true` in standard demo scenes.")
				}
			}
			
			if isLNPopupUIExample == false {
				Section {
					CellPaddedToggle("Hides Bottom Bar When Pushed", isOn: $hideBottomBar)
				} footer: {
					LNHeaderFooterView("Sets the `hidesBottomBarWhenPushed` property of pushed controllers in standard demo scenes.")
				}
				
				Section {
					CellPaddedToggle("Disable Scroll Edge Appearance", isOn: $disableScrollEdgeAppearance)
				} footer: {
					LNHeaderFooterView("Disables the scroll edge appearance for system bars in standard demo scenes.")
				}
			}
			
			Section {
				CellPaddedToggle("Context Menu Interactions", isOn: $contextMenu)
			} footer: {
				LNHeaderFooterView("Enables popup bar context menu interaction in standard demo scenes.")
			}
			
			Section {
				CellPaddedToggle("Customizations", isOn: $enableCustomizations)
			} footer: {
				LNHeaderFooterView("Enables popup bar customizations in standard demo scenes.")
			}
			
			Section {
				CellPaddedToggle("Custom Popup Bar", isOn: $customPopupBar)
			} footer: {
				LNHeaderFooterView("Enables a custom popup bar in standard demo scenes.")
			}
			
			Section {
				CellPaddedToggle("Disable Demo Scene Colors", isOn: $disableDemoSceneColors)
			} footer: {
				LNHeaderFooterView("Disables random background colors in the demo scenes.")
			}
			
			if isLNPopupUIExample {
				Section {
					CellPaddedToggle("Enable Funky Inherited Font", isOn: $enableFunkyInheritedFont)
				} footer: {
					LNHeaderFooterView("Enables an environment font that is inherited by the popup bar.")
				}
			}
			
			Section {
				CellPaddedToggle("Layout Debug", isOn: $layoutDebug)
				CellPaddedToggle("Hide Content View", isOn: $hidePopupBarContentView)
				CellPaddedToggle("Hide Floating Shadow", isOn: $hidePopupBarShadow)
				CellPaddedToggle("Use Right-to-Left Pseudolanguage With Right-to-Left Strings", isOn: $forceRTL).onChange(of: forceRTL) { _ in
					guard forceRTL != forceRTLAtOpen else {
						return
					}
					
					SettingsViewController.toggleRTL() { accepted in
						if accepted {
							return
						}
						
						forceRTL = forceRTLAtOpen
					}
				}
				
				NavigationLink {
					Form {
						Section {
							Picker(selection: $debugScaling) {
								CellPaddedText("Default").tag(0.0)
							}
						} footer: {
							LNHeaderFooterView("Uses the default scaling according to screen size and “Display Zoom” setting.")
						}
						
						Section {
							Picker(selection: $debugScaling) {
								CellPaddedText("320").tag(320.0)
							}
						} footer: {
							LNHeaderFooterView("Classic phones as well as “Larger Text” non-Max & non-Plus phones.")
						}
						
						Section {
							Picker(selection: $debugScaling) {
								CellPaddedText("375").tag(375.0)
								CellPaddedText("390").tag(390.0)
								CellPaddedText("393").tag(393.0)
							}
						} footer: {
							LNHeaderFooterView("Non-Max & non-Plus phones as well as “Larger Text” Max & Plus phones.")
						}
						
						Section {
							Picker(selection: $debugScaling) {
								CellPaddedText("414").tag(414.0)
								CellPaddedText("428").tag(428.0)
								CellPaddedText("430").tag(430.0)
							}
						} footer: {
							LNHeaderFooterView("Max & Plus phones.")
						}
					}.pickerStyle(.inline).navigationTitle("Scaling")
				} label: {
					HStack {
						LNText("Scaling")
						Spacer()
						LNText(debugScaling == 0 ? "Default" : "\(String(format: "%.0f", debugScaling))").foregroundColor(.secondary)
					}
				}
			} header: {
				LNHeaderFooterView("Popup Bar Debug")
			}
			
			Section {
				CellPaddedToggle("Touch Visualizer", isOn: $touchVisualizer)
			} header: {
				LNHeaderFooterView("Demonstration")
			} footer: {
				LNHeaderFooterView("Enables visualization of touches within the app, for demo purposes.")
			}
			
			if isLNPopupUIExample {
				Section {
					CellPaddedToggle("Enable", isOn: $enableExternalScenes)
				} header: {
					LNHeaderFooterView("External Libraries")
				} footer: {
					LNHeaderFooterView("Enables scenes for testing with external libraries.")
				}
			}
		}.pickerStyle(.inline).onAppear {
			forceRTLAtOpen = forceRTL
		}
	}
}

class SettingsViewController: UIHostingController<SettingsView> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: SettingsView())
	}
	
	class func alertRestartNeeded(completion: @escaping (Bool) -> ()) {
		let alertController = UIAlertController(title: NSLocalizedString("Restart Required", comment: ""), message: NSLocalizedString("Continuing will require exiting and restarting the app.", comment: ""), preferredStyle: .alert)
		if #available(iOS 16.0, *) {
			alertController.severity = .critical
		}
		alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
			completion(false)
		}))
		alertController.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: ""), style: .destructive, handler: { _ in
			completion(true)
			UserDefaults.standard.synchronize()
			exit(0)
		}))
		
		let window = UIWindow.value(forKey: "keyWindow") as! UIWindow
		var controller = window.rootViewController!
		while controller.presentedViewController != nil {
			controller = controller.presentedViewController!
		}
		controller.present(alertController, animated: true)
	}
	
	class func setRTL() {
		UserDefaults.standard.set(true, forKey: "AppleTextDirection")
		UserDefaults.standard.set(true, forKey: "NSForceRightToLeftWritingDirection")
		UserDefaults.standard.set(true, forKey: "NSForceRightToLeftLocalizedStrings")
	}
	
	class func resetRTL() {
		UserDefaults.standard.removeObject(forKey: "AppleTextDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftWritingDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftLocalizedStrings")
	}
	
	class func toggleRTL(completion: @escaping (Bool) -> ()) {
		alertRestartNeeded { accepted in
			guard accepted else {
				completion(false)
				return
			}
			
			completion(true)
			
			let wantsRTL = UserDefaults.standard.bool(forKey: __LNForceRTL)
			if wantsRTL {
				setRTL()
			} else {
				resetRTL()
			}
		}
	}
	
	class func reset() {
		let actualReset: () -> () = {
			UserDefaults.standard.removeObject(forKey: PopupSettingsEnableCustomizations)
			UserDefaults.standard.set(true, forKey: PopupSettingsExtendBar)
			UserDefaults.standard.set(true, forKey: PopupSettingsHidesBottomBarWhenPushed)
			UserDefaults.standard.removeObject(forKey: PopupSettingsDisableScrollEdgeAppearance)
			UserDefaults.standard.removeObject(forKey: PopupSettingsTouchVisualizerEnabled)
			UserDefaults.standard.removeObject(forKey: PopupSettingsCustomBarEverywhereEnabled)
			UserDefaults.standard.removeObject(forKey: PopupSettingsContextMenuEnabled)
			UserDefaults.standard.removeObject(forKey: PopupSettingsVisualEffectViewBlurEffect)
			UserDefaults.standard.removeObject(forKey: __LNPopupBarHideContentView)
			UserDefaults.standard.removeObject(forKey: __LNPopupBarHideShadow)
			UserDefaults.standard.removeObject(forKey: __LNPopupBarEnableLayoutDebug)
			UserDefaults.standard.removeObject(forKey: DemoAppDisableDemoSceneColors)
			UserDefaults.standard.removeObject(forKey: DemoAppEnableFunkyInheritedFont)
			UserDefaults.standard.removeObject(forKey: DemoAppEnableExternalScenes)
			
			UserDefaults.standard.removeObject(forKey: __LNForceRTL)
			resetRTL()
			UserDefaults.standard.removeObject(forKey: __LNDebugScaling)
			
			for key in [PopupSettingsBarStyle, PopupSettingsInteractionStyle, PopupSettingsCloseButtonStyle, PopupSettingsProgressViewStyle, PopupSettingsMarqueeStyle] {
				UserDefaults.standard.removeObject(forKey: key)
			}
			
			UserDefaults.standard.setValue(0xffff, forKey: PopupSettingsVisualEffectViewBlurEffect)
		}
		
		if UserDefaults.standard.bool(forKey: __LNForceRTL) {
			alertRestartNeeded { accepted in
				guard accepted else {
					return
				}
				
				actualReset()
			}
		} else {
			actualReset()
		}
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
				.navigationBarTitleDisplayMode(.inline)
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
		}.frame(minWidth: 320, minHeight: 480)
	}
}

#else

struct NoSettingsView : View {
	var body: some View {
		Text("No Settings")
			.fontWeight(.semibold)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(UIColor.systemGroupedBackground))
	}
}

class SettingsViewController: UIHostingController<NoSettingsView> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: NoSettingsView())
	}
	
	@IBAction func reset() {
		
	}
}

#endif
