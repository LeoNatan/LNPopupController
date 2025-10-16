// swift-tools-version:6.0
// LNPopupController:4.2.6

import PackageDescription
import Foundation.NSFileManager

let packageBase = URL(filePath: Context.packageDirectory, directoryHint: .isDirectory)

extension URL {
	var targetRelativePath: String {
		var rv = path
		rv.replace(packageBase.path, with: "")
		rv = rv.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
		return String(rv.dropFirst("LNPopupController/".count))
	}
}

//This recursively iterates all directories under LNPopupController/Private and adds them as header search paths.
let start = URL(filePath: "LNPopupController/LNPopupController/Private", relativeTo: packageBase)
var settings: [PackageDescription.CSetting] = [.headerSearchPath(start.targetRelativePath)]
if let enumerator = FileManager.default.enumerator(at: start, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
	for case let fileURL as URL in enumerator {
		do {
			let fileAttributes = try fileURL.resourceValues(forKeys:[.isDirectoryKey])
			if fileAttributes.isDirectory! {
				settings.append(.headerSearchPath(fileURL.targetRelativePath))
			}
		} catch { fatalError(error.localizedDescription) }
	}
}

//if true {
//	fatalError(settings.map { String(describing: $0) }.joined(separator: " "))
//}

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
			targets: ["LNPopupController", "LNPopupController-ObjC", "LNPopupController-SwiftPrivate"]),
		.library(
			name: "LNPopupController-Static",
			type: .static,
			targets: ["LNPopupController", "LNPopupController-ObjC", "LNPopupController-SwiftPrivate"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LNPopupController-ObjC",
			dependencies: [],
			path: "LNPopupController",
			exclude: ["Info.plist", "LNPopupController.xcodeproj", "LNPopupController/Private/Swift"],
			publicHeadersPath: "include",
			cSettings: settings),
		.target(
			name: "LNPopupController-SwiftPrivate",
			dependencies: ["LNPopupController-ObjC"],
			path: "LNPopupController/LNPopupController/Private/Swift"),
		.target(
			name: "LNPopupController",
			dependencies: ["LNPopupController-ObjC"],
			path: "LNPopupController+Swift")
	],
	cxxLanguageStandard: .gnucxx20
)
