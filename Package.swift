// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX"]),
    ],
    targets: [
        .target(name: "CombineX", dependencies: []),
        .testTarget(name: "CombineXTests", dependencies: ["CombineX"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
