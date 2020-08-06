// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "LNPopupController",
	platforms: [
		.iOS(.v12),
		.macOS(.v10_15)
	],
	products: [
		.library(
			name: "LNPopupController",
			type: .dynamic,
			targets: ["LNPopupController"]),
		.library(
			name: "LNPopupController-Static",
			targets: ["LNPopupController"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LNPopupController",
			dependencies: [],
			path: "LNPopupController",
			exclude: [
				"LNPopupControllerExample",
				"Supplements"
			],
			publicHeadersPath: "include",
			cSettings: [
				.headerSearchPath("."),
				.headerSearchPath("Private"),
			]),
	]
)
