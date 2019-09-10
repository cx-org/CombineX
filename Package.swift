// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        // stay and wait for https://github.com/Quick/Nimble/pull/681
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2"))
    ],
    targets: [
        .target(name: "CombineX"),
        .testTarget(name: "CombineXTests", dependencies: [
            "CombineX", "Quick", "Nimble"
        ])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
