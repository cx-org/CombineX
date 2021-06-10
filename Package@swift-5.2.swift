// swift-tools-version:5.2

import PackageDescription

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
        .library(name: "CXUtility", targets: ["CXUtility"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
//        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
//        .package(url: "https://github.com/ddddxxx/Semver.git", .upToNextMinor(from: "0.2.1")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility", dependencies: ["CXLibc"]),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
//        .target(name: "CXTestUtility", dependencies: ["CXUtility", "CXTest", "Semver", "CXShim", "Quick", "Nimble"]),
//        .testTarget(name: "CombineXTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
//        .testTarget(name: "CXFoundationTests", dependencies: ["CXTestUtility", "CXShim", "Quick", "Nimble"]),
//        .testTarget(name: "CXInconsistentTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
