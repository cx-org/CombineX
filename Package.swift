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
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "CombineX", dependencies: []),
        .testTarget(name: "CombineXTests", dependencies: ["CombineX", "Quick", "Nimble"], path: "Specs/SpecsTests"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
