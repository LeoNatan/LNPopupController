// swift-tools-version:5.2

import PackageDescription

let package = Package(
	name: "LNPopupController",
	platforms: [
		.iOS(.v12),
		.macOS(.v10_15)
	],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "LNPopupController",
			type: .dynamic,
			targets: ["LNPopupController"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
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
