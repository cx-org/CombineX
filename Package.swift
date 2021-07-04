// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
    ],
    dependencies: [
        // TODO: use swift-atomics which requires swift 5.1
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CombineX"]),
    ]
)
