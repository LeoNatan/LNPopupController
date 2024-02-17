// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "LNPopupController",
	platforms: [
		.iOS(.v13),
		.macCatalyst(.v13)
	],
	products: [
		.library(
			name: "LNPopupController",
			type: .dynamic,
			targets: ["LNPopupController", "LNPopupController-ObjC"]),
		.library(
			name: "LNPopupController-Static",
			type: .static,
			targets: ["LNPopupController", "LNPopupController-ObjC"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LNPopupController-ObjC",
			dependencies: [],
			path: "LNPopupController",
			exclude: ["Info.plist"],
			publicHeadersPath: "include",
			cSettings: [
				.headerSearchPath("."),
				.headerSearchPath("Private")
			]),
		.target(
			name: "LNPopupController",
			dependencies: ["LNPopupController-ObjC"],
			path: "LNPCSwiftRefinements")
	],
	cxxLanguageStandard: CXXLanguageStandard(rawValue: "gnu++17")
)
