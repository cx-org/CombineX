// swift-tools-version:5.0

import Foundation
import PackageDescription

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
let useCombineX = ProcessInfo.processInfo.environment["SWIFT_PACKAGE_USE_COMBINEX"] != nil
#else
let useCombineX = true
#endif

var combineTargetDependencies: [PackageDescription.Target.Dependency] = []
var combineSwiftSetting: [SwiftSetting]? = nil

if useCombineX {
    combineTargetDependencies += [
        .target(name: "CombineX"),
        .target(name: "CXFoundation"),
    ]
    combineSwiftSetting = [
        .define("USE_COMBINEX")
    ]
} else {
    combineTargetDependencies += [
        .target(name: "CXCompatible"),
    ]
}

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CombineX"]),
        .target(name: "CXCompatible", dependencies: []),
        .target(name: "CXShim", dependencies: combineTargetDependencies, swiftSettings: combineSwiftSetting),
        .testTarget(name: "CombineXTests", dependencies: ["CXUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXFoundationTests", dependencies: ["CXShim", "Quick", "Nimble"], swiftSettings: combineSwiftSetting),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
