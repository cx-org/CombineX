// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CombineX"]),
    ]
)
