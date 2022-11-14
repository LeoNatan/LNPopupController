// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "LNPopupController",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15)
	],
	products: [
		.library(
			name: "LNPopupController",
			targets: ["LNPopupController"]),
		.library(
			name: "LNPopupController-Dynamic",
			type: .dynamic,
			targets: ["LNPopupController"]),
		.library(
			name: "LNPopupController-Static",
			type: .static,
			targets: ["LNPopupController"]),
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
				.headerSearchPath("Private"),
			]),
		.target(
			name: "LNPopupController",
			dependencies: ["LNPopupController-ObjC"],
			path: "LNPCSwiftRefinements")
	],
	cxxLanguageStandard: CXXLanguageStandard(rawValue: "gnu++17")
)
