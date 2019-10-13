// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .testTarget(name: "CombineXTests", dependencies: ["CXUtility", "CombineX", "Quick", "Nimble"], swiftSettings: [.define("USE_COMBINE")])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
