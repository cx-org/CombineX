// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineQ",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "CombineQ", targets: ["CombineQ"]),
    ],
    targets: [
        .target(name: "CombineQ", dependencies: []),
        .testTarget(name: "CombineQTests", dependencies: ["CombineQ"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
