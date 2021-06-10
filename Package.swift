// swift-tools-version:5.0

import PackageDescription

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"])
    ],
    dependencies: [
//        .package(url: "https://github.com/ddddxxx/Semver.git", .upToNextMinor(from: "0.2.1")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility", dependencies: ["CXLibc"]),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
